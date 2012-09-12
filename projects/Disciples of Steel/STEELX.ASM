cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.386
	include parse.asm
	org	100h
start:	mov	sp,offset len
	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	fnm,idx
	mov	si,idx
	or	si,si
	jz	mq
	xor	dx,dx
	mov	ah,dl
mll:	lodsb
	or	al,al
	jz	m1a
	sub	al,30h
	jb	mq
	cmp	al,9
	ja	mq
	imul	dx,dx,10
	add	dx,ax
	jmp	short mll
m1a:	mov	nmr,dx
	mov	ax,3D00h
	mov	dx,fnm
	int	21h
	jnc	mnx
mq:	mov	dx,offset perr
	mov	ah,9
	int	21h
	int	20h
mnx:	mov	hdl,ax
	xchg	ax,bx
	mov	dx,offset hdr1
	mov	cx,800
	mov	ah,3Fh
	int	21h
	jc	mq
	cmp	ax,cx
	jne	mq
	mov	si,offset hdr1
	mov	di,offset ofss
	mov	cx,200
	mov	ebx,800
mlof:	xor	eax,eax
	lodsw
	lea	eax,[ebx+2*eax]
	xchg	eax,ebx
	stosd
	loop	mlof
	call	do_extract
	mov	ah,3Ch
	mov	dx,offset nnm
	mov	cx,20h
	int	21h
	xchg	ax,bx
	push	es
	pop	ds
	mov	ah,40h
	xor	dx,dx
	mov	cx,di
	int	21h
	mov	ah,3Eh
	int	21h
qqq:	mov	bx,cs:hdl
	mov	ah,3Eh
	int	21h
	int	20h
;------
do_extract proc	near
	; out: data ES:0,datasize DI
	mov	si,nmr
	add	si,si
	mov	ax,hdr1[si]
	test	ax,ax
	jz	qqq
	mov	ax,nmr
	aam
	add	nnm+6,al
	mov	al,ah
	aam
	xchg	ah,al
	add	word ptr nnm+4,ax
	add	si,si
	mov	cx,word ptr ofss[si+2]
	mov	dx,word ptr ofss[si]
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	shr	si,1
	mov	cx,hdr1[si]
	add	cx,cx
	mov	ax,offset len+16
	shr	ax,4
	mov	di,cs
	add	di,ax
	mov	fs,di
	mov	ds,di
	mov	ah,3Fh
	xor	dx,dx
	int	21h
	add	cx,16
	shr	cx,4
	add	di,cx
	mov	es,di
	push	cs
	pop	ds
	mov	ax,hdr2[si]
	add	ax,ax
	jnc	xunp
	mov	di,hdr1[si]
	add	di,di
	push	fs
	pop	es
	retn
xunp:	mov	cx,hdr1[si]
	add	cx,cx
	mov	dx,hdr2[si]
	add	dx,dx
	push	dx
	xor	si,si
	mov	di,si
	call	unp_data
	pop	di
	retn
do_extract endp
nme	db	'Disciples of Steel resource unpacker',13,10
	db	'(C) 1999 by White Jaguar',13,10,'$'
perr	db	'Usage: STEELX filename.MK1 block_index',13,10,'$'
nnm	db	'file000.bin',0
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
fnm	dw	?
idx	dw	?
hdl	dw	?
nmr	dw	?
hdr1	dw	200 dup(?)
hdr2	dw	200 dup(?)
ofss	dd	200 dup(?)
stk	dw	1024 dup(?)
len	equ	$
cseg	ends
end	start