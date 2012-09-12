cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.386
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jz	mx
	int	21h
	jc	errd
	xchg	ax,bx
	mov	ax,ds
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	mov	ah,3Eh
	int	21h
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	si,1Ch
	xor	di,di
	xor	ax,ax
mpl:	lodsb
	test	al,al
	jz	mpx
	js	mcp
	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short mpl
mcp:	sub	ax,80h
	mov	cx,ax
	rep	movsb
	jmp	short mpl
mpx:	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	movzx	cx,byte ptr es:[4]
	mov	dx,5
	int	10h
	lea	si,[ecx][2*ecx]
	add	si,dx
	mov	ax,es:[0]
	inc	ax
	mov	bx,es:[2]
	inc	bx
	cmp	cx,16
	ja	mpic
	push	ds
	push	es
	pop	ds
	pop	es
	mul	bx
	xor	di,di
	cmp	cx,2
	ja	mpc4
	mov	bx,ax
	add	bx,7
	shr	bx,3
	mov	dx,801h
	jmp	short ml2
mpc4:	cmp	cx,4
	ja	mpc16
	mov	bx,ax
	add	bx,3
	shr	bx,2
	mov	dx,402h
	jmp	short ml2
mpc16:	mov	bx,ax
	add	bx,1
	shr	bx,1
	mov	dx,204h
ml2:	mov	ah,0
	lodsb
	xchg	ah,al
	mov	cx,dx
ml1:	rol	ax,cl
	stosb
	mov	al,0
	dec	ch
	jnz	ml1
	dec	bx
	jnz	ml2
	mov	ax,ds:[0]
	inc	ax
	mov	bx,ds:[2]
	inc	bx
	xor	si,si
mpic:	push	es
	pop	ds
	mov	dx,bx
	mov	bx,ax
	mov	ax,0A000h
	mov	es,ax
	xor	di,di
mlo:	mov	cx,bx
mlo1:	lodsb
	test	al,al
	jz	mo1
	mov	es:[di],al
mo1:	inc	di
	loop	mlo1
	add	di,320
	sub	di,bx
	dec	dx
	jnz	mlo
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
errd0:	mov	ah,3Eh
	int	21h
errd:	mov	dx,offset derr
	jmp	short mx1
errv:	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Realms of Arkania I .ULI files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,'$'
perr	db	'Usage:ULIVIEW filename.ULI [filename.pal]',13,10
;	db	'Internal keys: ESC - immediate exit',13,10
;	db	'               any other - show next',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
cseg	ends
end	start
