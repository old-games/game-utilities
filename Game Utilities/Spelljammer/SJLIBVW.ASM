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
	int	21h
	jc	errd
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jc	errd0
	cmp	cx,ax
	jne	errd0
	mov	ah,3Eh
	int	21h
	jc	errd
	mov	ax,3D00h
	mov	dx,svn1
	test	dx,dx
	jz	mx
	int	21h
	jc	errd
	push	ax
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
	mov	ax,0A000h
	mov	es,ax
	pop	bx
	mov	dx,offset hdr
	mov	cx,400h
	mov	ah,3Fh
	int	21h
	mov	si,dx
	cmp	dword ptr [si],400h
	jne	type1
msql:	cmp	dword ptr [si],-1
	je	mqq
	mov	dx,[si]
	mov	cx,[si]+2
	mov	ax,4200h
	int	21h
	mov	ecx,[si]+4
	sub	ecx,[si]
	cmp	ecx,0FFFFh
	jbe	m1
	mov	cx,0FFFFh
m1:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	push	si
	call	dispseq
	pop	si
	add	si,4
	push	cs
	pop	ds
	jmp	short msql
type1:	xor	cx,cx
	xor	dx,dx
	mov	ax,4200h
	int	21h
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	call	dispseq
mqq:	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	int	20h
dispseq:push	bx
	xor	si,si
	mov	bp,ax
	lodsw
	test	ax,ax
	jz	mde1
	lodsw
	cmp	ax,1
	je	mde2
	dec	si
	dec	si
mde3:	lodsw
	call	dpage
	cmp	si,bp
	jb	mde3
	jmp	short dsqx
mde1:	dec	si
	dec	si
mde2:	call	dpage
	cmp	si,bp
	jb	mde2
dsqx:	pop	bx
	retn
dpage:	add	si,4
	xor	di,di
	lodsw
	mov	bx,ax
	lodsw
	mov	dx,ax
	lodsb
	test	al,1
	jz	mvl
	mov	ah,[si]
mvlt:	mov	cx,bx
mvlt1:	lodsb
	cmp	ah,al
	je	mtskp
	mov	es:[di],al
mtskp:	inc	di
	loop	mvlt1
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvlt
	jmp	short mvx
mvl:	mov	cx,bx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvl
mvx:	mov	ah,0
	int	16h
	cmp	al,27
	jne	mnq
	pop	bx
	pop	bx
	jmp	mqq
mnq:	xor	di,di
	xor	ax,ax
	mov	cx,32000
	rep	stosw
	retn
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
wjcp	db	'Spelljammer smallpics files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:SJLIBVW filename.LIB filename.PAL',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-show next',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup (?)
hdr	dd	100h dup(?)
cseg	ends
end	start
