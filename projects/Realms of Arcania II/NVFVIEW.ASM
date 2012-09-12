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
	parse	svn1,pnm,opt
	mov	ax,3D00h
	mov	dx,pnm
	or	dx,dx
	jz	mnp
	int	21h
	jc	errdd
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,300h
	mov	dx,offset pbuf
	int	21h
	mov	ah,3Eh
	int	21h
	jmp	short mpl
mnp:	mov	di,offset pbuf
	mov	ax,0FFFFh
	mov	cx,180h
	rep	stosw
mpl:	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jnz	mwx
mxx:	jmp	mx
errdd:	jmp	errd
mwx:	int	21h
	jc	errdd
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,2403
	mov	dx,offset hdr
	int	21h
	jc	errd0
	mov	fdsc,bx
	mov	ax,13h
	int	10h
	jnc	m1f
	jmp	errv
m1f:	push	cs
	pop	es
	movzx	bx,typ
	add	bx,bx
	mov	cx,cnt
	mov	si,offset buff
	mov	di,offset xys
	jmp	hdrtb[bx]
hdrtb	dw	htyp0,htyp1,htyp2,htyp3,htyp2,htyp3
htyp0:	mov	eax,[si]
	mov	bx,cx
	rep	stosd
	mov	cx,bx
	shld	edx,eax,16
	mul	dx
	movzx	edx,ax
	mov	eax,7
	mov	di,offset ofss
	inc	cx
mlt0:	stosd
	add	eax,edx
	loop	mlt0
	jmp	short mhpl
htyp1:	movzx	ebx,cx
	shl	bx,2
	add	bx,3
mlt1:	lodsd
	stosd
	shld	edx,eax,16
	mul	dx
	movzx	eax,ax
	mov	[di]+ofss-xys-4,ebx
	add	ebx,eax
	loop	mlt1
	mov	[di]+ofss-xys,ebx
	jmp	short mhpl
htyp2:	movzx	ebx,cx
	shl	bx,2
	add	bx,7
	lodsd
	mov	dx,cx
	rep	stosd
	mov	cx,dx
	mov	di,offset ofss
mlt2:	lodsd
	xchg	eax,ebx
	stosd
	add	ebx,eax
	loop	mlt2
	mov	eax,ebx
	stosd	
	jmp	short mhpl
htyp3:	movzx	ebx,cx
	shl	bx,3
	add	bx,3
mlt3:	movsd
	lodsd
	mov	[di]+ofss-xys-4,ebx
	add	ebx,eax
	loop	mlt3
	mov	[di]+ofss-xys,ebx
mhpl:	mov	bx,opt
	test	bx,bx
	jz	mpnst
	mov	bx,[bx]
	cmp	bx,2Dh
	je	mpst
mpnst:	mov	bx,cnt
	shl	bx,2
	add	bx,offset ofss
	mov	ax,4200h
	mov	cx,[bx]+2
	mov	dx,[bx]
	mov	bx,fdsc
	int	21h
	mov	ah,3Fh
	mov	cx,302h
	mov	dx,offset ccnt
	mov	si,dx
	int	21h
	test	ax,ax
	jnz	mpp
	cmp	pnm,0
	je	errp
	jmp	short mpst
mpp:	lodsw
	xchg	ax,cx
	mov	di,offset pbuf
mplp:	lodsd
	dec	si
	or	eax,0FF000000h
	cmp	eax,-1
	je	mpl1
	stosw
	shr	eax,16
	stosb
	jmp	short mpln
mpl1:	add	di,3
mpln:	loop	mplp
mpst:	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jnc	mhtx
	jmp	errv0
mhtx:	push	cs
	pop	ds
	mov	bx,idx
	cmp	bx,cnt
	je	mpgx
	inc	idx
	shl	bx,2
	mov	edx,ofss[bx]
	mov	ecx,ofss[bx]+4
	sub	ecx,edx
	push	bx
	push	cx
	shld	ecx,edx,16
	mov	ax,4200h
	mov	bx,fdsc
	int	21h
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	xor	dx,dx
	pop	cx
	mov	ah,3Fh
	int	21h
	mov	si,dx
	mov	di,dx
	movzx	bx,cs:typ
	and	bl,0FEh
	jmp	cs:paktb[bx]
paktb	dw	ptyp0,ptyp2,ptyp4
ptyp0:	rep	movsb		;no compression
	jmp	mptx
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
ptyp2:	mov	si,cx		;LZSS compression
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
	jmp	short mptx
errsz:	mov	dx,offset szerr
	jmp	errfh
ptyp4:	pop	bx		;RLE compression
	push	bx
	mov	ax,word ptr cs:xys[bx]
	mul	word ptr cs:xys[bx]+2
	mov	bx,ax
mtp3:	lodsb
	cmp	al,7Fh
	jne	mnl
	lodsb
	movzx	cx,al
	lodsb
	rep
mnl:	stosb
	cmp	di,bx
	jb	mtp3
mptx:	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	mov	di,si
	pop	bx
	mov	dx,word ptr cs:xys[bx]+2
	mov	bx,word ptr cs:xys[bx]
mlo:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mlo
mkb:	mov	ah,0
	int	16h
	cmp	al,27
	je	mpgx
	cmp	al,9
	jne	mclr
	push	es
	push	cs
	pop	es
	mov	ax,1012h
	mov	bx,80h
	mov	cx,128
	mov	dx,offset pbuf
	int	10h
	pop	es
	jmp	short mkb
mclr:	xor	ax,ax
	mov	di,ax
	mov	cx,32000
	rep	stosw
	jmp	mhtx
mpgx:	mov	ah,3Eh
	mov	bx,cs:fdsc
	int	21h
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
errv:	pop	bx
	mov	ah,3Eh
	int	21h
	mov	dx,offset aerr
	jmp	short mx1
errp:	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	mov	dx,offset nopal
	jmp	short mx1
wjcp	db	'Realms of Arkania I & II .NVF files viewer',13,10
	db	'Copyright (C) 1996,2000 by WhiteJaguar',13,10
	if	@Cpu and 10h
	db	'Can be run only on i486 and higher!',13,10
	endif
	db	10,'$'
perr	db	'Usage:NVFVIEW filename.NVF [filename.PAL [-] ]',13,10
	db	'"-" after palette disables file''s internal palette',13,10
	db	'Internal keys: ESC - immediate exit,',13,10
	db	"               TAB - duplicate palette's lower half in higher"
	db	13,10
	db	'               any other - show next',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
szerr	db	'Buffer is too big!',13,10,'$'
nopal	db	'No internal palette - .PAL file required!',13,10,'$'
idx	dw	0
svn1	dw	?
pnm	dw	?
opt	dw	?
fdsc	dw	?
pbuf	db	768 dup(?)
ccnt	dw	?
pbuf1	db	768 dup(?)
xys	dw	300*2 dup(?)
ofss	dd	300 dup(?)
hdr	equ	this byte
typ	db	?
cnt	dw	?
buff	dd	300*2 dup(?)
cseg	ends
end	start
