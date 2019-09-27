%ifndef LIB_DISK
%define LIB_DISK

struc DK_DiskInfo
    .NumberofCylinder resw 2
    .HeadPerCylinder resb 1
    .SectorPerHead resb 1
endstruc

DK_ReadSectorLBA:
    ; read sector via LBA
    ;---parameters----
    ; | disk index      |+18 byte
    ; | buffer pointer  |+14 dword
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
    ; | buffer pointer  |-12 dword
    ; | number of sector|-14 word
    ; | unused          |-15 byte
    ; | DAP (10h)       |-16 byte <--sp

    sub sp, 16
    mov byte [bp-16], 10h
    mov byte [bp-15], 0

    mov word ax, [bp+4]
    mov word [bp-14], ax

    mov eax, [bp+14]
    mov [bp-12], eax
    mov eax, [bp+16]
    mov [bp-10], eax

    mov eax, [bp+6]
    mov [bp-8], eax
    mov eax, [bp+8]
    mov [bp-6], eax
    mov eax, [bp+10]
    mov [bp-4], eax
    mov eax, [bp+12]
    mov [bp-2], eax
    mov si, sp

    mov byte dl, [bp+18]
    mov ah, 42h
    int 13h
    jc IO_Error

    add sp, 16
    pop bp
    ret

DK_ReadDiskInfo:
    ;--parameter end---
    ; | drive index | byte
    ; | buffer    | word, pointer to an Info
    ;--parameter start---
    ; | call-saved| word
    ; | bp        |
    ; | stack-top |
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

%endif
