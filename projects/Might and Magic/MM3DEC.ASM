cseg	segment	para public 'code'
	assume	cs:cseg,ds:cseg
	org	100h
	.286
start:	mov	ax,ds
	add	ax,1000h
	mov	dirseg+2,ax
	mov	ax,2
	call	dirrd		;load compressed directory
	mov	ax,flen+2
	shl	ax,3
	add	ax,17
	rcr	ax,1
	shr	ax,3
	add	ax,dirseg+2
	mov	fileseg,ax
mlp:	mov	ax,cs:fnmr
	cmp	ax,22Eh
	jae	mqq
	xor	cx,cx
	call	decomp		;decompress file
	push	bx
	mov	ah,3Ch		;save file
	mov	cx,20h
	mov	dx,offset rznm
	int	21h
	jc	errout
	mov	bx,ax
	mov	ah,40h
	mov	cx,fsiz
	pop	ds
	xor	dx,dx
	int	21h
	jc	errout
	mov	ah,3Eh
	int	21h
	push	cs
	pop	ds
	mov	bx,offset smtb
	mov	di,offset rznm+5
	mov	ax,fnmr
	inc	ax
	mov	fnmr,ax
	xchg	ah,al
	xlat
	mov	[di],al
	mov	al,ah
	aam	16
	xlat
	mov	[di]+2,al
	mov	al,ah
	xlat
	mov	[di]+1,al
	jmp	mlp
smtb	db	'0123456789ABCDEF'
mqq:	mov	bx,fdesc+2
	mov	ah,3Eh
	int	21h
	jc	errout
	mov	dx,offset pstr3
	jnc	mm1
errout:	mov	dx,offset derr
mm1:	push	cs
	pop	ds
	mov	ah,9
	int	21h
	int	20h
derr	db	'Disk error!',13,10,'$'
pstr3	db	'Done!',13,10,'$'
svmsz	dw	0
svnsg	dw	0
svnof	dw	0
dirrd	proc	near		;in AX=2 for compressed,0 for uncompressed
	push	es
	push	ds
	push	si
	push	di
	mov	si,ax
	mov	dx,offset fnm1
	shl	ax,2
	add	dx,ax
	push	cs
	pop	ds
	mov	ax,si
	xor	al,2
	mov	ah,3Dh
	int	21h
	jc	errout
	mov	cs:fdesc[si],ax
	mov	dx,offset flen
	add	dx,si
	mov	cx,2
	mov	bx,ax
	mov	ah,3Fh
	int	21h
	jc	errout
	xor	dx,dx
	mov	cx,dx
	mov	ax,4200h
	int	21h
	jc	errout
	mov	bx,cs:flen[si]
	shl	bx,3
	inc	bx
	inc	bx
	push	bx
	push	bx
	mov	ds,cs:dirseg[si]
	xor	dx,dx
	pop	cx
	mov	bx,cs:fdesc[si]
	mov	ah,3Fh
	int	21h
	jnc	mr1
	jmp	errout
mr1:	pop	cx
	mov	di,2
	sub	cx,di
	mov	es,cs:dirseg[si]
	mov	ah,0ACh
mr2:	mov	al,es:[di]
	rol	al,2
	add	al,ah
	stosb
	add	ah,67h
	loop	mr2
	pop	di
	pop	si
	pop	ds
	pop	es
	retn
dirrd	endp
decomp	proc	near		;in BX:AX @filename,out BX file seg
	push	bp
	push	ds
	push	es
	push	si
	push	di
	mov	cs:svtsg,cx
	mov	bp,2			;not unpacked
	mov	ds,cs:dirseg[bp]
	mov	si,ax
	shl	si,3
	inc	si
	inc	si
	xor	cx,cx
	lodsw
	lodsw
	mov	dx,ax
	lodsb
	mov	cl,al
	lodsw
	mov	cs:flen[bp],ax
	mov	bx,cs:fdesc[bp]
	mov	ax,4200h
	int	21h
	mov	bx,cs:flen[bp]
md11:	push	cs		;packed file load part
	pop	ds
	mov	dx,offset hbuf
	mov	cx,4
	mov	bx,fdesc+2
	mov	ah,3Fh
	int	21h
	mov	bx,hbuf+2
	xchg	bl,bh
	mov	fsiz,bx
	add	bx,16
	push	bx
	mov	ax,cs:svtsg
	or	ax,ax
	jnz	md12
	mov	ax,cs:fileseg
md12:	mov	cs:tsg,ax
	mov	ds,ax
	mov	cx,cs:flen+2
	sub	cx,4
	pop	dx
	sub	dx,cx
	mov	cs:plofs,dx
	mov	bx,cs:fdesc+2
	mov	ah,3Fh
	int	21h
	push	cs
	push	cs
	pop	ds
	pop	es
	xor	ax,ax
	mov	var1,ax
	mov	var2,8000h
	mov	bx,ax
	inc	ax
	mov	cx,arrl
	mov	dx,arrl*4-2
	mov	di,offset arr1
md14:	stosw
	mov	arr2[bx],bx
	mov	si,bx
	add	si,dx
	mov	arr3[bx],si
	inc	bx
	inc	bx
	loop	md14
	xor	bx,bx
	mov	si,arrl*2
	mov	cx,arrl-1
md15:	mov	ax,arr1[bx]
	add	ax,arr1[bx+2]
	mov	arr1[si],ax
	mov	arr3[si],bx
	mov	arr4[bx],si
	mov	arr4[bx+2],si
	add	bx,4
	inc	si
	inc	si
	loop	md15
	mov	ax,cs:hbuf
	mov	arr2-2,cx
	dec	cx
	mov	arr4-2,cx
	mov	cx,ar5l*2
	mov	var3,cx
	shr	cx,1
	mov	di,offset arr5
	rep	stosw
	mov	es,cs:tsg
	mov	var4,cx
md16:	mov	ax,var4
	cmp	ax,fsiz
	jae	md20
	mov	bx,word ptr arrx-2
	mov	dx,arrl*4-2
md17:	cmp	bx,dx
	jae	md19
	xor	cx,cx
	shl	var2,1
	jz	md22
md18:	rcl	cx,1
	shl	cx,1
	add	bx,cx
	mov	bx,arr3[bx]
	jmp	short md17
md19:	sub	bx,dx
	push	bx
	cmp	arr4-4,8000h
	je	md23
	jmp	md30
md20:	mov	bx,tsg
md21:	pop	di
	pop	si
	pop	es
	pop	ds
	pop	bp
	retn
md22:	mov	si,plofs
	add	plofs,2
	mov	ax,es:[si]
	xchg	al,ah
	stc
	rcl	ax,1
	mov	var2,ax
	jmp	short md18
md23:	int	20h		;control never comes here!
md30:	mov	bx,arr2[bx]
md31:	inc	arr1[bx]
	mov	dx,arr1[bx]
	cmp	dx,arr1[bx+2]
	jbe	md35
	mov	bp,bx
	mov	cx,2
	add	bp,cx
md32:	add	bp,cx
	cmp	dx,ds:arr1[bp]
	ja	md32
	sub	bp,cx
	mov	ax,ds:arr1[bp]
	mov	arr1[bx],ax
	mov	arr1[bp],dx
	mov	si,arr3[bx]
	mov	arr4[si],bp
	cmp	si,4*arrl-2
	jae	md33
	mov	arr4[si+2],bp
md33:	mov	di,ds:arr3[bp]
	mov	ds:arr3[bp],si
	mov	arr4[di],bx
	cmp	di,4*arrl-2
	jae	md34
	mov	arr4[di+2],bx
md34:	mov	arr3[bx],di
	mov	bx,bp
md35:	mov	bx,arr4[bx]
	or	bx,bx
	jnz	md31
	pop	bx
	shr	bx,1
	cmp	bx,100h
	jae	md38
	mov	di,var1
	mov	ax,bx
	stosb
	mov	var1,di
	mov	di,var3
	inc	var3
	mov	byte ptr arr5[di],al
	and	var3,0FFFh
	inc	var4
	jmp	md16
md36:	mov	si,plofs
	add	plofs,2
	mov	ax,es:[si]
	xchg	al,ah
	stc
md37:	rcl	ax,1
	rcl	bx,1
	loop	md37
	jmp	short md40
md38:	mov	bp,bx
	mov	cx,8
	xor	bx,bx
	mov	ax,var2
md39:	shl	ax,1
	jz	md36
	rcl	bx,1
	loop	md39
md40:	mov	var2,ax
	xor	ax,ax
	mov	al,arrx[bx+100h]
	mov	cl,6
	shl	ax,cl
	push	ax
	xor	dx,dx
	mov	dl,arrx[bx]
	dec	dx
md41:	dec	dx
	jz	md44
	shl	var2,1
	jz	md43
md42:	rcl	bx,1
	jmp	short md41
md43:	mov	si,plofs
	add	plofs,2
	mov	ax,es:[si]
	xchg	al,ah
	stc
	rcl	ax,1
	mov	var2,ax
	jmp	short md42
md44:	pop	ax
	and	bl,3Fh
	or	al,bl
	mov	bx,bp
	mov	si,var3
	sub	si,ax
	dec	si
	mov	dx,0FFFh
	mov	cx,bx
	sub	cx,0FDh
md45:	and	si,dx
	mov	al,byte ptr arr5[si]
	mov	di,var1
	stosb
	mov	var1,di
	mov	di,var3
	mov	byte ptr arr5[di],al
	inc	di
	and	di,dx
	mov	var3,di
	inc	var4
	inc	si
	loop	md45
	jmp	md16
decomp	endp
fnmr	dw	2
rznm	db	'file0002',0
fileseg	dw	?
var3	dw	?	;:0640
var4	dw	?	;:0642
dirseg	dw	?,?	;:0644	;file directory segments
fdesc	dw	0,0	;:0648	;file descriptors
flen	dw	?,?	;:064C	;loadable file length
svtsg	dw	?	;:0650	;if<>0,target segment for loading
plofs	dw	?	;:0656	;packed file load offset
tsg	dw	?	;:0658	;target segment for loading
var1	dw	?	;:065A
var2	dw	?	;:065C
hbuf	dw	?,?	;:065E	;buffer for header read
fsiz	dw	?	;:0662	;packed file real length
fnm1	db	'mm3.cur',0	;:066A
fnm2	db	'mm3.cc',0	;:0672
ar5l	equ	7E2h
arr5	dw	ar5l dup(?)	;:0672
	dw	7Eh dup(?)	;free(?) space
arrl	equ	13Ah
arr1	dw	arrl dup(?)	;:16B4
arr1a	dw	arrl dup(?)	;:1928
arr4	dw	2*arrl-1 dup(?)	;:1B9C
arr2	dw	arrl dup(?)	;:2082
arr3	dw	arrl dup(?)	;:22F6
arr3a	dw	arrl-1 dup(?)	;:256A
arrx	equ	this byte 	;:27DC	;this is initialized data!
	db	20h dup(3),30h dup(4),40h dup(5),30h dup(6),30h dup(7)
	db	10h dup(8),20h dup(0),10h dup(1),10h dup(2),10h dup(3)
	db	8 dup(4),8 dup(5),8 dup(6),8 dup(7),8 dup(8),8 dup(9)
	db	8 dup(10),8 dup(11),4 dup(12),4 dup(13),4 dup(14),4 dup(15)
	db	4 dup(16),4 dup(17),4 dup(18),4 dup(19),4 dup(20),4 dup(21)
	db	4 dup(22),4 dup(23),24,24,25,25,26,26,27,27,28,28,29,29,30,30
	db	31,31,'  !!""##$$%%&&''''(())**++,,--..//0123456789:;<=>?'
cseg	ends
end	start
