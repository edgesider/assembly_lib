%ifndef LIB_CONTROL
%define LIB_CONTROL

SC_Color equ 03h ; black background and cyan frontground
SC_Height equ 25
SC_Width equ 80
SC_MaxCol equ SC_Width - 1
SC_MaxRow equ SC_Height - 1
SC_CursorShape equ 0607h ; block-0007h, underline-0607h

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
    call SC_InitCursor
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

SC_GetCursor:
    ; get cursor position and save to (dl, dh)-(x, y)
    mov bx, 0h ; page
    mov ah, 03h ; get cursor position
    int 10h ; dh: y, dl: x
    ret

SC_MoveCursor:
    ; move cursor to (dl, dh).
    ; auto-normalize
    push bx
    push ax
    mov bx, 0 ; page
    mov ah, 02h
    int 10h
    pop ax
    pop bx
    ret

SC_MoveCursorBackward:
    push ax
    push bx
    push dx
    call SC_GetCursor

    cmp dl, 0
    jg _go_left
    cmp dh, 0 ; 0,0
    jng _move_backward_over
    ; go prev line
    mov dl, SC_MaxCol
    dec dh ; row -= 1
    mov ah, 02h
    int 10h
    jmp _move_backward_over
_go_left:
    dec dl
    mov ah, 02h ; set cursor position
    int 10h
_move_backward_over:
    pop dx
    pop bx
    pop ax
    ret

SC_MoveCursorForward:
    push ax
    push bx
    push dx
    call SC_GetCursor

    cmp dl, SC_Width
    jl _go_right
    cmp dh, SC_MaxRow
    jnl _move_forward_over  ; right-bot
    ; go_nextline
    mov dl, 0h
    inc dh ; row += 1
    mov ah, 02h
    int 10h
    jmp _move_forward_over
_go_right:
    inc dl
    mov ah, 02h ; set cursor position
    int 10h
_move_forward_over:
    pop dx
    pop bx
    pop ax
    ret

SC_MoveCursorNextLine:
    ; set y+=1, set x=0
    call SC_GetCursor ; x,y in dl,dh
    cmp dh, SC_Height
    jnl _move_nextline_over ; no move
    mov dl, 0
    inc dh
    call SC_MoveCursor
_move_nextline_over:
    ret

;SC_MoveCursorPrevLine:
    ;ret

SC_InitCursor:
    ; set cursor to 0,0
    mov bx, 0
    mov dx, 0
    mov ah, 02h
    int 10h
    ; change shape
    mov ah, 01h
    mov cx, SC_CursorShape
    int 10h
    ret

%endif
