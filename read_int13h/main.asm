org 07c00h
Buffer equ 0100h

    mov ax, cs
    mov ds, ax
    mov es, ax

    call SC_Init

    push 80h ; drive number: hd1
    push word infobuf
    call DK_ReadDiskInfo

    mov ax, [infobuf + DK_DiskInfo.NumberofCylinder]
    call IO_PrintNum
    mov al, '/'
    call IO_PutChar

    mov ah, 0
    mov al, [infobuf + DK_DiskInfo.HeadPerCylinder]
    call IO_PrintNum
    mov al, '/'
    call IO_PutChar

    mov al, [infobuf + DK_DiskInfo.SectorPerHead]
    call IO_PrintNum

    call SC_MoveCursorNextLine

    mov bx, Buffer
    mov dl, 80h   ; first disk
    mov ch, 00h   ; cylinder
    mov cl, 01h   ; cylider-high-2:sector
    mov dh, 00h   ; head
    mov al, 1
    mov ah, 02h ; read
    int 13h
    jc Error ; error on CF == 1
    push SuccString
    push 7
    call IO_Print_stack
    sub sp, 6
    jmp Done
Error:
    push ErrString
    push 5
    call IO_Print_stack
    sub sp, 6
    jmp $
Done:

    call SC_MoveCursorNextLine

    push Buffer
    push 5
    call IO_Print_stack

    jmp $

%include "io.asm"
%include "disk.asm"

infobuf resb DK_DiskInfo_size

SuccString: db "Succeed"
ErrString: db "Error"
;times 510-($-$$) db 0
;dw 0xaa55
