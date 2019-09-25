    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax
    ;call ClearScreen_PageUp
    call ClearScreen_Init
    call ChangeCursor
    call ChangeColor

    mov al, 'a'
    call Putchar

    mov ax, 65535
    call Printnum

    mov ax, String
    call Print_ax

    push String ; address
    push 13 ; length
    push 0a00h ; row:col
    call Print_stack

    call MoveCursorForward
    mov al, 'x'
    call Putchar

_LOOP:
    call Getchar
    call Putchar
    jmp _LOOP

    jmp $

%include "io.asm"
%include "control.asm"

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
