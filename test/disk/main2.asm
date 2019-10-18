org 8000h
Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    push word 0
    push word 81h
    push word Filename
    call DK_Fat12Find
    add sp, 6

    jmp $

%include "disk.asm"
%include "io.asm"

Filename: db "LOADER  BIN"
Str: db "test", 0
infobuf resb DK_DiskInfo_size
SuccStr: db "S"
;times 510-($-$$) db 0
;dw 0xaa55
