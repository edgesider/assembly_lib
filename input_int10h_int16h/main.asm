    org 07c00h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call ClearScreen_Init
_LOOP:
    call Getchar
    call Putchar
    jmp _LOOP

    jmp $

%include "../lib/io.asm"

times 510-($-$$) db 0
dw 0xaa55
