org 8000h

    mov ax, cs
    mov ds, ax
    mov es, ax

lp1:
    call SC_Init
    push word Str
    call IO_PrintStr
    jmp $

Str: db "Succeed!", 0x00

%include "io.asm"
%include "control.asm"
