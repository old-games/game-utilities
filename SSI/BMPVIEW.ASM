cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.386
	include	parse.asm
	org	100h
start:	mov	sp,offset fbuf-2
	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	nam,pal
	mov	ax,3D00h
	mov	dx,pal
	int	21h
	jc	mx
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jc	errd
	cmp	cx,ax
	jne	errd
	mov	ah,3Eh
	int	21h
	jc	errd
	mov	ax,3D00h
	mov	dx,nam
	int	21h
	jc	mx
	xchg	ax,bx
	mov	ax,ds
	mov	dx,offset fbuf
	shr	dx,4
	inc	dx
	add	ax,dx
	mov	svsg,ax
	xor	dx,dx
m1a:	mov	ds,ax
	mov	ah,3Fh
	mov	cx,8000h
	int	21h
	jc	errd
	cmp	ax,cx
	jne	m1d
	mov	ax,ds
	add	ax,800h
	jmp	short m1a
m1d:	mov	ah,3Eh
	int	21h
	jc	errd
	push	cs
	pop	ds
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv
	mov	ax,0A000h
	mov	es,ax
ml6:	mov	ds,cs:svsg
	mov	bx,cs:cpge
	inc	cs:cpge
	cmp	bx,ds:[0004h]
	jae	mqq
	shl	bx,2
	mov	ebx,[bx]+6
	mov	si,bx
	and	si,0Fh
	shr	ebx,4
	mov	ax,ds
	add	ax,bx
	mov	ds,ax
	lodsw
	mov	dx,ax
	lodsw
	cmp	byte ptr [si],0FFh
	jne	ml1
	cmp	dword ptr [si]+1,524E4C50h	;'PLNR'
	je	mplnr
	cmp	dword ptr [si]+1,4E414C50h	;'PLAN'
	je	mplan
ml1:	lodsb
	cmp	al,0FFh
	je	mnp
	mov	ah,al
	mov	al,0
	mov	di,ax
	shr	di,2
	add	di,ax
	mov	dx,di
	mov	cs:tmw,0
ml4:	test	cs:tmw,8000h
	jnz	ml1
	lodsw
	mov	cs:tmw,ax
	and	ax,7FFFh
	mov	di,ax
	add	di,dx
	inc	si
	lodsb
	mov	ah,0
	add	ax,si
	mov	bx,ax
ml5:	lodsb
	shr	al,1
	inc	ax
	movzx	cx,al
	jnc	ml2
	lodsb
	rep	stosb
	jmp	short ml3
ml2:	rep	movsb
ml3:	cmp	si,bx
	jae	ml4
	jmp	short ml5
mplnr:	push	dx
	mov	dx,320
	mul	dx
	mov	cs:maxof,ax
	pop	dx
	xor	bp,bp
	sub	bp,dx
	add	si,5
	lodsb
	mov	bx,si
	mov	cl,al
	mov	ax,1
	shl	ax,cl
	add	si,ax
	dec	ax
	mov	cs:bitmask,ax
	mov	cs:bitcnt,cl
	xor	cx,cx
	xor	di,di
	push	cx
mplp:	pop	cx
	call	geti
	test	al,al
	jnz	m1p
	call	geti
	test	al,al
	jz	m1p
	add	ax,2
	jmp	short mws
m1p:	xlat
	mov	ch,al
	mov	ax,1
mws:	push	cx
	xchg	ax,cx
	mov	al,ah
mws1:	add	bp,cx
	jge	mwp
mwr:	test	ax,ax
	jz	msk
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mplp
msk:	add	di,cx
	jmp	short mplp
mwp:	sub	cx,bp
	test	ax,ax
	jz	msk1
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mnxp
msk1:	add	di,cx
mnxp:	mov	cx,bp
	xor	bp,bp
	sub	bp,dx
	sub	di,dx
	add	di,320
	cmp	di,64000
maxof	equ	this word-2
	jae	mnp
	jcxz	mplp
	jmp	short mws1
mplan:	cmp	byte ptr [si]+5,0
	je	mfil
	push	dx
	mov	dx,320
	mul	dx
	mov	cs:maxof1,ax
	pop	dx
	mov	bp,dx
	add	si,5
	lodsb
	mov	bx,si
	mov	cl,al
	mov	ax,1
	shl	ax,cl
	add	si,ax
	dec	ax
	mov	cs:bitmask,ax
	mov	cs:bitcnt,cl
	xor	cx,cx
	xor	di,di
mplp1:	call	geti
	xlat
	test	al,al
	jz	msk2
	mov	es:[di],al
msk2:	inc	di
	cmp	di,bp
	jb	mplp1
	sub	di,dx
	add	di,320
	cmp	di,64000
maxof1	equ	this word-2
	jae	mnp
	add	bp,320
	jmp	short mplp1
mfil:	mov	bx,ax
	xor	di,di
	mov	al,[si]+6
	mov	ah,al
mfll:	mov	cx,dx
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	sub	di,dx
	add	di,320
	dec	bx
	jnz	mfll
mnp:	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	cmp	al,' '
	jne	ml6
	xor	di,di
	mov	cx,7D00h
	mov	ax,di
	rep	stosw
	jmp	ml6
geti:	mov	ax,[si]
	xchg	ah,al
	add	cl,0
bitcnt	equ	this byte-1
	rol	ax,cl
	and	ax,1000h
bitmask	equ	this word-2
	cmp	cl,8
	sbb	si,-1
	and	cl,7
	retn	
mqq:	mov	ax,3
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
wjcp	db	'SSI .BMP files viewer',13,10
	db	'Copyright (C) 1996,2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:BMPVIEW filename.BMP palette_name',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              SPACE-repaint screen & show next,',13,10
	db	'              other-show next w/o repainting',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
cpge	dw	0
nam	dw	?
pal	dw	?
svsg	dw	?
tmw	dw	?
pbuf	db	768 dup(?)
stk	db	1024 dup(?)
fbuf	equ	this byte
cseg	ends
end	start
