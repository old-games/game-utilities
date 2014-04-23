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
	mov	dx,svn1
	or	dx,dx
	jz	mx
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
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	pop	bx
	mov	ax,4202h
	xor	dx,dx
	mov	cx,dx
	int	21h
	mov	di,offset lentb
	mov	cx,(cnttb-lentb)/2
	push	cs
	pop	es
	repne	scasw
	jne	mqq
	sub	di,offset lentb+2
	shr	di,1
	push	di
	push	ax
	push	dx
	mov	ax,4200h
	xor	dx,dx
	mov	cx,dx
	int	21h
	xor	dx,dx
	pop	di
mrl:	dec	di
	js	mr1
	mov	ah,3Fh
	mov	cx,8000h
	int	21h
	mov	ax,ds
	add	ax,800h
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,8000h
	int	21h
	mov	ax,ds
	add	ax,800h
	mov	ds,ax
	jmp	short mrl
mr1:	pop	cx
	mov	ah,3Fh
	int	21h
	jc	errd1
	mov	ah,3Eh
	int	21h
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	pop	bx
	movzx	ebx,bx
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
nxp:	xor	di,di
	movzx	dx,cs:ysztb[ebx]
ml1:	mov	cx,cs:xsztb[ebx*2]
ml2:	lodsb
	test	al,al
	jz	msk
	mov	es:[di],al
msk:	inc	di
	loop	ml2
	add	di,320
	sub	di,cs:xsztb[ebx*2]
	dec	dx
	jnz	ml1
	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	dec	cs:cnttb[ebx]
	jz	mqq
	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
	cmp	si,8000h
	jb	nxp
	sub	si,8000h
	mov	ax,ds
	add	ax,800h
	mov	ds,ax
	jmp	short nxp
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
wjcp	db	'Arena .SET and like files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:SETVIEW filename.ext filename.PAL',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-repaint screen & show next,',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
lentb	dw	256,176,112,1088,475,16960,24640,11520,90,128
	dw	64,4096,576,81,3600,160000-20000h,24576,20480,16384,16383
	dw	12288,8192
cnttb	db	1,1,1,1,1,1,1,1,1,1
	db	1,1,9,9,9,5,6,5,4,4
	db	3,2
xsztb	dw	16,16,14,32,25,320,320,320,9,8
	dw	8,64,8,3,20,320,64,64,64,64
	dw	64,64
ysztb	db	16,11,8,34,19,53,77,36,10,16
	db	8,64,8,3,20,100,64,64,64,64
	db	64,64
svn1	dw	?
svn2	dw	?
pbuf	db	300h dup(?)
cseg	ends
end	start
