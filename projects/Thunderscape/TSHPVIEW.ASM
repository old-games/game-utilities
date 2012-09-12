cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.386
	include	parse.asm
	org	100h
start:	mov	sp,offset fbuf-2
	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	nam,pal
	mov	ax,3D00h
	mov	dx,pal
	or	dx,dx
	jz	mnpl
	int	21h
	jc	mx
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jc	errd
	cmp	cx,ax
	jne	errd
	mov	ah,3Eh
	int	21h
	jc	errd
	mov	ax,3D00h
mnpl:	mov	dx,nam
	int	21h
	jc	mx
	xchg	ax,bx
	mov	ax,ds
	mov	dx,offset fbuf
	shr	dx,4
	inc	dx
	add	ax,dx
	mov	svsg,ax
	xor	dx,dx
m1a:	mov	ds,ax
	mov	ah,3Fh
	mov	cx,8000h
	int	21h
	jc	errd
	cmp	ax,cx
	jne	m1d
	mov	ax,ds
	add	ax,800h
	jmp	short m1a
m1d:	mov	ah,3Eh
	int	21h
	jc	errd
	push	cs
	pop	ds
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv
	mov	ax,0A000h
	mov	es,ax
ml6:	mov	ds,cs:svsg
	mov	bx,cs:cpge
	inc	cs:cpge
	cmp	bx,ds:[0004h]
	jae	mqq
	shl	bx,3
	mov	ebx,[bx]+8
	mov	si,bx
	and	si,0Fh
	shr	ebx,4
	mov	ax,ds
	add	ax,bx
	mov	ds,ax
	add	si,4
	lodsw
	xchg	ax,bx
	lodsw
	xchg	ax,dx
	lodsd
	cmp	eax,7FFF0000h
	jge	mnp
	add	ax,dx
	push	ax
	lodsd
	xchg	ebx,eax
	add	ax,bx
	mov	dx,320
	mul	dx
	pop	di
	lea	di,[eax][edi]
	lodsd
	lodsd
	inc	eax
	sub	eax,ebx
	jle	mnp
mws:	push	ax
	push	di
mwl:	lodsb
	shr	al,1
	ja	mw1
	jnz	mw2
	jnc	mw3
	lodsb
	mov	ah,0
	add	di,ax
	jmp	short mwl
mw1:	movzx	cx,al
	lodsb
	rep	stosb
	jmp	short mwl
mw2:	movzx	cx,al
	rep	movsb
	jmp	short mwl
mw3:	pop	di
	pop	ax
	add	di,320
	dec	ax
	jnz	mws
mnp:	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	xor	di,di
	mov	cx,7D00h
	mov	ax,di
	rep	stosw
	jmp	ml6
mqq:	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd:	mov	dx,offset derr
	jmp	short mx1
errv:	mov	ax,3
	int	10h
	mov	dx,offset aerr
	jmp	short mx1
pbuf	db	0,0,0,62,61,63,59,58,60,56,55,57,57,56,58,53,52,54,50,49,51,48,47,49
	db	48,47,49,47,47,48,44,44,45,44,43,44,42,41,42,39,39,40,39,38,39,36,35,37
	db	35,34,35,33,33,34,30,30,31,27,27,28,26,25,26,24,24,25,22,21,22,21,21,22
	db	19,18,19,17,17,17,16,16,16,14,14,15,13,13,13,12,12,13,10,10,10,9,9,10
	db	7,7,8,5,4,5,4,4,4,2,2,2,0,0,0,28,43,45,20,36,39,13,29,33
	db	8,22,27,4,15,21,1,10,15,23,35,12,15,29,7,8,24,3,2,18,1,0,13,0
	db	18,6,25,13,3,19,9,1,13,5,0,8,17,13,34,12,8,28,8,3,21,4,1,15
	db	2,0,9,46,32,43,40,24,36,34,17,30,28,12,24,22,7,18,16,3,13,11,1,8
	db	59,55,52,56,51,47,52,47,43,49,44,39,46,40,35,43,37,31,40,33,28,37,30,24
	db	34,27,22,31,24,19,28,21,16,25,19,13,22,16,11,19,14,9,16,11,6,13,9,5
	db	41,33,48,34,24,42,23,29,47,17,24,43,12,19,39,8,14,35,4,11,31,1,7,27
	db	0,5,24,8,6,2,55,40,26,51,34,20,47,28,15,43,23,10,39,18,6,35,14,3
	db	33,21,17,30,20,14,28,19,11,26,19,9,22,16,7,18,13,6,14,11,4,10,8,3
	db	46,21,3,41,16,2,36,12,1,31,8,1,26,5,0,21,3,0,16,1,0,4,0,0
	db	63,63,36,63,59,31,63,54,26,63,47,21,63,40,17,63,31,12,63,22,7,63,11,3
	db	63,0,0,54,0,0,45,0,0,36,0,0,28,0,0,19,0,0,10,0,0,2,0,0
	db	0,2,0,0,6,0,2,11,0,5,15,1,8,20,3,13,24,6,18,29,9,23,33,12
	db	29,38,16,35,42,21,42,47,26,51,46,24,45,41,17,38,36,11,32,30,7,25,25,3
	db	19,19,1,56,35,9,54,30,6,52,26,4,52,21,3,41,19,1,31,17,0,28,13,0
	db	25,10,0,23,8,0,20,6,0,18,4,0,15,2,0,13,1,0,41,40,34,37,36,30
	db	33,33,26,30,29,23,26,26,20,23,22,17,19,19,13,15,15,11,12,12,8,57,50,37
	db	54,47,34,51,44,32,48,41,30,45,38,28,42,35,26,40,33,24,37,30,22,34,27,20
	db	31,25,18,29,23,16,60,63,59,53,57,49,47,52,41,43,47,33,41,42,26,37,36,20
	db	33,31,16,30,26,13,29,24,12,28,22,11,27,20,10,29,23,26,26,20,23,24,18,20
	db	21,16,17,19,14,15,16,12,12,14,10,10,11,8,8,9,6,6,60,63,43,52,57,34
	db	43,52,27,35,46,20,27,40,15,19,35,10,12,29,6,6,24,2,2,18,1,0,13,0
	db	63,43,49,56,33,38,49,24,28,43,17,19,36,11,11,30,7,6,62,54,37,58,47,25
	db	54,42,14,51,37,5,49,49,42,41,39,32,32,30,23,24,21,15,15,12,8,7,5,3
	db	52,63,63,47,61,63,42,60,63,37,57,63,32,53,63,27,49,63,22,44,63,17,39,63
	db	19,30,61,22,24,58,29,24,56,36,26,54,42,28,52,46,29,50,48,31,48,63,63,63
	db	1,12,0,0,9,0,0,8,0,13,9,5,12,7,3,11,5,2,10,4,1,9,2,0
	db	8,1,1,6,0,0,7,1,7,4,2,2,9,9,9,11,11,11,14,14,14,63,63,63
wjcp	db	'Thunderscape .SHP files viewer',13,10
	db	'Copyright (C) 1997 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:TSHPVIEW filename.SHP [palette_name]',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
cpge	dw	0
nam	dw	?
pal	dw	?
svsg	dw	?
tmw	dw	?
stk	db	1024 dup(?)
fbuf	equ	this byte
cseg	ends
end	start
