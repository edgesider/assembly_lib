%ifndef LIB_IO
%define LIB_IO

%include "control.asm"

Print_ax:
    push ax
    push bx
    push cx
    push dx
    mov bp, ax  ; es:bp, start of string
    mov cx, 13  ; length of string
    mov ax, 01301h ; ah=13h, al=01h
    mov bx, 000ch  ; bh=00h(page), bl=0ch(color)
    mov dx, 0900h  ; dh=0ah(row), dl=00h(column)
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

Print_stack:
    ; | stack top   |
    ; | call-saved  |
    ; | row:col     |
    ; | length      |
    ; | address     |
    ;; save and renew base of stack.
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov dx, [bp+4] ; dh=0ah(row), dl=00h(column)
    mov cx, [bp+6]  ; length of string
    mov bp, [bp+8]  ; es:bp, start of string
    mov ax, 01301h ; ah=13h, al=01h
    mov bx, 000ch  ; bh=00h(page), bl=0ch(color)
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

Putchar:
    ; print char and move cursor
    ; the char is in al
    ; if it is backspace, move cursor back
    push ax
    push bx
    push cx

    cmp al, 08h ; backspace
    jnz _ELSE
    call MoveCursorBackward
    mov al, ' '
    call Putchar
    call MoveCursorBackward
    jmp _DONE
_ELSE:
    mov ah, 0ah
    mov bh, 00h
    mov cx, 01h
    int 10h
    call MoveCursorForward
_DONE:
    pop cx
    pop bx
    pop ax
    ret

Printnum:
    ; print number in ax
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    mov cx, 0
_lp1:
    mov dx, 0
    div bx  ; dx:ax / bx == ax --- dx
    push dx
    inc cx
    or ax, ax
    jnz _lp1
_lp2:
    cmp cx, 0
    jz _over
    pop dx
    add dx, 30h
    mov al, dl
    call Putchar
    dec cx
    jmp _lp2
_over:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

Putnumber:
    ; put a 0-9 number in al to screen
    add al, 30h
    call Putchar
    ret

Getchar:
    ; get char to al
    push cx
    mov cx, 01h
    mov ah, 00h
    int 16h
    pop cx
    ret

%endif
