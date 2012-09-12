cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.286
	include parse.asm
	org	100h
start:	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	fnm,pnm,idx
	mov	ax,3D00h
	mov	dx,pnm
	int	21h
	jnc	mnx
mq:	mov	dx,offset perr
	mov	ah,9
	int	21h
	int	20h
mq1:	mov	ax,3
	int	10h
	int	20h
mnx:	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,768
	mov	dx,offset pal
	int	21h
	jc	mq
	mov	ah,3Eh
	int	21h
	jc	mq
	mov	ax,3D00h
	mov	dx,fnm
	int	21h
	jc	mq
	xchg	ax,bx
	mov	ah,3Fh
	mov	dx,offset hdr
	mov	cx,2
	int	21h
	jc	mq
	mov	ax,4202h
	xor	dx,dx
	mov	cx,dx
	int	21h
	sub	ax,word ptr hdr
	mov	hsz,ax
	mov	ax,4200h
	xor	dx,dx
	mov	cx,dx
	int	21h
	mov	cx,hsz
	mov	dx,offset hdr
	mov	ah,3Fh
	int	21h
	jc	mq
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
m1a:	mov	nmr,dx
m1:	mov	hdl,bx
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pal
	int	10h
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
mlp:	mov	bx,cs:nmr
	inc	cs:nmr
	cmp	bx,word ptr cs:hdr+4
	jb	mw0
	jmp	mq1
mw0:	mov	si,bx
	shl	si,1
	add	si,bx
	shl	si,1
	les	dx,dword ptr cs:hdr[si]+6
	mov	cx,es
	add	dx,cs:hsz
	adc	cx,0
	mov	ax,4200h
	mov	bx,cs:hdl
	int	21h
	mov	si,word ptr cs:hdr[si]+10
	mov	ax,si
	mul	ah
	mov	cx,ax
	mov	ah,3Fh
	xor	dx,dx
	int	21h
	mov	dx,si
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	mov	di,si
	mov	ax,si
	mov	cx,32000
	rep	stosw
	mov	di,ax
	mov	bl,dl
	mov	bh,0
mll1:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dh
	jnz	mll1
mki:	mov	ah,0
	int	16h
	cmp	al,27
	jne	mnx1
	jmp	mq1
mnx1:	cmp	al,0
	jne	mki
	mov	al,ah
mkr2:	cmp	al,72
	jne	mkr3
	sub	cs:nmr,2
	jns	m2g
	mov	cs:nmr,0
	jmp	short m2g
mkr3:	cmp	al,80
	jne	mkr4
m2g:	jmp	mlp
mkr4:	cmp	al,59
	jne	mki
	push	cs
	pop	es
	mov	ax,cs:nmr
	dec	ax
	mov	di,offset tmstr
	mov	bl,100
	div	bl
	mov	dl,ah
	aam
	xchg	al,ah
	xchg	ax,dx
	aam
	xchg	al,ah
	xchg	ax,dx
	mov	bx,3030h
	add	ax,bx
	add	dx,bx
	stosw
	mov	ax,dx
	stosw
	mov	ax,1300h
	mov	bx,0FFh
	mov	cx,4
	mov	dx,181Bh
	lea	bp,[di]-4
	mov	di,bp
	int	10h
	mov	ah,0
	int	16h
	mov	bp,di
	mov	al,219
	rep	stosb
	mov	cl,4
	mov	bl,0
	mov	ax,1300h
	int	10h
	jmp	mki
nme	db	'Shadow of Yserbius .TSU files viewer',13,10
	db	'(C) 1996 by White Jaguar',13,10,'$'
perr	db	'Usage: YSTSUVW flename.TSU filename.PAL [picture index]',13,10
	db	'Internal keys: F1 - display current picture index,',13,10
	db	'               Down/Up - next/previous picture.',13,10,'$'
nmr	dw	0
fnm	dw	?
pnm	dw	?
idx	dw	?
hdl	dw	?
pal	db	768 dup(?)
hdr	db	1600h dup(?)
hsz	dw	?
tmstr	db	6 dup(?)
cseg	ends
end	start