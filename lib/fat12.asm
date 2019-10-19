%ifndef LIB_FAT12
%define LIB_FAT12

%include "disk.asm"

struc Fat12_FileEntry
    .Name resb 11
    .Attr resb 1
    .Res resb 10
    .WrtTime resb 2
    .WrtData resb 2
    .FstClus resb 2
    .Size resb 4
endstruc

Fat12_TmpBuf equ 0200h

Fat12_FatCnt equ 2
Fat12_SecPerFat equ 9
Fat12_RootEntCnt equ 224
Fat12_EntPerSec equ 512/32 ; ==16
Fat12_BytePerEnt equ 32

Fat12_List:

Fat12_Find:
    ; find file named [bp+4] in disk whose index is [bp+8]
    ; :return: void
    ;----parameters----
    ;| file description |+8 word; pointer to a Fat12FileEntry
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

_Fat12Find_Loop:
    cmp word [bp-6], 16
    jl _Fat12Find_Endif0
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
_Fat12Find_Endif0:
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
    jz _Fat12Find_Found
    inc word [bp-6]
    dec word [bp-2]

    cmp word [bp-2], 0
    jz _Fat12Find_NotFound
    jmp _Fat12Find_Loop

_Fat12Find_Found:
    push si
    lea ax, [bp-518]
    mov bx, Fat12_BytePerEnt
    imul bx, [bp-6]
    add bx, ax  ; bx now point to current file entry

    mov cx, Fat12_BytePerEnt
    mov si, [bp+8]
_Fat12Find_Loop1:
    mov ax, [bx]
    mov [si], ax
    inc bx
    inc si
    loop _Fat12Find_Loop1
    pop si
    mov ax, [bp+8]
    jmp _Fat12Find_Over
_Fat12Find_NotFound:
    mov ax, 0
_Fat12Find_Over:

    add sp, 518
    pop bp
    ret

Fat12Read:

%endif
