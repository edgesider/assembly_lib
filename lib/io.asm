%ifndef LIB_IO
%define LIB_IO

%include "control.asm"

struc IO_Cursor
    .row resb 1
    .col resb 1
endstruc

struc IO_LineUsage
    .usage resb SC_Height ; every item stores the number of valid char in corresponding line
endstruc

IO_Init:
    push es
    mov ax, IO_BufStart
    mov es, ax
    mov di, 0
    mov cx, IO_Cursor_size + IO_LineUsage_size
    mov ax, 0
    rep stosb
    pop es
    mov ax, 0xb800
    mov gs, ax
    ret

IO_PrintStr:
    ; print null-terminated string to screen
    ;---parameters:----
    ;               |+6
    ; | address     |+4 word: pointer to string
    ;---:parameters----
    ; | call-saved  |+2
    ; | saved-bp    |+0 <--bp <--sp
    ret

IO_PrintChar:
    ;---parameters:----
    ;               |+6
    ; | padding     |+5
    ; | char        |+4 byte: char to print
    ;---:parameters----
    ; | call-saved  |+2
    ; | saved-bp    |+0 <--bp <--sp
    push bp
    mov bp, sp
    push ax
    push cx
    push bx

    mov al, [bp + 4]
    cmp al, 0x0d ; return
    jz _print_char_return
    cmp al, 0x08 ; backspace
    jz _print_char_back
    jmp _printable

_print_char_return:
    call IO_CursorStepNewLine
    jmp _print_char_done

_print_char_back:
    call IO_CursorStepBack
    mov al, ' '
    call _IO_PrintCharPure
    jmp _print_char_done

_printable:
    call _IO_PrintCharPure
    call IO_CursorStep
    jmp _print_char_done

_print_char_done:
    call _IO_CursorUpdate
    pop bx
    pop cx
    pop ax
    pop bp
    ret

_IO_CursorCalcIndex:
    ; calculate cursor's linear index to bx
    push cx
    mov cx, 0
    mov cl, [IO_CursorBuf+IO_Cursor.row]
    mov bx, cx
    imul bx, 80
    mov cl, [IO_CursorBuf+IO_Cursor.col]
    add bx, cx
    pop cx
    ret

_IO_PrintCharPure:
    ; print al purely
    push bx
    push ax
    call _IO_CursorCalcIndex
    shl bx, 1
    mov ah, 0x07
    mov [gs:bx], ax
    pop ax
    pop bx
    ret

IO_PrintNum2:
    ;---parameters:----
    ;               |+6
    ; | number      |+4 word: number to print
    ;---:parameters----
    ; | call-saved  |+2
    ; | saved-bp    |+0 <--bp <--sp
    ret

_IO_CursorUpdate:
    push bx
    push dx
    push ax
    call _IO_CursorCalcIndex ; index is now in bx
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

IO_CursorStep:
    push bx
    mov bl, [IO_CursorBuf+IO_Cursor.col]
    cmp bl, SC_MaxCol
    jle _stepright
    call IO_CursorStepNewLine
    jmp _stepdone
_stepright:
    call _IO_LineUsageInc
    inc byte [IO_CursorBuf+IO_Cursor.col]
_stepdone:
    pop bx
    ret

IO_CursorStepBack:
    push bx
    mov bl, [IO_CursorBuf+IO_Cursor.col]
    cmp bl, 0
    jle _stepback_last_line

    ; move left
    call _IO_LineUsageDec
    dec byte [IO_CursorBuf+IO_Cursor.col]
    jmp _stepback_done

_stepback_last_line:
    mov bl, [IO_CursorBuf+IO_Cursor.row]
    cmp bl, 0
    jz _stepback_done
    dec byte [IO_CursorBuf+IO_Cursor.row]
    call _IO_LineUsageGet
    mov byte [IO_CursorBuf+IO_Cursor.col], bl
_stepback_done:
    pop bx
    ret

_IO_LineUsageInc:
    ; 0x8168
    push es
    push bx
    mov bx, 0
    mov bl, [IO_CursorBuf+IO_Cursor.row]
    mov ax, IO_LineUsageBuf
    mov es, ax
    inc byte [es:bx]
    pop bx
    pop es
    ret

_IO_LineUsageDec:
    push es
    push bx
    mov bx, 0
    mov bl, [IO_CursorBuf+IO_Cursor.row]
    mov ax, IO_LineUsageBuf
    mov es, ax
    dec byte [es:bx]
    pop bx
    pop es
    ret

_IO_LineUsageGet:
    ; get current line usage to bx
    push es
    mov bx, 0
    mov bl, [IO_CursorBuf+IO_Cursor.row]
    mov ax, IO_LineUsageBuf
    mov es, ax
    mov byte bl, [es:bx]
    pop es
    ret

IO_CursorStepNewLine:
    inc byte [IO_CursorBuf+IO_Cursor.row]
    mov byte [IO_CursorBuf+IO_Cursor.col], 0
    ret

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

ErrStr: db 'Error!'
IO_BufStart:
IO_CursorBuf: times IO_Cursor_size db 0
IO_LineUsageBuf: times IO_LineUsage_size db 0
%endif
