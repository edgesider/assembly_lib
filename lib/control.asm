%ifndef LIB_CONTROL
%define LIB_CONTROL

ChangeColor:
    mov ax, 0600h ; ah=06h(scroll up call), al=00h(no scroll)
    mov bh, 03h   ; bh_h=4h(red back), bh_l=3h(cyan front)
    mov	cx, 0			; left top: (0, 0)
    mov	dx, 0184fh		; right bottom: (80, 50)
    int 10h
    ret

ChangeCursor:
    mov ah, 01h
    mov cx, 2607h
    int 10h
    ret

ClearScreen_PageUp:
    mov cx, 0000h
    mov dh, 24
    mov dl, 79
    mov al, 00h ; al=00h(rows to scroll, 0 is clear)
    mov ah, 06h ; ah=06h(scroll up)
    int 10h
    ret

ClearScreen_Init:
    ; reset display mode in order to clear screen
    mov ah, 0fh ; get display mode to al
    int 10h
    mov ah, 00h ; set display mode from al
    int 10h
    ret

MoveCursorBackward:
    push ax
    push bx
    push dx
    mov bx, 0h ; page
    mov ah, 03h ; get cursor position
    int 10h ; dh: row, dl: col
    sub dl, 1h
    mov ah, 02h ; set cursor position
    int 10h
    pop dx
    pop bx
    pop ax
    ret

MoveCursorForward:
    push ax
    push bx
    push dx
    mov bx, 0h ; page
    mov ah, 03h ; get cursor position
    int 10h ; dh: row, dl: col
    add dl, 1h
    mov ah, 02h ; set cursor position
    int 10h
    pop dx
    pop bx
    pop ax
    ret

%endif
