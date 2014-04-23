cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.386
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jc	errd0
	cmp	cx,ax
	jne	errd0
	mov	ah,3Eh
	int	21h
	jc	errd
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	push	ax
mnp:	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	pop	bx
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	jc	errd1
	cmp	ax,cx
	je	errd1
	xchg	ax,cx
	mov	ah,3Eh
	int	21h
	mov	al,ds:[0002]
	cmp	al,3
	je	lzw12
	cmp	al,6
	je	lzw14
	mov	ax,ds:[0000]
	sub	cx,3
	cmp	ax,cx
	jne	mqq
	mov	ax,0A000h
	mov	es,ax
	mov	si,3
	xor	di,di
	mov	bp,cx
	xor	cx,cx
mrll:	cmp	bp,si
	jbe	mwq
	lodsb
	test	al,al
	js	msf
	jnz	mcp
	lodsw
	xchg	ah,al
	xchg	ax,cx
	lodsb
	rep	stosb
	jmp	short mrll
msf:	neg	al
	mov	cl,al
	lodsb
	rep	stosb
	jmp	short mrll
mcp:	mov	cl,al
	rep	movsb
	jmp	short mrll
lzw12:	mov	ax,offset getcd12
	mov	bx,1000h
	jmp	short lzw
lzw14:	mov	ax,offset getcd14
	mov	bx,4000h
lzw:	mov	cs:getcd,ax
	mov	cs:cdlim,bx
	mov	ax,ds:[0000]
	dec	cx
	dec	cx
	cmp	ax,cx
	jne	mqq
	mov	ax,ds
	add	ax,1000h
	mov	fs,ax
	mov	ax,0A000h
	mov	es,ax
	mov	si,3
	xor	di,di
	lodsw
	mov	cs:dstlim,ax
	xor	dx,dx		;DL-codes left,DH-lastdatachar
	mov	bp,100h		;_usedcds
	movzx	esp,sp
	call	cs:getcd
	push	ax		;_prevcode
	mov	dh,al		;_lastdatachar
	stosb
mainlp:	cmp	di,64000
dstlim	equ	this word-2
	jae	mwq0
	call	cs:getcd
	mov	cx,ax		;_tempcode
	mov	bx,offset lzstr
	cmp	ax,bp		;_usedcds
	jb	lzwunp
	mov	cs:[bx],dh	;_lastdatachar
	inc	bx
	mov	ax,[esp]	;_prevcode
lzwunp:	cmp	ax,100h
	jb	unp1b
	mov	dh,fs:[2*eax][eax]+2
	mov	cs:[bx],dh
	inc	bx
	mov	ax,fs:[2*eax][eax]
	jmp	short lzwunp
unp1b:	mov	dh,al		;_lastdatachar;code=byte
	mov	cs:[bx],al
	inc	bx
str2pic:dec	bx
	mov	al,cs:[bx]
	stosb
	cmp	bx,offset lzstr
	ja	str2pic
	cmp	bp,1000h
cdlim	equ	this word-2
	jae	nomore
	mov	fs:[2*ebp][ebp]+2,dh	;_lastdatachar
	mov	ax,[esp]	;_prevcode
	mov	fs:[2*ebp][ebp],ax
	inc	bp
nomore:	mov	[esp],cx	;_tempcode-->_prevcode
	jmp	mainlp
getcd12:dec	dl
	jns	mgc1
	lodsw
	xchg	ah,al
	shl	eax,16
	lodsw
	xchg	ah,al
	mov	cs:bitstr+4,eax
	lodsw
	xchg	ah,al
	shl	eax,16
	mov	cs:bitstr,eax
	mov	dl,3
mgc1:	mov	eax,cs:bitstr+4
	mov	ecx,cs:bitstr
	shld	cs:bitstr+4,ecx,12
	shl	ecx,12
	mov	cs:bitstr,ecx
	shr	eax,20
	retn
getcd14:dec	dl
	jns	mgc2
	lodsw
	xchg	ah,al
	shl	eax,16
	lodsw
	xchg	ah,al
	mov	cs:bitstr+4,eax
	lodsw
	xchg	ah,al
	shl	eax,8
	lodsb
	shl	eax,8
	mov	cs:bitstr,eax
	mov	dl,3
mgc2:	mov	eax,cs:bitstr+4
	mov	ecx,cs:bitstr
	shld	cs:bitstr+4,ecx,14
	shl	ecx,14
	mov	cs:bitstr,ecx
	shr	eax,18
	retn
mwq0:	pop	ax
mwq:	mov	ah,0
	int	16h
mqq:	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd1:	mov	ax,3
	int	10h
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
wjcp	db	'Dragon Strike .CMP files viewer',13,10
	db	'Copyright (C) 1998 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:CMPVIEW filename.CMP filename.PAL',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
	evendata
svn1	dw	?
svn2	dw	?
pof	dw	?
pbuf	db	768 dup(?)
getcd	dw	?
bitstr	dd	?,?
lzstr	db	4000h dup(?)
cseg	ends
end	start
