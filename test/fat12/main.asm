org 8000h
Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    push word FileEntryBuf
    push word 81h
    push word Filename
    call Fat12_Find
    add sp, 6

    cmp ax, 0
    jz _notfound
    push word Found
    call IO_PrintStr
    add sp, 2
    jmp _endif
_notfound:
    push word NotFound
    call IO_PrintStr
    add sp, 2
_endif

    jmp $

%include "fat12.asm"
%include "io.asm"

Filename: db "LOADER  BIN", 0
Str: db "test", 0
Found: db "found", 0
NotFound: db "not found", 0
;SuccStr: db "S"
FileEntryBuf: resb Fat12_FileEntry_size
;times 510-($-$$) db 0
;dw 0xaa55
