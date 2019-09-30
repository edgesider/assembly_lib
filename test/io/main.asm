    org 0x8000

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    call IO_Init

    push word 'L'
    call IO_PrintChar
    add sp, 2

    mov ax, 12345
    call IO_PrintNum

    push word str
    call IO_PrintStr
    add sp, 2

p:
    call IO_GetChar
    push ax
    call IO_PrintChar
    add sp, 2
    jmp p

    jmp $

%include "io.asm"

str: db CH_Return, "abcd", CH_Return, CH_Null
