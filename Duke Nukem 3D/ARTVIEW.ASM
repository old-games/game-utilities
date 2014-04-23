cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include	parse.asm
	.386
	org	100h
maxart	equ	512
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	nam
	mov	ax,3D00h
	mov	dx,offset pnm
	int	21h
	jc	errc
	xchg	ax,bx
	mov	dx,offset pbuf
	mov	cx,300h
	mov	ah,3Fh
	int	21h
	mov	ah,3Eh
	int	21h
	mov	ax,3D00h
	mov	dx,nam
	int	21h
	jc	mx
	mov	fhdl,ax
	xchg	ax,bx
	mov	dx,offset ahdr
	mov	cx,16
	mov	ah,3Fh
	int	21h
	mov	eax,stopn
	sub	eax,startn
	inc	eax
	cmp	ax,maxart
	ja	errx
	mov	fcnt,ax
	shl	eax,1
	push	eax
	mov	cx,ax
	mov	dx,offset xszs
	mov	ah,3Fh
	int	21h
	mov	dx,offset yszs
	mov	ah,3Fh
	int	21h
	mov	cx,fcnt
	pop	eax
	lea	eax,[4*eax]+10h
	mov	di,offset ofss
	xor	si,si
	xor	bp,bp
ml1:	stosd
	xchg	ebx,eax
	mov	ax,xszs[si]
	mul	yszs[si]
	shl	edx,16
	jz	m3
	mov	bp,1
m3:	mov	dx,ax
	lea	eax,[edx][ebx]
	inc	si
	inc	si
	loop	ml1
	test	bp,bp
	jz	m4
	mov	dx,offset zerr
	mov	ah,9
	int	21h
	mov	ah,0
	int	16h
m4:	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	xor	esi,esi
mrp:	push	esi
	mov	bx,cs:fhdl
	mov	dx,word ptr cs:ofss[4*esi]
	mov	cx,word ptr cs:ofss[4*esi]+2
	mov	ax,4200h
	int	21h
	mov	ax,cs:xszs[2*esi]
	mul	cs:yszs[2*esi]
	test	dx,dx
	jz	mmm
	mov	ax,-1
mmm:	mov	cx,ax
	jcxz	next
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	mov	dx,cs:yszs[2*esi]
	mov	bx,cs:xszs[2*esi]
	xor	si,si
	mov	di,si
ml3:	push	di
	mov	cx,dx
ml2:	lodsb
	cmp	al,255
	je	m1
	mov	es:[di],al
m1:	add	di,320
	loop	ml2
	pop	di
	inc	di
	dec	bx
	jnz	ml3
	mov	ah,0
	int	16h
	cmp 	al,27 
	je 	exit
	cmp 	ah,72
	jne 	next
	pop	esi
	dec	esi
	jns	nx1
	xor	esi,esi
	jmp	short nx1
next:	pop	esi
	inc	esi
	cmp	si,cs:fcnt
	jae	exit
nx1:	xor	di,di
	mov	cx,32000
	xor	ax,ax
	rep	stosw
	jmp	mrp
exit:	mov	bx,cs:fhdl
	mov	ah,3Eh
	int	21h
	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h
errc:	mov	dx,offset cerr
	jmp	short mx1
errx:	mov	ah,3Eh
	int	21h
	mov	dx,offset xerr
	jmp	short mx1
errv:	mov	ax,3
	int	10h
	mov	dx,offset aerr
mx2:	mov	bx,fhdl
	mov	ah,3Eh
	int	21h
	jmp	short mx1
pnm	db	'palette.dat',0
wjcp	db	'Duke Nukem 3D .ART files viewer',13,10
	db	'Copyright (C) 1999 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:ARTVIEW filename.ART',13,10,'$'
cerr	db	'PALETTE.DAT not found!',13,10,'$'
xerr	db	'Too many sprites in file!',13,10,'$'
zerr	db	'Some sprites are too large to display correctly!',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
nam	dw	?
pbuf	db	300h dup (?)
ahdr	dd	?,?
startn	dd	?
stopn	dd	?
fcnt	dw	?
fhdl	dw	?
xszs	dw	maxart dup(?)
yszs	dw	maxart dup(?)
ofss	dd	maxart dup(?)
cseg	ends
end	start
