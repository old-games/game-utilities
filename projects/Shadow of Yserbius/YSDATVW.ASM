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
	mov	cx,1024
	int	21h
	jc	mq
	mov	ax,4202h
	xor	dx,dx
	mov	cx,dx
	int	21h
	mov	word ptr fsz+2,dx
	mov	word ptr fsz,ax
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
	cmp	bx,256
	jb	mw0
	jmp	mq1
mw0:	mov	si,bx
	shl	si,2
	les	dx,cs:hdr[si]
	mov	di,es
	and	di,dx
	inc	di
	jz	mlp
	mov	cx,es
mww:	add	si,4
	les	ax,cs:hdr[si]
	mov	di,es
	and	di,ax
	inc	di
	jz	mww
	mov	si,ax
	sub	si,dx
	add	dx,1024
	adc	cx,0
	mov	ax,4200h
	mov	bx,cs:hdl
	int	21h
	mov	cx,si
	mov	ah,3Fh
	xor	dx,dx
	int	21h
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	mov	di,si
	mov	ax,si
	mov	cx,32000
	rep	stosw
	mov	di,ax
	lodsw
	mov	dx,ax
	lodsw
	mov	bx,ax
	mov	ch,0
	mov	bp,dx
mw2:	lodsb
	cmp	al,0F0h
	jb	mw1
	mov	ah,al
	shl	ah,4
	jmp	short mw2
mw1:	mov	cl,al
	shr	cl,4
	inc	cx
	and	al,0Fh
	or	al,ah
mw4:	stosb
	dec	bp
	jnz	mw3
	add	di,320
	sub	di,dx
	mov	bp,dx
	dec	bx
	jz	mki
mw3:	loop	mw4	
	jmp	short mw2
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
	mov	bx,10
	div	bl
	mov	dl,ah
	aam
	xchg	al,ah
	mov	bx,3030h
	add	ax,bx
	add	dl,bl
	stosw
	mov	al,dl
	stosb
	mov	ax,1300h
	mov	bx,0FFh
	mov	cx,3
	mov	dx,181Bh
	lea	bp,[di]-3
	mov	di,bp
	int	10h
	mov	ah,0
	int	16h
	mov	bp,di
	mov	al,219
	rep	stosb
	mov	cl,3
	mov	bl,0
	mov	ax,1300h
	int	10h
	jmp	mki
nme	db	'Shadow of Yserbius .DAT files viewer',13,10
	db	'(C) 1996 by White Jaguar',13,10,'$'
perr	db	'Usage: YSDATVW flename.DAT filename.PAL [picture index]',13,10
	db	'Internal keys: F1 - display current picture index,',13,10
	db	'               Down/Up - next/previous picture.',13,10,'$'
nmr	dw	0
fnm	dw	?
pnm	dw	?
idx	dw	?
hdl	dw	?
pal	db	768 dup(?)
hdr	dd	256 dup(?)
fsz	dd	?
tmstr	db	6 dup(?)
cseg	ends
end	start