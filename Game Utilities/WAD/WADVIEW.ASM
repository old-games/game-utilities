cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	.386P
	include parse.asm
lodsbx	macro
	db	67h
	lodsb
	endm
movsbx	macro
	db	67h
	movsb
	endm
	org	100h
start:	mov	sp,6FFEh
	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	fl,of,pn
a1:	in	al,64h			;open HMA...
	and	al,2
	jnz	short a1
	mov	al,0D1h
	out	64h,al
a2:	in	al,64h
	and	al,2
	jnz	short a2
	mov	al,0DFh
	out	60h,al			;...done
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,large offset gdt
	mov	dsc0b,eax
	lgdt	gdt
	cli
	mov	eax,cr0
	or	al,1
	mov	cr0,eax
	jmp	$+2
	mov	ax,8
	mov	es,ax
	mov	ds,ax
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	jmp	$+2
	push	cs
	push	cs
	pop	ds
	pop	es
	mov	si,of
	or	si,si
	jz	mpr
	xor	edx,edx
mo3:	lodsb
	or	al,al
	jz	mos
	cmp	al,61h
	jb	mo1
	sub	al,20h
mo1:	sub	al,30h
	jb	mpr
	cmp	al,10
	jb	mo2
	cmp	al,11h
	jb	mpr
	sub	al,7
	cmp	al,15
	ja	mpr
mo2:	shl	edx,4
	or	dl,al
	jmp	short mo3
mos:	mov	dword ptr fof0,edx
mpr:	mov	ax,3D00h
	mov	dx,pn
	or	dx,dx
	jz	mdr
	int	21h
	jc	derr
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jc	derr0
	cmp	cx,ax
	jne	derr0
	mov	ah,3Eh
	int	21h
	jc	derr
mdr:	mov	dx,fl
	or	dx,dx
	jz	perr
	mov	ax,3D00h
	int	21h
	jnc	nx
derr:	mov	dx,offset dems
derrx:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h
perr:	mov	dx,offset usgs
	jmp	short derrx
derr1:	mov	ax,3
	int	10h
derr0:	mov	ah,3Eh
	int	21h
	jmp	short derr
nx:	xchg	ax,bx
	push	bx
	mov	ax,13h
	int	10h
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	pop	bx
next:	mov	ax,4200h
	mov	cx,fof1
	mov	dx,fof0
	int	21h
	mov	dx,offset fofs
	mov	cx,16
	mov	ah,3Fh
	int	21h
	jc	derr1
	add	dword ptr fof0,16
	mov	ax,4200h
	mov	dx,word ptr fofs
	mov	cx,word ptr fofs+2
	cmp	dword ptr fsiz,0
	jne	mnz
	sub	dword ptr fof0,16
	jmp	kwait
mnz:	int	21h
	mov	ax,cs
	add	ax,800h
	mov	fs,ax
	add	ax,1000h
	mov	gs,ax
	add	ax,1000h
	mov	ds,ax
	push	ds
	xor	dx,dx
	mov	ecx,cs:fsiz
	push	cx
	shr	ecx,15
	jcxz	m1
m2:	push	cx
	mov	ah,3Fh
	mov	cx,8000h
	int	21h
	mov	ax,ds
	add	ax,800h
	mov	ds,ax
	pop	cx
	loop	m2
m1:	pop	cx
	and	cx,7FFFh
	mov	ah,3Fh
	int	21h
	pop	ds
	push	fs
	pop	es
	xor	esi,esi
	mov	edi,esi
	mov	eax,esi
	mov	cx,16000
	rep	stosd
	mov	dx,0A000h
	mov	es,dx
	mov	edi,esi
	mov	cx,16000
	rep	stosd
	lodsw
	xchg	ax,cx
	xor	dx,dx
	add	esi,6
m4:	lodsd
	push	esi
	push	cx
	xchg	eax,esi
m3:	lodsbx
	cmp	al,0FFh
	je	msx
	mov	ah,0
	imul	di,ax,320
	add	di,dx
	lodsbx
	movzx	cx,al
	lodsbx
ml:	mov	byte ptr fs:[di],0FFh
	movsbx
	add	di,319
	loop	ml
	lodsbx
	jmp	short m3
msx:	pop	cx
	pop	esi
	inc	dx
	loop	m4
kwait:	mov	ah,0
	int	16h
	cmp	ax,3C00h
	je	msv
	push	cs
	pop	ds
	cmp 	al,27 
	je 	exit
	cmp 	ah,72
	jne 	next
	sub	dword ptr fof0,32
	jmp 	next
msv:	push	bx
	push	gs
	pop	es
	mov	ax,cs
	add	ax,2800h
	mov	ds,ax
	xor	di,di
	mov	si,di
	mov	ax,1	;...
	stosw
	mov	al,10
	stosw
	mov	al,0
	stosw		;...file header
	mov	eax,[si]+4	;...
	stosd			;...insertion point as garbage
	xor	ax,ax	;...
	stosw
	lodsw		;X-size
	mov	cx,ax
	stosw
	xor	ax,ax
	stosw
	lodsw		;Y-size
	stosw		;...page header
	mov	bx,0A000h
	mov	ds,bx
	xor	si,si
	xchg	ax,cx
	jmp	short mslx
ms5:	push	cx
	mov	si,dx
	mov	al,bl
	shr	bx,6
	and	ax,3Fh
	jz	ms5a
ms5b:	mov	cx,ax
	dec	ax
	stosb
	rep	movsb
ms5a:	mov	al,40h
	dec	bx
	jns	ms5b
	pop	cx
	jmp	short msl3
mslx:	push	cx
	push	ax
	push	si
	xchg	ax,cx
	xor	ax,ax
	stosw
	push	di
	mov	bx,si
	dec	si
msl1:	inc	si
	cmp	fs:[si],al
	loopz	msl1
	je	ms4
	inc	cx
	mov	ax,si
	sub	ax,bx
	stosw
msl3:	xor	bx,bx
	mov	dx,si
msl2:	cmp	byte ptr fs:[si],0FFh
	je	ms0
	or	bx,bx
	jnz	ms5
msl4:	inc	si
	inc	bx
	cmp	byte ptr fs:[si],0
	loopz	msl4
	jcxz	ms4
	xchg	bx,cx
	mov	al,cl
	shr	cx,6
	and	al,3Fh
	jz	ms7a
	dec	ax
	or	al,80h
	stosb
ms7a:	mov	al,0BFh
	rep	stosb
ms7b:	mov	cx,bx
	jmp	short msl3
mslx0:	jmp	short mslx
ms0:	lodsb
	mov	ah,al
	cmp	[si],ax
	jne	ms2
	cmp	word ptr fs:[si],0FFFFh
	jne	ms2
	cmp	cx,3
	jb	ms2
	cmp	bl,0
	je	ms6a
	dec	si
	jmp	ms5
ms6a:	dec	cx
	dec	bx
ms6:	inc	si
	inc	bx
	cmp	byte ptr fs:[si],0FFh
	jne	ms3
	test	bl,40h
	jnz	ms3
	cmp	[si],al
ms3:	loopz	ms6
	jnz	ms8
	inc	bx
	inc	si
ms8:	mov	al,bl
	dec	ax
	or	al,0C0h
	stosw
	jcxz	ms4
	jmp	msl3
ms2:	inc	bx
	loop	msl2
	mov	si,dx
	mov	al,bl
	shr	bx,6
	and	ax,3Fh
	jz	ms2a
ms2b:	mov	cx,ax
	dec	ax
	stosb
	rep	movsb
ms2a:	mov	al,40h
	dec	bx
	jns	ms2b
ms4:	pop	bx
	mov	ax,di
	sub	ax,bx
	mov	es:[bx]-2,ax
	pop	si
	add	si,320
	pop	ax
	pop	cx
	loop	mslx0
	push	cs
	pop	ds
	mov	dx,offset fnam
	mov	ah,3Ch
	mov	cx,20h
	int	21h
	jc	exit0
	xchg	ax,bx
	mov	ah,40h
	mov	cx,di
	xor	dx,dx
	push	es
	pop	ds
	int	21h
	mov	ah,3Eh
	int	21h
	pop	bx
	push	cs
	pop	ds
	jmp	next
exit0:	pop	bx
exit:	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	int	20h
pbuf	db	0,0,0,7,5,2,5,3,1,18,18,18,63,63,63,6,6,6,4,4,4,2,2,2
	db	1,1,1,11,13,7,8,10,3,5,7,1,3,5,0,19,14,10,17,12,8,15,10,6
	db	63,45,45,61,42,42,60,40,40,58,37,37,57,35,35,55,33,33,54,30,30,52,28,28
	db	50,26,26,49,24,24,47,22,22,46,21,21,44,19,19,43,17,17,41,15,15,40,14,14
	db	38,12,12,37,11,11,35,10,10,34,8,8,32,7,7,31,6,6,29,5,5,28,4,4
	db	26,3,3,25,2,2,23,1,1,22,1,1,20,1,1,19,0,0,17,0,0,16,0,0
	db	63,58,55,63,56,52,63,54,49,63,52,46,63,51,44,63,49,41,63,47,38,63,46,36
	db	63,44,32,61,42,30,59,40,28,57,38,26,55,36,24,53,34,22,51,32,20,50,31,19
	db	47,30,18,44,28,17,42,27,16,40,26,15,38,24,14,35,23,13,33,21,12,31,20,11
	db	29,19,10,26,17,9,23,16,8,20,15,7,18,13,6,15,11,5,12,10,4,10,8,3
	db	59,59,59,57,57,57,55,55,55,54,54,54,52,52,52,50,50,50,49,49,49,47,47,47
	db	45,45,45,44,44,44,42,42,42,41,41,41,39,39,39,37,37,37,36,36,36,34,34,34
	db	32,32,32,31,31,31,29,29,29,27,27,27,26,26,26,24,24,24,22,22,22,21,21,21
	db	19,19,19,17,17,17,16,16,16,14,14,14,13,13,13,11,11,11,9,9,9,8,8,8
	db	29,63,27,27,59,25,25,55,23,23,51,21,22,47,19,20,43,17,18,39,15,16,36,13
	db	15,32,11,13,28,10,11,24,8,9,20,6,7,16,5,5,12,3,4,8,2,2,5,1
	db	47,41,35,45,39,33,43,37,31,41,35,29,39,33,27,38,31,26,36,30,24,34,28,22
	db	32,26,21,30,24,19,29,23,18,27,21,16,25,20,15,23,18,13,21,16,12,20,15,11
	db	39,32,24,35,29,20,32,26,18,29,23,15,25,20,12,22,17,10,19,14,8,16,12,6
	db	30,31,24,27,28,21,25,26,19,22,24,17,20,21,14,17,19,12,15,17,10,13,15,9
	db	63,63,28,58,54,21,53,46,16,48,38,11,43,30,7,38,22,4,33,16,1,28,10,0
	db	63,63,63,63,54,54,63,46,46,63,38,38,63,30,30,63,23,23,63,15,15,63,7,7
	db	63,0,0,59,0,0,56,0,0,53,0,0,50,0,0,47,0,0,44,0,0,41,0,0
	db	38,0,0,34,0,0,31,0,0,28,0,0,25,0,0,22,0,0,19,0,0,16,0,0
	db	57,57,63,49,49,63,42,42,63,35,35,63,28,28,63,20,20,63,13,13,63,6,6,63
	db	0,0,63,0,0,56,0,0,50,0,0,44,0,0,38,0,0,32,0,0,26,0,0,20
	db	63,63,63,63,58,54,63,53,46,63,49,38,63,44,30,63,40,22,63,35,14,63,31,6
	db	60,28,5,58,27,3,55,25,3,53,23,2,50,21,1,48,19,0,45,17,0,43,16,0
	db	63,63,63,63,63,53,63,63,44,63,63,35,63,63,26,63,63,17,63,63,8,63,63,0
	db	41,15,0,39,13,0,36,11,0,33,8,0,19,14,9,16,11,6,13,8,4,11,6,2
	db	0,0,20,0,0,17,0,0,14,0,0,11,0,0,8,0,0,5,0,0,2,0,0,0
	db	63,39,16,63,57,18,63,30,63,63,0,63,51,0,51,39,0,38,27,0,26,41,26,26
nme	db	'ID Software WAD files graphics viewer/convertor',13,10
	db	'Copyright (C) 1995 by WhiteJaguar and CLUDG',13,10,'$'
usgs	db	'Usage: WADVIEW filename.WAD [pic_desc_ofs [filename.PAL]]'
	db	13,10,'Default offset & palette are for DOOM 3 WAD',13,10
	db	'DO NOT use when EMS driver active!',13,10
	db	'Internal keys:Up-prev.image,F2-save to MM3''s .VGA file,'
	db	13,10,'any other-next image.',13,10,'$'
dems	db	'Disk error!',13,10,'$'
gdt	equ	this qword
dsc0	dw	15
dsc0b	dd	0
	dw	0
dscr	dw	2000h,0
	db	0,0F2h,80h,0
fof0	dw	7218h
fof1	dw	00E3h
fofs	dd	0
fsiz	dd	0
fnam	db	9 dup(0)
fl	dw	?
pn	dw	?
of	dw	?
lstr	dw	?,?
cseg	ends
end	start        
