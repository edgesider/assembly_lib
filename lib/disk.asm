%ifndef LIB_DISK
%define LIB_DISK

%include "config.asm"
%include "io.asm"

struc DK_DiskInfo
    .NumberofCylinder resw 1
    .HeadPerCylinder resb 1
    .SectorPerHead resb 1
endstruc

struc DK_Fat12FileEntry
    .Name resb 11
    .Attr resb 1
    .Res resb 10
    .WrtTime resb 2
    .WrtData resb 2
    .FstClus resb 2
    .Size resb 4
endstruc

DK_ReadSector:
    ; read sector to ds:[bp+14]
    %ifdef DISK_LBA
    ; via LBA
    ;---parameters----
    ; | disk index      |+18 word
    ; | buffer pointer  |+14 dword segment:offset
    ; | start sector    |+6 qword
    ; | number of sector|+4 word
    ;---parameters----
    ; | call-saved      |+2
    ; | saved-bp        |+0 <--bp <--sp
    ;----stack-top(bp)----
    push bp
    mov bp, sp

    ; int13h, ah=42h
    ; paramater struct:
    ;                   |-0 <--bp
    ; | start sector    |-8  qword
    ; | buffer pointer  |-12 dword segment:offset
    ; | number of sector|-14 word
    ; | unused          |-15 byte
    ; | DAP (10h)       |-16 byte <--sp

    sub sp, 16
    mov byte [bp-16], 10h
    mov byte [bp-15], 0

    mov word ax, [bp+4]
    mov word [bp-14], ax

    mov ax, [bp+14]
    mov [bp-12], ax
    mov ax, [bp+16]
    mov [bp-10], ax

    mov ax, [bp+6]
    mov [bp-8], ax
    mov ax, [bp+8]
    mov [bp-6], ax
    mov ax, [bp+10]
    mov [bp-4], ax
    mov ax, [bp+12]
    mov [bp-2], ax
    mov si, sp

    mov byte dl, [bp+18]
    mov ah, 42h
    int 13h
    jc IO_Error

    add sp, 16
    pop bp
    ret
    %else
    ; via CHS
    ;---parameters----
    ; | disk index      |+18 word (only lower byte will be used)
    ; | buffer pointer  |+14 dword (only lower word will be used)
    ; | start sector    |+6 qword (only lower dword will be used)
    ; | number of sector|+4 word (only lower byte will be used)
    ;---parameters----
    ; | call-saved      |+2
    ; | saved-bp        |+0 <--bp <--sp
    ;----stack-top(bp)----
    push bp
    mov bp, sp

    ;               | <--bp
    ; |             |-DK_DiskInfo_size  <--sp
    sub sp, DK_DiskInfo_size

    push word [bp+18]
    mov ax, bp
    sub ax, DK_DiskInfo_size
    push ax
    call DK_ReadDiskInfo
    add sp, 4

    ; x, y, z = CHS tuple
    ; n = sector number
    ; SPH = sector per head, HPC = head per cylinder
    ; n = z + SPH * (y + x * HPC)
    ; z = n % SPH, let H = n / SPH
    ; y = H % HPC
    ; x = H / HPC
    sub sp, 1   ; store sector
    ;               | <--bp
    ; |             |-DK_DiskInfo_size
    ; | z: sector   |-1-DK_DiskInfo_size <--sp
    mov ax, [bp+6]
    mov dx, [bp+8]  ; dx:ax = start sector
    mov bh, 0
    mov bl, [bp-DK_DiskInfo_size+DK_DiskInfo.SectorPerHead]
    div bx   ; div: dx:ax / src == ax --- dx
    ; now z is in dx, H is in ax
    and dl, 00111111b
    mov [bp-1-DK_DiskInfo_size], dl
    mov dx, 0
    mov bh, 0
    mov bl, [bp-DK_DiskInfo_size+DK_DiskInfo.HeadPerCylinder]
    div bx
    ; now y is in dx, x is in ax

    push es
    mov cx, ds
    mov es, cx

    mov cl, [bp-1-DK_DiskInfo_size] ; cylinder-higher-2bit : sector
    inc cl
    mov ch, al  ; cylinder lower-8-bit
    shr ax, 2
    and al, 11000000b ; higher-2-bit
    or cl, al   ; cylinder and sector in cx
    mov dh, dl  ; head in dl
    add sp, 1
    mov bx, [bp+14] ; buffer
    mov dl, [bp+18] ; disk index
    mov al, [bp+4]
    mov ah, 02h  ; read function
    int 13h

    pop es
    jc IO_Error

    add sp, DK_DiskInfo_size
    pop bp
    ret
    %endif

DK_ReadDiskInfo:
    ;--parameters---
    ; | driver index| word
    ; | buffer      | word, pointer to an Info
    ;--parameters---
    ; | call-saved  | word
    ; | bp          |
    ; | stack-top   |
    push bp
    mov bp, sp

    mov ah, 08h
    mov dl, [bp+6]
    int 13h
    jc IO_Error

    mov bx, [bp+4]  ; buffer pointer

    inc dh
    mov byte [bx+DK_DiskInfo.HeadPerCylinder], dh

    mov ax, cx
    and al, 00111111b
    mov byte [bx+DK_DiskInfo.SectorPerHead], al

    mov ax, cx
    mov al, ah
    mov ch, 0
    mov ah, 0
    shl cx, 2
    or ah, ch
    inc ax
    mov word [bx+DK_DiskInfo.NumberofCylinder], ax

    pop bp
    ret

DK_Fat12List:

DK_Fat12Find:
    ; find file named [bp+4] in disk whose index is [bp+8]
    ; :return: void
    ;----parameters----
    ;| file description |+8 word; pointer to a DK_Fat12FileEntry
    ;| disk index       |+6 word
    ;| filename         |+4 word; pointer to filename, length=11
    ;----parameters----
    ;| call-saved       |+2 word
    ;| saved-bp         |+0 <--bp <--sp
    ;---stack top(bp)---
    ;| entry remain     |-2 word
    ;| next sector      |-4 word
    ;| current entry    |-6 word
    ;| tmp buffer       |-518 byte*512

    ; We need to know:
    ; start of root (via count of fats and sector per each fat)
    ; and count of root file entries
Fat12_TmpBuf equ 0200h

Fat12_FatCnt equ 2
Fat12_SecPerFat equ 9
Fat12_RootEntCnt equ 224
Fat12_EntPerSec equ 512/32 ; ==16
Fat12_BytePerEnt equ 32
    push bp
    mov bp, sp
    sub sp, 518

    ;for (int i = 224; i > 0; i--) {
        ;if (current_ent >= 16) {
            ;ReadNewSector(sector_to_read)
            ;sector_to_read++
            ;current_ent = 0
        ;}
        ;if (Compare(current_ent, filename) == 0) {
            ;return true;
        ;}
        ;current_ent++
    ;}
    ;return false

    mov word [bp-2], Fat12_RootEntCnt
    mov word [bp-4], 1+Fat12_FatCnt*Fat12_SecPerFat
    mov word [bp-6], 16

_DK_Fat12Find_Loop:
    cmp word [bp-6], 16
    jl _DK_Fat12Find_Endif0
    push word [bp+6]
    push ss
    lea bx, [bp-518]
    push bx
    push dword 0
    push word 0
    push word [bp-4] ; sector to read
    push 1
    call DK_ReadSector
    add sp, 16
    inc word [bp-4]
    mov word [bp-6], 0
_DK_Fat12Find_Endif0:
    ; here compare an entry
    mov ax, Fat12_BytePerEnt
    imul ax, [bp-6]
    lea bx, [bp-518]
    add ax, bx
    push word 0
    push ax
    push ds
    push word [bp+4]
    push word 11
    call IO_StrCmp
    add sp, 10
    cmp ax, 0
    jz _DK_Fat12Find_Found
    inc word [bp-6]
    dec word [bp-2]

    cmp word [bp-2], 0
    jz _DK_Fat12Find_NotFound
    jmp _DK_Fat12Find_Loop

_DK_Fat12Find_Found:
    push si
    lea ax, [bp-518]
    mov bx, Fat12_BytePerEnt
    imul bx, [bp-6]
    add bx, ax  ; bx now point to current file entry

    mov cx, Fat12_BytePerEnt
    mov si, [bp+8]
_DK_Fat12Find_Loop1:
    mov ax, [bx]
    mov [si], ax
    inc bx
    inc si
    loop _DK_Fat12Find_Loop1
    pop si
    mov ax, [bp+8]
    jmp _DK_Fat12Find_Over
_DK_Fat12Find_NotFound:
    mov ax, 0
_DK_Fat12Find_Over:

    add sp, 518
    pop bp
    ret

DK_Fat12Read:

%endif
