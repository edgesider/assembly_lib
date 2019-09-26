%ifndef LIB_DISK
%define LIB_DISK

struc DK_DiskInfo
    .NumberofCylinder resw 2
    .HeadPerCylinder resb 1
    .SectorPerHead resb 1
endstruc

DK_ReadDiskInfo:
    ; | stack-top |
    ; | bp        |
    ; | call-saved| word
    ; -parameter start---
    ; | buffer    | word, pointer to an Info
    ; | drive index | byte
    ; -parameter end---
    ; | stack-bot |
    push bp
    mov bp, sp

    mov ah, 08h
    mov dl, [bp+6]
    int 13h
    jc Error

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
