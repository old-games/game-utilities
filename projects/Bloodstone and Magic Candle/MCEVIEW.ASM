cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.286
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1
	mov	ax,3D00h
	mov	dx,svn1
	or	dx,dx
	jnz	mnx
	jmp	mx
mnx:	int	21h
	jnc	mne
	jmp	errd
mne:	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	push	ax
	mov	ah,3Eh
	int	21h
	pop	bx
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	xor	si,si
	mov	di,si
dcmp:	xor	ax,ax
	lodsb
	test	al,80h
	jnz	mcpy
	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short mdl
mcpy:	xor	al,80h
	mov	cx,ax
	rep	movsb
mdl:	cmp	si,bx
	jb	dcmp
	push	di
	mov	ax,13h
	int	10h
	jc	errv
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	xor	dx,dx
	int	10h
	jc	errv0
	push	es
	pop	ds
	mov	ax,0A000h
	mov	es,ax
	mov	si,300h
	xor	di,di
	pop	ax
	cmp	ax,320*200+768
	je	sz1
	cmp	ax,176*144+768
	je	sz2
;Files  G64.MCE,G66.MCE,G67.MCE,G68.MCE must be glued together to view, as they
;all are only parts of one full-screen picture
	jmp	short mqq
sz2:	mov	bx,144
ml2:	mov	cx,176/2
	rep	movsw
	add	di,320-176
	dec	bx
	jnz	ml2
	jmp	short mwq
sz1:	mov	cx,32000
	rep	movsw
mwq:	mov	ah,0
	int	16h
mqq:	mov	ax,3
	int	10h
	int	20h
mx:	mov	dx,offset perr
mx1:	mov	ah,9
	push	cs
	pop	ds
	int	21h
	int	20h	
errd:	mov	dx,offset derr
	jmp	short mx1
errv0:	mov	ax,3
	int	10h
errv:	pop	bx
	mov	ah,3Eh
	int	21h
	mov	dx,offset aerr
	jmp	short mx1
wjcp	db	'Bloodstone .MCE files viewer',13,10
	db	'Copyright (C) 2000 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:MCEVIEW filename.MCE',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
cseg	ends
end	start
