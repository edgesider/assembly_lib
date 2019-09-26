    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax
    call SC_Init


    mov ax, String
    call IO_Print_ax

    push String ; address
    push 13 ; length
    call IO_Print_stack

_LOOP:
    call IO_GetChar
    call IO_PutChar
    jmp _LOOP

    jmp $

%include "io.asm"

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
