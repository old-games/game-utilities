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
	jnz	mwx
mxx:	jmp	mx
errdd:	jmp	errd
mwx:	int	21h
	jc	errdd
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,30
	mov	dx,offset hdr
	int	21h
	cmp	nme,01464941h		;'AIF',1
	jne	mer2
	cmp	typ,0
	je	mer3			;this format are PALs and too-big RAWs
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	jc	mer1
	cmp	ax,cx
	jne	mlnx
mer1:	jmp	errd0
mer2:	mov	dx,offset fherr
	jmp	errfh
mer3:	mov	dx,offset fderr
	jmp	errfh
mlnx:	push	ax
	mov	ah,3Eh
	int	21h
	mov	ax,13h
	int	10h
	jnc	m1f
	jmp	errv
m1f:	push	ds
	pop	es
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	pop	dx
	sub	dx,300h		;THIS value needs for MTYP3 !!!
	int	10h
	jnc	mvn
	jmp	errv0
mvn:	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	xor	si,si
	mov	di,si
	cmp	cs:typ,3
	je	mtyp3
	mov	ax,cs:hei
	mul	cs:len
	mov	bx,ax
	cmp	cs:typ,1
	je	mtyp1
mlp:	lodsb
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
	jb	mlp
	jmp	mallw
mtyp1:	lodsb
	cmp	al,7Fh
	jne	mnl
	lodsb
	movzx	cx,al
	lodsb
	rep
mnl:	stosb
	cmp	di,bx
	jb	mtyp1
	jmp	mallw
errsz:	mov	dx,offset szerr
	jmp	errfh
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
cnt	dw	0
mtyp3:	mov	si,dx
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
	mov	cs:cnt,di
	pop	di
	mov	cl,8
mcpy:	shftb
	stosb
	dec	cs:cnt
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
mallw:	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	mov	di,si
	mov	bx,cs:len
	mov	dx,cs:hei
mlo:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mlo
	mov	ah,0
	int	16h
	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd0:	mov	ah,3Eh
	int	21h
errd:	mov	dx,offset derr
	jmp	short mx1
errfh:	mov	word ptr cs:errd+1,dx
	jmp	short errd0
errv0:	mov	ax,3
	int	10h
errv:	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Realms of Arkania II .AIF files viewer',13,10
	db	'Copyright (C) 1996 by WhiteJaguar',13,10
	if	@Cpu and 10h
	db	'Can be run only on i486 and higher!',13,10
	endif
	db	10,'$'
perr	db	'Usage:AIFVIEW filename.AIF',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
fherr	db	'Not an .AIF!',13,10,'$'
fderr	db	'This .AIF is not a picture!',13,10,'$'
szerr	db	'Buffer is too big!',13,10,'$'
svn1	dw	?
hdr	equ	this byte
nme	dd	?
typ	dw	?
len	dw	?
hei	dw	?
n_a	dw	?
fill	db	18 dup(?)
cseg	ends
end	start
