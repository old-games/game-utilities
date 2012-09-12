cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.386
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
	or	dx,dx
	jz	m1b
	int	21h
	jc	errd
	xchg	ax,bx
	mov	dx,offset pbuf
	mov	cx,800
	mov	ah,3Fh
	int	21h
	jc	errd0
	mov	cx,ax
	mov	si,dx
	mov	di,offset pal0
	cmp	cx,768
	je	mpm
	sub	cx,3
	lodsb
	test	al,al
	jnz	errd0
	lodsw
	cmp	cx,768
	jne	mp1
	cmp	ax,0
	jne	errd0
	jmp	short mpm
mp1:	cmp	cx,192
	jne	errd0
	cmp	ah,40h
	jne	errd0
	cmp	al,0C0h
	ja	errd0
	mov	ah,0
	lea	ax,[eax][2*eax]
	add	di,ax
mpm:	shr	cx,1
	rep	movsw
	mov	ah,3Eh
	int	21h
m1b:	mov	ax,3D00h
	mov	dx,svn1
	test	dx,dx
	jz	mx0
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ax,ds
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	ah,3Fh
	mov	cx,0FFFFh
	int	21h
	jc	errd0
	push	ax
	mov	ah,3Eh
	int	21h
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pal0
	int	10h
	jc	errv0
	pop	ax
	cmp	ax,20002
	jne	mdn1
	cmp	word ptr ds:[0],200
	je	m_pln
mdn1:	mov	ax,ds:[0]
	mov	bx,ds:[2]
	lea	cx,[eax][ebx]
	test	cx,cx
	jz	mq
	cmp	ax,320
	ja	mq
	cmp	bx,200
	ja	mq
	cmp	bx,0
	je	m_rol
	cmp	byte ptr ds:[5],0
	jne	m_del
	cmp	byte ptr ds:[7],0
	je	m_stp
	jmp	mq
m_pln:	mov	si,2
	mov	bx,200
	mov	dx,100
mpout:	mov	ax,0A000h
	mov	es,ax
	xor	di,di
m_p1:	mov	cx,bx
	rep	movsb
	sub	di,bx
	add	di,320
	dec	dx
	jnz	m_p1
	jmp	mx
m_rol:	xor	si,si
	mov	bp,[si]
	mov	cs:mqa,offset m_rl
m_r0:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	push	si
	mov	si,[si]
	jmp	m_s0
m_rl:	pop	si
	add	si,4
	cmp	si,bp
	jb	m_r0
	jmp	mq
m_del:	xor	si,si
	call	init1p
m_d00:	xor	ax,ax
m_d0:	cmp	di,dx
	jae	m_sx
	lodsb
	shr	al,1
	jc	m_d1
	shr	al,1
	mov	cx,ax
	jc	m_d2
	lodsb
	stosb
	mov	ah,al
	xor	bx,bx
	loop	m_d3
	jmp	short m_d00
m_d5:	mov	al,bh
	shl	bx,4
	jnz	m_d4
m_d3:	lodsb
	shrd	bx,ax,4
	or	bh,1
m_d4:	sar	al,4
	add	al,ah
	stosb
	mov	ah,al
	loop	m_d5
	jmp	short m_d00
m_d2:	jcxz	m_d6
	add	di,cx
	jmp	short m_d0
m_d6:	lodsb	
	add	di,ax
	jmp	short m_d0
m_d1:	shr	al,1
	mov	cx,ax
	jc	m_d7
	lodsb
	rep	stosb
	jmp	short m_d0
m_d7:	movsb
	jmp	short m_d0
m_stp:	xor	si,si
m_s0:	call	init1p
	add	si,4
m_s1:	cmp	di,dx
	jae	m_sx
	lodsb
	test	al,0C0h
	jns	m_s2
	and	ax,7Fh
	add	di,ax
	jmp	short m_s1
m_s2:	jz	m_s3
	and	ax,3Fh
	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short m_s1
m_s3:	mov	cx,ax
	rep	movsb
	jmp	short m_s1
m_sx:	push	es
	pop	ds
	pop	bx
	pop	dx
	xor	si,si
	jmp	mpout
init1p:	pop	cx
	mov	ax,ds
	add	ax,1000h
	mov	es,ax
	xor	di,di
	lodsw
	mov	bx,ax
	lodsw
	push	ax
	push	bx
	mul	bx
	mov	dx,ax
	push	cx
	mov	cx,ax
	xor	ax,ax
	shr	cx,1
	adc	cx,0
	rep	stosw
	xor	di,di
	retn
mx:	mov	ah,0
	int	16h
	jmp	cs:mqa
mq:	mov	ax,3
	int	10h
	int	20h
mqa	dw	offset mq
mx0:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd0:	mov	ah,3Eh
	int	21h
	push	cs
	pop	ds
errd:	mov	dx,offset derr
	jmp	short mx1
errv0:	mov	ax,3
	int	10h
errv:	push	cs
	pop	ds
	mov	dx,offset aerr
	jmp	short mx1
pal0	db	 0, 0, 0, 0, 0,42, 0,42, 0, 0,42,42,42, 0, 0,36, 0,42,42,21, 0
	db	42,42,42,21,21,21,21,21,63,21,63,21,21,63,63,63,21,21,59,23,63
	db	63,63,21,63,63,63,58,58,58,54,54,54,51,51,51,47,47,47,44,44,44
	db	41,41,41,37,37,37,34,34,34,30,30,30,27,27,27,24,24,24,20,20,20
	db	17,17,17,13,13,13,10,10,10, 7, 7, 7,63,63, 0,48,39, 0,33,21, 0
	db	19, 8, 0,63,31, 0,48,21, 0,34,12, 0,20, 6, 0,63, 0, 0,49, 0, 0
	db	35, 0, 0,21, 0, 0,42,21, 0,29,13, 0,17, 6, 0, 5, 1, 0, 0,63, 0
	db	 0,47, 0, 0,31, 0, 0,15, 0, 0, 0,63, 0, 0,47, 0, 0,31, 0, 0,15
	db	55, 0,63,37, 0,48,22, 0,34,11, 0,20, 0,63,63, 0,47,47, 0,31,31
	db	 0,15,15, 0, 0,47,30,30,30,12,12,12,50, 0, 0,63,63,31,55,63,31
	db	47,63,31,39,63,31,31,63,31,31,63,39,31,63,47,31,63,55,31,63,63
	db	31,55,63,31,47,63,31,39,63,45,45,63,49,45,63,54,45,63,58,45,63
	db	63,45,63,63,45,58,63,45,54,63,45,49,63,45,45,63,49,45,63,54,45
	db	63,58,45,63,63,45,58,63,45,54,63,45,49,63,45,45,63,45,45,63,49
	db	45,63,54,45,63,58,45,63,63,45,58,63,45,54,63,45,49,63, 0, 0,28
	db	 7, 0,28,14, 0,28,21, 0,28,28, 0,28,28, 0,21,28, 0,14,28, 0, 7
	db	28, 0, 0,28, 7, 0,28,14, 0,28,21, 0,28,28, 0,21,28, 0,14,28, 0
	db	 7,28, 0, 0,28, 0, 0,28, 7, 0,28,14, 0,28,21, 0,28,28, 0,21,28
	db	 0,14,28, 0, 7,28,13,29,45,12,27,44,10,24,43, 9,22,42, 8,20,41
	db	 7,18,40, 6,16,39, 5,14,39, 4,12,38, 3,10,37, 2, 8,36, 2, 6,35
	db	 1, 4,34, 0, 2,33, 0, 1,32, 0, 0,32,50,46,31,47,44,27,45,43,23
	db	42,42,20,38,40,17,34,37,14,30,35,11,26,32, 9,22,30, 7,23,29, 7
	db	24,27, 6,24,26, 6,25,25, 6,23,22, 6,22,19, 6,21,17, 6,63,63,63
	db	58,58,58,54,54,54,50,50,50,46,46,46,41,41,41,37,37,37,33,33,33
	db	29,29,29,24,24,24,20,20,20,16,16,16,12,12,12, 7, 7, 7, 3, 3, 3
	db	 0, 0, 0,59,59,59,51,54,57,43,49,55,36,45,53,30,40,51,24,36,49
	db	18,32,47,13,29,45,54,58,50,51,56,46,48,55,42,46,53,38,43,52,35
	db	40,50,31,38,49,28,36,48,25,21,21,21,18,18,18,14,14,14,11,11,11
	db	 8, 8, 8, 5, 5, 5, 2, 2, 2, 0, 0, 0,19,19,56,15,15,53,12,12,50
	db	 8, 8,47, 6, 6,45, 3, 3,42, 1, 1,39, 0, 0,37,27,58,27,22,55,22
	db	17,52,17,12,49,12, 8,46, 8, 5,43, 5, 1,40, 1, 0,38, 0,24,55,55
	db	22,52,52,19,49,49,17,47,47,16,44,44,14,42,42,12,39,39,11,37,37
	db	63,21,21,60,16,16,57,13,13,54, 9, 9,51, 6, 6,48, 3, 3,45, 1, 1
	db	42, 0, 0,46,17,50,45,16,48,44,15,46,43,15,44,42,14,42,40,13,39
	db	38,12,36,36,12,34,57,57,26,55,55,21,52,53,17,50,51,13,48,49, 9
	db	46,47, 5,44,45, 2,40,42, 0,63,63,63,57,57,57,52,52,52,47,47,47
	db	42,42,42,37,37,37,32,32,32,27,27,27
wjcp	db	'Project Nomad graphics viewer',13,10
	db	'Copyright (C) 1996,2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:NOMADVW picfile [palette.PAL]',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	800 dup(?)
cseg	ends
end	start
