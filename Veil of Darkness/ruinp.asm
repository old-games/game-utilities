section .text 

    mov    bx, indexTranslationTable   ; bx = offset of the translation table
    add    ax, ax                      ; ax *= 2 since each element of the table is 16-bit
    add    bx, ax 
    mov    ax, [cs:bx]                 ; new index -> old index
    neg    ax
    add    ax, -2
    retf

indexTranslationTable:
dw 0


