cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.286
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
	jc	errdd
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jnc	m1c
ed0:	jmp	errd0
m1c:	cmp	cx,ax
	jne	ed0
	mov	ah,3Eh
	int	21h
	jnc	m1b
errdd:	jmp	errd
m1b:	mov	ax,3D00h
	mov	dx,svn1
	test	dx,dx
	jnz	m1nx
	jmp	mx
m1nx:	int	21h
	jc	errdd
	push	ax
	mov	ax,13h
	int	10h
	jnc	m1f
	jmp	errv
m1f:	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jnc	mvn
	jmp	errv0
mvn:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	pop	bx
	mov	cx,0FFFFh
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	jnc	mlnx
mer1:	jmp	errd1
mlnx:	xor	dx,dx
	mov	bp,20*20+8
	div	bp
	mov	cx,ax
	cmp	word ptr ds:[bp],20
	je	mfc
	cmp	word ptr ds:[bp]+2,20
	jne	mfc
	add	bp,2
mfc:	mov	ah,3Eh
	int	21h
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
mvw:	lodsw
	test	ax,ax
	jz	mskp
	mov	bx,ax
	lodsw
	xor	di,di
	mov	dx,cx
ml2:	mov	cx,ax
	rep	movsb
	add	di,320
	sub	di,ax
	dec	bx
	jnz	ml2
	add	si,bp
	sub	si,20*20+4
	mov	ah,0
	int	16h
	cmp	al,27
	mov	ax,0
	mov	di,ax
	mov	cx,4800
	rep	stosw
	mov	cx,dx
	loopnz	mvw
	jmp	short mqq
mskp:	add	si,bp
	sub	si,2
	loop	mvw
mqq:	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd1:	mov	ax,3
	int	10h
errd0:	mov	ah,3Eh
	int	21h
errd:	mov	dx,offset derr
	jmp	short mx1
errv0:	mov	ax,3
	int	10h
errv:	pop	bx
	mov	ah,3Eh
	int	21h
	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Disciples of Steel smallpics file viewer',13,10
	db	'Copyright (C) 1999 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:SSMALVW filename.SML [filename.PAL]',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-show next',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup (?)
cseg	ends
end	start
