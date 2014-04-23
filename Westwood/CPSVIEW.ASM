cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.286
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn1,svn2
	mov	ax,3D00h
	mov	dx,svn2
	or	dx,dx
	jz	m1b
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
	or	dx,dx
	jnz	mwx
	jmp	mx
mwx:	int	21h
	jc	errdd
	xchg	ax,bx
	mov	dx,8
	xor	cx,cx
	mov	ax,4200h
	int	21h
	mov	cx,2
	mov	ah,3Fh
	mov	dx,offset pof
	int	21h
	mov	cx,pof
	jcxz	mnp
	mov	ah,3Fh
	mov	dx,offset pbuf
	int	21h
mnp:	push	bx
	mov	ax,13h
	int	10h
	jnc	m1f
	jmp	errv
m1f:	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jnc	mvn
	jmp	errv0
mvn:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	pop	bx
	xor	dx,dx
	mov	cx,0FFFFh
	mov	ah,3Fh
	int	21h
	jc	mer1
	cmp	ax,cx
	jne	mlnx
mer1:	jmp	errd1
mlnx:	mov	ah,3Eh
	int	21h
	mov	ax,0A000h
	mov	es,ax
	xor	si,si
	mov	di,si
mlp:	lodsb
	cmp	al,80h
	je	mwq
	cmp	al,0FEh
	jbe	mo1
	lodsw
	mov	cx,ax
mcp:	lodsw
	push	si
	mov	si,ax
mcp1:	cli
	seges
	rep	movsb
	sti
	pop	si
	jmp	short mlp
mo1:	jb	mo2
	lodsw
	mov	cx,ax
	lodsb
	rep	stosb
	jmp	short mlp
mo2:	mov	ch,0
	test	al,0C0h
	jns	mo4
	jnp	mo3
	and	al,3Fh
	add	al,3
	mov	cl,al
	jmp	short mcp
mo3:	and	al,3Fh
	mov	cl,al
	rep	movsb
	jmp	short mlp
mo4:	mov	cl,al
	shr	cl,4
	add	cl,3
	and	al,0Fh
	mov	ah,al
	lodsb
	push	si
	mov	si,di
	sub	si,ax
	jmp	short mcp1
mwq:	mov	ah,0
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
wjcp	db	'.CPS files viewer',13,10
	db	'Copyright (C) 1996 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:CPSVIEW filename.CPS [filename.PAL]',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn1	dw	?
svn2	dw	?
pof	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
