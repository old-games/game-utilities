cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg
	org	100h
	.286
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	mov	ax,cs		;release memory
	dec	ax
	mov	ds,ax
	mov	ax,ds:[0003h]
	mov	cs:svmsz,ax
	mov	ah,4Ah
	mov	bx,1000h
	int	21h
	push	cs
	pop	ds
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
	mov	svax,di
	inc	di
	repne	scasb
	mov	ax,2400h	;#0'$'
	jne	m1
	mov	bl,[di]
	dec	di
	cmp	bl,'1'
	jbe	m1
	cmp	bl,'3'
	ja	m1
	mov	bx,offset xnm0b
	je	m1a
	mov	bx,offset xnm0a
m1a:	mov	mde,bx
m1:	stosw
	mov	ax,2
	call	dirrd		;load compressed directory
	xor	ax,ax
	call	dirrd		;load uncompressed directory
	mov	dx,offset pstr1
	mov	ah,9
	int	21h
	mov	dx,svax
	mov	ah,9
	int	21h
	mov	dx,offset pstr2
	mov	ah,9
	int	21h
	mov	bx,cs
	mov	ax,svax
	call	decomp		;decompress file
	push	bx
	mov	bx,dscs		;close sources
	or	bx,bx
	jz	m2
	mov	ah,3Eh
	int	21h
	jc	mje
m2:	mov	bx,dscs+2
	mov	ah,3Eh
	int	21h
	jc	mje
	mov	ah,3Ch		;save file
	mov	cx,20h
	mov	dx,svax
	int	21h
	jc	mje
	mov	bx,ax
	mov	ah,40h
	mov	cx,fsiz
	pop	ds
	xor	dx,dx
	int	21h
	jnc	mnm
mje:	jmp	errout
mnm:	mov	ah,3Eh
	int	21h
	jc	errout
	push	cs
	pop	ds
	mov	dx,offset pstr3
	mov	ah,9
	int	21h
	int	20h
mx:	mov	dx,offset perr
	mov	ah,9
	int	21h
	int	20h
svbx	dw	0	;:80DA
svax	dw	0	;:80DC
tsg	dw	0	;:80E6
dirs	dw	0,0	;:80EA
dscs	dw	0,0	;:80EE
lens	dw	0,0	;:80F2
svcx	dw	0	;:80F6
svdx	dw	0	;:80F8
nme	db	'MAZE'	;:8104
xnm0	db	'dark.cur',8 dup(0)	;:8108
xnm1	db	'dark.cc',0		;:8118
xnm0a	db	'dark.cur',8 dup(0)	;MOE
xnm1a	db	'intro.cc',0		;
xnm0b	db	'xeen.cur',8 dup(0)	;
xnm1b	db	'xeen.cc',0		;
errout:	mov	dx,offset derr
	jmp	short ma1
errou1:	mov	dx,offset merr
ma1:	push	cs
	pop	ds
	mov	ah,9
	int	21h
	int	20h
merr	db	'Out of memory!',13,10,'$'
derr	db	'Disk error!',13,10,'$'
pstr3	db	'Done!',13,10,'$'
wjcp	db	'Might and Magic IV-V resource unpacker',13,10
	db	'Copyright (C) 1995 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:XEENDCM filename [mode]',13,10
	db	'where modes are: 1 for DARK.CC & DARK.CUR',13,10
	db	'2 for INTRO.CC & DARK.CUR, and 3 for XEEN.CC & XEEN.CUR',13,10
	db	'$'
pstr1	db	'Unpacking $'
pstr2	db	'... $'
mde	dw	offset xnm0
svmsz	dw	0
fsiz	dw	0
dirrd	proc	near	;in AX=0 for savegame,2 for resource
	push	es
	push	ds
	push	si
	push	di
	mov	si,ax
	mov	dx,mde
	shl	ax,3
	add	dx,ax
	push	cs
	pop	ds
	mov	ax,si
	xor	al,2
	mov	ah,3Dh
	int	21h
	jnc	mrnx
mrer:	jmp	errout
mrnx:	mov	cs:dscs[si],ax
	mov	dx,offset lens
	add	dx,si
	mov	cx,2
	mov	bx,ax
	mov	ah,3Fh
	int	21h
	jc	mrer
	xor	dx,dx
	mov	cx,dx
	mov	bx,cs:dscs[si]
	mov	ax,4200h
	int	21h
	jc	mrer
	mov	bx,cs:lens[si]
	shl	bx,3
	inc	bx
	inc	bx
	push	bx
	push	bx
	call	memget
	mov	cs:dirs[si],bx
	mov	ds,bx
	xor	dx,dx
	pop	cx
	mov	bx,cs:dscs[si]
	mov	ah,3Fh
	int	21h
	jc	mrer
	pop	cx
	mov	di,2
	sub	cx,di
	mov	es,cs:dirs[si]
	mov	ah,0ACh
mr1:	mov	al,es:[di]
	rol	al,2
	add	al,ah
	stosb
	add	ah,67h
	loop	mr1
	pop	di
	pop	si
	pop	ds
	pop	es
	retn
dirrd	endp
memget	proc	near
	add	bx,15
	rcr	bx,1
	shr	bx,3
	push	bx
	mov	bx,2
	mov	ax,5801h
	int	21h
	pop	bx
	mov	ah,48h
	int	21h
	push	ax
	pushf
	xor	bx,bx
	mov	ax,5801h
	int	21h
	popf
	pop	bx
	jnc	mgx
	jmp	errou1
mgx:	retn
memget	endp
decomp	proc	near
	push	bp
	push	ds
	push	es
	push	si
	push	di
	xor	cx,cx		;MOE
	mov	dx,cx		;MOE
	mov	cs:svcx,cx
	mov	cs:svdx,dx
	mov	cs:svbx,bx
	mov	cs:svax,ax
;	mov	ds,bx		;this part is not needed here
;	mov	dx,ax
;	mov	ax,3D00h
;	int	21h
;	jc	md4
;	mov	bx,ax
;	xor	dx,dx
;	mov	cx,dx
;	mov	ax,4202h
;	int	21h
;	jnc	md0
;	jmp	md12
;md0:	push	ax
;	xor	dx,dx
;	mov	cx,dx
;	mov	ax,4200h
;	int	21h
;	jnc	md1
;	jmp	md12
;md1:	pop	ax
;	push	ax
;	push	bx
;	mov	bx,cs:svcx
;	or	bx,bx
;	jnz	md2
;	mov	bx,ax
;	add	bx,15
;	rcr	bx,1
;	shr	bx,3
;	mov	ax,4800h
;	int	21h
;	jc	errou1
;	mov	cs:svcx,ax
;md2:	mov	ax,cs:svcx
;	pop	bx
;	mov	ds,ax
;	mov	dx,cs:svdx
;	pop	cx
;	push	cx
;	mov	ax,3F00h
;	int	21h
;	jc	md12
;	mov	ax,3E00h
;	int	21h
;	mov	bx,cs:svcx
;	pop	ax
;	pop	di
;	pop	si
;	pop	es
;	pop	ds
;	pop	bp
;	retn
md4:	mov	ds,cs:svbx
	mov	si,cs:svax
	xor	bp,bp
	mov	bx,bp
	mov	cx,4
	mov	dx,7F60h
md5:	lodsb
	and	al,dh
	cmp	al,dl
	jb	md6
	sub	al,20h
md6:	cmp	al,cs:nme[bx]
	je	md7
	mov	bp,2
md7:	inc	bx
	loop	md5
	sub	si,4
	xor	ax,ax
	mov	bx,ax
md8:	lodsb
	or	ax,ax
	jz	md10
	and	al,dh
	cmp	al,dl
	jb	md9
	sub	al,20h
md9:	xchg	bl,bh
	rol	bx,1
	add	bx,ax
	jmp	short md8
md10:	mov	ds,cs:dirs[bp]
	xor	si,si
	lodsw
	mov	cx,ax
	mov	di,8
md11:	cmp	bx,[si]
	je	md13
	add	si,di
	loop	md11
md12:	jmp	mrer
md13:	xor	cx,cx
	lodsw
	lodsw
	mov	dx,ax
	lodsb
	mov	cl,al
	lodsw
	mov	cs:lens[bp],ax
	mov	bx,cs:dscs[bp]
	mov	ax,4200h
	int	21h
	jc	md12
	mov	bx,cs:lens[bp]
	mov	ax,cs:svcx
	or	ax,ax
	jnz	md14
	call	memget
	mov	ax,bx
md14:	mov	cs:tsg,ax
	mov	ds,ax
	mov	dx,cs:svdx
	mov	cx,cs:lens[bp]
	mov	cs:fsiz,cx
	mov	bx,cs:dscs[bp]
	mov	ah,3Fh
	int	21h
	jc	md12
	call	decif
	mov	bx,cs:tsg
	jmp	md17
md17:	pop	di
	pop	si
	pop	es
	pop	ds
	pop	bp
	retn
decomp	endp
decif	proc	near
	cmp	bp,2
	jne	mfx
	push	ax
	push	ds
	push	es
	push	si
	push	di
	mov	cx,ax
	mov	ax,cs:tsg
	mov	ds,ax
	mov	es,ax
	mov	si,dx
	mov	di,si
mf1:	lodsb
	xor	ax,35h
	stosb
	loop	mf1
	pop	di
	pop	si
	pop	es
	pop	ds
	pop	ax
mfx:	retn
decif	endp
cseg	ends
end	start
