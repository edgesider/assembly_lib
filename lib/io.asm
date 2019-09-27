%ifndef LIB_IO
%define LIB_IO

IO_Print_stack:
    ;-----------------
    ; | address     |
    ; | length      |
    ;-----------------
    ; | call-saved  |
    ; | stack top   |

    ;; save and renew base of stack.
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    call SC_GetCursor
    ;mov dx, [bp+4] ; dh=0ah(row), dl=00h(column)
    mov cx, [bp+4]  ; length of string
    mov bp, [bp+6]  ; es:bp, start of string
    mov ax, 01301h ; ah=13h, al=01h
    mov bh, 00h  ; bh=00h(page)
    mov bl, SC_Color
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

IO_PutChar:
    ; print char and move cursor
    ; the char is in al
    ; if it is backspace, move cursor back
    push ax
    push bx
    push cx

    cmp al, 08h ; backspace
    jnz _else0
    call SC_MoveCursorBackward
    mov al, ' '
    call IO_PutChar
    call SC_MoveCursorBackward
    jmp _done0
_else0:
    cmp al, 0dh ; enter/return
    jnz _else1
    call SC_MoveCursorNextLine
    jmp _done0
_else1:
    mov ah, 0ah
    mov bh, 00h
    mov cx, 01h
    int 10h
    call SC_MoveCursorForward
_done0:
    pop cx
    pop bx
    pop ax
    ret

IO_PrintNum:
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
    call IO_PutChar
    dec cx
    jmp _lp2
_over:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

IO_GetChar:
    ; get char to al
    push cx
    mov cx, 01h
    mov ah, 00h
    int 16h
    pop cx
    ret

IO_Error:
    push ErrStr
    push 6
    call IO_Print_stack
    add sp, 4
    jmp $

%include "control.asm"

ErrStr: db 'Error!'
%endif
