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
	jc	errdd
	mov	dx,offset pbuf
	mov	cx,768
	xchg	bx,ax
	mov	ah,3Fh
	int	21h
	jnc	m1c
ed0:	jmp	errd0
m1c:	cmp	cx,ax
	jne	ed0
	mov	ah,3Eh
	int	21h
	jnc	m1b
errdd:	jmp	errd
m1b:	mov	ax,3D00h
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
	cmp	word ptr ds:[0],0
	je	nocompr
	mov	ax,ds
	add	ax,1000h
	mov	es,ax
	xor	si,si
	xor	di,di
	mov	ax,[si]
	mov	cx,9
	rep	movsb
	add	ax,si
	push	ax	;enddata
	movzx	esp,sp
	xor	ecx,ecx
	xor	eax,eax
	xor	ebp,ebp
	add	si,4
	lodsw
	mov	bp,si
	lea	si,[esi][eax*4]
	xor	dx,dx
	mov	bl,[si]
	mov	bh,0FFh
	inc	si
nxcde:	xor	ax,ax
nxbit:	test	bh,bh
	jnz	gotbit
	cmp	si,[esp]
	jae	nodata
	mov	bl,[si]
	mov	bh,0FFh
	inc	si
gotbit:	xor	cx,cx
	shr	bx,1
	rcl	cx,2
	lea	ecx,[ecx][4*eax]
	mov	ax,ds:[ecx][ebp]
	test	ax,ax
	jns	nxbit
	not	ax
	cmp	ax,100h
	je	nrmx
	test	dh,dh
	jnz	dorep
	cmp	ax,90h
	je	setrep
	mov	dl,al
	stosb
	jmp	short nxcde
setrep:	mov	dh,1
	jmp	short nxcde
dorep:	test	ax,ax
	jz	wrt90
	mov	cx,ax
	mov	al,dl
	dec	cx
	rep	stosb
	mov	dh,0	
	jmp	short nxcde
wrt90:	mov	al,90h
	stosb
	mov	dh,0
	jmp	short nxcde
nrmx:
nodata:	pop	ax
	push	es
	pop	ds
	push	cs
	pop	es
nocompr:mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
	mov	ax,0A000h
	mov	es,ax
	mov	si,4
	xor	di,di
	lodsw
	mov	bx,ax
	lodsw
	mov	dx,ax
	lodsb
	test	al,1
	jz	mvl
	mov	ah,[si]
mvlt:	mov	cx,bx
mvlt1:	lodsb
	cmp	ah,al
	je	mtskp
	mov	es:[di],al
mtskp:	inc	di
	loop	mvlt1
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvlt
	jmp	short mvx
mvl:	mov	cx,bx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mvl
mvx:	mov	ah,0
	int	16h
	mov	ax,3
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
wjcp	db	'Spelljammer .MSH files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:MSHVIEW filename.MSH filename.PAL',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
