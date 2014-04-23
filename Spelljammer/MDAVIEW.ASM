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
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	ax,ds:[4]
	mul	word ptr ds:[6]
	mov	dx,ax
	mov	si,ds:[0Ch]
	xor	di,di
	call	unpcx
	push	cs
	pop	es
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
	mov	ax,ds:[8]
	shl	ax,2
	mov	bp,0Ch
	add	ax,bp
	push	ax
	mov	ax,0A000h
	mov	es,ax
	call	drawp1
	jmp	short mkb
nxpg:	mov	si,ds:[bp]
blkl:	lodsb
	cmp	al,0
	jne	blkn0
	lodsw
	mov	di,ax
	lodsw
	mov	dx,320
	mul	dx
	add	di,ax
	lodsw
blk0a:	mov	dx,ax
	add	dx,di
	call	unpcx
	jmp	short blkl
blkn0:	cmp	al,1
	jne	blkn1
	lodsw
	mov	di,ax
	lodsw
	mov	dx,320
	mul	dx
	add	di,ax
	lodsw
blk1a:	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short blkl
blkn1:	cmp	al,2
	jne	blkn2
	xor	ax,ax
	lodsb
	mov	di,ax
	lodsb
	mov	dx,320
	mul	dx
	add	di,ax
	xor	ax,ax
	lodsb
	jmp	short blk0a
blkn2:	cmp	al,3
	jne	blkx
	xor	ax,ax
	lodsb
	mov	di,ax
	lodsb
	mov	dx,320
	mul	dx
	add	di,ax
	xor	ax,ax
	lodsb
	jmp	short blk1a
blkx:
mkb:	mov	ah,0
	int	16h
	cmp	al,27
	je	mqq
	add	bp,4
	pop	ax
	push	ax
	cmp	bp,ax
	jb	nxpg
mqq:	mov	ax,3
	int	10h
	int	20h
unpcx:	cmp	di,dx
	jae	mupx
	lodsb
	cmp	al,0C0h
	jae	mucp
	stosb
	jmp	short unpcx
mucp:	and	ax,3Fh
	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short unpcx
mupx:	retn
drawp1:	mov	bx,ds:[4]
	mov	dx,ds:[6]
	push	ds
	mov	ax,cs
	add	ax,2000h
	mov	ds,ax
	xor	si,si
	xor	di,di
mp1l:	mov	cx,bx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mp1l
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
wjcp	db	'Spelljammer .MDA files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:MDAVIEW filename.MDA filename.PAL',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
