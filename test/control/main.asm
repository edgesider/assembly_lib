    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
_lp3:
    call IO_GetChar
    push word ax
    call IO_PrintChar
    add sp, 2
    jmp _lp3

    jmp $

%include "io.asm"
%include "control.asm"

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
