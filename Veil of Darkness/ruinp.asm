;nasm ruinp.asm -o ruinp.bin
section .text 

; func ru_input (al - scancode, bx - eng table)
ru_input:
    mov ah, 0
    cmp byte [cs:keyb_ru], 0
    je ru_inp_orig
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
    retf
rl_not_yo:
    add ax, 0x20
    cmp al, 0xB0
    jb rl_done
    add ax, 0x30
rl_done:
    retf
    nop



keyb_ru db 1

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
    ; 19E3:0026  to lower
    call 0xFFFF:0xFFFF
