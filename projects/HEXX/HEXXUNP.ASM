cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.286
	org	100h
	include parse.asm
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errdd
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,0FFFFh
	xor	dx,dx
	int	21h
	mov	ah,3Eh
	int	21h
	mov	si,dx
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	xor	di,di
dcmblk:	lodsw
	test	al,7Fh
	jnz	errfh
	xchg	ah,al
	xchg	ax,bx
	lodsw
	xchg	ah,al
	xchg	ax,dx
	push	bx
	and	bx,7FFFh
	inc	dx
	call	mktbls
	mov	cx,dx
	mov	dx,bx
	xor	ax,ax
dcd:	lodsb
	call	decode
	loop	dcd
	pop	ax
	test	ax,ax
	js	dcmblk
enddcm:	push	cs
	pop	ds
	mov	dx,svn2
	mov	cx,20h
	mov	ah,3Ch
	int	21h
	xchg	ax,bx
	push	es
	pop	ds
	xor	dx,dx
	mov	cx,di
	mov	ah,40h
	int	21h
	mov	ah,3Eh
	int	21h
	int	20h
errfh:	mov	dx,offset fherr
	jmp	short mx1
errdd:	mov	dx,offset derr
	jmp	short mx1
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
decode:	mov	bp,dx
mdl:	mov	bx,ax
	mov	bl,ss:hash[bx]
	inc	bl
	jz	mdsr
	jns	mdw
	sub	bl,81h
	cmp	bp,bx
	jb	mdw
	mov	bp,bx
mdr:	push	bp
	mov	al,ss:tb3[bp]
	call	mdrec
	pop	bp
	mov	al,ss:tb2[bp]
mdrec:	dec	bp
	jns	mdl
	stosb
	retn	
mdsr:	cmp	al,ss:tb1[bp]
	je	mdr
	dec	bp
	jns	mdsr
mdw:	stosb
	retn	
mktbls:	push	es
	push	di
	push	cs
	pop	es
	push	bx
	mov	di,offset hash
	mov	cx,80h
	xor	ax,ax
	rep	stosw
	mov	di,offset hash
	mov	bp,bx
mhl:	mov	bl,ds:[bp][si]
	cmp	byte ptr es:[bx][di],0
	jne	mh2
	mov	ax,bp
	xor	al,80h
	jns	mh2
	mov	es:[bx][di],al
	jmp	short mh3
mh2:	mov	byte ptr es:[bx][di],0FFh
mh3:	dec	bp
	jns	mhl
	pop	bx
	mov	di,offset tb1
	lea	cx,[bx]+1
	rep	movsb
	mov	di,offset tb2
	lea	cx,[bx]+1
	rep	movsb
	mov	di,offset tb3
	lea	cx,[bx]+1
	rep	movsb
	pop	di
	pop	es
	retn	
wjcp	db	'HEXX files unpacker',13,10
	db	'Copyright (C) 1999 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:HEXXUNP srcfile targetfile',13,10,'$'
derr	db	'Disk error!',13,10,'$'
fherr	db	'Error in packed file!',13,10,'$'
	evendata
svn1	dw	?
svn2	dw	?
tb1	db	100h dup(?)
tb2	db	100h dup(?)
tb3	db	100h dup(?)
hash	db	100h dup(?)
cseg	ends
end	start
