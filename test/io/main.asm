    org 0x8000

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    call IO_Init

p:
    call IO_GetChar
    push ax
    call IO_PrintChar
    jmp p

;_LOOP:
    ;call IO_GetChar
    ;call IO_PutChar
    ;jmp _LOOP

    jmp $

%include "io.asm"

buf: times 128 db 0

;times 510-($-$$) db 0
;dw 0xaa55
