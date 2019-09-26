    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init

    mov al, 'a'
    call IO_PutChar

    mov ax, 65535
    call IO_PrintNum

    mov ax, String
    call IO_Print_ax

    push String ; address
    push 13 ; length
    call IO_Print_stack

    call SC_MoveCursorForward
    mov al, 'x'
    call IO_PutChar

    jmp $

%include "io.asm"

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
