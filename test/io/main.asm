    org 0x8000

    mov ax, cs
    mov ds, ax
    mov es, ax

    mov sp, 0x8000
    mov bp, sp
    call SC_Init

    push word 'L'
    call IO_PrintChar
    add sp, 2

    mov ax, 12345
    call IO_PrintNum

    push word str
    call IO_PrintStr
    add sp, 2

    push ds
    push word str1
    push ds
    push word str3
    push word 4
    call IO_StrCmp ; return value is in ax
    call IO_PrintNum

    push word CH_Return
    call IO_PrintChar

    push word str1
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
%include "disk.asm"

str: db CH_Return, "abcd", CH_Return, CH_Null
str1: db "abcd", 0
str2: db "abcd", 0
str3: db "dcba", 0
