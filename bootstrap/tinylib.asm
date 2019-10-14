%ifndef TINYLIB
%define TINYLIB

SC_Color equ 03h ; black background and cyan frontground
SC_Height equ 23
SC_Width equ 80
SC_MaxCol equ SC_Width - 1
SC_MaxRow equ SC_Height - 1
SC_CursorShape equ 0607h ; block-0007h, underline-0607h

TinyLibInit:
    ; set size of screen
    ; clean screan
    mov cx, 0000h ; left top
    mov dl, SC_Width ; right
    mov dh, SC_Height ; bot
    mov al, 0 ; clean screen
    mov bh, SC_Color; black back, cyan front
    mov ah, 06h
    int 10h

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

Print:
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

    call GetCursor
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

GetChar:
    ; get char to al
    push cx
    mov cx, 01h
    mov ah, 00h
    int 16h
    pop cx
    ret

GetCursor:
    ; get cursor position and save to (dl, dh)-(x, y)
    mov bx, 0h ; page
    mov ah, 03h ; get cursor position
    int 10h ; dh: y, dl: x
    ret

MoveCursor:
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

MoveCursorNextLine:
    ; set y+=1, set x=0
    call GetCursor ; x,y in dl,dh
    cmp dh, SC_Height
    jnl _move_nextline_over ; no move
    mov dl, 0
    inc dh
    call MoveCursor
_move_nextline_over:
    ret

ReadSector:
    ; via CHS
    ;---parameters----
    ; | disk index      |+18 word (only lower byte will be used)
    ; | buffer pointer  |+14 dword (only lower word will be used)
    ; | start sector    |+6 qword (only lower dword will be used)
    ; | number of sector|+4 word (only lower byte will be used)
    ;---parameters----
    ; | call-saved      |+2
    ; | saved-bp        |+0 <--bp <--sp
    ;----stack-top(bp)----
    push bp
    mov bp, sp

    ;               | <--bp
    ; |             |-DK_DiskInfo_size  <--sp
    sub sp, DK_DiskInfo_size

    push word [bp+18]
    mov ax, bp
    sub ax, DK_DiskInfo_size
    push ax
    call ReadDiskInfo
    add sp, 4

    ; x, y, z = CHS tuple
    ; n = sector number
    ; SPH = sector per head, HPC = head per cylinder
    ; n = z + SPH * (y + x * HPC)
    ; z = n % SPH, let H = n / SPH
    ; y = H % HPC
    ; x = H / HPC
    sub sp, 1   ; store sector
    ;               | <--bp
    ; |             |-DK_DiskInfo_size
    ; | z: sector   |-1-DK_DiskInfo_size <--sp
    mov ax, [bp+6]
    mov dx, [bp+8]  ; dx:ax = start sector
    mov bh, 0
    mov bl, [bp-DK_DiskInfo_size+DK_DiskInfo.SectorPerHead]
    div bx   ; div: dx:ax / src == ax --- dx
    ; now z is in dx, H is in ax
    and dl, 00111111b
    mov [bp-1-DK_DiskInfo_size], dl
    mov dx, 0
    mov bh, 0
    mov bl, [bp-DK_DiskInfo_size+DK_DiskInfo.HeadPerCylinder]
    div bx
    ; now y is in dx, x is in ax

    push es
    mov cx, ds
    mov es, cx

    mov cl, [bp-1-DK_DiskInfo_size] ; cylinder-higher-2bit : sector
    inc cl
    mov ch, al  ; cylinder lower-8-bit
    shr ax, 2
    and al, 11000000b ; higher-2-bit
    or cl, al   ; cylinder and sector in cx
    mov dh, dl  ; head in dl
    add sp, 1
    mov bx, [bp+14] ; buffer
    mov dl, [bp+18] ; disk index
    mov al, [bp+4]
    mov ah, 02h  ; read function
    int 13h

    pop es
    jc IO_Error

    add sp, DK_DiskInfo_size
    pop bp
    ret

ReadDiskInfo:
    ;--parameters---
    ; | driver index| word
    ; | buffer      | word, pointer to an Info
    ;--parameters---
    ; | call-saved  | word
    ; | bp          |
    ; | stack-top   |
    push bp
    mov bp, sp

    mov ah, 08h
    mov dl, [bp+6]
    int 13h
    jc IO_Error

    mov bx, [bp+4]  ; buffer pointer

    inc dh
    mov byte [bx+DK_DiskInfo.HeadPerCylinder], dh

    mov ax, cx
    and al, 00111111b
    mov byte [bx+DK_DiskInfo.SectorPerHead], al

    mov ax, cx
    mov al, ah
    mov ch, 0
    mov ah, 0
    shl cx, 2
    or ah, ch
    inc ax
    mov word [bx+DK_DiskInfo.NumberofCylinder], ax

    pop bp
    ret

IO_Error:
    push ErrStr
    push 6
    call Print
    add sp, 4
    jmp $

ErrStr: db 'Error!'

struc DK_DiskInfo
    .NumberofCylinder resw 2
    .HeadPerCylinder resb 1
    .SectorPerHead resb 1
endstruc

%endif
