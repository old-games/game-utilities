section .text 

    push cs
    pop ds

    mov ax, 100
    mov bx, 200
    add ax,bx

    pop ds
    popaf
    ret


