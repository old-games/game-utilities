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
	mov	dx,fi
	mov	ax,3D00h
	int	21h
	jnc	mnx
	mov	dx,offset derr
	jmp	short mx
mx1:	mov	dx,offset serr
mx2:	mov	ah,3Eh
	int	21h
mx:	push	cs
	pop	ds
	mov	ah,9
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
	mov	cs:war1,si
	mov	cs:war2,si
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
	mov	ah,0
	lodsb
	or	al,al
	jnz	m2
	stosb
	movsb
	loop	ml1
	jmp	mn
m2:	push	di
	inc	di
	mov	dx,si
	add	dx,ax
	movsb
m3:	cmp	si,dx
	jae	mjn
	lodsb
	test	al,0C0h
	jz	m3a
	jns	m01
	jmp	m4
m3a:	stosb
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
m01:	test	al,20h
	jnz	m02
	stosb
	lodsb
	segcs
	xlat
	stosb
	jmp	short m3
mjn:	jmp	mn1
m02:	stosb
	and	ax,1Fh
	add	al,4
	push	dx
	mov	dx,ax
	lodsw
	push	si
	neg	ax
	add	ax,si
	push	cx
	push	di
	push	es
	push	cs
	pop	es
	mov	di,offset war1
	mov	cx,cs:wi
m02l:	scasw
	jb	m02a
	loop	m02l
	jmp	short m02b
m02a:	dec	di
	dec	di
m02b:	dec	di
	dec	di
	pop	es
	mov	cx,dx
	push	ax
	mov	si,ax
	segcs
	add	ax,[di]+war2-war1
	mov	di,ax
	push	ax
m02la:	lodsb
	segcs
	xlat
	scasb
	loope	m02la
	pop	ax
	jne	mcp
	pop	si
	neg	ax
	inc	ax
	inc	ax
	pop	di
	add	ax,di
	stosw
	pop	cx
	pop	si
	pop	dx
	jmp	short m3
mcp:	pop	si
	mov	ax,dx
	dec	ax
	pop	di
	dec	di
	stosb
	mov	cx,dx
mcpl:	lodsb
	segcs
	xlat
	stosb
	loop	mcpl
	pop	cx
	pop	si
	pop	dx
	jmp	short m07a
m4:	jp	m5
	test	al,20h
	jnz	m03
m6:	stosb
	lodsb
	segcs
	xlat
	stosb
	lodsb
	segcs
	xlat
	stosb
	jmp	m3
m03:	stosb
	jmp	m3
mll:	jmp	ml0
ml0l:	jmp	ml1
m5:	push	dx
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
	inc	ax
	inc	ax
	stosb
	inc	ax
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
m07a:	push	bx
	mov	bx,cs:wi
	inc	cs:wi
	shl	bx,1
	mov	cs:war1[bx],si
	mov	ax,di
	sub	ax,si
	mov	cs:war2[bx],ax
	pop	bx
	jmp	m3
mn1:	mov	ax,di
	pop	bx
	sub	ax,bx
	dec	ax
	or	ah,ah
	jz	mnz
	mov	dx,offset ferr
	jmp	mx
mnz:	mov	es:[bx],al
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
nme	db	'Might and Magic IV VGA files palette convertor',13,10
	db	'Copyright (C) 1995 by White Jaguar',13,10
	db	'Usage: RECOLOR4 infile outfile TTB_file',13,10,'$'
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
wi	dw	1
fi	dw	?
fo	dw	?
ft	dw	?
ttb	db	256 dup(?)
war1	dw	2000 dup(?)
war2	dw	2000 dup(?)
cseg	ends
end	start