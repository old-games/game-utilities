cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.386
	include parse.asm
	org	100h
start:	mov	sp,offset len
	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	idx
	mov	si,idx
	or	si,si
	jz	m1
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
m1a:	dec	dx
	mov	nmr,dx
m1:	mov	ax,3D00h
	mov	dx,offset res
	int	21h
	jnc	mnx
mq:	mov	dx,offset perr
	mov	ah,9
	int	21h
	int	20h
mnx:	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,8
	mov	dx,offset hdr
	int	21h
	jc	mq
	mov	ah,3Fh
	mov	cx,rescnt1
	lea	cx,[ecx+ecx-2]
	mov	dx,offset resdir
	int	21h
	mov	hdl,bx
	movzx	ebx,rescnt1
	lea	ebx,[ebx+ebx-2+8]
	add	ebx,uksize
	mov	cx,nmr
	jcxz	mnl1
	xor	eax,eax
	mov	si,dx
ml1:	lodsw
	add	ebx,eax
	loop	ml1
mnl1:	mov	curoff,ebx
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pal
	int	10h
m_res:	mov	edx,curoff
	shld	ecx,edx,16
	mov	ax,4200h
	mov	bx,hdl
	int	21h
	mov	si,nmr
	add	si,si
	mov	cx,resdir[si]
	xor	dx,dx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	int	21h
	mov	ax,ds:[2]
	shr	ax,10
	cmp	ax,20h
	je	mskip
	mov	ax,ds:[0]
	and	ax,3FFh
	jz	mskip
	cmp	ax,320
	ja	mskip
	mov	ax,ds:[2]
	and	ax,3FFh
	jz	mskip
	cmp	ax,200
	ja	mskip
	mov	ax,ds:[2]
	shr	ax,10
	cmp	ax,1Fh
	je	m8b
	cmp	cx,24
	jb	mskip
;unpack 4-bit
	and	dword ptr ds:[0],03FF03FFh
	lea	bp,[ecx-10h]
	movzx	ebp,bp
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	ax,ds:[0]
	mul	word ptr ds:[2]
	mov	dx,ax
	mov	si,7
	xor	edi,edi
	mov	bl,1
m4nxt:	call	getnib
	cmp	al,6
	je	m4cp1
	cmp	al,7
	je	m4pnt
	cmp	al,8
	jb	m4tb1
	cmp	al,0Eh
	je	m4cpy
	cmp	al,0Fh
	je	m4fill
m4tfil:	xor	al,9
	mov	cl,al
	shl	cl,2
	mov	eax,ds:[4]
	shr	eax,cl
	and	eax,0Fh
	jmp	short m4fl1
m4cp1:	mov	eax,edi
	sub	ax,ds:[0]
	mov	al,es:[eax]
	stosb
	jmp	short m4loop
m4pnt:	call	getnib
	jmp	short m4tb2
m4tb1:	xor	al,1
	mov	cl,al
	shl	cl,2
	mov	eax,ds:[4]
	shr	eax,cl
	and	eax,0Fh
m4tb2:	mov	al,ds:[ebp][eax]
	stosb
	jmp	short m4loop
m4cpy:	call	getlen
	push	esi
	mov	si,di
	sub	si,ds:[0]
	seges
	rep	movsb
	pop	esi
	jmp	short m4loop
m4fill:	call	getnib
m4fl1:	mov	al,ds:[ebp][eax]
	call	getlen
	rep	stosb
m4loop:	cmp	di,dx
	jb	m4nxt
	inc	si
	cmp	si,bp
	jb	mskip
	jmp	outpic0
m8b:	cmp	cx,10
	jb	mskip
	mov	al,ds:[6]
	cmp	al,1
	jbe	mskip
	cmp	al,3
	ja	mskip
	je	mtype3
;unpack 8-bit type 2
mtype2:	and	dword ptr ds:[0],03FF03FFh
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	dx,cx
	mov	si,8
	xor	di,di
m2l0:	lodsb
	mov	ah,0FFh
	mov	bx,ax
m2l1:	shr	bx,1
	jnc	m2cpy
	movsb
	jmp	short m2lp
m2cpy:	lodsw
	mov	cx,ax
	and	cx,0Fh
	add	cl,3
	shr	ax,4
	xchg	ax,si
	neg	si
	add	si,di
	seges
	rep	movsb
	mov	si,ax
m2lp:	cmp	si,dx
	jae	outpic1
	test	bh,bh
	jnz	m2l1
	jmp	short m2l0
;unpack 8-bit type 3
mtype3:	and	dword ptr ds:[0],03FF03FFh
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	dx,cx
	mov	si,8
	xor	di,di
m3l0:	lodsb
	mov	ah,0FFh
	mov	bx,ax
m3l1:	shr	bx,1
	jnc	m3cpy
	movsb
	jmp	short m3lp
m3cpy:	lodsw
	mov	cx,ax
	and	cx,1Fh
	add	cl,3
	shr	ax,5
	xchg	ax,si
	neg	si
	add	si,di
	seges
	rep	movsb
	mov	si,ax
m3lp:	cmp	si,dx
	jae	outpic1
	test	bh,bh
	jnz	m3l1
	jmp	short m3l0
;output graphics
outpic0:mov	dx,ds:[2]
	mov	bx,ds:[0]
	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	xor	di,di
mpl2:	mov	cx,bx
mpl1:	lodsb
	test	al,al
	je	mpsk
	stosb
	loop	mpl1
	jmp	short mpnx
mpsk:	inc	di
	loop	mpl1
mpnx:	add	di,320
	sub	di,bx
	dec	dx
	jnz	mpl2
	jmp	short mki
outpic1:mov	dx,ds:[2]
	mov	bx,ds:[0]
	push	es
	pop	ds
	mov	cx,0A000h
	mov	es,cx
	xor	si,si
	xor	di,di
mpl3:	mov	cx,bx
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mpl3
;kbd dialog
mki:	push	cs
	push	cs
	pop	ds
	pop	es
	mov	ah,0
	int	16h
	cmp	al,27
	jne	mnx1
mq1:	mov	bx,cs:hdl
	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	int	20h
mnx1:	cmp	al,0
	jne	mki
	mov	al,ah
	cmp	al,72
	jne	mkr3
	mov	icr,-1
	jmp	short mclr
mkr3:	cmp	al,80
	jne	mkr4
	mov	icr,1
	jmp	short mclr
mkr4:	cmp	al,59
	jne	mki
	mov	ax,nmr
	inc	ax
	mov	di,offset tmstr
	mov	bx,100
	div	bl
	mov	dl,ah
	aam
	xchg	al,ah
	xchg	ax,dx
	aam
	xchg	al,ah
	xchg	ax,dx
	mov	bx,3030h
	add	ax,bx
	add	dx,bx
	stosw
	mov	ax,dx
	stosw
	mov	ax,1300h
	mov	bx,0FFh
	mov	cx,4
	mov	dx,181Bh
	sub	di,4
	mov	bp,di
	int	10h
	mov	ah,0
	int	16h
	mov	bp,di
	mov	al,219
	rep	stosb
	mov	cl,4
	mov	bl,0
	mov	ax,1300h
	int	10h
	jmp	mki
;clear screen
mclr:	mov	ax,0A000h
	mov	es,ax
	xor	eax,eax
	xor	di,di
	mov	cx,16000
	rep	stosd
;skip to next/previous picture
mskip:	push	cs
	pop	ds
mskip1:	mov	ax,icr
	add	nmr,ax
	jns	mst1
	mov	icr,1
	jmp	short mskip1
mst1:	mov	bx,nmr
	cmp	bx,rescnt1
	jae	mq1
	add	bx,bx
	test	ax,ax
	js	mstb
	movzx	eax,word ptr resdir[bx]-2
	add	curoff,eax
	jmp	m_res
mstb:	movzx	eax,word ptr resdir[bx]
	sub	curoff,eax
	jmp	m_res
getnib:	cmp	si,bp
	jae	mnsk
	xor	bl,1
	jz	mnb1
	lodsb
	and	eax,0Fh
	retn
mnb1:	movzx	eax,byte ptr [si]
	shr	al,4
	retn
mnsk:	pop	ax
	cmp	ax,offset getlen
	jb	mskip
	pop	eax
	pop	ax
	jmp	mskip
getlen:	push	eax
	call	getnib
	mov	ecx,eax
	cmp	cl,0Fh
	je	mgl1
	add	cl,2
	pop	eax
	retn
mgl1:	call	getnib
	mov	ecx,eax
	call	getnib
	shl	cl,4
	or	cl,al
	cmp	cl,0FFh
	je	mgl2
	add	cx,11h
	pop	eax
	retn
mgl2:	call	getnib
	mov	ecx,eax
	call	getnib
	shl	cl,4
	or	cl,al
	call	getnib
	shl	cx,4
	or	cl,al
	call	getnib
	shl	cx,4
	or	cl,al
	pop	eax
	retn
res	db	'graphics.dat',0
nme	db	'Dungeon Master 2 (32-bit version) resource viewer',13,10
	db	'(C) 2000 by White Jaguar',13,10,'$'
perr	db	'Usage: DM2VIEW [sprite index]',13,10
	db	'File "GRAPHICS.DAT" must be in the current directory',13,10
	db	'Internal keys: F1 - display current sprite index,',13,10
	db	'               Down/Up - next/previous sprite.',13,10,'$'
	evendata
pal	db	0,0,0,3,2,0,7,4,0,10,6,0,14,8,1,17,10,1,21,12,1,24,14,2,29,18,4
	db	33,22,6,38,25,8,42,29,10,46,33,12,50,37,14,54,41,16,59,45,18,0
	db	0,0,2,1,3,5,2,6,7,3,9,10,4,12,13,5,15,15,6,18,18,8,22,22,9,27
	db	27,11,32,31,12,37,36,14,42,40,16,48,45,17,53,49,19,58,54,21,63
	db	0,0,0,0,0,3,0,0,6,0,0,9,0,0,12,0,0,15,0,0,18,0,0,21,0,0,26,0,0
	db	31,0,0,37,0,0,42,0,0,47,0,0,53,0,0,58,0,0,63,0,0,0,1,1,4,2,3,8
	db	4,5,12,5,7,16,7,9,20,8,11,25,10,13,29,9,19,33,7,26,37,6,32,42,5
	db	38,46,4,44,50,2,51,55,1,57,59,0,63,63,0,0,0,4,3,2,8,7,5,13,11,7
	db	17,15,10,22,19,13,26,23,15,30,27,18,35,31,21,39,35,23,45,43,27
	db	51,50,30,54,53,35,57,55,39,60,58,44,63,60,49,0,0,0,2,3,2,4,7,4
	db	6,11,6,8,15,8,10,18,10,12,22,12,14,26,14,17,30,17,20,35,20,24
	db	39,24,28,44,28,32,49,32,36,54,36,39,58,39,43,63,43,0,0,0,1,2,1
	db	2,5,2,3,8,3,4,11,4,5,14,5,8,20,8,5,24,8,2,28,8,0,32,8,1,34,14,2
	db	37,21,4,40,28,11,45,31,18,50,34,25,55,38,0,0,0,0,2,0,0,4,0,0,6
	db	0,0,9,0,0,11,0,0,13,0,0,18,0,0,22,0,0,27,0,0,31,0,0,36,0,0,44,0
	db	0,52,0,0,57,0,0,63,0,0,0,0,4,4,0,8,8,0,12,12,0,17,17,0,21,21,0
	db	25,25,0,29,29,0,34,34,0,38,38,0,42,42,0,46,46,0,51,51,0,55,55,0
	db	59,59,0,63,63,0,0,0,0,4,3,0,8,6,0,12,9,0,17,12,0,21,15,0,25,18
	db	0,29,21,0,34,24,0,38,28,0,42,31,0,46,34,0,51,37,0,55,40,0,59,43
	db	0,63,46,0,0,0,0,4,2,0,8,4,0,12,6,0,17,9,0,21,11,0,25,13,0,29,15
	db	0,34,18,0,38,20,0,42,22,0,46,24,0,51,27,0,55,29,0,59,31,0,63,34
	db	0,0,0,0,4,0,0,8,0,0,12,0,0,17,0,0,21,0,0,25,0,0,29,0,0,34,0,0
	db	38,0,0,42,0,0,46,0,0,51,0,0,55,0,0,59,0,0,63,0,0,0,0,0,1,0,0,3
	db	1,0,4,2,0,6,3,0,8,3,0,11,5,1,13,6,1,16,7,1,19,8,2,22,10,2,25,12
	db	4,27,14,5,30,17,7,33,19,8,36,21,10,0,0,0,4,3,2,8,6,4,13,9,7,17
	db	12,9,21,15,11,26,18,14,30,21,16,34,24,18,39,27,21,43,30,23,47
	db	33,25,52,36,28,55,41,31,59,46,34,63,51,38,0,0,0,2,2,2,5,5,4,8,8
	db	6,11,11,9,14,14,11,17,17,13,20,20,16,24,24,20,28,28,24,32,32,28
	db	36,36,32,40,40,36,44,44,40,48,48,44,52,52,48,0,0,0,2,2,2,5,5,5
	db	7,7,7,10,10,10,13,13,13,15,15,15,20,20,20,24,24,24,28,28,28,36
	db	36,36,40,40,40,44,44,44,50,50,50,57,57,57,63,63,63
nmr	dw	0
icr	dw	1
idx	dw	?
hdl	dw	?
hdr	equ	this byte
ftype	db	?
fsign	db	?
rescnt1	dw	?
uksize	dd	?
curoff	dd	?
resdir	dw	1600h dup(?)
tmstr	db	6 dup(?)
stk	dw	512 dup(?)
len	equ	$
cseg	ends
end	start