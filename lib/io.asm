%ifndef LIB_IO
%define LIB_IO

%include "control.asm"

CH_Return equ 0x0d
CH_Null equ 0x00

IO_StrCmp:
    ; :return(ax): 0 if equal, other if not equal
    ;---parameters---
    ; | str1        |+10 dword segment:offset
    ; | str2        |+6 dword segment:offset
    ; | length      |+4 word
    ;---parameters---
    ; | call-saved  |+2
    ; | saved-bp    |+0 <--bp <--sp
    push bp
    mov bp, sp

    push ds
    push es
    push si
    push di
    push cx

    mov si, [bp+10]  ; str1
    mov ds, [bp+12]  ; str1
    mov di, [bp+6]   ; str2
    mov es, [bp+8]  ; str2
    mov cx, [bp+4]   ; length
_strcmp_loop0:
    cmp cx, 0  ; string ends
    jz _strcmp_loop0_end_true
    dec cx
    mov dl, [ds:si]
    mov dh, [es:di]
    sub dl, dh
    jnz _strcmp_loop0_end_false
    inc si
    inc di
    jmp _strcmp_loop0

_strcmp_loop0_end_true:
    mov ax, 0
    jmp _strcmp_over
_strcmp_loop0_end_false:
    mov al, dl
    mov ah, 0

_strcmp_over:

    pop cx
    pop di
    pop si
    pop es
    pop ds
    pop bp
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
    mov al, [ds:bx]
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
    call SC_CursorStepNewLine
    jmp _print_char_done

_print_char_back:
    call SC_CursorStepBack
    mov al, ' '
    call _IO_PrintCharPure
    jmp _print_char_done

_printable:
    call _IO_PrintCharPure
    call SC_CursorStep
    jmp _print_char_done

_print_char_done:
    call _SC_CursorUpdate
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

_IO_PrintCharPure:
    ; print character in al without moving cursor
    push bx
    push ax
    call _SC_CursorCalcIndex
    shl bx, 1
    mov ah, 0x07
    mov [gs:bx], ax
    pop ax
    pop bx
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

ErrStr: db 'Error!', 0
%endif
