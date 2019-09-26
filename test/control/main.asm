    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    mov dx, 0600h
    call SC_MoveCursor

    call SC_GetCursor
    mov ax, 0
    mov al, dh
    call IO_PrintNum
    call SC_MoveCursorNextLine
    mov ax, 0
    mov al, dl
    call IO_PrintNum
    call SC_MoveCursorNextLine

_lp3:
    call IO_GetChar
    call IO_PutChar
    jmp _lp3

    jmp $

%include "io.asm"
%include "control.asm"

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
