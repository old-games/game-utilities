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
	parse	svn1
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,1000
	mov	dx,offset hdr
	int	21h
	jc	errd0
	mov	fdsc,bx
	cmp	h1sig,01424F42h	;'BOB',1
	jne	m1
	mov	al,h1mpg
	movzx	bx,h1seq
	mul	bl
	mov	cx,ax
	movzx	ax,h1unk
	add	bx,ax
	add	bx,offset h1bdy
	jcxz	m1nl
m1l:	mov	ax,[bx]+1
	lea	bx,[eax*4][ebx]+3
	loop	m1l
m1nl:	mov	di,offset hdr
	mov	si,bx
	mov	cx,[bx]
	sub	bx,di
	mov	word ptr stoff,bx
	rep	movsb
m1:	mov	edx,dscoff
	add	edx,stoff
	shld	ecx,edx,16
	mov	ax,4200h
	mov	bx,fdsc
	int	21h
	mov	ah,3Fh
	mov	dx,offset adsc
	mov	cx,6
	int	21h
	mov	ax,13h
	int	10h
	jc	errv
	push	cs
	pop	es
	mov	di,offset pbuf
	mov	cx,180h
	mov	ax,-1
	rep	stosw
	mov	ah,3Fh
	movzx	cx,colcnt
	lea	cx,[ecx][ecx*2]
	mov	dx,offset pbuf
	int	21h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	int	10h
	jc	errv0
	mov	edx,h2sz
	add	edx,stoff
	shld	ecx,edx,16
	mov	ax,4200h
	mov	bx,fdsc
	int	21h
	mov	si,offset dscoff
	cmp	seqcnt,0
	je	m2
	mov	si,offset hdr
	add	si,word ptr seqofs
	add	si,0Ch
m2:	mov	ecx,[si]
	sub	ecx,h2sz
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	cmp	cs:lzflag,0
	je	mnlz1
	call	unlz
	push	es
	pop	ds
mnlz1:	xor	si,si
	xor	di,di
	movzx	dx,cs:mheig
	mov	bx,cs:mwid
	call	disppic
	push	cs
	pop	ds
	mov	di,offset seqofs
	movzx	cx,seqcnt
	test	cx,cx
	jz	mpgx
mnsq:	push	di
	push	cx
	mov	si,[di]
	add	si,offset hdr
	mov	edx,[si]+0Ch
	add	edx,stoff
	shld	ecx,edx,16
	mov	ax,4200h
	mov	bx,fdsc
	int	21h
	mov	dx,offset dscoff
	pop	cx
	push	cx
	cmp	cx,1
	je	m3
	mov	dx,[di]+4
	add	dx,offset hdr+0Ch
m3:	mov	di,dx
	mov	ecx,[di]
	sub	ecx,[si]+0Ch
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	cmp	cs:lzflag,0
	je	mnlz2
	push	si
	call	unlz
	pop	si
	push	es
	pop	ds
mnlz2:	movzx	cx,cs:[si]+0Bh
	mov	bx,320
	movzx	ax,byte ptr cs:[si]+6
	mul	bx
	add	ax,cs:[si]+4
	mov	di,ax
	movzx	dx,byte ptr cs:[si]+7
	mov	bx,cs:[si]+8
	xor	si,si
msql:	push	di
	push	dx
	push	bx
	push	cx
	call	disppic
	pop	cx
	pop	bx
	pop	dx
	pop	di
	loop	msql
	push	cs
	pop	ds
	pop	cx
	pop	di
	add	di,4
	dec	cx
	jnz	mnsq
	jmp	mpgx
disppic:mov	ax,0A000h
	mov	es,ax
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
wjcp	db	'Realms of Arkania II .BOB files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10
	if	@Cpu and 10h
	db	'Can be run only on i486 and higher!',13,10
	endif
	db	10,'$'
perr	db	'Usage:BOBVIEW filename.BOB',13,10
	db	'Internal keys: ESC - immediate exit,',13,10
	db	'               any other - show next picture (1 phase)'
	db	13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
szerr	db	'Buffer is too big!',13,10,'$'
stoff	dd	0
svn1	dw	?
fdsc	dw	?
pbuf	db	768 dup(?)
adsc	equ	this byte
dummy	dw	?,?
colcnt	db	?
lzflag	db	?
hdr	equ	this byte
h1sig	dd	?
h1mpg	db	?
h1seq	db	?
h1unk	db	?
h1bdy	equ	this byte
	org	hdr
h2sz	dd	?
dscoff	dd	?
mwid	dw	?
mheig	db	?
seqcnt	db 	?
seqofs	dd	?
	org	hdr
hdata	db	1000 dup (?)
cseg	ends
end	start
