cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.286
	include parse.asm
	org	100h
start:	mov	sp,offset len
	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	pnm,idx
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
m1:	mov	ax,3D00h
	mov	dx,offset res
	int	21h
	jc	mq
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,1804h
	mov	dx,offset hdc
	int	21h
	jc	mq
	mov	hdl,bx
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pal
	int	10h
	mov	dx,offset len+15
	shr	dx,4
	mov	ax,ds
	add	ax,dx
	mov	bfseg,ax
m2:	mov	bx,nmr
	cmp	bx,hdc
	jb	m2aa
	jmp	mq1
m2aa:	inc	nmr
	shl	bx,2
	mov	dx,hdr[bx]
	mov	cx,hdr[bx]+2
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	push	dx
	push	ax
	mov	ah,3Fh
	mov	cx,5
	mov	dx,offset id
	int	21h
	pop	dx
	pop	cx
	cmp	id,4845h	;'EH'
	je	mnq1
;	jmp	mq1
mnq1:	cmp	typ,1		;needs to solve type 1
	je	mn2
	cmp	typ,2
	jne	m2
mn2:	cmp	cnt,7
	jb	m2
	add	dx,cnt
	adc	cx,0
	sub	dx,2
	sbb	cx,0
	mov	ax,4200h
	int	21h
	push	ax
	mov	ah,3Fh
	mov	cx,7
	mov	dx,offset strs
	int	21h
	pop	ax
	add	ax,7
	cmp	mde,3
	jne	m2
	mov	dl,cnt1
	mov	dh,0
	cmp	dx,1
	jne	mw1
	xchg	dx,strs
mw1:	mov	scn,dx
	mov	tcn,dx
	mov	dx,strs
	mov	strs1,dx
	and	ax,3FFh
	mov	cx,400h
	sub	cx,ax
	mov	dx,offset buf
	mov	ah,3Fh
	int	21h
	mov	bcn,ax
	mov	bof,0
	mov	al,cnt2
	mov	ah,0
	shl	ax,3
	mov	sln,ax
	mov	sln1,ax
	mov	es,bfseg
	xor	di,di
	mov	ax,di
	mov	cx,32000
	rep	stosw
	push	cs
	pop	es
	mov	di,offset lz
	mov	cx,0FEEh
	mov	lof,cx
	mov	al,0FEh
	rep	stosb
	xor	si,si
	mov	di,si
	mov	sof,si
m4:	test	si,100h
	jnz	m5
	call	bget
	mov	ah,0FFh
	mov	si,ax
m5:	shr	si,1
	jnc	m6
	call	bget
	call	bput
	jmp	m4
m6:	call	bget
	push	ax
	call	bget
	mov	cx,ax
	pop	ax
	mov	dx,cx
	and	dx,0F0h
	shl	dx,4
	mov	dl,al
	and	cx,0Fh
	add	cx,3
m8:	mov	bx,dx
	mov	al,lz[bx]
	inc	dx
	and	dx,0FFFh
	call	bput
	loop	m8
	jmp	m4
mw:	pop	ax
	mov	cpk,0
mws:	call	pout
mki:	push	cs
	pop	es
	mov	ah,0
	int	16h
	cmp	al,27
	jne	mnx1
	jmp	mq1
mnx1:	cmp	al,0
	jne	mki
	mov	al,ah
	cmp	al,75
	jne	mkr1
	mov	ax,cpk
	dec	ax
	js	mki
mkw:	mov	cpk,ax
	jmp	short mws
mkr1:	cmp	al,77
	jne	mkr2
	mov	ax,cpk
	inc	ax
	cmp	ax,strs
	jb	mkw
	jmp	short mki
mkr2:	cmp	al,72
	jne	mkr3
	sub	nmr,2
	jns	m2g
	mov	nmr,0
	jmp	short m2g
mkr3:	cmp	al,80
	jne	mkr4
m2g:	jmp	m2
mkr4:	cmp	al,59
	jne	mki
	mov	ax,nmr
	dec	ax
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
	stosw
	mov	ax,dx
	stosw
	mov	al,'/'
	stosb
	mov	ax,cpk
	aam
	mov	dl,al
	mov	al,ah
	aam
	xchg	al,ah
	add	ax,bx
	add	dl,bl
	stosw
	mov	al,dl
	mov	ah,'/'
	stosw
	mov	ax,strs
	aam
	mov	dl,al
	mov	al,ah
	aam
	xchg	al,ah
	add	ax,bx
	add	dl,bl
	stosw
	mov	al,dl
	stosb
	mov	ax,1300h
	mov	bx,0FFh
	mov	cx,12
	mov	dx,181Bh
	lea	bp,[di]-12
	mov	di,bp
	int	10h
	mov	ah,0
	int	16h
	mov	bp,di
	mov	al,219
	rep	stosb
	mov	cl,12
	mov	bl,0
	mov	ax,1300h
	int	10h
	jmp	mki
bget:	dec	bcn
	jns	m3
	mov	ah,3Fh
	mov	cx,400h
	mov	dx,offset buf
	mov	bx,hdl
	int	21h
	dec	ax
	mov	bcn,ax
	mov	bof,0
m3:	mov	bx,bof
	inc	bof
	mov	al,buf[bx]
	retn
bput:	cmp	trp,0FFh
	je	m9
	cmp	trp,al
	je	m10
m9:	mov	es,bfseg
	stosb
	push	cs
	pop	es
	dec	di
m10:	inc	di
	cmp	di,sln1
	jb	m7
	mov	bx,sln
	add	sln1,bx
	dec	tcn
	jnz	m7
	dec	strs1
	jnz	mnnw
	jmp	mw
mnnw:	mov	bx,scn
	mov	tcn,bx
m7:	mov	bx,lof
	mov	lz[bx],al
	inc	bx
	and	bx,0FFFh
	mov	lof,bx
	retn
pout:	mov	ax,scn
	mov	cx,ax
	mul	cpk
	mul	sln
	mov	si,ax
	mov	ds,bfseg
	mov	ax,0A000h
	mov	es,ax
	xor	bx,bx
	mov	di,bx
	mov	dx,cx
	mov	ax,bx
	mov	cx,32000
	rep	stosw
mil:	mov	di,bx
	mov	cx,cs:sln
	rep	movsb
	add	bx,320
	dec	dx
	jnz	mil
	push	cs
	pop	ds
	retn
res	db	'resource',0
nme	db	'The Summoning resource viewer',13,10
	db	'(C) 1996 by White Jaguar',13,10,'$'
perr	db	'Usage: SUMVIEW filename.PAL [sprite index]',13,10
	db	'File "RESOURCE." must be in the current directory',13,10
	db	'Internal keys: F1 - display current sprite index,',13,10
	db	'               Right/Left - next/previous sprite phase,',13,10
	db	'               Down/Up - next/previous sprite.',13,10,'$'
nmr	dw	0
pnm	dw	?
idx	dw	?
bfseg	dw	?
tmstr	db	12 dup(?)
pal	db	768 dup(?)
hdl	dw	?
hdc	dw	?,?
hdr	dw	0C00h dup(?)
buf	db	400h dup(?)
lz	db	1000h dup(?)
bcn	dw	?
bof	dw	?
lof	dw	?
id	dw	?
typ	db	?
cnt	dw	?
strs	dw	?
cnt1	db	?
cnt2	db	?
trp	db	?
mde	db	?
fill	db	?
sln	dw	?
sln1	dw	?
sof	dw	?
scn	dw	?
tcn	dw	?
strs1	dw	?
cpk	dw	?
stk	dw	512 dup(?)
len	equ	$
cseg	ends
end	start