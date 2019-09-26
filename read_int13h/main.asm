    org 07c00h

Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init

    mov bx, Buffer
    mov dl, 80h   ; first disk
    mov ch, 00h   ; cylinder
    mov cl, 01h   ; cylider-high-2, sector
    mov dh, 00h   ; head
    mov al, 1
    mov ah, 02h ; read
    int 13h

    jc Error ; error on CF == 1
    push SuccString
    push 13
    push 0a00h
    call IO_Print_stack
    sub sp, 6
    jmp Done
Error:
    push ErrString
    push 19
    push 0a00h
    call IO_Print_stack
    sub sp, 6
    jmp $
Done:

    push Buffer
    push 5
    push 0b00h
    call IO_Print_stack

    jmp $

%include "io.asm"

SuccString: db "Read Succeed!"
ErrString: db "Read Error! Halt..."
times 510-($-$$) db 0
dw 0xaa55
