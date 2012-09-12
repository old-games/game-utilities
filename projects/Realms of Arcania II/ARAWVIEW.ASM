cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include	parse.asm
	.286
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	nam
	mov	ax,3D00h
	mov	dx,nam
	int	21h
	jc	mx
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	xor	dx,dx
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,0FFFFh
	int	21h
	jc	errd
	mov	ah,3Eh
	int	21h
	jc	errd
	push	ds
	pop	es
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,ds:[0024h]
	mov	si,cx
	add	si,cx
	add	si,cx
	mov	dx,26h
	add	si,dx
	int	10h
	jc	errv
	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	mov	bx,ds:[0020h]
	inc	bx
	mov	dx,ds:[0022h]
	inc	dx
mds1:	push	di
	mov	cx,bx
	rep	movsb
	pop	di
	add	di,320
	dec	dx
	jnz	mds1
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
errd:	mov	dx,offset derr
	jmp	short mx1
errv:	mov	ax,3
	int	10h
	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Realms of Arkania II .RAW files viewer',13,10
	db	'Copyright (C) 1997 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:ARAWVIEW filename.RAW',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
nam	dw	?
cseg	ends
end	start
