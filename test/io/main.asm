    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
_LOOP:
    call IO_GetChar
    call IO_PutChar
    jmp _LOOP

    jmp $

%include "io.asm"

times 510-($-$$) db 0
dw 0xaa55
