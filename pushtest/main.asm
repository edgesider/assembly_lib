    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, 13h
    push ax
    push ax
    push ax
    push ax
    pop ax
    pop ax
    pop ax
    pop ax

    jmp $

String: db "Hello, world!"
times 510-($-$$) db 0
dw 0xaa55
