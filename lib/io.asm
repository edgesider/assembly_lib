%ifndef LIB_IO
%define LIB_IO

%include "control.asm"

CH_Return equ 0x0d
CH_Null equ 0x00

struc IO_Cursor
    .row resb 1
    .col resb 1
endstruc

struc IO_LineUsage
    .usage resb SC_Height ; every item stores the number of valid char in corresponding line
endstruc

IO_Init:
    push es
    mov ax, ds
    mov es, ax
    mov di, IO_BufStart
    mov cx, IO_Cursor_size + IO_LineUsage_size
    mov ax, 0
    cld
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
    push bp
    mov bp, sp
    push ax
    push bx

    mov ah, 0
    mov bx, [bp+4]
_print_str_loop0:
    mov al, [bx]
    inc bx
    cmp al, 0
    jz _print_str_end
    push ax
    call IO_PrintChar
    add sp, 2
    jmp _print_str_loop0
_print_str_end:
    pop bx
    pop ax
    pop bp
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
    push dx
    call IO_PrintChar
    add sp, 2
    dec cx
    jmp _lp2
_over:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ----utils----
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
    push ax
    push bx
    mov ax, 0
    mov al, [IO_CursorBuf+IO_Cursor.row]
    mov bx, IO_LineUsageBuf
    add bx, ax
    inc byte [bx]
    pop bx
    pop ax
    ret

_IO_LineUsageDec:
    push ax
    push bx
    mov ax, 0
    mov al, [IO_CursorBuf+IO_Cursor.row]
    mov bx, IO_LineUsageBuf
    add bx, ax
    dec byte [bx]
    pop bx
    pop ax
    ret

_IO_LineUsageGet:
    ; get current line usage to bx
    push ax
    mov ax, 0
    mov al, [IO_CursorBuf+IO_Cursor.row]
    mov bx, IO_LineUsageBuf
    add bx, ax
    mov byte bl, [bx]
    mov bh, 0
    pop ax
    ret

IO_CursorStepNewLine:
    inc byte [IO_CursorBuf+IO_Cursor.row]
    mov byte [IO_CursorBuf+IO_Cursor.col], 0
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
    call IO_PrintStr
    add sp, 2
    jmp $

ErrStr: db 'Error!'
IO_BufStart:
IO_CursorBuf: times IO_Cursor_size db 0
IO_LineUsageBuf: times IO_LineUsage_size db 0
%endif
