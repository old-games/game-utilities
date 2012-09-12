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
	mov	dx,svn1
	or	dx,dx
	jz	mx
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
	push	ax
	mov	ax,13h
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
	mov	cs:flen,ax
	mov	ah,3Eh
	int	21h
	xor	si,si
nxp:	push	si
	mov	ax,ds
	add	ax,1000h
	mov	es,ax
	mov	ax,[si]+4
	mul	word ptr [si]+6
	mov	bx,ax
	xor	di,di
	test	byte ptr [si]+8,3
	jnz	mm2
	test	byte ptr [si]+8,4
	jnz	mm4
	test	byte ptr [si]+8,8
	jnz	mm8
	push	ds
	pop	es
	lea	di,[si]+0Ch
mdis:	push	es
	pop	fs
	mov	ax,0A000h
	mov	es,ax
	mov	si,di
	pop	di
	push	di
	mov	ax,[di]+2
	imul	ax,ax,320
	add	ax,[di]
	mov	dx,[di]+6
	mov	bx,[di]+4
	mov	di,ax
mpl2:	mov	cx,bx
mpl1:	segfs
	lodsb
	test	al,al
	jz	mskp1
	mov	es:[di],al
mskp1:	inc	di
	loop	mpl1
	sub	di,bx
	add	di,320
	dec	dx
	jnz	mpl2
	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
	pop	si
	add	si,[si]+0Ah
	add	si,0Ch
	cmp	si,cs:flen
	jb	nxp
mqq:	mov	ax,3
	int	10h
	int	20h
mm2:	add	si,0Ch
mbnx:	lodsb
	mov	cl,al
	and	cx,7Fh
	inc	cx
	test	al,al
	jns	mbc
	lodsb
	rep	stosb
	jmp	short mbl
mbc:	rep	movsb
mbl:	cmp	di,bx
	jb	mbnx
mux:	xor	di,di
	jmp	mdis
mm4:	add	si,0Ch
	mov	di,-0FEEh
	mov	ax,2020h
	mov	cx,0FEEh/2
	rep	stosw
mlf:	lodsb
	mov	dl,al
	mov	dh,0FFh
mln:	shr	dx,1
	jnc	mls
	movsb
mln1:	cmp	di,bx
	jae	mux
	test	dh,dh
	jz	mlf
	jmp	short mln
mls:	lodsw
	mov	cl,ah
	and	cx,0Fh
	add	cx,3
	shr	ah,4
	lea	bp,[di]+0FEEh
	and	bp,0F000h
	add	bp,ax
	sub	bp,0FEEh
	cmp	bp,di
	jb	mls1
	sub	bp,1000h
mls1:	xchg	bp,si
	seges
	rep	movsb
	mov	si,bp
	jmp	short mln1
mm8:	add	si,0Ch
	call	unp8
	xor	di,di
	jmp	mdis
;src DS:SI, dst ES:0
;As COM-programs have SS=CS,[BP] addressing is used here without CS: prefix
;For the same consideration,[EBP][EBP] addressing is used instead of [EBP*2]
;(SS: prefix used because TASM, being too smart, puts DS: there otherwise)
unp8:	lodsw
	test	ax,ax
	jnz	short mu1
	xor	di,di
	retn
mu1:	mov	cs:realsz,ax
	call	inithuf
	mov	di,-0FC4h	;initialize buffer,for use of addr.wrapping
	mov	eax,20202020h
	mov	cx,0FC4h/4
	rep	stosd
	lodsw
	xchg	ah,al
	mov	cs:bitstr,ax
	mov	dl,16		;bitcount DL
	xor	di,di
	jmp	short mu2
mulp:	call	getcde
	test	bh,bh
	jnz	short mu_lz
	mov	al,bl
	stosb
	jmp	short mu2
mu_lz:	add	bl,3
	mov	dh,bl
	call	getofs
	push	si
	lea	si,[di]-1
	sub	si,bx
	movzx	cx,dh
	seges
	repe	movsb
	pop	si
mu2:	cmp	di,cs:realsz
	jb	mulp
	retn
inithuf:push	es	;Huffman data initialization
	push	cs
	pop	es
	mov	di,offset cdweigh
	mov	cx,13Ah
	mov	ax,1
	rep	stosw
	mov	di,offset cdtree
	mov	ax,273h
	mov	cx,13Ah
mil1:	stosw
	inc	ax
	loop	mil1
	mov	di,offset cdwords+273h*2
	xor	ax,ax
	mov	cx,13Ah
mil2:	stosw
	inc	ax
	loop	mil2
	mov	bx,offset cdweigh
	lea	di,[bx]+13Ah*2
	mov	cx,273h-13Ah
mil3:	mov	ax,cs:[bx]
	add	ax,cs:[bx]+2
	stosw
	add	bx,4
	loop	mil3
	mov	ax,-1
	stosw
	mov	di,offset cdtree+13Ah*2
	xor	ax,ax
	mov	cx,273h-13Ah
mil4:	stosw
	inc	ax
	inc	ax
	loop	mil4
	mov	di,offset cdwords
	mov	ax,13Ah
	mov	cx,273h-13Ah
mil5:	stosw
	stosw
	inc	ax
	loop	mil5
	xor	ax,ax
	stosw
	pop	es
	retn
getcde:	movzx	ebx,word ptr cs:cdtree+272h*2	;get compression code
	jmp	short mg1
mgl:	shl	cs:bitstr,1
	adc	bx,0
	mov	bx,cs:cdtree[ebx*2]
	dec	dl
	jnz	short mg1
	lodsw
	xchg	ah,al
	mov	cs:bitstr,ax
	mov	dl,16
mg1:	cmp	bx,273h
	jb	mgl
	sub	bx,273h
	push	bx
	call	doadapt
	pop	bx
	retn
doadapt:mov	bx,cs:cdwords[ebx*2]+273h*2	;adaptive Huffman decoding
mhlp:	lea	ecx,cdweigh[ebx*2]
	mov	ebp,ecx
	inc	word ptr [bp]
	mov	ax,[bp]
	cmp	[bp]+2,ax
	jae	short mh1
mhl1:	inc	bp
	inc	bp
	cmp	[bp]+2,ax
	jb	short mhl1
	xchg	ax,[bp]
	mov	cs:[ecx],ax
	sub	bp,offset cdweigh
	shr	bp,1
	mov	cx,cs:cdtree[ebx*2]
	mov	cs:cdwords[ecx*2],bp
	cmp	cx,273h
	jae	short mh2
	mov	cs:cdwords[ecx*2]+2,bp
mh2:	xchg	cx,ss:cdtree[ebp][ebp]
	mov	cs:cdwords[ecx*2],bx
	cmp	cx,273h
	jae	short mh3
	mov	cs:cdwords[ecx*2]+2,bx
mh3:	mov	cs:cdtree[ebx*2],cx
	mov	bx,bp
mh1:	mov	bx,cs:cdwords[ebx*2]
	test	bx,bx
	jnz	mhlp
	cmp	cs:cdweigh+272h*2,8000h
	je	short rescale
	retn
rescale:push	bx
	mov	cx,273h		;rescale Huffman tree
	xor	bp,bp
	mov	bx,bp
mrl1:	cmp	cdtree[bp],273h
	jb	short mr1
	mov	ax,cdweigh[bp]
	inc	ax
	shr	ax,1
	mov	cs:cdweigh[bx],ax
	mov	ax,cdtree[bp]
	mov	cs:cdtree[bx],ax
	inc	bx
	inc	bx
mr1:	inc	bp
	inc	bp
	loop	mrl1
	xor	bp,bp
	mov	cx,13Ah*2
mrl2:	mov	ax,cdweigh[bp]
	add	ax,cdweigh[bp]+2
	mov	bx,cx
mr2:	dec	bx
	dec	bx
	cmp	cs:cdweigh[bx],ax
	ja	short mr2
	inc	bx
	inc	bx
	shl	eax,16
	mov	ax,bp
	shr	ax,1
mr3:	xchg	ax,cs:cdtree[bx]
	rol	eax,16
	xchg	ax,cs:cdweigh[bx]
	rol	eax,16
	inc	bx
	inc	bx
	cmp	bx,cx
	jbe	short mr3
	add	bp,4
	inc	cx
	inc	cx
	cmp	cx,273h*2
	jb	mrl2
	mov	cx,273h
	xor	bx,bx
mrl3:	mov	bp,cs:cdtree[ebx*2]
	cmp	bp,273h
	lea	bp,cdwords[ebp*2]
	mov	[bp],bx
	jae	short mr4
	mov	[bp]+2,bx
mr4:	inc	bx
	loop	mrl3
	pop	bx
	retn
getofs:	xor	ebx,ebx		;read offset for LZ
	mov	ch,byte ptr cs:bitstr+1
	shl	cs:bitstr,8
	sub	dl,8
	ja	mo1
	mov	cl,dl
	neg	cl
	lodsw
	xchg	ah,al
	shld	bx,ax,cl
	shl	ax,cl
	mov	cs:bitstr,ax
	add	dl,16
mo1:	or	bl,ch
	mov	ch,cs:ctbl1[bx]
	mov	cl,cs:ctbl2[bx]
	sub	cl,2
	mov	ax,cs:bitstr
	sub	dl,cl
	ja	short mo2
	add	cl,dl
	shld	bx,ax,cl
	lodsw
	xchg	ah,al
	mov	cl,dl
	neg	cl
	add	dl,16
mo2:	shld	bx,ax,cl
	shl	ax,cl
	mov	cs:bitstr,ax
	shl	bx,2
	mov	bh,ch
	shr	bx,2
	retn
	evendata
ctbl1	db	20h dup(0),10h dup(1),10h dup(2),10h dup(3),8 dup(4),8 dup(5)
	db	8 dup(6),8 dup(7),8 dup(8),8 dup(9),8 dup(0Ah),8 dup(0Bh)
      	db	4 dup(0Ch),4 dup(0Dh),4 dup(0Eh),4 dup(0Fh),4 dup(10h)
      	db	4 dup(11h),4 dup(12h),4 dup(13h),4 dup(14h),4 dup(15h)
      	db	4 dup(16h),4 dup(17h),18h,18h,19h,19h,1Ah,1Ah,1Bh,1Bh,1Ch,1Ch
      	db	1Dh,1Dh,1Eh,1Eh,1Fh,1Fh,20h,20h,21h,21h,22h,22h,23h,23h,24h,24h
      	db	25h,25h,26h,26h,27h,27h,28h,28h,29h,29h,2Ah,2Ah,2Bh,2Bh,2Ch,2Ch
      	db	2Dh,2Dh,2Eh,2Eh,2Fh,2Fh,30h,31h,32h,33h,34h,35h,36h,37h,38h,39h
      	db	3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
ctbl2	db	20h dup(3),30h dup(4),40h dup(5),30h dup(6),30h dup(7)
	db	10h dup(8)
bitstr	dw	0
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
wjcp	db	'Arena .CIF files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:CIFVIEW filename.CIF filename.PAL',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-repaint screen & show next,',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
flen	dw	?
pbuf	db	300h dup(?)
realsz	dw	?
cdtree	dw	273h dup(?)
cdweigh	dw	(273h+1) dup(?)
cdwords	dw	(273h+13Ah) dup(?)
cseg	ends
end	start
