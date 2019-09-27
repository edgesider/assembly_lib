org 8000h

    mov ax, cs
    mov ds, ax
    mov es, ax

lp1:
    ;call IO_GetChar
    mov al, '1'
    call IO_PutChar
    jmp lp1

%include "../lib/io.asm"
