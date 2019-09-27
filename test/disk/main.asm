org 07c00h
Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init
    ;call TEST_ReadSector
    ;call TEST_ReadDiskInfo
    ;call TEST_ReadSectorLBA

    jmp $

;TEST_ReadSectorLBA:
    ;push byte 80h
    ;push dword Buffer
    ;push dword 0000h
    ;push dword 0001h
    ;push word 1
    ;call DK_ReadSectorLBA
    ;jc IO_Error

    ;push Buffer
    ;push 5
    ;call IO_Print_stack
    ;ret

;TEST_ReadDiskInfo:
    ;push 80h ; drive number: hd1
    ;push word infobuf
    ;call DK_ReadDiskInfo

    ;mov ax, [infobuf + DK_DiskInfo.NumberofCylinder]
    ;call IO_PrintNum
    ;mov al, '/'
    ;call IO_PutChar

    ;mov ah, 0
    ;mov al, [infobuf + DK_DiskInfo.HeadPerCylinder]
    ;call IO_PrintNum
    ;mov al, '/'
    ;call IO_PutChar

    ;mov al, [infobuf + DK_DiskInfo.SectorPerHead]
    ;call IO_PrintNum

    ;call SC_MoveCursorNextLine
    ;ret

;TEST_ReadSector:
    ;push word 80h
    ;push word Buffer
    ;push dword 1200
    ;push word 1
    ;call DK_ReadSectorCHS
    ;add sp, 10

    ;push Buffer ; word
    ;push 5 ; word
    ;call IO_Print_stack
    ;add sp, 4
    ;ret

%include "disk.asm"
%include "io.asm"

infobuf resb DK_DiskInfo_size
SuccStr: db "S!"
times 510-($-$$) db 0
dw 0xaa55
