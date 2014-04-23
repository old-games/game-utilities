cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg
	include	parse.asm
	org	100h
	.286
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
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
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	ah,3Fh
	mov	cx,0FFFFh
	int	21h
	jc	errd
	mov	ah,3Eh
	int	21h
	jc	errd
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
	xor	si,si
	xor	di,di
	lodsw
	mov	dx,ax
	lodsw
	mov	bx,ax
mvl:	mov	cx,bx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvl
	mov	ah,0
	int	16h
	mov	ax,3
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
wjcp	db	'Disciples of Steel picture viewer',13,10
	db	'Copyright (C) 1999 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:STEELVW filename.PIC filename.PAL',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
