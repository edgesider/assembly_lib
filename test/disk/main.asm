org 8000h
Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    call TEST_ReadSector

    jmp $

TEST_ReadDiskInfo:
    push 80h ; drive number: hd1
    push word infobuf
    call DK_ReadDiskInfo

    mov ax, [infobuf + DK_DiskInfo.NumberofCylinder]
    call IO_PrintNum
    push word '/'
    call IO_PrintChar
    add sp, 2

    mov ah, 0
    mov al, [infobuf + DK_DiskInfo.HeadPerCylinder]
    call IO_PrintNum
    push word '/'
    call IO_PrintChar
    add sp, 2

    mov al, [infobuf + DK_DiskInfo.SectorPerHead]
    call IO_PrintNum

    call SC_CursorStepNewLine
    ret

TEST_ReadSector:
    push byte 81h
    push dword Buffer
    push dword 0
    push dword 1200
    push word 1
    call DK_ReadSector
    add sp, 2+4+8+2

    mov byte [Buffer+5], 0
    push Buffer ; word
    call IO_PrintStr
    add sp, 4
    ret

%include "disk.asm"
%include "io.asm"

Str: db "test", 0
infobuf resb DK_DiskInfo_size
SuccStr: db "S"
;times 510-($-$$) db 0
;dw 0xaa55
