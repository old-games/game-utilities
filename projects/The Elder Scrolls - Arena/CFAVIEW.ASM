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
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	jc	errd1
	mov	ah,3Eh
	int	21h
	mov	si,0Ch
	movzx	cx,byte ptr ds:[0Bh]
	mov	ax,ds:[2]
	mul	word ptr ds:[4]
	mov	bx,ax
nxp:	push	cx
	push	si
	push	bx
	mov	si,[si]
	mov	ax,ds
	add	ax,1000h
	mov	es,ax
	xor	di,di
mblp:	lodsb
	mov	cl,al
	and	cx,7Fh
	inc	cx
	test	al,al
	jns	mbc
	lodsb
	rep	stosb
	jmp	short mbl
mbc:	rep	movsb
mbl:	cmp	di,bx
	jb	mblp
	push	es
	pop	fs
	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	mov	si,di
	mov	dx,ds:[2]
	mov	bp,ds:[0]
	mov	cl,ds:[0Ah]
	cmp	cl,8
	jne	bshift
	mov	bx,bp
mpl2:	mov	cx,bx
mpl1:	segfs
	lodsb
	test	al,al
	jz	mskp1
	mov	es:[di],al
mskp1:	inc	di
	loop	mpl1
	sub	di,bx
	add	di,320
	dec	dx
	jnz	mpl2
	jmp	mkb
bshift:	mov	cs:bitcnt1,cl
	mov	cs:bitcnt2,cl
	mov	ax,1
	shl	ax,cl
	dec	ax
	mov	cs:bitmsk,al
	xor	ebx,ebx
mpl:	mov	cl,bl
	and	cl,7
	ror	ebx,3
	mov	ax,fs:[bx]
	xchg	ah,al
	shl	ax,cl
	rol	ax,6
bitcnt1	equ	this byte-1
	and	al,3Fh
bitmsk	equ	this byte-1
	jz	mskp
	movzx	eax,al
	mov	al,ds:[4Ch][eax]
	mov	es:[di],al
mskp:	inc	di
	rol	ebx,3
	add	ebx,6
bitcnt2	equ	this byte-1
	cmp	di,bp
	jb	mpl
	sub	di,ds:[0]
	add	di,320
	add	bp,320
	add	ebx,7
	and	ebx,-8
	dec	dx
	jnz	mpl
mkb:	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
	pop	bx
	pop	si
	pop	cx
	add	si,2
	loop	nxpp
mqq:	mov	ax,3
	int	10h
	int	20h
nxpp:	jmp	nxp
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
wjcp	db	'The Arena .CFA files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:CFAVIEW filename.CFA filename.PAL',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-repaint screen & show next,',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	300h dup(?)
cseg	ends
end	start
