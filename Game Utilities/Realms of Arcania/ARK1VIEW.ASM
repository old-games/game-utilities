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
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
	or	dx,dx
	jz	mfl
	int	21h
	jc	errd
	xchg	ax,bx
	mov	dx,offset pbuf
	mov	cx,300h
	mov	ah,3Fh
	int	21h
	jc	errd
	cmp	ax,cx
	jne	errd
	mov	ah,3Eh
	int	21h
	mov	ax,3D00h
mfl:	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	xchg	ax,bx
	xor	dx,dx
	xor	cx,cx
	mov	ax,4202h
	int	21h
	shrd	edi,edx,16
	mov	di,ax
	xor	dx,dx
	xor	cx,cx
	mov	ax,4200h
	int	21h
	mov	dx,offset tvar
	mov	cx,4
	mov	ah,3Fh
	int	21h
	xor	dx,dx
	xor	cx,cx
	mov	ax,4200h
	int	21h
	cmp	tvar,'02PP'
	je	bigpic
	cmp	tvar,edi
	je	bigpic
	cmp	byte ptr tvar,4Ch
	je	picrle
	cmp	edi,812
	je	smlb
	cmp	edi,1754
	je	char
	cmp	edi,7EC2h
	je	icn1
	cmp	edi,0C00h
	je	icn2
	cmp	edi,1440h
	je	icn3
	cmp	edi,0FA05h
	jb	mt1
	cmp	edi,0FD02h
	jbe	fulbmp
mt1:	cmp	edi,11C00h
	jne	errfh
	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	fcn,71
	mov	len,32
	mov	heig,32
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,0F000h
	mov	ah,3Fh
	int	21h
	mov	ax,cs
	add	ax,1F00h
	mov	ds,ax
	mov	cx,2C00h
	mov	ah,3Fh
	int	21h
	mov	ah,3Eh
	int	21h
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	es,ax
	jmp	mallw
bigpic:	mov	fcn,1
	call	pload
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	lea	si,[di]-4
	xor	di,di
	mov	eax,[si]-1
	mov	al,0
	if	@Cpu and 10h
	bswap	eax		;Ä486
	else
	shr	eax,16		;¿
	xchg	ah,al		;Á386
	endif
	mov	di,ax
	cmp	di,0FA00h
	je	msz1n
	ja	msz1p
	cmp	di,5C62h
	je	msz2p
	cmp	di,0B202h
	je	msz3p
	cmp	di,681h
	jne	errfh
msz4np:	cmp	cs:svn2,0
	je	errpl
	mov	cs:poff,0
	mov	ax,16
	mov	bx,104
	jmp	short mnxt
msz3p:	mov	ax,320
	mov	bx,140
	jmp	short mnxt
msz2p:	mov	ax,128
	mov	bx,184
	jmp	short mnxt
msz1n:	cmp	cs:svn2,0
	je	errpl
	mov	cs:poff,0
msz1p:	mov	ax,320
	mov	bx,200
mnxt:	mov	cs:len,ax
	mov	cs:heig,bx
	cmp	cs:poff,0
	je	mnx1
	mul	bx
	mov	cs:poff,ax
mnx1:	dec	di
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
	jmp	mallw
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
picrle:	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	len,320
	mov	heig,200
	mov	fcn,1
	call	pload
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	bx,di
	xor	si,si
	xor	di,di
mrle:	lodsb
	cmp	al,7Fh
	jne	mnl
	lodsb
	movzx	cx,al
	lodsb
	rep
mnl:	stosb
	cmp	si,bx
	jb	mrle
	jmp	mallw
char:	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	ax,4200h
	mov	dx,730
	sub	di,dx
	xor	cx,cx
	int	21h
	mov	len,32
	mov	heig,32
	jmp	mbm0
smlb:	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	len,16
	mov	heig,16
	mov	fcn,3
	jmp	short mbm1
icn1:	mov	poff,7BC0h
	mov	len,24
	mov	heig,24
	mov	fcn,55
	jmp	short mbm1
icn2:	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	len,32
	mov	heig,32
	mov	fcn,3
	jmp	short mbm1
icn3:	cmp	svn2,0
	je	errpl
	mov	poff,0
	mov	len,24
	mov	heig,24
	mov	fcn,9
	jmp	short mbm1
fulbmp:	mov	poff,0FA00h
	mov	len,320
	mov	heig,200
mbm0:	mov	fcn,1
mbm1:	call	pload
	push	ds
	pop	es
mallw:	mov	ax,13h
	int	10h
	jc	errv
	push	es
	pop	ds
	mov	bx,0
	mov	si,cs:poff
	cmp	si,0
	je	mp0
	call	setp1
	jmp	maw0
mp0:	push	cs
	pop	es
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
maw0:	xor	si,si
maw1:	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	mov	bx,cs:len
	mov	dx,cs:heig
mlo:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mlo
	push	si
mkb:	mov	ah,0
	int	16h
	cmp	al,27
	je	mq
	mov	bx,20h
	cmp	al,'1'
	je	mcp
	mov	bx,60h
	cmp	al,'2'
	je	mcp
	mov	bx,0E0h
	cmp	al,'3'
	je	mcp
	dec	cs:fcn
	jz	mq
	pop	si
	test	si,si
	jnz	maw1
	mov	ax,ds
	add	ax,1000h
	mov	ds,ax
	jmp	short maw1
mcp:	mov	si,cs:poff
	cmp	si,0
	je	mkb
	call	setp1
	jmp	short mkb
setp1:	push	ds
	pop	es
	mov	cx,[si]
	mov	dx,bx
	add	dx,cx
	cmp	dx,100h
	jbe	mcp1
	mov	cx,100h
	sub	cx,bx
mcp1:	lea	dx,[si]+2
	mov	ax,1012h
	int	10h
	retn
pload:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,di
	mov	ah,3Fh
	int	21h
	mov	ah,3Eh
	int	21h
	retn
mq:	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h
errpl:	mov	dx,offset nopal
	jmp	short mx1
errd0:	mov	ah,3Eh
	int	21h
errd:	mov	dx,offset derr
	jmp	short mx1
errfh:	mov	word ptr cs:errd+1,offset fherr
	jmp	short errd0
errv:	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Realms of Arkania I assorted graphic files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10
	if	@Cpu and 10h
	db	'Can be run only on i486 and higher!',13,10
	endif
	db	10,'$'
perr	db	'Usage:ARK1VIEW filename.ext [filename.pal]',13,10
	db	'Internal keys: ESC - immediate exit',13,10
	db	'               1 - reload palette starting at color 20h',13,10
	db	'               2 - reload palette starting at color 60h',13,10
	db	'               3 - reload palette starting at color 0E0h',13,10
	db	'               any other - show next',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
fherr	db	'Unsupported file format!',13,10,'$'
nopal	db	'No internal palette - .PAL file required!',13,10,'$'
poff	dw	-1
svn1	dw	?
svn2	dw	?
tvar	dd	?
len	dw	?
heig	dw	?
fcn	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
