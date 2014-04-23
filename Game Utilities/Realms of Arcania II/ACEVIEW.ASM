cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.486
	org	100h
	%nolist
	include parse.asm
bytd	macro	strg
	db	0&strg&h
	endm
shftb	macro
	local	@@sh
	cmp	dh,cl
	jae	@@sh
	call	readd
@@sh:	xor	ax,ax
	shrd	ax,bp,cl
	shr	ebp,cl
	add	dl,cl
	sub	dh,cl
	xchg	al,ah
	segcs
	xlat
	endm
shftw	macro	
	local	@@sh
	cmp	dh,cl
	jae	@@sh
	call	readd
@@sh:	xor	ax,ax
	shrd	ax,bp,cl
	shr	ebp,cl
	add	dl,cl
	sub	dh,cl
	segcs
	xlat
	xchg	al,ah
	segcs
	xlat
	endm
	%list
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,pnm
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	mov	fdsc,ax
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,2000
	mov	dx,offset hdr
	int	21h
	jc	errd0
	cmp	sig,00454341h	;'ACE',0
	jne	errd0
	mov	dx,pnm
	test	dx,dx
	jz	mnpal
	mov	ax,3D00h
	int	21h
	jc	errd0
	xchg	ax,bx
	mov	dx,offset pbuf
	mov	cx,300h
	mov	ah,3Fh
	int	21h
	pushf
	mov	ah,3Eh
	int	21h
	popf
	jc	errd0
	jmp	short mvid
mnpal:	mov	cx,-1
	mov	dx,-300h
	mov	ax,4202h
	int	21h
	mov	dx,offset pbuf
	mov	cx,300h
	mov	ah,3Fh
	int	21h
mvid:	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	int	10h
	jc	errv0
	cmp	seqcnt,1
	ja	mmseqs
	mov	dx,8+6
	xor	cx,cx
	mov	bx,fdsc
	mov	ax,4200h
	int	21h
	movzx	cx,s1cnt
	call	dispseq
	jmp	mpgx
mmseqs:	movzx	cx,seqcnt
	xor	si,si
mlseq:	push	cx
	push	si
	mov	edx,s2ofs[si]
	shld	ecx,edx,16
	mov	bx,fdsc
	mov	ax,4200h
	int	21h
	movzx	cx,s2cnt[si]
	jcxz	mseqx
	call	dispseq
mseqx:	pop	si
	pop	cx
	add	si,16
	loop	mlseq
	jmp	mpgx
dispseq:push	cx
	mov	dx,offset pichdr
	mov	cx,0Eh
	mov	bx,fdsc
	mov	ah,3Fh
	int	21h
	mov	cx,word ptr picsz
	xor	dx,dx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	mov	ah,3Fh
	int	21h
	mov	al,cs:piccomp
	mov	dx,offset unlz
	cmp	al,50
	je	do_unp
	mov	bx,cs:picwid
	imul	bx,cs:picheig
	xor	si,si
	mov	di,si
	mov	dx,offset unrle
	cmp	al,1
	je	do_unp
	mov	dx,offset unblk
	cmp	al,2
	jne	no_unp
do_unp:	call	dx
	push	es
	pop	ds
no_unp:	mov	ax,cs:picdy
	mov	bx,320
	mul	bx
	add	ax,cs:picdx
	mov	di,ax
	mov	bx,cs:picwid
	mov	dx,cs:picheig
	call	disppic
	push	cs
	pop	ds
	pop	cx
	loop	dispseq
	retn
disppic:mov	ax,0A000h
	mov	es,ax
	push	di
	xor	di,di
	xor	ax,ax
	mov	cx,32000
	rep	stosw
	pop	di
	xor	si,si
mlo:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mlo
	mov	ah,0
	int	16h
	cmp	al,27
	je	mpgx
	retn
mpgx:	mov	ah,3Eh
	mov	bx,cs:fdsc
	int	21h
	mov	ax,3
	int	10h
	int	20h
unrle:	lodsb
	cmp	al,7Fh
	jne	mnl
	lodsb
	movzx	cx,al
	lodsb
	rep
mnl:	stosb
	cmp	di,bx
	jb	unrle
	retn
unblk:	lodsb
	cmp	al,80h
	jae	mfl
	inc	al
	mov	ah,0
	mov	cx,ax
	rep	movsb
	jmp	short mlw
mfl:	mov	cl,1
	sub	cl,al
	mov	ch,0
	lodsb
	rep	stosb
mlw:	cmp	di,bx
	jb	unblk
	retn
unlz:	mov	si,cx		;LZSS compression
	sub	si,4
	mov	eax,[si]-1
	mov	al,0
	or	ax,ax
	jnz	errsz
	if	@Cpu and 10h
	bswap	eax		;Ä486
	else
	shr	eax,16		;¿
	xchg	ah,al		;Á386
	endif
	mov	di,ax
	dec	di
	mov	bx,offset trtbl
	mov	dx,8
	add	dl,[si]+3
	std
mupl:	mov	cl,1
	shftb
	or	al,al
	jnz	munc
	mov	cl,2
	push	di
	mov	di,1
mccn:	shftb
	add	di,ax
	cmp	al,3
	je	mccn
	mov	cs:cntt,di
	pop	di
	mov	cl,8
mcpy:	shftb
	stosb
	dec	cs:cntt
	jnz	mcpy
	cmp	di,-1
	je	mlzx
munc:	push	di
	mov	cl,2
	shftb
	mov	di,ax
	mov	cl,[di]+4
	cmp	al,3
	jne	mnrm
	mov	di,cx
	mov	cl,1
	shftb
	mov	cl,7
	or	al,al
	jz	mnnr1
	mov	cx,di
mnnr1:	shftw
	push	ax
	mov	di,3
	mov	cl,3
mnnrl:	shftb
	add	di,ax
	cmp	al,7
	je	mnnrl
	pop	ax
	jmp	short mlz
mnrm:	shftw
mlz:	lea	cx,[di]+2
	pop	di
	push	ds
	push	si
	push	es
	pop	ds
	lea	si,[di]+1
	add	si,ax
	rep	movsb
	pop	si
	pop	ds
mltst:	cmp	di,-1
	jne	mupl
mlzx:	cld
	retn
readd:	mov	dh,cl
	movzx	cx,dl
	shr	cx,3
	and	dl,7
	sub	si,cx
	if	@Cpu and 10h
	mov	ebp,[si]-4	;¿
	bswap	ebp		;Á486
	else
	mov	cx,[si]-4	;¿
	xchg	ch,cl		;´
	mov	bp,cx		;´
	mov	cx,[si]-2	;´
	xchg	ch,cl		;´
	shl	ebp,16		;´
	mov	bp,cx		;Á386
	endif
	mov	ecx,[si]-3
	mov	cl,8
	sub	cl,dl
	shld	ebp,ecx,cl
	mov	cl,dh
	mov	dh,32
	retn
trtbl	equ	this byte
	irpc	dig1,084C2A6E195D3B7F
	irpc	dig2,084C2A6E195D3B7F
	bytd	<dig2&&dig1>
	endm
	endm
cntt	dw	0
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errsz:	mov	dx,offset szerr
	mov	word ptr cs:errd+1,dx
errd0:	mov	bx,cs:fdsc
	mov	ah,3Eh
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
wjcp	db	'Realms of Arkania II .ACE files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10
	if	@Cpu and 10h
	db	'Can be run only on i486 and higher!',13,10
	endif
	db	10,'$'
perr	db	'Usage:ACEVIEW filename.ACE [filename.PAL]',13,10
	db	'Internal keys: ESC - immediate exit,',13,10
	db	'               any other - show next picture (1 phase)'
	db	13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
szerr	db	'Buffer is too big!',13,10,'$'
svn1	dw	?
pnm	dw	?
fdsc	dw	?
pbuf	db	768 dup(?)
pichdr	equ	this byte
picsz	dd	?
picdx	dw	?
picdy	dw	?
picwid	dw	?
picheig	dw	?
piccomp	db	?
dmy2	db	?
hdr	equ	this byte
sig	dd	?
dmy1	dw	?
seqcnt	db	?
frwait	db	?
seqhdr	equ	this byte
s1wid	dw	?
s1heig	dw	?
s1cnt	db	?
s1cflg	db	?
	org	seqhdr
s2ofs	dd	?
s2id	dw	?
s2wid	dw	?
s2heig	dw	?
s2xoff	dw	?
s2yoff	dw	?
s2cnt	db	?
s2cflg	db	?
	org	hdr
hdata	db	2000 dup (?)
cseg	ends
end	start
