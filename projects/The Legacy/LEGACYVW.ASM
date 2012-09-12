cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.386
	include parse.asm
	org	100h
start:	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	idx
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
m1a:	cmp	dx,5016
	jbe	m1b
	mov	dx,5016
m1b:	mov	nmr,dx
m1:	mov	ax,3D00h
	mov	dx,offset res
	int	21h
	jc	mqq
	mov	hdl,ax
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,5017*4
	mov	dx,offset hdc
	int	21h
	jc	mq
	mov	ax,13h
	int	10h
m2:	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	mov	cx,32000
	xor	ax,ax
	rep	stosw
	push	cs
	pop	es
	mov	bx,nmr
	cmp	bx,5017
	jae	mq1
	inc	nmr
	shl	bx,2
	mov	dx,word ptr hdc[bx]
	mov	cx,word ptr hdc[bx]+2
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	mov	ah,3Fh
	mov	dx,offset phdr
	mov	cx,phlen
	int	21h
	mov	ah,3Fh
	mov	dx,offset tpal
	mov	cx,colcnt
	shl	cx,2
	int	21h
	mov	cx,colcnt
	mov	si,dx
	mov	di,offset pal
palc:	lodsd
	shr	eax,2
	and	eax,3F3F3Fh
	stosd
	dec	di
	loop	palc
	mov	ax,1012h
	xor	bx,bx
	mov	cx,colcnt
	mov	dx,offset pal
	int	10h
	mov	dx,word ptr bdyoff
	mov	cx,word ptr bdyoff+2
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	mov	dx,offset bcnt
	mov	cx,2
	mov	ah,3Fh
	int	21h
	mov	cx,bcnt
	test	cx,cx
	jz	mbmp1	;if bitmap
	shl	cx,2
	mov	dx,offset blks
	mov	ah,3Fh
	int	21h
mbmp1:	mov	cx,maxbdy
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	ah,3Fh
	int	21h	;read body (or some more if compressed)
	mov	ax,0A000h
	mov	es,ax
	cmp	cs:bcnt,0
	je	mbmp
	cmp	cs:bpp,4
	je	mcmp4
mcmp8:	xor	ecx,ecx
	mov	cx,offset blks
	xor	si,si
	xor	bp,bp
	mov	di,bp
	mov	dx,cs:wid
	mov	bx,cs:heig
mnxbl:	dec	cs:bcnt
	js	mki0	
mwrbl:	mov	ax,cs:[ecx]
	add	cx,2
ml1c:	dec	ax
	js	mskbl
	mov	bh,[si]
	inc	si
	test	bh,bh
	jz	msk1e
	mov	es:[di],bh
msk1e:	add	di,4
	cmp	di,dx
	jb	ml1c
	add	dx,320
	mov	di,dx
	sub	di,cs:wid
	add	di,bp
	dec	bl	;as heig<=200
	jnz	ml1c
	inc	bp
	cmp	bp,4
	jae	mki0
	mov	di,bp
	mov	dx,cs:wid
	mov	bx,cs:heig
	jmp	short ml1c
mskbl:	mov	ax,cs:[ecx]
	add	cx,2
	lea	di,[edi][eax*4]
ml1b:	cmp	di,dx
	jb	mnxbl
	sub	di,dx
	and	di,-4
	dec	bl	;as heig<=200
	jz	mnl1b
	add	dx,320
	add	di,dx
	sub	di,cs:wid
	add	di,bp
	jmp	short ml1b
mnl1b:	inc	bp
	cmp	bp,4
	jae	mki0
	add	di,bp
	mov	dx,cs:wid
	mov	bx,cs:heig
	jmp	short ml1b
mcmp4:	xor	ecx,ecx
	mov	cx,offset blks
	xor	si,si
	xor	di,di
	mov	dx,cs:wid
	mov	bx,cs:heig
mnxbl1:	dec	cs:bcnt
	js	mki0
	mov	bp,cs:[ecx]
	add	cx,2
ml1d:	dec	bp
	js	mskbl1
	lodsb
	mov	ah,al
	shr	al,4
	jz	msk1c
	mov	es:[di],al
msk1c:	inc	di
	cmp	di,dx
	jae	mnl1d
	mov	al,ah
	and	al,0Fh
	jz	msk1d
	mov	es:[di],al
msk1d:	inc	di
	cmp	di,dx
	jb	ml1d
mnl1d:	add	dx,320
	mov	di,dx
	sub	di,cs:wid
	dec	bx
	jnz	ml1d
	jmp	mki0
mskbl1:	mov	bp,cs:[ecx]
	add	cx,2
	add	bp,bp
	add	di,bp
ml1e:	cmp	di,dx
	jb	mnxbl1
	dec	bx
	jz	mki0
	sub	di,dx
	and	di,-2
	add	dx,320
	add	di,dx
	sub	di,cs:wid
	jmp	short ml1e
mbmp:	cmp	cs:bpp,4
	je	mbmp4
mbmp8:	xor	si,si
	xor	bp,bp
ml3:	mov	di,bp
	mov	dx,cs:wid
	mov	bx,cs:heig
	cmp	dx,bp
	jbe	mki0
ml1:	lodsb
	test	al,al
	jz	msk1
	mov	es:[di],al
msk1:	add	di,4
	cmp	di,dx
	jb	ml1
	add	dx,320
	mov	di,dx
	sub	di,cs:wid
	add	di,bp
	dec	bx
	jnz	ml1
	inc	bp
	cmp	bp,4
	jb	ml3
	jmp	mki0
mbmp4:	xor	si,si
	xor	di,di
	mov	dx,cs:wid
	mov	bx,cs:heig
ml1a:	lodsb
	mov	ah,al
	shr	al,4
	jz	msk1a
	mov	es:[di],al
msk1a:	inc	di
	cmp	di,dx
	jae	mnl1
	mov	al,ah
	and	al,0Fh
	jz	msk1b
	mov	es:[di],al
msk1b:	inc	di
	cmp	di,dx
	jb	ml1a
mnl1:	add	dx,320
	mov	di,dx
	sub	di,cs:wid
	dec	bx
	jnz	ml1a
	jmp	mki0
mki0:	push	cs
	push	cs
	pop	ds
	pop	es
mki:	mov	ah,0
	int	16h
	cmp	al,27
	je	mq1
	cmp	al,0
	jne	mki
	mov	al,ah
	cmp	al,72
	jne	mkr3
	sub	nmr,2
	jns	m2
	mov	nmr,0
	jmp	m2
mkr3:	cmp	al,80
	je	m2
mkr4:	cmp	al,59
	jne	mki
	mov	ax,nmr
	dec	ax
	cwd
	mov	di,offset tmstr
	mov	bx,10
	div	bx
	mov	dh,dl
	div	bl
	mov	dl,ah
	aam
	xchg	al,ah
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
mq1:	mov	ax,3
	int	10h
mq:	mov	ah,3Eh
	mov	bx,cs:hdl
	int	21h
mqq:	int	20h
res	db	'wmcc.mcc',0
nme	db	'The Legacy resource viewer',13,10
	db	'(C) 2000 by White Jaguar',13,10,'$'
perr	db	'Usage: LEGACYVW [sprite index]',13,10
	db	'File "WMCC.MCC" must be in the current directory',13,10
	db	'Internal keys: F1 - display current sprite index,',13,10
	db	'               Down/Up - next/previous sprite.',13,10,'$'
	evendata
nmr	dw	0
idx	dw	?
hdl	dw	?
hdc	dd	5017 dup(?)
tpal	db	256*4 dup(?)
pal	db	768 dup(?),?
phdr	equ	$
bdyoff	dd	?
shit1	dw	?
wid	dw	?
heig	dw	?
bpp	dw	?
slen	dw	?
maxbdy	dw	?
shit2	dd	?
colcnt	dw	?
phlen	equ	$-phdr
bcnt	dw	?
blks	dw	1000*2 dup(?)
tmstr	db	4 dup(?)
cseg	ends
end	start