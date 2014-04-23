cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include	parse.asm
	.286
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	m1fl
	int	21h
	jnc	mnx
	jmp	mx
mnx:	xchg	ax,bx
	mov	bp,1
	jmp	short mnrm
m1fl:	mov	ax,3D00h
	mov	dx,offset fnm
	int	21h
	jnc	m1fy
	jmp	errf
m1fy:	xchg	ax,bx
	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h
	int	21h
	sub	ax,320h
	sbb	dx,0
	mov	bp,0F306h
	div	bp
	mov	bp,ax
	xor	cx,cx
	mov	dx,320h
	mov	ax,4200h
	int	21h
mnrm:	mov	ax,13h
	int	10h
	jnc	mlp
	jmp	errv
mlp:	mov	dx,offset pbuf
	mov	cx,0F306h
	mov	ah,3Fh
	int	21h
	xor	dx,dx
	sub	ax,306h
	mov	cx,0C00h
	div	cx
	test	dx,dx
	jz	ms1
	inc	ax
ms1:	push	bx
	push	ax
	mov	cx,300h
	mov	bx,offset pbuf
ml1:	shr	byte ptr [bx],2
	inc	bx
	loop	ml1
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	push	ds
	pop	es
	int	10h
	jc	errv
	mov	ax,0A000h
	mov	es,ax
	mov	si,offset fdat
	xor	di,di
	pop	dx
ml3:	mov	bx,192
ml2:	mov	cx,16/2
	rep	movsw
	add	di,320-16
	dec	bx
	jnz	ml2
	sub	di,320*192-16
	dec	dx
	jnz	ml3
	pop	bx
	mov	ah,0
	int	16h
	dec	bp
	jz	mlq
	cmp	al,27
	jne	mlp
mlq:	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
	jmp	short mx1
errf:	mov	dx,offset ferr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h
errv1:	pop	bx
errv:	mov	ax,3
	int	10h
	mov	dx,offset aerr
mx2:	mov	ah,3Eh
	int	21h
	jmp	short mx1
fnm	db	'v.mct',0
wjcp	db	'Magic Candle and Bloodstone V*.MCT files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:VMCTVIEW [filename.MCT]',13,10,'$'
ferr	db	'V.MCT not found!',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
pbuf	db	300h dup(?)
fhdr	dw	3 dup(?)
fdat	db	256*240 dup(?)
cseg	ends
end	start
