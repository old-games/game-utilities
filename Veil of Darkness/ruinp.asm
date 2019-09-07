;nasm ruinp.asm -o ruinp.bin
section .text 

; func ru_input (al - scancode, bx - eng table)
ru_input:
    mov ah, 0
    test byte [cs:keyb_ru], 1
    jz ru_inp_orig
    cmp al, 0x10
    jb ru_inp_orig
    cmp ax, 0x34
    ja ru_inp_orig
    sub ax, 0x10
    mov bx, key_table
    shl ax, 1
    add bx, ax
    mov ax, word [cs:bx]
    retf
ru_inp_orig:
    shl ax, 1
    add bx, ax
    mov ax, word [bx]
    retf
    nop

; func tolower (al - char)
ru_lower:
    mov ah, 0
    cmp al, 0xF0
    jne rl_not_yo
    inc ax
    jmp rl_done
rl_not_yo:
    cmp al, 0x41 ; check ranges eng(0x41 - 0x5A) ru (0x80 - 0x9F)
    jb rl_done
    cmp al, 0x9F ; 0x41 - 0x9F
    ja rl_done
    cmp al, 0x80 ; 0x80 - 0x9F
    jae rl_make
    cmp al, 0x5A ; 0x41 - 0x5A
    ja rl_done
rl_make:
    add ax, 0x20
    cmp al, 0xB0
    jb rl_done
    add ax, 0x30
rl_done:
    test byte [cs:tolower_far],1
    jnz rl_retfar
    ret
rl_retfar:
    retf
    nop

;func strincmp (al - first char, bl - nextchar, dx - range)
ru_strincmp:
    mov byte [cs:tolower_far],0
    call ru_lower
    xchg al,bl
    call ru_lower
    xchg al,bl
    mov byte [cs:tolower_far],1
    retf
    nop

;func hotkey_conv ax - hotkey
hotkey_conv:
    mov bx, hotkey_table
hk_next:
    mov cx, word[cs:bx]
    test cx, cx
    jz hk_ret
    add bx, 2
    cmp al, ch
    jnz hk_next
    mov al, cl 
hk_ret:
    mov     cx, 21h 
    mov     bx, 54Eh
    retf
    nop


keyb_ru db 1
tolower_far db 1

key_table
dw  0x89 ; 0x10 'Q'
dw  0x96 ; 0x11 'W'
dw  0x93 ; 'E'
dw  0x8A ; 'R'
dw  0x85 ; 'T'
dw  0x8D ; 'Y'
dw  0x83 ; 'U'
dw  0x98 ; 'I'
dw  0x99 ; 'O'
dw  0x87 ; 'P'
dw  0x95 ; '['
dw  0x9A ; ']'
dw  0x000d ; '.'
dw  0x011d ; '.'
dw  0x94 ; 'A'
dw  0x9B ; 'S'
dw  0x82 ; 0x20 'D'
dw  0x80 ; 'F'
dw  0x8F ; 'G'
dw  0x90 ; 'H'
dw  0x8E ; 'J'
dw  0x8B ; 'K'
dw  0x84 ; 'L'
dw  0x86 ; ';'
dw  0x9D ; '''
dw  0xF0 ; 0x29 '`'
dw  0x012a ; '*'
dw  0x005c ; '\'
dw  0x9F ; 'Z'
dw  0x97 ; 'X'
dw  0x91 ; 'C'
dw  0x8C ; 'V'
dw  0x88 ; 'B'
dw  0x92 ; 'N'
dw  0x9C ; 'M'
dw  0x81 ; ','
dw  0x9E ; 0x34 0x2e '.'

hotkey_table
dw 0x9441
dw 0x9143
dw 0x8244
dw 0x9849
dw 0x9C4D
dw 0x994F
dw 0x8750
dw 0x8554
dw 0x8C56
dw 0x955B
dw 0x9A5D
dw 0

;HELPER CHUNK CODE.2
    nop
    nop
    nop
    nop
    nop
    ;122E:113A - readkey
    mov bx, 0xe17
    call 0xFFFF:0xFFFF
    mov si, ax
    
    nop
    ;122E:1162 - peek key
    mov bx, 0xe17
    call 0xFFFF:0xFFFF

    nop
min3:
    int 3    

    nop
    ;0050:9AD7 max sym cmd
    cmp word [bp-0x30], 0x00F1
    jg min3
    
    nop
    ;0050:A704 max sym name
    cmp byte [bp-01], 0

    nop
    ; 19E3:0026  to lower, 0050:0538 hotkey_conv
    call 0xFFFF:0xFFFF
