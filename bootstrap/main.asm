; Load first 5120 bytes of hda to memory and jump to there.

org 07c00h
LoaderAddr equ 8000h ; address to put loader
DiskIndex equ 80h    ; disk to load
SectorToRead equ 10

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    push StrLoading
    push 19
    call IO_Print_stack
    add sp, 4
    call SC_MoveCursorNextLine

    push word DiskIndex
    push word LoaderAddr
    push dword 0
    push word SectorToRead
    call DK_ReadSectorCHS
    add sp, 10

    push StrLoaded
    push 36
    call IO_Print_stack

    call IO_GetChar
    jmp 0:LoaderAddr

StrLoading: db "Loading from hda..."
StrLoaded: db "Loaded! Press any key to continue..."

%include "tinyio.asm"
%include "tinydisk.asm"

times 510-($-$$) db 0
dw 0xaa55
