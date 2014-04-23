cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.386
	org	100h
	include parse.asm
start:	movzx	esp,sp
	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,0FFFFh
	xor	dx,dx
	int	21h
	mov	ah,3Eh
	int	21h
	push	cs
	pop	ds
	mov	ax,3D00h
	mov	dx,svn2
	int	21h
	jc	errd
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
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	mov	cx,ds:[0]
	mov	cs:fcnt,cx
	xor	bx,bx
m01:	mov	cs:frms[bx],es
	add	bx,bx
	mov	si,[bx]+2
	cmp	si,-1
	jne	m02a
	shr	bx,1
	xor	ax,ax
	mov	cs:frms[bx],ax
	jmp	short m03
m02a:	shl	si,4
	mov	ax,[bx]+4
	shl	ax,4
	push	cx
	push	bx
	call	unpack
	cmp	word ptr es:[0000],-1
	je	m04
	int	20h
m04:	add	di,15
	shr	di,4
	mov	ax,es
	add	ax,di
	mov	es,ax
	pop	bx
	pop	cx
	shr	bx,1
m03:	inc	bx
	inc	bx
	loop	m01
	mov	bp,cs:fcnt
	mov	bx,offset frms
	xor	ax,ax
	mov	dx,ax
m08:	mov	si,cs:[bx]
	test	si,si
	jz	m06a
	mov	ds,si
	mov	cx,ds:[0002]
	mov	si,4
m07:	mov	di,[si]
	cmp	ax,[di]+8
	jge	m05
	mov	ax,[di]+8
m05:	cmp	dl,[di]+7
	jae	m06
	mov	dl,[di]+7
m06:	inc	si
	inc	si
	loop	m07
m06a:	inc	bx
	inc	bx
	dec	bp
	jnz	m08
	mov	cs:xof,ax
	mov	cs:yof,dx
	push	cs
	push	cs
	pop	ds
	pop	es	
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv
nxfrm:	mov	bx,cs:curfrm
	add	bx,bx
	mov	bp,cs:frms[bx]
	test	bp,bp
	jz	m15
	mov	ds,bp
	mov	bp,ds:[0002]
	mov	si,4
	mov	ax,cs
	add	ax,1000h
	mov	es,ax
pgloop:	xor	di,di
	push	si		;;;
	mov	si,[si]
	mov	cx,10h
	rep	movsw
	mov	dx,[si]-20h
	sub	dx,20h
	test	byte ptr [si]+5-20h,80h
	jnz	decomp
	mov	cx,dx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short enddcm
decomp:	xor	ax,ax
m10:	lodsb
	test	al,al
	js	m09
	mov	cx,ax
	lodsb
	rep	stosb
	sub	dx,2
	ja	m10
	jmp	short enddcm
m09:	neg	al
	mov	cx,ax
	rep	movsb
	inc	ax
	sub	dx,ax
	ja	m10
enddcm:	push	ds		;;;
	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	mov	si,20h
	mov	ax,cs:yof
	sub	al,ds:[0007]
	lea	ax,[eax][4*eax]
	shl	ax,6
	mov	di,ax
	add	di,cs:xof
	sub	di,ds:[0008]
	test	byte ptr ds:[0005],40h
	jz	notrp
	mov	ah,ds:[0006]
m13:	mov	cx,ds:[0002]
	push	di
m12:	lodsb
	inc	di
	cmp	al,ah
	je	m11
	dec	di
	stosb
m11:	loop	m12
	pop	di
	add	di,320
	dec	byte ptr ds:[0004]
	jnz	m13
	jmp	short kwait
notrp:	mov	cx,ds:[0002]
	push	di
	rep	movsb
	pop	di
	add	di,320
	dec	byte ptr ds:[0004]
	jnz	notrp
kwait:	mov	ah,0
	int	16h
	cmp	al,' '
	jne	m14
	xor	di,di
	mov	ax,di
	mov	cx,32000
	rep	stosw
m14:	cmp	al,27
	jne	m16
mqq:	mov	ax,3
	int	10h
	int	20h
m16:	push	ds
	pop	es
	pop	ds
	pop	si
	inc	si
	inc	si
	dec	bp
	jnz	pgloop
m15:	mov	ax,cs:curfrm
	inc	ax
	cmp	ax,cs:fcnt
	je	mqq
	mov	cs:curfrm,ax
	jmp	nxfrm
;src DS:SI,target ES:0,size AX
unpack:	push	es
	push	cs
	pop	es
	push	si
	mov	di,offset fsgn
	mov	cx,10
	repe	cmpsb
	je	m02
	pop	si
	pop	es
	mov	cx,ax
	xor	di,di
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	retn
m02:	pop	cx
	pop	es
lzwdcd:	sub	ax,30	;garbage:10 at start,20 at end
	add	ax,si
	mov	cs:sze,ax
	push	es
	push	cs
	pop	es
	xor	eax,eax			;init LZW...
	mov	di,offset lzbytes
	mov	cx,256
m1:	stosb
	inc	al
	jnz	m1
	mov	di,offset lzcodes
	mov	cx,256
	rep	stosw
	mov	cs:usedcds,101h
	mov	cs:allcds,1FFh
	mov	cs:bitcnt,9
	mov	cs:bitrdy,0		;...done
	pop	es
	xor	di,di
	xor	dx,dx		;it's my flag register: 1-repeat,DH-lastcolor
	call	getcode
	push	ax		;_prevcode
	push	ax		;_lastdatachar
	call	putbyte
mainlp:	call	getcode
	cmp	ax,-1
	je	endlzw
	cmp	ax,100h
	jne	no_init
	call	initget
no_init:mov	bp,ax		;_tempcode
	mov	bx,offset lzstr
	cmp	ax,cs:usedcds
	jb	lzwunp
	ja	endlzw		;BUG TRAP
	mov	ax,[esp]	;_lastdatachar
	mov	cs:[bx],al
	inc	bx
	mov	ax,[esp]+2	;_prevcode
lzwunp:	cmp	ax,100h
	jb	unp1b
	mov	cl,cs:lzbytes[eax]
	mov	cs:[bx],cl
	inc	bx
	mov	ax,cs:lzcodes[2*eax]
	jmp	short lzwunp
unp1b:	mov	[esp],ax	;_lastdatachar;code=byte
	mov	cs:[bx],al
	inc	bx
str2pic:dec	bx
	mov	al,cs:[bx]
	call	putbyte
	cmp	bx,offset lzstr
	ja	str2pic
	mov	ax,cs:usedcds
	cmp	ax,1000h
	jae	nomore
	mov	cx,[esp]	;_lastdatachar
	mov	cs:lzbytes[eax],cl
	mov	cx,[esp]+2	;_prevcode
	mov	cs:lzcodes[2*eax],cx
	inc	cs:usedcds
nomore:	mov	[esp]+2,bp	;_tempcode-->_prevcode
	jmp	mainlp
;-------
endlzw:	pop	ax
	pop	ax
	retn			;di=new size
;-------
putbyte:test	dl,1
	jnz	dorep
	cmp	al,90h
	je	setrep
	mov	dh,al
	stosb
	retn
setrep:	or	dl,1
	retn
dorep:	xor	dl,1
	test	ax,ax
	jz	put90h
	lea	ecx,[eax]-1
	mov	al,dh
	rep	stosb
	retn
put90h:	mov	al,90h
	stosb
	retn
;-------
initget:mov	cs:usedcds,100h
	mov	cs:bitcnt,9
	mov	cs:allcds,1FFh
	jmp	short mg2
getcode:mov	bx,cs:bitrdy
	mov	ax,cs:usedcds
	mov	cx,cs:bitcnt
	cmp	bx,cx
	jb	rdblk
	cmp	ax,cs:allcds
	jbe	doshift
rdblk:	cmp	ax,cs:allcds
	jbe	mg2
	inc	cx
	mov	cs:bitcnt,cx
	mov	ax,1
	shl	ax,cl
	cmp	cl,12
	je	mg1
	dec	ax
mg1:	mov	cs:allcds,ax
mg2:	mov	cx,cs:bitcnt
	mov	bx,cx
	push	es
	push	di
	push	cs
	pop	es
	mov	di,offset bitstr
mgl1:	cmp	si,cs:sze
	je	mgl1x
	movsb
	loop	mgl1
mgl1x:	pop	di
	pop	es
	sub	bx,cx
	shl	bx,3
	jnz	doshift
	mov	cs:bitrdy,bx
	mov	ax,-1
	retn
doshift:mov	cx,cs:bitcnt
	sub	bx,cx
	mov	cs:bitrdy,bx
	mov	eax,1
	shl	eax,cl
	dec	eax
	and	eax,cs:bitstr
	mov	ebx,cs:bitstr+4
	shrd	cs:bitstr,ebx,cl
	mov	ebx,cs:bitstr+8
	shrd	cs:bitstr+4,ebx,cl
	shr	cs:bitstr+8,cl
	retn
;-------
errv:	mov	dx,offset aerr
	mov	ax,3
	int	10h
	jmp	short mx1
errd:	mov	dx,offset derr
	jmp	short mx1
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
wjcp	db	'Golden Axe .SPR files viewer',13,10
	db	'Copyright (C) 1998 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:AXESPRVW filename.SPR filename.PAL'
	db	13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
fsgn	db	'GOLDENAXE',12
curfrm	dw	0
	evendata
svn1	dw	?
svn2	dw	?
sze	dw	?
usedcds	dw	?
allcds	dw	?
bitcnt	dw	?
bitrdy	dw	?
bitstr	dd	?,?,?
lzbytes	db	1000h dup(?)
lzcodes	dw	1000h dup(?)
lzstr	db	1000h dup(?)
pbuf	db	768 dup(?)
fcnt	dw	?
frms	dw	24h dup(?)
xof	dw	?
yof	dw	?
cseg	ends
end	start
