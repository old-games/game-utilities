

 org 62EBh;
 
 
 section .text

	global _start 
 	_start:
 		jmp real_start
 		logfac db 1

	_my_draw_proc:
			cmp bx,28A2h
			je start_run
			cmp bx,28A4h
			je cont_run
			mov si,[bx]
			cmp si,0FFFFh
			ret
		start_run:
			pushf
			pusha
			push es
			push ds
			mov ax,ds
			mov es,ax
			mov ax,cs
			mov ds,ax
			mov bx,mydata
			mov si,[bx]
			add bx,4
			mov [cur_adr],bx
			sub bx,2
			jmp to_letter
		cont_run:
			pushf
			pusha
			push es
			push ds
			mov ax,ds
			mov es,ax
			mov ax,cs
			mov ds,ax
			mov bx,[cur_adr]
			mov si,[bx]
			add bx,4
			mov [cur_adr],bx
			sub bx,2
		to_letter:
			cmp si,0FFFFh
			jnz make_letter
			jmp do_ret
		make_letter:
			mov ax,[bx]
			mov di,28A2h
			stosw
			cmp si,28A0h
			ja myletter
			jmp do_ret
		myletter:
			mov ax,28B0h
			mov di,ax
			mov cx,8
		next_l:
			movsw
			dec cx
			jnz next_l
			mov si,28B0h
		do_ret:
			mov ax,si
			mov di,28A4h
			stosw
			pop ds
			pop es
			popa
			popf
			mov bx,28A0h
			mov si,[bx+4]
			cmp si,0FFFFh
			ret
		
		cur_adr dw 0
		mydata dw 27C0h,12C4h,27E0h,1226h,0xFFFF
		
		
real_start:
	call _my_draw_proc
	mov ax,4C00h
	int 21h
		