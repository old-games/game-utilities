cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg
	org	100h
	.286
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	mov	si,80h		;parse parameters
	lodsb
	cbw
	or	ax,ax
	jz	mxx
	mov	cx,ax
	mov	di,si
	mov	al,' '
	repe	scasb
	jne	mnx
mxx:	jmp	mx
mnx:	dec	di
	mov	svn1,di
	inc	di
	repne	scasb
	jne	m1
	jcxz	m1e
	push	di
	mov	svn2,di
	repne	scasb
	mov	al,0
	jne	m1a
	dec	di
m1a:	cmp	di,svn2
	je	m1d
	stosb
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
m1b:	mov	lfg,1
m1d:	pop	di
m1e:	dec	di
m1:	mov	al,0
	stosb
	mov	ax,3D00h
	mov	dx,svn1
	int	21h
	jc	errd
	push	ax
	mov	ax,13h
	int	10h
	jc	errv
	cmp	lfg,0
	je	mvn
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jc	errv0
mvn:	mov	ax,0A000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,8000h
	mov	ah,3Fh
	pop	bx
	int	21h
	jc	errd1
	cmp	ax,cx
	jne	errd1
	mov	ax,0A800h
	mov	ds,ax
	mov	cx,7A00h
	mov	ah,3Fh
	int	21h
	jc	errd1
	cmp	ax,cx
	jne	errd1
	mov	ah,3Eh
	int	21h
	mov	ah,0
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
wjcp	db	'Might and Magic .RAW-file viewer',13,10
	db	'Copyright (C) 1995 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:RAWVIEW filename.RAW [filename.PAL]',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
lfg	db	0
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
