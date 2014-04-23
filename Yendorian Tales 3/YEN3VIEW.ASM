cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.386
	include parse.asm
	org	100h
start:	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	pnm,idx
	mov	ax,3D00h
	mov	dx,pnm
	int	21h
	jc	mq
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,768
	mov	dx,offset pal
	int	21h
	jc	mq
	mov	ah,3Eh
	int	21h
	mov	si,idx
	or	si,si
	jz	m1
	xor	dx,dx
	mov	ah,dl
mll:	lodsb
	or	al,al
	jz	m1a
	sub	al,30h
	jb	mq
	cmp	al,9
	ja	mq
	imul	dx,dx,10
	add	dx,ax
	jmp	short mll
m1a:	cmp	dx,acnt
	jae	mq
	mov	nmr,dx
m1:	mov	ax,3D00h
	mov	dx,offset res
	int	21h
	jc	mq
	mov	hdl,ax
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pal
	int	10h
	mov	ax,nmr
	xor	esi,esi
mfx:	add	si,2
	cmp	ax,nmrs[si]
	jae	mfx
	sub	si,2
	mov	ax,0A000h
	mov	es,ax
m22:	mov	ax,nmr
	sub	ax,nmrs[si]
	mul	szs[si]
	add	ax,word ptr ofss[esi*2]
	adc	dx,word ptr ofss[esi*2]+2
	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	mov	cx,szs[si]
	xor	dx,dx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	int	21h
	push	esi
	mov	dx,cs:yszs[si]
	mov	bx,cs:xszs[si]
	xor	si,si
	xor	di,di
ml2:	mov	cx,bx
ml1:	lodsb
	cmp	al,0FFh
	jz	msk
	mov	es:[di],al
msk:	inc	di
	loop	ml1
	sub	di,bx
	add	di,320
	dec	dx
	jnz	ml2
	pop	esi
	push	cs
	pop	ds
mki:	mov	ah,0
	int	16h
	cmp	al,27
	je	mq1
	cmp	al,0
	jne	mki
	mov	al,ah
	cmp	al,72
	jne	mkr3
	mov	ax,nmr
	dec	ax
	jns	m2a
	xor	ax,ax
m2a:	cmp	nmrs[si],ax
	jbe	m2
	sub	si,2
	jmp	short m2
mkr3:	cmp	al,80
	jne	mkr4
	mov	ax,nmr
	inc	ax
	cmp	ax,acnt
	jae	mq1
	cmp	nmrs[si+2],ax
	ja	m2
	add	si,2
m2:	mov	nmr,ax
	xor	di,di
	xor	ax,ax
	mov	cx,32000
	rep	stosw
	jmp	m22
mkr4:	cmp	al,59
	jne	mki
	mov	ax,nmr
	mov	di,offset tmstr
	mov	bx,10
	div	bl
	mov	dh,ah
	aam
	mov	dl,al
	mov	al,ah
	aam
	xchg	al,ah
	mov	bx,3030h
	add	ax,bx
	add	dx,bx
	mov	[di],ax
	mov	[di+2],dx
	mov	ax,1300h
	mov	bx,0FFh
	mov	cx,4
	mov	dx,181Bh
	mov	bp,di
	push	es
	push	cs
	pop	es
	int	10h
	mov	ah,0
	int	16h
	mov	bp,di
	mov	al,219
	mov	ah,al
	mov	[di],ax
	mov	[di+2],ax
	mov	cl,4
	mov	bl,0
	mov	ax,1300h
	int	10h
	pop	es
	jmp	mki
mq:	mov	dx,offset perr
	mov	ah,9
	int	21h
	int	20h
mq1:	mov	ax,3
	int	10h
	int	20h
res	db	'pictures.vga',0
nme	db	'Yendorian Tales 3 resource viewer',13,10
	db	'Copyright (C) 2000 by White Jaguar',13,10,'$'
perr	db	'Usage: YEN3VIEW filename.PAL [sprite index]',13,10
	db	'File "PICTURES.VGA" must be in the current directory',13,10
	db	'Internal keys: F1 - display current sprite index,',13,10
	db	'               Down/Up - next/previous sprite.',13,10,'$'
szs	dw	0F5F4h,5622h,54C4h,51A4h,40C0h,3640h,1DC0h,400h,100h,40h
xszs	dw	318,210,140,190,224,224,56,32,16,8
yszs	dw	198,105,155,110,74,62,136,32,16,8
ofss	dd	00000000h,001618ECh,004A95A4h,00A3FC5Ch,00EFE2D4h,00F6F7D4h 
	dd	00F9EF54h,010211D4h,0104E1D4h,010635D4h 
nmrs	dw	0,23,179,449,687,715,729,799,979,1319,1895
acnt	equ	1895
nmr	dw	0
pnm	dw	?
idx	dw	?
hdl	dw	?
pal	db	768 dup(?)
tmstr	db	4 dup(?)
cseg	ends
end	start