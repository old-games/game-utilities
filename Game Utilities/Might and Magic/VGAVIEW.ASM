cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	.286
	org	100h
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
	jc	errdd
	push	ax
	mov	ax,13h
	int	10h
	jnc	m1f
	jmp	errv
m1f:	cmp	lfg,0
	je	mvn
	mov	ax,1012h
	xor	bx,bx
	mov	cx,256
	mov	dx,offset pbuf
	int	10h
	jnc	mvn
	jmp	errv0
mvn:	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	xor	dx,dx
	mov	cx,8000h
	mov	ah,3Fh
	pop	bx
	int	21h
	jc	mer1
	cmp	ax,cx
	jb	mlnx
	push	ds
	mov	ax,cs
	add	ax,1800h
	mov	ds,ax
	mov	cx,8000h
	mov	ah,3Fh
	int	21h
	jnc	mvnn
mer1:	jmp	errd1
mvnn:	pop	ds
mlnx:	mov	ah,3Eh
	int	21h
	mov	cx,ds:[0000h]	;ds=filesegment,:[0]=images count
	mov	si,2		;picture addrs array start
mvw:	push	cx
	push	si
	mov	di,cs:modv	;control bitmap:#0-mirror flag;#9#8-scale index
				;#1-cut flag,#15#14-mult index(3-x4,2-x2)
	mov	cx,0		;shift from left
	mov	bx,0		;starting display string
	mov	ax,0A000h
	mov	es,ax
	call	vgaview
	mov	ah,0
	int	16h
	cmp	al,' '
	jne	mvw1
	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
mvw1:	pop	si
	cmp	al,'m'
	je	mvw3
	cmp	al,'c'
	je	mvw4
	cmp	al,'1'
	jb	mvw2a
	cmp	al,'6'
	ja	mvw2a
	cmp	al,'4'
	ja	mvw5
	sub	al,31h
	jmp	short mvw6
mvw5:	sub	al,33h
	shl	al,6
mvw6:	mov	byte ptr cs:modv+1,al
	jmp	short mvw2
mvw4:	xor	cs:modv,3
mvw3:	xor	cs:modv,1
mvw2:	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
	pop	cx
	jmp	short mvw
mvw2a:	add	si,4
	cmp	al,27
	pop	cx
	loopnz	mvw
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
arr1	equ	this word	;:069C	;string starts
strbg	=	0
	rept	200
	dw	strbg
strbg	=	strbg+320
	endm
var6	dw	0		;:0B5A
var7	dw	0		;:0B5C
var8	dw	0		;:0B5E
var2	dw	0		;:0B60
var3	dw	0		;:0B62
var4	dw	0		;:0B64
var5	dw	0		;:0B66
var1	dw	0		;:0B68
arr2	dw	0FFFFh,0DB6Dh	;:0B6A	;scaling bitmaps
	dw	0A529h,8421h	;(1-draw pixel,0-not):1/1,3/4,1/2,1/4 
	;---------
var9	db	0		;:0E8D
var10	dw	0		;:0E8E
var11	dw	0		;:0E90
not_now:int	20h
vgaview	proc	near
	cld
	or	di,di
	js	mv6
	and	di,303h
	test	di,2
	jz	mv4
	jmp	cut	;loc_224,:2158
mv4:	test	di,300h
	jz	mv5
	jmp	scale	;loc_187,:1EDC
mv5:	test	di,1
	jz	mv7
	jmp	mirror	;loc_175,:1E22
mv6:	jmp	whats	;loc_314,:26FE
mv7:	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms1
	pop	cx
	pop	bx
	pop	si
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv14
ms1:	lodsw
	add	cx,ax
	mov	dx,cx
	inc	si
	inc	si
	lodsw
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	xor	cx,cx
mv8:	lodsw
	or	ax,ax
	jz	mv13
	cmp	bx,400
	jae	mv12
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	add	di,dx
	lodsw
	add	di,ax
mv9:	cmp	si,bp
	je	mv13
	lodsb
	test	al,80h
	jnz	mv10
	mov	cl,al
	inc	cx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short mv9
mv10:	test	al,40h
	jnz	mv11
	and	ax,3Fh
	inc	ax
	add	di,ax
	jmp	short mv9
mv11:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	lodsb
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mv9
mv12:	add	si,ax
mv13:	inc	bx
	inc	bx
	dec	cs:var1
	jnz	mv8
mv14:	retn
mirror:	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms2
	pop	cx
	pop	bx
	pop	si
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv14
ms2:	lodsw
	add	cx,ax
	lodsw
	add	cx,ax
	mov	dx,cx
	dec	dx
	lodsw
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	xor	cx,cx
mv16:	lodsw
	or	ax,ax
	jz	mv25
	cmp	bx,400
	jae	mv24
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	add	di,dx
	lodsw
	sub	di,ax
mv17:	cmp	si,bp
	je	mv25
	lodsb
	test	al,80h
	jnz	mv22
	mov	cl,al
	inc	cx
	shr	cx,1
	jnc	mv18
	lodsb
	std
	stosb
	cld
mv18:	jz	mv17
	dec	di
mv19:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv20
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv20
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv20
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv19
mv20:	inc	di
	jmp	short mv17
mv21:	retn
mv22:	test	al,40h
	jnz	mv23
	and	ax,3Fh
	inc	ax
	sub	di,ax
	jmp	short mv17
mv23:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	lodsb
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	short mv17
mv24:	add	si,ax
mv25:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv26
	jmp	mv16
mv26:	retn
scale:	test	di,1
	jz	mv28
	jmp	mscale		;loc_203,:1FDC
mv28:	mov	ax,di
	mov	al,ah
	mov	ah,0
	shl	ax,1
	mov	di,ax
	mov	ax,cs:arr2[di]
	mov	dx,ax
	mov	cs:var2,dx
	shl	ax,1
	mov	cs:var3,ax
	push	dx
	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms3
	pop	cx
	pop	bx
	pop	si
	pop	dx
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv34
	mov	cs:var2,dx
ms3:	lodsw
	call	ms5
	add	cx,ax
	mov	cs:var5,cx
	mov	cs:var4,dx
	inc	si
	inc	si
	lodsw
	call	ms6
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	xor	cx,cx
mv29:	shl	cs:var2,1
	jnc	mv38
	jnz	mv30
	mov	ax,cs:var3
	mov	cs:var2,ax
mv30:	lodsw
	or	ax,ax
	jz	mv40
	cmp	bx,400
	jae	mv39
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	add	di,cs:var5
	lodsw
	mov	dx,cs:var4
	call	ms5
	add	di,ax
mv31:	cmp	si,bp
	je	mv40
	lodsb
	test	al,80h
	jnz	mv36
	mov	cl,al
	inc	cx
mv32:	lodsb
	shl	dx,1
	jz	mv35
	jnc	mv33
	stosb
mv33:	loop	mv32
	jmp	short mv31
mv34:	retn
mv35:	mov	dx,cs:var3
	stosb
	loop	mv32
	jmp	short mv31
mv36:	test	al,40h
	jnz	mv37
	and	ax,3Fh
	inc	ax
	call	ms5
	add	di,ax
	jmp	short mv31
mv37:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	mov	ax,cx
	call	ms5
	mov	cx,ax
	lodsb
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mv31
mv38:	lodsw
	dec	bx
	dec	bx
mv39:	add	si,ax
mv40:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv41
	jmp	mv29
mv41:	retn
mv42:	jmp	mv53
mscale:	mov	ax,di
	mov	al,ah
	mov	ah,0
	shl	ax,1
	mov	di,ax
	mov	ax,cs:arr2[di]
	mov	dx,ax
	mov	cs:var2,dx
	shl	ax,1
	mov	cs:var3,ax
	push	dx
	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms4
	pop	cx
	pop	bx
	pop	si
	pop	dx
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv49
	mov	cs:var2,dx
ms4:	lodsw
	mov	di,ax
	lodsw
	add	ax,di
	call	ms5
	add	cx,ax
	mov	cs:var5,cx
	mov	cs:var4,dx
	lodsw
	call	ms6
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	xor	cx,cx
mv44:	shl	cs:var2,1
	jnc	mv42
	jnz	mv45
	mov	ax,cs:var3
	mov	cs:var2,ax
mv45:	lodsw
	or	ax,ax
	jz	mv55
	cmp	bx,400
	jae	mv54
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	add	di,cs:var5
	lodsw
	mov	dx,cs:var4
	call	ms5
	sub	di,ax
mv46:	cmp	si,bp
	je	mv55
	lodsb
	test	al,80h
	jnz	mv51
	mov	cl,al
	inc	cx
mv47:	lodsb
	shl	dx,1
	jz	mv50
	jnc	mv48
	std
	stosb
	cld
mv48:	loop	mv47
	jmp	short mv46
mv49:	retn
mv50:	mov	dx,cs:var3
	std
	stosb
	cld
	loop	mv47
	jmp	short mv46
mv51:	test	al,40h
	jnz	mv52
	and	ax,3Fh
	inc	ax
	call	ms5
	sub	di,ax
	jmp	short mv46
mv52:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	mov	ax,cx
	call	ms5
	mov	cx,ax
	lodsb
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	short mv46
mv53:	lodsw
	dec	bx
	dec	bx
mv54:	add	si,ax
mv55:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv56
	jmp	mv44
mv56:	retn
ms5:	or	ax,ax
	jz	mv59
	push	cx
	mov	cx,ax
	xor	ax,ax
mv57:	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	loop	mv57
mv58:	pop	cx
mv59:	retn
mv60:	mov	dx,cs:var3
	inc	ax
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	dec	cx
	jz	mv58
	shl	dx,1
	jz	mv60
	adc	al,ah
	loop	mv57
	pop	cx
	retn
ms6:	or	ax,ax
	jz	mv62
	mov	cx,ax
	xor	ax,ax
mv61:	shl	cs:var2,1
	jz	mv63
	adc	al,ah
	loop	mv61
mv62:	retn
mv63:	mov	bp,cs:var3
	mov	cs:var2,bp
	inc	ax
	loop	mv61
	retn
cut:	test	di,300h		;loc_224
	jz	mv65
	jmp	mv114
mv65:	test	di,1
	jz	mv66
	jmp	mv85
mv66:	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms7
	pop	cx
	pop	bx
	pop	si
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv68
ms7:	lodsw
	add	cx,ax
	mov	dx,cx
	inc	si
	inc	si
	lodsw
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax	
mv67:	lodsw
	or	ax,ax
	jz	mv70
	cmp	bx,400
	jae	mv69
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	mov	cx,di
	add	cx,8
	add	di,dx
	lodsw
	add	di,ax
	cmp	di,cx
	jb	mv71
	add	cx,0D8h
	sub	cx,di
	mov	cs:var8,cx
	jns	mv75
	mov	si,bp
	jmp	mv80
mv68:	retn
mv69:	jmp	mv79
mv70:	jmp	mv80
mv71:	cmp	si,bp
	je	mv70
	sub	ax,ax
	lodsb
	test	al,80h
	jnz	mv72
	inc	ax
	add	si,ax
	add	di,ax
	cmp	di,cx
	jl	mv71
	jz	mv74
	mov	ax,di
	sub	ax,cx
	sub	si,ax
	mov	di,cx
	mov	cx,ax
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short mv74
mv72:	test	al,40h
	jnz	mv73
	and	al,3Fh
	inc	ax
	add	di,ax
	cmp	di,cx
	jl	mv71
	jz	mv74
	jmp	short mv74
mv73:	and	al,3Fh
	add	al,3
	inc	si
	add	di,ax
	cmp	di,cx
	jl	mv71
	jz	mv74
	mov	ax,di
	sub	ax,cx
	mov	di,cx
	mov	cx,ax
	dec	si
	lodsb
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
mv74:	mov	cs:var8,0D8h
mv75:	sub	cx,cx
mv76:	cmp	si,bp
	je	mv80
	lodsb
	test	al,80h
	jnz	mv77
	mov	cl,al
	inc	cx
	sub	cs:var8,cx
	js	mv82
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short mv76
mv77:	test	al,40h
	jnz	mv78
	and	ax,3Fh
	inc	ax
	sub	cs:var8,ax
	js	mv83
	add	di,ax
	jmp	short mv76
mv78:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	lodsb
	mov	ah,al
	sub	cs:var8,cx
	js	mv84
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mv76
mv79:	add	si,ax
mv80:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv81
	jmp	mv67
mv81:	retn
mv82:	add	cx,cs:var8
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
mv83:	mov	si,bp
	jmp	short mv80
mv84:	add	cx,cs:var8
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	mov	si,bp
	jmp	short mv80
mv85:	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms8
	pop	cx
	pop	bx
	pop	si
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv88
ms8:	lodsw
	add	cx,ax
	lodsw
	add	cx,ax
	mov	dx,cx
	dec	dx
	lodsw
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
mv86:	lodsw
	or	ax,ax
	jz	mv90
	cmp	bx,400
	jae	mv89
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	mov	cx,di
	add	cx,0DFh
	add	di,dx
	lodsw
	sub	di,ax
	cmp	di,cx
	ja	mv91
	sub	cx,0D7h
	sub	cx,di
	neg	cx
	and	cx,7FFFh
	mov	cs:var8,cx
	js	mv87
	jmp	mv97
mv87:	mov	si,bp
	jmp	mv105
mv88:	retn
mv89:	jmp	mv104
mv90:	jmp	mv105
mv91:	cmp	si,bp
	je	mv90
	sub	ax,ax
	lodsb
	test	al,80h
	jnz	mv94
	inc	ax
	add	si,ax
	sub	di,ax
	cmp	di,cx
	jg	mv91
	jz	mv96
	mov	ax,cx
	sub	ax,di
	sub	si,ax
	mov	di,cx
	mov	cx,ax
	shr	cx,1
	jnc	mv92
	lodsb
	std
	stosb
	cld
mv92:	jz	mv96
	dec	di
mv93:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv93
	inc	di
	jmp	short mv96
mv94:	test	al,40h
	jnz	mv95
	and	al,3Fh
	inc	ax
	sub	di,ax
	cmp	di,cx
	jg	mv91
	jz	mv96
	jmp	short mv96
mv95:	and	al,3Fh
	add	al,3
	inc	si
	sub	di,ax
	cmp	di,cx
	jg	mv91
	jz	mv96
	mov	ax,cx
	sub	ax,di
	mov	di,cx
	mov	cx,ax
	dec	si
	lodsb
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
mv96:	mov	cs:var8,0D8h
mv97:	sub	cx,cx
mv98:	cmp	si,bp
	je	mv105
	lodsb
	test	al,80h
	jnz	mv102
	mov	cl,al
	inc	cx
	sub	cs:var8,cx
	js	mv107
	shr	cx,1
	jnc	mv99
	lodsb
	std
	stosb
	cld
mv99:	jz	mv98
	dec	di
mv100:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv101
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv101
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv101
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv100
mv101:	inc	di
	jmp	short mv98
mv102:	test	al,40h
	jnz	mv103
	and	ax,3Fh
	inc	ax
	sub	cs:var8,ax
	js	mv110
	sub	di,ax
	jmp	short mv98
mv103:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	lodsb
	mov	ah,al
	sub	cs:var8,cx
	js	mv111
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	short mv98
mv104:	add	si,ax
mv105:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv106
	jmp	mv86
mv106:	retn
mv107:	add	cx,cs:var8
	shr	cx,1
	jnc	mv108
	lodsb
	std
	stosb
	cld
mv108:	jz	mv110
	dec	di
mv109:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv109
mv110:	mov	si,bp
	jmp	short mv105
mv111:	add	cx,cs:var8
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	mov	si,bp
	jmp	short mv105
mv112:	retn
mv113:	jmp	mv129
mv114:	test	di,1
	jz	mv115
	jmp	mv135
mv115:	mov	ax,di
	mov	al,ah
	sub	ah,ah
	shl	ax,1
	mov	di,ax
	mov	ax,cs:arr2[di]
	mov	dx,ax
	mov	cs:var2,dx
	shl	ax,1
	mov	cs:var3,ax
	push	dx
	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms9
	pop	cx
	pop	bx
	pop	si
	pop	dx
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv112
	mov	cs:var2,dx
ms9:	lodsw
	call	ms5
	add	cx,ax
	mov	cs:var5,cx
	mov	cs:var4,dx
	inc	si
	inc	si
	lodsw
	call	ms6
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	sub	cx,cx
mv116:	shl	cs:var2,1
	jnc	mv113
	jnz	mv117
	mov	ax,cs:var3
	mov	cs:var2,ax
mv117:	lodsw
	or	ax,ax
	jz	mv121
	cmp	bx,400
	jae	mv122
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	mov	ax,di
	add	ax,8
	mov	cs:var6,ax
	add	ax,0D7h
	mov	cs:var7,ax
	add	di,cs:var5
	lodsw
	mov	dx,cs:var4
	call	ms5
	add	di,ax
mv118:	cmp	si,bp
	je	mv121
	lodsb
	test	al,80h
	jnz	mv125
	mov	cl,al
	inc	cx
mv119:	lodsb
	shl	dx,1
	jz	mv124
	jnc	mv120
	cmp	di,cs:var6
	jb	mv123
	cmp	di,cs:var7
	ja	mv123
	stosb
mv120:	loop	mv119
	jmp	short mv118
mv121:	jmp	short mv131
mv122:	jmp	short mv130
mv123:	inc	di
	loop	mv119
	jmp	short mv118
mv124:	mov	dx,cs:var3
	cmp	di,cs:var6
	jb	mv123
	cmp	di,cs:var7
	ja	mv123
	stosb
	loop	mv119
	jmp	short mv118
mv125:	test	al,40h
	jnz	mv126
	and	ax,3Fh
	inc	ax
	call	ms5
	add	di,ax
	jmp	short mv118
mv126:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	mov	ax,cx
	call	ms5
	mov	cx,ax
	lodsb
	or	cx,cx
	jz	mv118
mv127:	cmp	di,cs:var6
	jb	mv128
	cmp	di,cs:var7
	ja	mv128
	stosb
	loop	mv127
	jmp	mv118
mv128:	inc	di
	loop	mv127
	jmp	mv118
mv129:	lodsw
	dec	bx
	dec	bx
mv130:	add	si,ax
mv131:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv132
	jmp	mv116
mv132:	retn
mv133:	jmp	mv149
mv134:	retn
mv135:	mov	ax,di
	mov	al,ah
	sub	ah,ah
	shl	ax,1
	mov	di,ax
	mov	ax,cs:arr2[di]
	mov	dx,ax
	mov	cs:var2,dx
	shl	ax,1
	mov	cs:var3,ax
	push	dx
	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms10
	pop	cx
	pop	bx
	pop	si
	pop	dx
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv134
	mov	cs:var2,dx
ms10:	lodsw
	mov	di,ax
	lodsw
	add	ax,di
	call	ms5
	add	cx,ax
	mov	cs:var5,cx
	mov	cs:var4,dx
	lodsw
	call	ms6
	add	bx,ax
	shl	bx,1
	lodsw
	mov	cs:var1,ax
	sub	cx,cx
mv136:	shl	cs:var2,1
	jnc	mv133
	jnz	mv137
	mov	ax,cs:var3
	mov	cs:var2,ax
mv137:	lodsw
	or	ax,ax
	jz	mv143
	cmp	bx,400
	jae	mv141
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	mov	ax,di
	add	ax,8
	mov	cs:var6,ax
	add	ax,0D7h
	mov	cs:var7,ax
	add	di,cs:var5
	lodsw
	mov	dx,cs:var4
	call	ms5
	sub	di,ax
mv138:	cmp	si,bp
	je	mv143
	lodsb
	test	al,80h
	jnz	mv145
	mov	cl,al
	inc	cx
mv139:	lodsb
	shl	dx,1
	jz	mv144
	jnc	mv140
	cmp	di,cs:var6
	jb	mv142
	cmp	di,cs:var7
	ja	mv142
	std
	stosb
	cld
mv140:	loop	mv139
	jmp	short mv138
mv141:	jmp	short mv150
mv142:	dec	di
	loop	mv139
	jmp	short mv138
mv143:	jmp	short mv151
mv144:	mov	dx,cs:var3
	cmp	di,cs:var6
	jb	mv142
	cmp	di,cs:var7
	ja	mv142
	std
	stosb
	cld
	loop	mv139
	jmp	short mv138
mv145:	test	al,40h
	jnz	mv146
	and	ax,3Fh
	inc	ax
	call	ms5
	sub	di,ax
	jmp	short mv138
mv146:	mov	cl,al
	and	cl,3Fh
	add	cl,3
	mov	ax,cx
	call	ms5
	mov	cx,ax
	lodsb
	or	cx,cx
	jz	mv138
	std
mv147:	cmp	di,cs:var6
	jb	mv148
	cmp	di,cs:var7
	ja	mv148
	stosb
	loop	mv147
	cld
	jmp	mv138
mv148:	dec	di
	loop	mv147
	cld
	jmp	mv138
mv149:	lodsw
	dec	bx
	dec	bx
mv150:	add	si,ax
mv151:	inc	bx
	inc	bx
	dec	cs:var1
	jz	mv152
	jmp	mv136
mv152:	retn
mv153:	retn
whats:	mov	byte ptr cs:var10,2	;loc_314
	test	di,4000h
	jz	mv155
	inc	byte ptr cs:var10
mv155:	push	si
	push	bx
	push	cx
	mov	si,[si]
	call	ms11
	pop	cx
	pop	bx
	pop	si
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	mv153
ms11:	lodsw
	mov	dx,ax
	add	ax,ax
	cmp	byte ptr cs:var10,2
	je	mv156
	add	ax,dx
mv156:	add	cx,ax
	mov	dx,cx
	inc	si
	inc	si
	lodsw
	mov	cx,ax
	add	ax,ax
	cmp	byte ptr cs:var10,2
	je	mv157
	add	ax,cx
mv157:	add	bx,ax
	add	bx,bx
	lodsw
	mov	cs:var1,ax
mv158:	mov	cs:var11,si
	mov	al,byte ptr cs:var10
	mov	cs:var9,al
mv159:	lodsw
	or	ax,ax
	jz	mv164
	cmp	bx,400
	jae	mv165
	mov	bp,si
	add	bp,ax
	mov	di,cs:arr1[bx]
	add	di,dx
	lodsw
	mov	cx,ax
	add	ax,ax
	cmp	byte ptr cs:var10,2
	je	mv160
	add	ax,cx
mv160:	add	di,ax
mv161:	cmp	si,bp
	je	mv164
	lodsb
	test	al,80h
	jnz	mv166
	push	dx
	push	bp
	mov	bp,cs:var10
	mov	dl,al
	inc	dx
	shr	dx,1
	jnc	mv162
	lodsb
	mov	cx,bp
	rep	stosb
	or	dx,dx
	jz	mv163
mv162:	lodsb
	mov	cx,bp
	rep	stosb
	lodsb
	mov	cx,bp
	rep	stosb
	dec	dx
	jz	mv163
	lodsb
	mov	cx,bp
	rep	stosb
	lodsb
	mov	cx,bp
	rep	stosb
	dec	dx
	jnz	mv162
mv163:	pop	bp
	pop	dx
	jmp	short mv161
mv164:	jmp	short mv172
mv165:	jmp	short mv171
mv166:	test	al,40h
	jnz	mv168
	and	ax,3Fh
	inc	ax
	mov	cx,ax
	add	ax,ax
	cmp	byte ptr cs:var10,2
	je	mv167
	add	ax,cx
mv167:	add	di,ax
	jmp	short mv161
mv168:	sub	cx,cx
	mov	cl,al
	and	cl,3Fh
	add	cl,3
	mov	ax,cx
	add	cx,cx
	cmp	byte ptr cs:var10,2
	je	mv169
	add	cx,ax
mv169:	lodsb
	rep	stosb
	jmp	short mv161
mv170:	retn
mv171:	add	si,ax
mv172:	inc	bx
	inc	bx
	dec	cs:var9
	jz	mv173
	mov	si,cs:var11
	jmp	mv159
mv173:	dec	cs:var1
	jz	mv170
	jmp	mv158
vgaview	endp
wjcp	db	'Might and Magic ]I[ graphics viewer',13,10
	db	'Copyright (C) 1995 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:VGAVIEW filename.VGA [filename.PAL]',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              SPACE-repaint screen & show next,',13,10
	db	'              M-toggle mirror mode & redraw,',13,10
;"mirror mode" отражает картинку относительно вертикальной оси
	db	'              C-toggle cut mode & redraw,',13,10
;"cut mode" обрезает картинку в 8 точках от левой границы экрана,
;не позволяя сильно сдвинутым влево картинкам выехать справа экрана
	db	'              1..4-set scale(1/1,3/4,1/2,1/4) & redraw,',13,10
;"scale" устанавливает масштаб уменьшения(точно-16/16,11/16,7/16 и 4/16)
;по битовым картам показа(1-рисовать пиксел,0-нет) в массиве ARR2
	db	'              5,6-set factor(2/1,3/1) & redraw,',13,10
	db	'              other-show next w/o repainting',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
lfg	db	0
modv	dw	0	;drawing mode
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
