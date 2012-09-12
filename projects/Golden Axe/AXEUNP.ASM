cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.386
	org	100h
	include parse.asm
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	xor	eax,eax			;init LZW...
	mov	di,offset lzbytes
	mov	cx,256
m1:	stosb
	inc	al
	jnz	m1
	mov	di,offset lzcodes
	mov	cx,256
	rep	stosw
	mov	usedcds,101h
	mov	allcds,1FFh
	mov	bitcnt,9
	mov	bitrdy,0		;...done
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errdd
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,0FFFFh
	xor	dx,dx
	int	21h
	mov	cs:fsz,ax
	mov	ah,3Eh
	int	21h
	mov	si,dx
	mov	di,offset fsgn
	mov	cx,10
	repe	cmpsb
	jne	errfh
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	xor	di,di
	sub	cs:fsz,20	;I don't know why,but it's done...
	xor	dx,dx		;it's my flag register: 1-repeat,DH-lastcolor
	movzx	esp,sp
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
mgl1:	cmp	si,cs:fsz
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
endlzw:	push	cs
	pop	ds
	mov	dx,svn2
	mov	cx,20h
	mov	ah,3Ch
	int	21h
	xchg	ax,bx
	push	es
	pop	ds
	xor	dx,dx
	mov	cx,di
	mov	ah,40h
	int	21h
	mov	ah,3Eh
	int	21h
	int	20h
errfh:	mov	dx,offset fherr
	jmp	short mx1
errdd:	mov	dx,offset derr
	jmp	short mx1
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
wjcp	db	'Golden Axe files unpacker',13,10
	db	'Copyright (C) 1998 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:AXEUNP srcfile targetfile',13,10,'$'
derr	db	'Disk error!',13,10,'$'
fherr	db	'Not a packed GOLDENAXE file!',13,10,'$'
fsgn	db	'GOLDENAXE',12
	evendata
svn1	dw	?
svn2	dw	?
fsz	dw	?
usedcds	dw	?
allcds	dw	?
bitcnt	dw	?
bitrdy	dw	?
bitstr	dd	?,?,?
lzbytes	db	1000h dup(?)
lzcodes	dw	1000h dup(?)
lzstr	db	1000h dup(?)
cseg	ends
end	start
