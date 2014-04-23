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
	mov	ah,3Eh
	int	21h
	mov	si,0Ah
	mov	cx,ds:[0]
	inc	cx
nxp:	push	cx
	push	si
	mov	ax,ds
	add	ax,1000h
	mov	es,ax
	call	basepg
	cmp	si,0Ah
	je	mvw
	lodsw
	lodsw
	mov	dx,ax
mbl1:	dec	dx
	js	mvw
	lodsw
	mov	di,ax
	lodsw
	mov	cx,ax
	rep	movsb
	jmp	short mbl1
mvw:	push	es
	pop	fs
	mov	ax,0A000h
	mov	es,ax
	xor	di,di
	mov	si,di
	mov	dx,ds:[8]
	mov	bx,ds:[6]
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
	add	si,[si]
	add	si,2
	pop	cx
	loop	nxpp
mqq:	mov	ax,3
	int	10h
	int	20h
nxpp:	jmp	nxp
basepg:	push	si
	mov	si,0Ah
	lodsw
	lea	bx,[esi][eax]
	xor	di,di
mblp:	lodsb
	mov	cl,al
	and	cx,7Fh
	inc	cx
	test	al,al
	jns	mbc
	lodsb
	rep	stosb
	jmp	short mbl
mbc:	rep	movsb
mbl:	cmp	si,bx
	jb	mblp
	pop	si
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
wjcp	db	'Arena .DFA files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:DFAVIEW filename.DFA filename.PAL',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-repaint screen & show next,',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pbuf	db	300h dup(?)
cseg	ends
end	start
