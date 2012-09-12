cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg,ss:cseg
	org	100h
	.286
	include parse.asm
start:	mov	dx,offset nme
	mov	ah,9
	int	21h
	mov	ah,4Ah
	mov	bx,1000h
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
	push	bx
	add	ax,0Fh
	xchg	bx,ax
	shr	bx,4
	mov	ah,48h
	int	21h
mx3:	mov	dx,offset merr
	jc	mx2
	mov	ds,ax
	mov	bx,1000h
	mov	ah,48h
	int	21h
	jc	mx3
	mov	es,ax
	pop	bx
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
m1:	cmp	es:[si]-2,0FFFFh
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
	lodsw
	or	ax,ax
	jnz	m2
	stosw
	loop	ml1
	jmp	mn
m2:	push	di
	inc	di
	mov	dx,si
	add	dx,ax
	lodsw
	stosb
m3:	cmp	si,dx
	jae	mn1
	lodsb
	test	al,0C0h
	js	m4
	stosb
	push	cx
	inc	ax
	mov	cl,al
	mov	ch,0
mli:	lodsb
	segcs
	xlat
	stosb
	loop	mli
	pop	cx
	jmp	short m3
m4:	jp	m5
	cmp	al,0A0h
	jae	m6
	or	al,20h
	stosb
	jmp	short m3
m6:	stosb
	mov	al,0BFh
	stosb
	jmp	short m3
mll:	jmp	short ml0
m5:	mov	ah,al
	lodsb
	segcs
	xlat
	xchg	ah,al
	cmp	al,0E0h
	jae	m8
	and	al,7Fh
	stosw
	jmp	short m3
m8:	and	al,5Fh
	stosw
	mov	al,5Dh
	stosw
	jmp	short m3
mn1:	mov	ax,di
	pop	bx
	sub	ax,bx
	dec	ax
	or	ah,ah
	jz	mnz
	mov	dx,offset ferr
	jmp	mx
mnz:	mov	es:[bx],al
	loop	ml1
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
nme	db	'Might and Magic ]I[ to IV VGA files convertor',13,10
	db	'Copyright (C) 1995 by White Jaguar',13,10
	db	'Usage: CONV3TO4 infile outfile [TTB_file]',13,10,'$'
derr	db	'Can''t open input file$'
derr1	db	'Can''t create output file$'
derr2	db	'Can''t open TTB file$'
serr	db	'Input file too large$'
merr	db	'Can''t allocate memory$'
rerr	db	'Can''t read input file$'
rerr1	db	'Can''t read TTB file$'
werr	db	'Can''t write output file$'
ferr	db	'File cannot be converted$'
nerr	db	'Conversion completed$'
fi	dw	?
fo	dw	?
ft	dw	?
ttb	db	256 dup(?)
cseg	ends
end	start