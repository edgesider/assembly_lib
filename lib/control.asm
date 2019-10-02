%ifndef LIB_CONTROL
%define LIB_CONTROL

SC_Color equ 03h ; black background and cyan frontground
SC_Height equ 25
SC_Width equ 80
SC_MaxCol equ SC_Width - 1
SC_MaxRow equ SC_Height - 1
SC_CursorShape equ 0607h ; block-0007h, underline-0607h

struc SC_Cursor
    .row resb 1
    .col resb 1
endstruc

struc SC_LineUsage
    .usage resb SC_Height ; every item stores the number of valid char in corresponding line
endstruc

SC_Init:
    ; set size of screen
    ; clean screan
    mov cx, 0000h ; left top
    mov dl, SC_Width ; right
    mov dh, SC_Height ; bot
    mov al, 0 ; clean screen
    mov bh, SC_Color; black back, cyan front
    mov ah, 06h
    int 10h
    push es
    mov ax, ds
    mov es, ax
    mov di, SC_BufStart
    mov cx, SC_Cursor_size + SC_LineUsage_size
    mov ax, 0
    cld
    rep stosb
    pop es
    mov ax, 0xb800
    mov gs, ax
    ret
    ret

SC_ClearScreen_PageUp:
    mov cx, 0000h
    mov dh, 24
    mov dl, 79
    mov al, 00h ; al=00h(rows to scroll, 0 is clear)
    mov ah, 06h ; ah=06h(scroll up)
    int 10h
    ret

SC_ClearScreen_Init:
    ; reset display mode in order to clear screen
    mov ah, 0fh ; get display mode to al
    int 10h
    mov ah, 00h ; set display mode from al
    int 10h
    ret

_SC_CursorCalcIndex:
    ; calculate cursor's linear index to bx
    push cx
    mov cx, 0
    mov cl, [SC_CursorBuf+SC_Cursor.row]
    mov bx, cx
    imul bx, 80
    mov cl, [SC_CursorBuf+SC_Cursor.col]
    add bx, cx
    pop cx
    ret

_SC_CursorUpdate:
    push bx
    push dx
    push ax
    call _SC_CursorCalcIndex ; index is now in bx
    mov dx, 0x3d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x3d5
    mov al, bh
    out dx, al
    mov dx, 0x3d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x3d5
    mov al, bl
    out dx, al
    pop ax
    pop dx
    pop bx
    ret

SC_CursorStep:
    push bx
    mov bl, [SC_CursorBuf+SC_Cursor.col]
    cmp bl, SC_MaxCol
    jle _stepright
    call SC_CursorStepNewLine
    jmp _stepdone
_stepright:
    call _SC_LineUsageInc
    inc byte [SC_CursorBuf+SC_Cursor.col]
_stepdone:
    pop bx
    ret

SC_CursorStepBack:
    push bx
    mov bl, [SC_CursorBuf+SC_Cursor.col]
    cmp bl, 0
    jle _stepback_last_line

    ; move left
    call _SC_LineUsageDec
    dec byte [SC_CursorBuf+SC_Cursor.col]
    jmp _stepback_done
_stepback_last_line:
    mov bl, [SC_CursorBuf+SC_Cursor.row]
    cmp bl, 0
    jz _stepback_done
    dec byte [SC_CursorBuf+SC_Cursor.row]
    call _SC_LineUsageGet
    mov byte [SC_CursorBuf+SC_Cursor.col], bl
_stepback_done:
    pop bx
    ret

SC_CursorStepNewLine:
    inc byte [SC_CursorBuf+SC_Cursor.row]
    mov byte [SC_CursorBuf+SC_Cursor.col], 0
    ret

_SC_LineUsageInc:
    push ax
    push bx
    mov ax, 0
    mov al, [SC_CursorBuf+SC_Cursor.row]
    mov bx, SC_LineUsageBuf
    add bx, ax
    inc byte [bx]
    pop bx
    pop ax
    ret

_SC_LineUsageDec:
    push ax
    push bx
    mov ax, 0
    mov al, [SC_CursorBuf+SC_Cursor.row]
    mov bx, SC_LineUsageBuf
    add bx, ax
    dec byte [bx]
    pop bx
    pop ax
    ret

_SC_LineUsageGet:
    ; get current line usage to bx
    push ax
    mov ax, 0
    mov al, [SC_CursorBuf+SC_Cursor.row]
    mov bx, SC_LineUsageBuf
    add bx, ax
    mov byte bl, [bx]
    mov bh, 0
    pop ax
    ret

SC_BufStart:
SC_CursorBuf: times SC_Cursor_size db 0
SC_LineUsageBuf: times SC_LineUsage_size db 0

%endif
