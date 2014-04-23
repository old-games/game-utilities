cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg
	include	parse.asm
	org	100h
	.386
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
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
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	ah,3Fh
	mov	cx,0FFFFh
	int	21h
	jc	errd
	mov	ah,3Eh
	int	21h
	jc	errd
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
	push	ds
	pop	fs
	push	cs
	pop	ds
	mov	bx,4
	mov	si,fs:[2]
	lea	si,[esi+esi+4]
	mov	cx,fs:[2]
nxpg:	push	cx
	test	word ptr fs:[0],4
	jnz	mnclr
	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	xor	ax,ax
	mov	cx,32000
	rep	stosw
mnclr:	push	bx
	push	si
	test	word ptr fs:[0],1
	jz	mnbase
	mov	si,fs:[2]
	lea	si,[esi+esi+4]
	mov	bx,4
	call	drawpge
	pop	si
	pop	bx
	push	bx
	push	si
mnbase:	call	drawpge
	pop	si
	pop	bx
	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	mov	ax,fs:[bx]
	lea	si,[esi+2*eax]
	add	bx,2
	pop	cx
	loop	nxpg
mqq:	mov	ax,3
	int	10h
	int	20h
drawpge:mov	di,fs:[si]+2
	imul	di,di,320
	add	di,fs:[si]
	push	di
	cmp	dword ptr fs:[si]+4,'GWC'
	jne	mrdy
	mov	cx,fs:[bx]
	add	cx,cx
	mov	dx,fs:[si]+8
	add	dx,dx
	add	si,12
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	xor	di,di
	call	unp_data
	xor	si,si
	jmp	short mout
mrdy:	push	fs
	pop	es
	add	si,4
mout:	pop	di
	push	ds
	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	lodsw
	mov	dx,ax
	lodsw
	mov	bx,ax
mvl:	mov	cx,bx
	test	word ptr fs:[0],4
	jnz	mvcp
mvl1:	lodsb
	test	al,al
	jz	mskp
	mov	es:[di],al
mskp:	inc	di
	loop	mvl1
	jmp	short mvnx
mvcp:	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
mvnx:	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvl
	pop	ds
	retn
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
wjcp	db	'Disciples of Steel animation viewer',13,10
	db	'Copyright (C) 1999 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:STANMVW filename.ANM filename.PAL',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
unp_data proc	near
; In: source FS:SI, target ES:DI, srcsize CX, dstsize DX ;changes BP
;initialization section
	add	cx,si
	movzx	ecx,cx
	shl	ecx,3
	mov	srcend,ecx
	add	dx,di
	mov	dstend,dx
	push	es
	push	di
	push	cs
	pop	es
	mov	di,offset useflag
	xor	eax,eax
	mov	cx,125
	rep	stosd
	pop	di
	pop	es
	mov	bitcnt,1	;bits in code
	mov	splitf,1	;1 - splitmode on
	mov	allcds,2	;codespace size for current bits/code
	mov	usedcds,0	;no. of used codes
	mov	prevcode,0	;previous code
	mov	low2scn,0	;"low code to scan" or something similar
	mov	lowused,0	;"low codes used" or something similar
	mov	cd2ruse,1	;"code to reuse" or something similar
	movzx	ebx,si
	shl	ebx,3		;source offset in bits
	mov	bmask,1		;bit mask for code
	xor	dx,dx		;flag register: 1-repeat,DH-lastdatachar
;unpacking section
xloop:	mov	eax,ebx
	shr	eax,3
	mov	eax,fs:[eax]
	mov	cl,bl
	and	cl,7
	shr	eax,cl
	cmp	splitf,0
	je	getcode
	inc	ebx
	shr	eax,1
	jc	getscde
	add	ebx,8
	mov	ah,0
	not	ax
	jmp	short code_
getscde:and	ax,bmask
	jmp	short getcdx
getcode:and	ax,bmask
	sub	ax,100h
getcdx:	add	ebx,bitcnt
code_:	movzx	eax,ax
	xor	si,si
	test	ax,ax
	jz	xqq		;code 100h is End Of Data
	mov	curcode,ax
	js	onechar
	cmp	ax,usedcds
	jbe	lz2str
	xor	ax,ax
	jmp	short onechar
lzwloop:mov	impflag[eax],4
	mov	cl,lzbytes[eax]
	mov	lzstr[si],cl
	inc	si
	mov	ax,lzcodes[2*eax]
lz2str:	test	ax,ax
	jg	lzwloop
onechar:not	ax
	mov	lastbyte,al
	mov	lzstr[si],al
doout:	mov	al,lzstr[si]
	test	dl,1
	jnz	dorep
	cmp	al,90h
	jne	do1b
	or	dl,1
	jmp	short outnx
dorep:	xor	dl,1
	test	ax,ax
	jz	put90h
	lea	ecx,[eax]-1
	mov	al,dh
	rep	stosb
	jmp	short outnx
put90h:	mov	al,90h
	jmp	short outb
do1b:	mov	dh,al
outb:	stosb
outnx:	cmp	di,dstend
	jae	xqq
	dec	si
	jns	doout
	cmp	prevcode,0
	je	donecde
	xor	ax,ax
	cmp	curcode,0
	jle	is_byte
	inc	ax
is_byte:mov	si,low2scn
	sub	al,useflag[si]
	add	useflag[si],al
	cbw
	add	lowused,ax
	inc	si
	cmp	si,500
	jb	newscan
	xor	si,si
newscan:mov	low2scn,si
	xor	ax,ax
	cmp	lowused,375
	jge	toomuch
	inc	ax
toomuch:xor	al,splitf
	jz	not_sw
	mov	ax,1
	mov	cl,byte ptr bitcnt
	shl	ax,cl
	xor	splitf,1
	jnz	issplit
	sub	ax,100h
issplit:mov	allcds,ax
not_sw:	cmp	usedcds,1F00h-1
	jne	arefree
	mov	si,cd2ruse
	mov	cx,101h
scanlp:	inc	si
	cmp	si,1F00h
	jne	nowrap
	mov	si,1
nowrap:	movzx	ax,impflag[si]
	cmp	ax,cx
	jae	notthis
	mov	cx,ax
	mov	bp,si
notthis:dec	impflag[si]
	jz	takeit
	cmp	si,cd2ruse
	jne	scanlp
takeit:	mov	cd2ruse,si
	mov	si,bp
	jmp	short inscode
arefree:inc	usedcds
	mov	si,usedcds
	cmp	si,allcds
	jb	inscode
	inc	bitcnt
	mov	ax,bmask
	inc	ax
	add	bmask,ax
	mov	ax,1
	mov	cl,byte ptr bitcnt
	shl	ax,cl
	test	splitf,1
	jnz	isspl1
	sub	ax,100h
isspl1:	mov	allcds,ax
inscode:mov	al,lastbyte
	mov	lzbytes[si],al
	mov	impflag[si],2
	add	si,si
	mov	ax,prevcode
	mov	lzcodes[si],ax
donecde:mov	ax,curcode
	mov	prevcode,ax
	cmp	ebx,srcend
	jb	xloop
xqq:	retn
	even
bitcnt	dd	?
srcend	dd	?
dstend	dw	?
bmask	dw	?
allcds	dw	?
cd2ruse	dw	?
usedcds	dw	?
curcode	dw	?
prevcode dw	?
low2scn	dw	?
lowused	dw	?
lastbyte db	?
splitf	db	?
lzstr	db	1F00h dup(?)	;0022h
lzcodes	dw	1F00h dup(?)	;1F22h
lzbytes	db	1F00h dup(?)	;5D22h
impflag	db	1F00h dup(?)	;7C22h
useflag	db	500 dup(?)	;9B22h
unp_data endp
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
