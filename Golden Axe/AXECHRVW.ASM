cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.386
	org	100h
	include parse.asm
start:	movzx	esp,sp
	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2,svn3
	mov	ax,svn3
	test	ax,ax
	jnz	m01
	xchg	svn2,ax
	mov	svn3,ax
m01:	mov	ax,3D00h
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
	mov	cs:fsz1,ax
	mov	ah,3Eh
	int	21h
	mov	si,dx
	mov	di,offset fsgn
	mov	cx,10
	repe	cmpsb
	je	m02
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	si,dx
	mov	di,dx
	mov	cx,cs:fsz1
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short m03
m02:	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	ax,cs:fsz1
	call	lzwdcd
m03:	push	cs
	push	cs
	pop	ds
	pop	es
	mov	ax,3D00h
	mov	dx,svn2
	or	dx,dx
	jz	mnomap
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
	mov	cs:fsz2,ax
	mov	ah,3Eh
	int	21h
	mov	si,dx
	mov	di,offset fsgn
	mov	cx,10
	repe	cmpsb
	je	m04
	mov	ax,cs
	add	ax,3000h
	mov	es,ax
	mov	si,dx
	mov	di,dx
	mov	cx,cs:fsz2
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short m05
m04:	mov	ax,cs
	add	ax,3000h
	mov	es,ax
	mov	ax,cs:fsz2
	call	lzwdcd
	jmp	short m05
mnomap:	mov	ax,cs
	add	ax,3000h
	mov	es,ax
	xor	di,di
	mov	ax,40
	stosw
	mov	ax,cs:fsz1
	shr	ax,6
	mov	bx,ax
	xor	dx,dx
	mov	cx,40
	div	cx
	test	dx,dx
	jz	m06
	inc	ax
	neg	dx
	add	dx,cx
m06:	stosw
	xor	ax,ax
	mov	cx,bx
m07:	stosw
	inc	ax
	inc	ax
	loop	m07
	xor	ax,ax
	mov	cx,dx
	rep	stosw
m05:	push	cs
	push	cs
	pop	ds
	pop	es
	mov	ax,3D00h
	mov	dx,svn3
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
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv
	mov	ax,cs
	add	ax,2000h
	mov	ds,ax
	add	ax,1000h
	mov	fs,ax
	mov	ax,0A000h
	mov	es,ax
	xor	bx,bx
mscr:	movzx	ax,bh
	mul	word ptr fs:[0000]
	mov	si,ax
	movzx	ax,bl
	add	si,ax
	inc	si
	inc	si
	add	si,si
	xor	di,di
	mov	dl,fs:[0002]
	cmp	dl,25
	jbe	m11
	mov	dl,25
m11:	push	si
	mov	bp,40
m10:	segfs
	lodsw
	shl	ax,5
	xchg	si,ax
	mov	dh,8
m09:	mov	cx,4
	rep	movsw
	add	di,320-8
	dec	dh
	jnz	m09
	sub	di,320*8-8
	mov	si,ax
	dec	bp
	jnz	m10
	add	di,320*7
	pop	si
	mov	ax,fs:[0000]
	lea	si,[esi][2*eax]
	dec	dl
	jnz	m11
mkb:	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	cmp	ax,4B00h	;Left
	jne	m12
	test	bl,bl
	jz	mkb
	dec	bl
	jmp	mscr
m12:	cmp	ax,4D00h	;Right
	jne	m13
	mov	al,fs:[0000]
	sub	al,40
	cmp	bl,al
	je	mkb
	inc	bl
	jmp	short mscr
m13:	cmp	ax,4800h	;Up
	jne	m14
	test	bh,bh
	jz	mkb
	dec	bh
	jmp	mscr
m14:	cmp	ax,5000h	;Down
	jne	mkb
	mov	al,fs:[0002]
	sub	al,25
	jbe	mkb
	cmp	bh,al
	je	mkb
	inc	bh
	jmp	mscr
mqq:	mov	ax,3
	int	10h
	int	20h
lzwdcd:	sub	ax,20	;I don't know why,but it's done...
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
wjcp	db	'Golden Axe .CHR & .MAP files viewer',13,10
	db	'Copyright (C) 1998 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:AXECHRVW filename.CHR [filename.MAP] filename.PAL'
	db	13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
fsgn	db	'GOLDENAXE',12
	evendata
svn1	dw	?
svn2	dw	?
svn3	dw	?
fsz1	dw	?
fsz2	dw	?
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
cseg	ends
end	start
