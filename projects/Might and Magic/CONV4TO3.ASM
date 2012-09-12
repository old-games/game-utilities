cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	org	100h
	.386
	include parse.asm
start:	mov	dx,offset nme
	mov	ah,9
	int	21h
	parse	fi,fo,ft
	mov	di,offset ttb
	mov	cx,256
	mov	al,0
ml00:	stosb
	inc	ax
	loop	ml00
	mov	dx,ft
	or	dx,dx
	jz	m0
	mov	ax,3D00h
	int	21h
	mov	dx,offset derr2
	jc	mx
	xchg	ax,bx
	mov	dx,offset ttb
	mov	cx,256
	mov	ah,3Fh
	int	21h
	mov	dx,offset rerr1
	jc	mx2
	mov	ah,3Eh
	int	21h
m0:	mov	dx,fi
	mov	ax,3D00h
	int	21h
	jnc	mnx
	mov	dx,offset derr
	jmp	short mx
mx1:	mov	dx,offset serr
mx2:	push	cs
	pop	ds
	mov	ah,3Eh
	int	21h
mx:	mov	ah,9
	int	21h
	int	20h
mnx:	xchg	ax,bx
	mov	ax,4202h
	xor	dx,dx
	mov	cx,dx
	int	21h
	or	dx,dx
	jnz	mx1
	push	ax
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	add	ax,1000h
	mov	es,ax
	mov	ax,4200h
	xor	dx,dx
	mov	cx,dx
	int	21h
	pop	cx
	mov	ah,3Fh
	int	21h
	mov	dx,offset rerr
	jc	mx2
	mov	ah,3Eh
	int	21h
	xor	si,si
	mov	di,si
	lodsw
	stosw
	xchg	cx,ax
	shl	cx,1
	mov	ax,0FFFFh
	rep	stosw
	xor	si,si
	lodsw
	xchg	ax,cx
	shl	cx,1
ml0:	lodsw
	or	ax,ax
	jnz	m1
	mov	es:[si]-2,ax
mln:	loop	ml0
	jmp	mr
m1:	cmp	word ptr es:[si]-2,0FFFFh
	jne	mln
	push	si
	push	cx
	mov	es:[si]-2,di
	dec	cx
	jz	m1a
mla:	cmp	[si],ax
	jne	m1b
	mov	es:[si],di
m1b:	inc	si
	inc	si
	loop	mla
m1a:	xchg	ax,si
	movsw
	movsw
	movsw
	lodsw
	stosw
	xchg	ax,cx
ml1:	mov	bx,offset ttb
	mov	ah,0
	lodsb
	or	al,al
	jnz	m2
	lodsb
	sub	cx,ax
	push	cx
	inc	ax
	xor	cx,cx
	xchg	ax,cx
	rep	stosw
	pop	cx
	loop	ml1
	jmp	mn
m2:	push	di
	stosw
	mov	dx,si
	add	dx,ax
	lodsb
	stosw
	xor	bp,bp
	mov	cs:mde,0
	mov	cs:dsv,di
	push	cs
	pop	es
m3:	cmp	si,dx
	jae	mjn
	lodsb
	test	al,0C0h
	js	m4
	jnz	m01
	cmp	cs:mde,1
	je	m3a
	call	sve
	mov	cs:mde,1
m3a:	push	cx
	inc	ax
	mov	ah,0
	add	bp,ax
	mov	cx,ax
mli:	lodsb
	segcs
	xlat
	stosb
	loop	mli
	pop	cx
	jmp	short m3
m01:	test	al,20h
	jnz	m02
	cmp	cs:mde,2
	jne	m01a
	mov	ah,al
	lodsb
	segcs
	xlat
	dec	si
	xchg	al,ah
	cmp	cs:csv,ah
	je	m01b
m01a:	call	sve
	cmp	cs:mde,0
	jne	m01a
	mov	cs:mde,2
m01b:	and	ax,1Fh
	add	al,3
	add	bp,ax
	lodsb
	segcs
	xlat
	mov	cs:csv,al
	jmp	short m3
m02:	cmp	cs:mde,1
	je	m02a
	call	sve
	mov	cs:mde,1
m02a:	and	ax,1Fh
	add	al,4
	add	bp,ax
	push	cx
	mov	cx,ax
	lodsw
	push	si
	sub	si,ax
ml0i:	lodsb
	segcs
	xlat
	stosb
	loop	ml0i
	pop	si
	pop	cx
	jmp	m3
m4:	jp	m5
	test	al,20h
	jnz	m03
	cmp	cs:mde,1
	je	m4a
	call	sve
	mov	cs:mde,1
m4a:	and	ax,1Fh
	inc	ax
	inc	ax
	add	bp,ax
	add	bp,ax
	push	cx
	mov	cx,ax
	lodsw
	segcs
	xlat
	xchg	ah,al
	segcs
	xlat
	xchg	ah,al
	rep	stosw
	pop	cx
	jmp	m3
mjn:	call	sve
	cmp	cs:mde,0
	jne	mjn
	jmp	mn1
m03:	cmp	cs:mde,3
	je	m03a
m03b:	call	sve
	cmp	cs:mde,0
	jne	m03b
	mov	cs:mde,3
m03a:	and	ax,1Fh
	inc	ax
	add	bp,ax
	jmp	m3
m5:	cmp	cs:mde,1
	je	m5a
	call	sve
	mov	cs:mde,1
m5a:	push	dx
	mov	dl,al
	shr	dl,3
	and	dl,3
	mov	dh,dl
	jnz	m05
	mov	dh,1
m05:	test	al,20h
	jz	m06
	neg	dl
	neg	dh
m06:	and	ax,7
	add	ax,3
	add	bp,ax
	push	cx
	xchg	cx,ax
	lodsb
	mov	ah,al
ml01:	segcs
	xlat
	stosb
	add	ah,dl
	dec	cx
	jz	m07
	mov	al,ah
	segcs
	xlat
	stosb
	add	ah,dh
	mov	al,ah
	loop	ml01
m07:	pop	cx
	pop	dx	
	jmp	m3
sve:	cmp	cs:mde,0
	je	svx
	push	ax
	push	cx
	push	ds
	push	cs
	pop	ds
	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	di,dsv
	cmp	mde,1
	je	svm
	cmp	mde,2
	jne	svs
svf:	mov	ax,bp
	sub	ax,42h
	jbe	ms1
	mov	bp,ax
	mov	al,0FFh
	mov	ah,csv
	stosw
	jmp	short svf
ms1:	add	al,3Fh
	js	ms2
	or	al,0C0h
	mov	ah,csv
	stosw
	jmp	short svx0
ms2:	add	ax,3
	mov	dsv,di
	mov	cx,ax
	mov	bp,ax
	mov	al,csv
	push	cs
	pop	es
	mov	di,offset buf
	rep	stosb
	mov	mde,1
	pop	ds
	pop	cx
	pop	ax
	retn
svs:	mov	ax,bp
	and	ax,3Fh
	jz	ms3
	dec	ax
	or	al,80h
	stosb
ms3:	shr	bp,6
	mov	cx,bp
	mov	al,0BFh
	rep	stosb
	jmp	short svx0
svm:	mov	ax,bp
	push	si
	mov	si,offset buf
	shr	bp,7
	and	ax,7Fh
	jz	ms4
ms5:	mov	cx,ax
	dec	ax
	stosb
	rep	movsb
ms4:	mov	al,80h
	dec	bp
	jns	ms5
	pop	si
svx0:	mov	mde,0
	mov	dsv,di
	pop	ds
	push	cs
	pop	es
	pop	cx
	pop	ax
svx:	mov	di,offset buf
	xor	bp,bp
	retn
mll:	jmp	ml0
ml0l:	jmp	ml1
mn1:	mov	ax,cs
	add	ax,2000h
	mov	es,ax
	mov	di,cs:dsv
	mov	ax,di
	pop	bx
	sub	ax,bx
	dec	ax
	dec	ax
	mov	es:[bx],ax
	loop	ml0l
mn:	pop	cx
	pop	si
	loop	mll
mr:	push	cs
	pop	ds
	mov	dx,fo
	mov	cx,20h
	mov	ah,3Ch
	int	21h
	jnc	mn2
	mov	dx,offset derr1
	jmp	mx2
mn2:	xchg	ax,bx
	push	es
	pop	ds
	xor	dx,dx
	mov	cx,di
	mov	ah,40h
	int	21h
	mov	dx,offset werr
	jc	mn3
	mov	dx,offset nerr
mn3:	jmp	mx2	
nme	db	'Might and Magic IV to ]I[ VGA files convertor',13,10
	db	'Copyright (C) 1995 by White Jaguar',13,10
	db	'Usage: CONV4TO3 infile outfile [TTB_file]',13,10,'$'
derr	db	'Can''t open input file$'
derr1	db	'Can''t create output file$'
derr2	db	'Can''t open TTB file$'
serr	db	'Input file too large$'
rerr	db	'Can''t read input file$'
rerr1	db	'Can''t read TTB file$'
werr	db	'Can''t write output file$'
nerr	db	'Conversion completed$'
mde	db	?	;block type=none
csv	db	?	;fill color save
dsv	dw	?	;dest.ofs.save
fi	dw	?
fo	dw	?
ft	dw	?
ttb	db	256 dup(?)
buf	db	320 dup(?)
cseg	ends
end	start