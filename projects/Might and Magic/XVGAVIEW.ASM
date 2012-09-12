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
	mov	ax,0A000h
	mov	es,ax
	mov	ax,cs:modv	;key code
	mov	dx,cs:scalv	;scaling factor
	mov	cx,0		;shift from left
	mov	bx,0		;starting display string
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
	cmp	ax,3B00h	;F1
	jb	mvw1a
	cmp	ax,4100h	;F7
	ja	mvw1a
	or	al,al
	jnz	mvw1a
	sub	ah,1Ah
	jmp	short mvw9
mvw1a:	cmp	al,'m'
	je	mvw3
	cmp	al,'w'
	je	mvw4
	cmp	al,'l'
	je	mvw10
	cmp	al,'0'
	jb	mvw2a
	cmp	al,'9'
	jbe	mvw7
	cmp	al,'a'
	jb	mvw8
	cmp	al,'f'
	ja	mvw2a
	sub	al,27h
mvw7:	sub	al,30h
	mov	ah,0
	mov	cs:scalv,ax
	jmp	short mvw2
mvw8:	cmp	al,'A'
	jb	mvw2a
	cmp	al,'X'
	ja	mvw2a
	sub	al,41h
	mov	byte ptr cs:modv,al
	jmp	short mvw2
mvw5:	sub	al,33h
	shl	al,6
mvw6:	mov	byte ptr cs:modv+1,al
	jmp	short mvw2
mvw10:	xor	byte ptr cs:scalv+1,80h
	jmp	short mvw2
mvw9:	xor	byte ptr cs:modv+1,ah
mvw4:	xor	byte ptr cs:modv+1,0A0h
mvw3:	xor	byte ptr cs:modv+1,80h
mvw2:	xor	di,di
	mov	cx,7D00h
	xor	ax,ax
	rep	stosw
	pop	cx
mvw0a:	jmp	mvw
mvw2a:	add	si,4
	cmp	al,27
	pop	cx
	loopnz	mvw0a
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
var27	dw	0		;:0BF2	;?
var28	dw	200		;:0BF4	;?
var29	dw	0		;:0BF6	;?
var30	dw	320		;:0BF8	;?
var31	dw	0		;:0BFA
var1	dw	0		;:0C1E
wtop	dw	0		;:0C20	;window (screen page?) top
wbot	dw	200		;:0C22	;window bottom
var8	dw	0		;:0C24
arr1	equ	this word	;:1342	;string starts
strbg	=	0
	rept	200
	dw	strbg
strbg	=	strbg+320
	endm
var7	dw	0		;:16D8
var9	dw	0		;:16DA
var2	dw	0		;:16DC
var3	dw	0		;:16DE
dcol	dw	100h,101h,202h,303h	;:16E0	;color shift
	dw	0FF00h,0FFFFh,0FEFEh,0FDFDh
var19	dw	0		;:16F0
var20	dw	0		;:16F2
var21	dw	0		;:16F4
scal	dw	0FFFFh,0FFEFh,0EFEFh,0EFEEh	;:179A
	dw	0EEEEh,0EEAEh,0AEAEh,0AEAAh
	dw	0AAAAh,0AA8Ah,8A8Ah,8A88h
	dw	8888h,8880h,8080h,8000h
var6	dw	0		;:17BA
var4	dw	0,0		;:17BC
var5	dw	0		;:17C0
var10	dw	0		;:17C2
var11	dw	0		;:17C4
andc	db	30h,0C0h,0B0h,10h	;:1812
	db	41h,20h,40h,21h
	db	48h,46h,43h,40h
	db	0D0h,0D3h,0D6h,0D8h
	db	1,4,7,0Ah
	db	0EAh,0EEh,0F2h,0F6h
addc	db	0Fh,0Fh,0Fh,0Fh		;:182A
	db	0Fh,7,7,0Fh
	db	7,7,7,7
	db	7,7,7,7
	db	0Fh,0Fh,0Fh,0Fh
	db	7,7,7,7
var12	dw	0		;:1842
var13	dw	0		;:1844
arr5	dw	-3,3,6 dup(0)	;:1846
	dw	-5,5,6 dup(0)
	dw	-7,7,6 dup(0)
	dw	-9,9,6 dup(0)
	dw	-7,7,6 dup(0)
	dw	-9,9,6 dup(0)
	dw	-11,11,6 dup(0)
	dw	-13,13,6 dup(0)
var24	dw	0		;:18C6
var25	dw	0		;:18C8
var17	dw	0		;:18CA
var18	dw	0		;:18CC
var22	dw	0		;:18CE
var23	dw	0		;:18D0
var14	dw	0		;:18D2
arr2	dw	0Eh,1Eh,3Eh,7Eh		;:18D4
var26	dw	0		;18DC
var15	dw	0		;18DE
arr3	dw	3,3,3,3,2,2,2,2		;:18E0
	dw	1,1,1,1,0,0,0,0
var16	dw	0		;:1900
arr4	dw	7Eh,7Eh,7Eh,7Eh		;:1902
	dw	3Eh,3Eh,3Eh,3Eh
	dw	1Eh,1Eh,1Eh,1Eh
	dw	0Eh,0Eh,0Eh,0Eh
arr6	dw	0F01h,0F03h,0F07h,0F0Fh	;:1922
arr7	dw	1,2,4,8			;:192A
arr10	dw	4,7,10,13		;:1932
arr8	dw	3333h,6666h,999Ah,0CCCDh	;:193A
arr9	dw	1,2,4,8,1,3,7,15	;:1942
	dw	8,12,14,15,1,2,1,2
avar	dw	0			;:1962
vgaview	proc	near
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	si
	mov	si,[si]
	call	wrk
	pop	si
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	inc	si
	inc	si
	mov	si,[si]
	or	si,si
	jz	vgx
	call	wrk
vgx:	retn
wrk:	or	dx,dx
	jns	mv008
	jmp	dble		;mv783
mv008:	or	ax,ax
	jns	mv009
	jmp	mv067
mv009:	test	ah,0Fh
	jz	mv016
	and	ah,0Fh
	dec	ah
	jnz	mv010
	jmp	clmod		;mv373
mv010:	dec	ah
	jnz	mv011
	jmp	disper		;mv516
mv011:	dec	ah
	jnz	mv012
	jmp	fx3		;mv579
mv012:	dec	ah
	jnz	mv013
	jmp	fx4		;mv582
mv013:	dec	ah
	jnz	mv014
	jmp	fx5		;mv580
mv014:	dec	ah
	jnz	mv015
	jmp	fx6		;mv581
mv015:	jmp	usrwin		;mv740
mv016:	test	ax,2000h
	jz	mv017
	jmp	mv129
mv017:	or	dx,dx
	jz	norm		;mv018
	jmp	scale		;mv033
norm:	lodsw			;=mv018
	add	cx,ax
	lodsw
	lodsw
	add	bx,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv019
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv020
mv019:	shl	bx,1
	mov	di,cs:arr1[bx]
mv020:	add	di,cx
	mov	cs:var2,di
	lodsw
	mov	cs:var3,ax
mv021:	mov	di,cs:var2
	add	cs:var2,320
	dec	cs:var3
	js	mv026
	xor	ax,ax
	lodsb
	mov	dx,cs:var1
	inc	cs:var1
	or	ax,ax
	jz	mv024
	cmp	dx,cs:wtop
	jb	mv023
	cmp	dx,cs:wbot
	jae	mv023
	mov	dx,si
	add	dx,ax
	lodsb
	add	di,ax
mv022:	cmp	dx,si
	je	mv021
	xor	ax,ax
	lodsb
	or	al,al
	js	mv027
	test	al,40h
	jz	mv025
	test	al,20h
	jnz	mv029
	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mv022
mv023:	add	si,ax
	jmp	short mv021
mv024:	lodsb
	sub	cs:var3,ax
	add	cs:var1,ax
	mov	dx,320
	mul	dx
	add	cs:var2,ax
	jmp	short mv021
mv025:	inc	ax
	mov	cx,ax
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	short mv022
mv026:	retn
mv027:	test	al,40h
	jnz	mv030
	test	al,20h
	jnz	mv028
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	rep	stosw
	jmp	short mv022
mv028:	and	al,1Fh
	inc	ax
	add	di,ax
	jmp	short mv022
mv029:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	mov	si,bx
	jmp	mv022
mv030:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv031:	stosb
	add	al,bl
	dec	cx
	jz	mv032
	stosb
	add	al,bh
	loop	mv031
mv032:	jmp	mv022
scale:	mov	bp,dx		;=mv033
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	lodsw
	mov	cs:var5,cx
	call	ms5
	add	cs:var5,ax
	mov	cs:var6,bp
	lodsw
	mov	dx,ax
	call	ms5
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv034
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv035
mv034:	add	bx,bx
	mov	di,cs:arr1[bx]
mv035:	add	di,cs:var5
	mov	cs:var2,di
mv036:	mov	di,cs:var2
	add	cs:var2,320
mv037:	dec	cs:var3
	js	mv042
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv043
	rol	cs:var4,1
	jnc	mv041
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv040
	cmp	dx,cs:wbot
	jae	mv040
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	add	di,ax
mv038:	cmp	dx,si
	je	mv036
	xor	ax,ax
	lodsb
	or	al,al
	js	mv049
	test	al,40h
	jz	mv044
	test	al,20h
	jz	mv039
	jmp	mv053
mv039:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	short mv038
mv040:	add	si,ax
	jmp	short mv036
mv041:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv037
mv042:	retn
mv043:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	mv037
mv044:	inc	ax
	mov	cx,ax
mv045:	lodsb
	rol	bp,1
	jnc	mv048
mv046:	stosb
	loop	mv045
	jmp	short mv038
mv047:	lodsb
	rol	bp,1
	jc	mv046
mv048:	loop	mv047
	jmp	short mv038
mv049:	test	al,40h
	jnz	mv058
	test	al,20h
	jnz	mv052
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv050:	rol	bp,1
	jnc	mv051
	stosb
mv051:	xchg	al,ah
	loop	mv050
	jmp	mv038
mv052:	and	al,1Fh
	inc	ax
	call	ms5
	add	di,ax
	jmp	mv038
mv053:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv054:	lodsb
	rol	bp,1
	jnc	mv057
mv055:	stosb
	loop	mv054
	mov	si,bx
	jmp	mv038
mv056:	lodsb
	rol	bp,1
	jc	mv055
mv057:	loop	mv056
	mov	si,bx
	jmp	mv038
mv058:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv059:	rol	bp,1
	jnc	mv060
	stosb
mv060:	add	al,bl
	dec	cx
	jz	mv062
	rol	bp,1
	jnc	mv061
	stosb
mv061:	add	al,bh
	loop	mv059
mv062:	jmp	mv038
ms5:	push	bx
	or	ax,ax
	jz	mv064
	mov	cx,ax
	xor	ax,ax
	mov	bx,ax
mv063:	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	dec	cx
	jz	mv064
	rol	bp,1
	adc	al,ah
	adc	bh,bl
	loop	mv063
	add	ax,bx
mv064:	pop	bx
	retn
ms6:	or	ax,ax
	jz	mv066
	mov	cx,ax
	xor	ax,ax
mv065:	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	dec	cx
	jz	mv066
	rol	cs:var4,1
	adc	al,ah
	loop	mv065
mv066:	retn
mv067:	test	ah,0Fh
	jz	mv073
	and	ah,0Fh
	dec	ah
	jnz	mv068
	jmp	mclmd		;mv445
mv068:	dec	ah
	jnz	mv069
	jmp	mdispr		;mv548
mv069:	dec	ah
	jnz	mv070
	jmp	mfx3		;mv658
mv070:	dec	ah
	jnz	mv071
	jmp	mfx4		;mv661
mv071:	dec	ah
	jnz	mv072
	jmp	mfx5		;mv659
mv072:	sub	ah,ah
	jmp	mfx6		;mv660
mv073:	or	dx,dx
	jz	mv074
	jmp	mv098
mv074:	test	ax,2000h
	jz	mirror		;mv076
	jmp	wmirr		;mv243
mv075:	retn
mirror:	lodsw			;=mv076
	sub	cx,ax
	lodsw
	dec	ax
	add	cx,ax
	lodsw
	add	bx,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv077
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv078
mv077:	add	bx,bx
	mov	di,cs:arr1[bx]
mv078:	add	di,cx
	mov	cs:var2,di
	lodsw
	mov	cs:var3,ax
mv079:	mov	di,cs:var2
	add	cs:var2,320
	dec	cs:var3
	js	mv075
	xor	ax,ax
	lodsb
	mov	dx,cs:var1
	inc	cs:var1
	or	ax,ax
	jz	mv083
	cmp	dx,cs:wtop
	jb	mv081
	cmp	dx,cs:wbot
	jae	mv081
	mov	dx,si
	add	dx,ax
	lodsb
	sub	di,ax
mv080:	cmp	dx,si
	je	mv079
	xor	ax,ax
	lodsb
	or	al,al
	js	mv088
	test	al,40h
	jz	mv084
	test	al,20h
	jz	mv082
	jmp	mv091
mv081:	add	si,ax
	jmp	short mv079
mv082:	and	al,1Fh
	add	al,3
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
	jmp	short mv080
mv083:	lodsb
	sub	cs:var3,ax
	add	cs:var1,ax
	mov	dx,320
	mul	dx
	add	cs:var2,ax
	jmp	mv079
mv084:	inc	ax
	mov	cx,ax
	shr	cx,1
	jnc	mv085
	lodsb
	std
	stosb
	cld
	jz	mv080
mv085:	dec	di
mv086:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv087
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv087
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv087
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv086
mv087:	inc	di
	jmp	short mv080
mv088:	test	al,40h
	jnz	mv095
	test	al,20h
	jnz	mv089
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	xchg	al,ah
	dec	di
	std
	rep	stosw
	cld
	inc	di
	jmp	short mv090
mv089:	and	al,1Fh
	inc	ax
	sub	di,ax
mv090:	jmp	mv080
mv091:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
	shr	cx,1
	jnc	mv092
	lodsb
	std
	stosb
	cld
mv092:	jz	mv090
	dec	di
mv093:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv094
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv094
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv094
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv093
mv094:	inc	di
	mov	si,bx
	jmp	mv080
mv095:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	std
mv096:	stosb
	add	al,bl
	dec	cx
	jz	mv097
	stosb
	add	al,bh
	loop	mv096
mv097:	cld
	jmp	mv080
mv098:	test	ax,2000h
	jz	mscale		;mv099
	jmp	mwscal		;mv303
mscale:	mov	bp,dx		;=mv099
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	mov	cs:var5,cx
	lodsw
	call	ms5
	sub	cs:var5,ax
	mov	cs:var6,bp
	mov	bp,cs:var4
	lodsw
	mov	dx,ax
	dec	ax
	call	ms5
	add	cs:var5,ax
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv100
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv101
mv100:	add	bx,bx
	mov	di,cs:arr1[bx]
mv101:	add	di,cs:var5
	mov	cs:var2,di
mv102:	mov	di,cs:var2
	add	cs:var2,320
mv103:	dec	cs:var3
	js	mv105
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv109
	rol	cs:var4,1
	jnc	mv108
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv107
	cmp	dx,cs:wbot
	jae	mv107
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	sub	di,ax
mv104:	cmp	dx,si
	je	mv102
	xor	ax,ax
	lodsb
	or	al,al
	js	mv115
	test	al,40h
	jz	mv110
	test	al,20h
	jz	mv106
	jmp	mv119
mv105:	retn
mv106:	and	al,1Fh
	add	al,3
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
	jmp	short mv104
mv107:	add	si,ax
	jmp	short mv102
mv108:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv103
mv109:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	mv103
mv110:	inc	ax
	mov	cx,ax
mv111:	lodsb
	rol	bp,1
	jnc	mv114
mv112:	std
	stosb
	cld
	loop	mv111
	jmp	short mv104
mv113:	lodsb
	rol	bp,1
	jc	mv112
mv114:	loop	mv113
	jmp	mv104
mv115:	test	al,40h
	jnz	mv124
	test	al,20h
	jnz	mv118
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
	std
mv116:	rol	bp,1
	jnc	mv117
	stosb
mv117:	xchg	al,ah
	loop	mv116
	cld
	jmp	mv104
mv118:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	jmp	mv104
mv119:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv120:	lodsb
	rol	bp,1
	jnc	mv123
mv121:	std
	stosb
	cld
	loop	mv120
	mov	si,bx
	jmp	mv104
mv122:	lodsb
	rol	bp,1
	jc	mv121
mv123:	loop	mv122
	mov	si,bx
	jmp	mv104
mv124:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	std
mv125:	rol	bp,1
	jnc	mv126
	stosb
mv126:	add	al,bl
	dec	cx
	jz	mv128
	rol	bp,1
	jnc	mv127
	stosb
mv127:	add	al,bh
	loop	mv125
mv128:	cld
	jmp	mv104
mv129:	or	dx,dx
	jz	window		;mv130
	jmp	wscale		;mv173
window:	lodsw			;=mv130
	add	cx,ax
	lodsw
	lodsw
	add	bx,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv131
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv132
mv131:	add	bx,bx
	mov	di,cs:arr1[bx]
mv132:	mov	bp,di
	add	bp,8
	mov	cs:var7,bp
	mov	cs:var2,di
	mov	cs:var8,cx
	lodsw
	mov	cs:var3,ax
mv133:	mov	di,cs:var2
	add	cs:var2,320
	mov	bp,cs:var7
	add	cs:var7,320
	dec	cs:var3
	js	mv140
	xor	ax,ax
	lodsb
	mov	dx,cs:var1
	inc	cs:var1
	or	ax,ax
	jz	mv142
	cmp	dx,cs:wtop
	jb	mv141
	cmp	dx,cs:wbot
	jae	mv141
	add	di,cs:var8
	mov	dx,si
	add	dx,ax
	lodsb
	add	di,ax
	cmp	di,bp
	jae	mv134
	jmp	mv159
mv134:	add	bp,216
	sub	bp,di
	js	mv138
	jz	mv138
mv135:	cmp	dx,si
	je	mv133
	xor	ax,ax
	lodsb
	or	al,al
	js	mv146
	test	al,40h
	jz	mv143
	test	al,20h
	jz	mv136
	jmp	mv149
mv136:	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
	mov	ah,al
	cmp	cx,bp
	ja	mv139
mv137:	sub	bp,cx
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	or	bp,bp
	jnz	mv135
mv138:	mov	si,dx
	jmp	mv133
mv139:	mov	cx,bp
	jmp	short mv137
mv140:	retn
mv141:	add	si,ax
	jmp	mv133
mv142:	lodsb
	sub	cs:var3,ax
	add	cs:var1,ax
	mov	dx,320
	mul	dx
	add	cs:var2,ax
	add	cs:var7,ax
	jmp	mv133
mv143:	inc	ax
	mov	cx,ax
	cmp	cx,bp
	ja	mv145
mv144:	sub	bp,cx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	or	bp,bp
	jz	mv138
	jmp	short mv135
mv145:	mov	cx,bp
	jmp	short mv144
mv146:	test	al,40h
	jnz	mv152
	test	al,20h
	jnz	mv148
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	add	cx,cx
	cmp	cx,bp
	jae	mv147
	sub	bp,cx
	shr	cx,1
	rep	stosw
	jmp	mv135
mv147:	mov	cx,bp
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	mov	si,dx
	jmp	mv133
mv148:	and	al,1Fh
	inc	ax
	sub	bp,ax
	js	mv157
	jz	mv157
	add	di,ax
	jmp	mv135
mv149:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
	cmp	cx,bp
	ja	mv151
mv150:	sub	bp,cx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	mov	si,bx
	or	bp,bp
	jz	mv157
	jmp	mv135
mv151:	mov	cx,bp
	jmp	short mv150
mv152:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	cmp	cx,bp
	ja	mv156
mv153:	sub	bp,cx
mv154:	stosb
	add	al,bl
	dec	cx
	jz	mv155
	stosb
	add	al,bh
	loop	mv154
mv155:	or	bp,bp
	jz	mv157
	jmp	mv135
mv156:	mov	cx,bp
	jmp	short mv153
mv157:	mov	si,dx
mv158:	jmp	mv133
mv159:	cmp	dx,si
	je	mv158
	xor	ax,ax
	lodsb
	or	al,al
	js	mv161
	test	al,40h
	jz	mv160
	test	al,20h
	jnz	mv166
	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,bp
	jb	mv159
	mov	cx,di
	sub	cx,bp
	mov	di,bp
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	mv134
mv160:	inc	ax
	add	si,ax
	add	di,ax
	cmp	di,bp
	jb	mv159
	mov	cx,di
	sub	cx,bp
	mov	di,bp
	sub	si,cx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	jmp	mv134
mv161:	test	al,40h
	jnz	mv167
	test	al,20h
	jnz	mv165
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	cx,ax
	lodsw
	add	di,cx
	cmp	di,bp
	jb	mv159
	mov	cx,di
	sub	cx,bp
	shr	di,1
	mov	di,bp
	jnc	mv162
	stosb
	xchg	al,ah
	dec	cx
mv162:	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
mv163:	jmp	mv134
mv164:	jmp	mv159
mv165:	and	al,1Fh
	inc	ax
	add	di,ax
	cmp	di,bp
	jae	mv163
	jmp	mv159
mv166:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	add	di,cx
	cmp	di,bp
	jb	mv164
	mov	bx,si
	sub	si,ax
	add	si,cx
	mov	cx,di
	sub	cx,bp
	mov	di,bp
	sub	si,cx
	shr	cx,1
	rep	movsw
	rcl	cx,1
	rep	movsb
	mov	si,bx
	jmp	mv134
mv167:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,bp
	jb	mv164
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	sub	di,cx
mv168:	cmp	di,bp
	jae	mv170
	inc	di
	add	al,bl
	dec	cx
	jz	mv169
	cmp	di,bp
	jae	mv171
	inc	di
	add	al,bh
	loop	mv168
mv169:	jmp	mv134
mv170:	stosb
	add	al,bl
	dec	cx
	jz	mv172
mv171:	stosb
	add	al,bh
	loop	mv170
mv172:	jmp	mv134
wscale:	mov	bp,dx		;=mv173
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	lodsw
	mov	cs:var5,cx
	call	ms5
	add	cs:var5,ax
	mov	cs:var6,bp
	lodsw
	mov	dx,ax
	call	ms5
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv174
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv175
mv174:	add	bx,bx
	mov	di,cs:arr1[bx]
mv175:	mov	cs:var2,di
	add	di,8
	mov	cs:var7,di
	jmp	short mv179
mv176:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var7,ax
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	short mv180
mv177:	add	si,ax
	jmp	short mv180
mv178:	add	si,ax
mv179:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv180:	dec	cs:var3
	js	mv181
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv176
	rol	cs:var4,1
	jnc	mv177
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv178
	cmp	dx,cs:wbot
	jae	mv178
	add	di,cs:var5
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv182
	jmp	mv209
mv181:	retn
mv182:	add	cs:var9,216
	sub	cs:var9,di
	js	mv186
	jz	mv186
mv183:	cmp	dx,si
	je	mv179
	xor	ax,ax
	lodsb
	or	al,al
	js	mv193
	test	al,40h
	jz	mv188
	test	al,20h
	jz	mv184
	jmp	mv199
mv184:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	mov	ah,al
	cmp	cx,cs:var9
	ja	mv187
mv185:	sub	cs:var9,cx
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	cmp	cs:var9,cx
	jne	mv183
mv186:	mov	si,dx
	jmp	mv179
mv187:	mov	cx,cs:var9
	jmp	short mv185
mv188:	inc	ax
	mov	cx,ax
mv189:	lodsb
	rol	bp,1
	jnc	mv192
mv190:	stosb
	dec	cs:var9
	jz	mv197
	loop	mv189
	jmp	short mv183
mv191:	lodsb
	rol	bp,1
	jc	mv190
mv192:	loop	mv191
	jmp	short mv183
mv193:	test	al,40h
	jnz	mv204
	test	al,20h
	jnz	mv196
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv194:	rol	bp,1
	jnc	mv195
	stosb
	dec	cs:var9
	jz	mv197
mv195:	xchg	al,ah
	loop	mv194
	jmp	mv183
mv196:	and	al,1Fh
	inc	ax
	call	ms5
	sub	cs:var9,ax
	js	mv197
	jz	mv197
	add	di,ax
	jmp	mv183
mv197:	mov	si,dx
mv198:	jmp	mv179
mv199:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv200:	lodsb
	rol	bp,1
	jnc	mv203
mv201:	stosb
	dec	cs:var9
	jz	mv197
	loop	mv200
	mov	si,bx
	jmp	mv183
mv202:	lodsb
	rol	bp,1
	jc	mv201
mv203:	loop	mv202
	mov	si,bx
	jmp	mv183
mv204:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv205:	rol	bp,1
	jnc	mv206
	stosb
	dec	cs:var9
	jz	mv197
mv206:	add	al,bl
	dec	cx
	jz	mv208
	rol	bp,1
	jnc	mv207
	stosb
	dec	cs:var9
	jz	mv197
mv207:	add	al,bh
	loop	mv205
mv208:	jmp	mv183
mv209:	cmp	dx,si
	je	mv198
	xor	ax,ax
	lodsb
	or	al,al
	js	mv219
	test	al,40h
	jz	mv211
	test	al,20h
	jz	mv210
	jmp	mv226
mv210:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv209
	mov	cx,di
	sub	cx,cs:var9
	mov	di,cs:var9
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	mv182
mv211:	inc	ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,bx
	add	di,ax
	cmp	di,cs:var9
	jb	mv209
	jz	mv217
	mov	bp,cs:var10
	sub	si,bx
	sub	di,ax
	mov	cx,bx
mv212:	lodsb
	rol	bp,1
	jnc	mv216
mv213:	cmp	di,cs:var9
	jb	mv218
	stosb
mv214:	loop	mv212
	jmp	mv182
mv215:	lodsb
	rol	bp,1
	jc	mv213
mv216:	loop	mv215
mv217:	jmp	mv182
mv218:	inc	di
	jmp	short mv214
mv219:	test	al,40h
	jz	mv220
	jmp	mv234
mv220:	test	al,20h
	jnz	mv224
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	add	di,cx
	cmp	di,cs:var9
	jb	mv225
	jz	mv217
	sub	di,cx
	mov	bp,cs:var10
	mov	cx,bx
mv221:	rol	bp,1
	jnc	mv222
	cmp	di,cs:var9
	jb	mv223
	stosb
mv222:	xchg	al,ah
	loop	mv221
	jmp	mv182
mv223:	inc	di
	jmp	short mv222
mv224:	and	al,1Fh
	inc	ax
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv217
mv225:	jmp	mv209
mv226:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,2
	add	di,ax
	cmp	di,cs:var9
	jb	mv225
	jz	mv230
	mov	bp,cs:var10
	mov	cx,bx
	mov	bx,si
	sub	si,2
	mov	si,[si]
	sub	di,ax
mv227:	lodsb
	rol	bp,1
	jnc	mv232
mv228:	cmp	di,cs:var9
	jb	mv233
	stosb
mv229:	loop	mv227
	mov	si,bx
mv230:	jmp	mv182
mv231:	lodsb
	rol	bp,1
	jc	mv228
mv232:	loop	mv231
	mov	si,bx
	jmp	mv182
mv233:	inc	di
	jmp	short mv229
mv234:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var11,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv225
	jz	mv238
	sub	di,cx
	mov	cx,cs:var11
	mov	bp,cs:var10
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
mv235:	cmp	di,cs:var9
	jae	mv239
	rol	bp,1
	jnc	mv236
	inc	di
mv236:	add	al,bl
	dec	cx
	jz	mv238
	cmp	di,cs:var9
	jae	mv241
	rol	bp,1
	jnc	mv237
	inc	di
mv237:	add	al,bh
	loop	mv235
mv238:	jmp	mv182
mv239:	rol	bp,1
	jnc	mv240
	stosb
mv240:	add	al,bl
	dec	cx
	jz	mv238
mv241:	rol	bp,1
	jnc	mv242
	stosb
mv242:	add	al,bh
	loop	mv239
	jmp	mv182
wmirr:	lodsw			;=mv243
	sub	cx,ax
	lodsw
	dec	ax
	add	cx,ax
	lodsw
	add	bx,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv244
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv245
mv244:	add	bx,bx
	mov	di,cs:arr1[bx]
mv245:	mov	bp,di
	add	bp,223
	mov	cs:var7,bp
	mov	cs:var2,di
	mov	cs:var8,cx
	lodsw
	mov	cs:var3,ax
	jmp	short mv249
mv246:	retn
mv247:	lodsb
	sub	cs:var3,ax
	add	cs:var1,ax
	mov	dx,320
	mul	dx
	add	cs:var7,ax
	add	cs:var2,ax
	jmp	short mv249
mv248:	add	si,ax
mv249:	mov	di,cs:var2
	add	cs:var2,320
	mov	bp,cs:var7
	add	cs:var7,320
	dec	cs:var3
	js	mv246
	xor	ax,ax
	lodsb
	mov	dx,cs:var1
	inc	cs:var1
	or	ax,ax
	jz	mv247
	cmp	dx,cs:wtop
	jb	mv248
	cmp	dx,cs:wbot
	jae	mv248
	add	di,cs:var8
	mov	dx,si
	add	dx,ax
	lodsb
	sub	di,ax
	cmp	di,bp
	jb	mv250
	jmp	mv281
mv250:	sub	bp,216
	mov	ax,bp
	mov	bp,di
	sub	bp,ax
	js	mv254
	jz	mv254
mv251:	cmp	dx,si
	je	mv249
	xor	ax,ax
	lodsb
	or	al,al
	js	mv263
	test	al,40h
	jz	mv256
	test	al,20h
	jz	mv252
	jmp	mv267
mv252:	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
	mov	ah,al
	cmp	cx,bp
	ja	mv255
mv253:	sub	bp,cx
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	or	bp,bp
	jnz	mv251
mv254:	mov	si,dx
	jmp	mv249
mv255:	mov	cx,bp
	jmp	short mv253
mv256:	inc	ax
	mov	cx,ax
	cmp	cx,bp
	ja	mv262
mv257:	sub	bp,cx
	shr	cx,1
	jnc	mv258
	lodsb
	std
	stosb
	cld
	jz	mv261
mv258:	dec	di
mv259:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv260
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv260
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv260
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv259
mv260:	inc	di
mv261:	or	bp,bp
	jz	mv254
	jmp	short mv251
mv262:	mov	cx,bp
	jmp	short mv257
mv263:	test	al,40h
	jz	mv264
	jmp	mv276
mv264:	test	al,20h
	jnz	mv266
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	xchg	al,ah
	add	cx,cx
	std
	dec	di
	cmp	cx,bp
	jae	mv265
	sub	bp,cx
	shr	cx,1
	rep	stosw
	cld
	inc	di
	jmp	mv251
mv265:	mov	cx,bp
	shr	cx,1
	rep	stosw
	rcl	cx,1
	mov	al,ah
	inc	di
	rep	stosb
	cld
	mov	si,dx
	jmp	mv249
mv266:	and	al,1Fh
	inc	ax
	sub	bp,ax
	js	mv274
	jz	mv274
	sub	di,ax
	jmp	mv251
mv267:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
	cmp	cx,bp
	ja	mv273
mv268:	sub	bp,cx
	shr	cx,1
	jnc	mv269
	lodsb
	std
	stosb
	cld
	jz	mv272
mv269:	dec	di
mv270:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv271
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv271
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv271
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv270
mv271:	inc	di
mv272:	mov	si,bx
	or	bp,bp
	jz	mv274
	jmp	mv251
mv273:	mov	cx,bp
	jmp	short mv268
mv274:	mov	si,dx
mv275:	jmp	mv249
mv276:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	cmp	cx,bp
	ja	mv280
mv277:	sub	bp,cx
	std
mv278:	stosb
	add	al,bl
	dec	cx
	jz	mv279
	stosb
	add	al,bh
	loop	mv278
mv279:	cld
	or	bp,bp
	jz	mv274
	jmp	mv251
mv280:	mov	cx,bp
	jmp	short mv277
mv281:	cmp	dx,si
	je	mv275
	xor	ax,ax
	lodsb
	or	al,al
	js	mv287
	test	al,40h
	jz	mv283
	test	al,20h
	jz	mv282
	jmp	mv293
mv282:	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,bp
	jae	mv281
	mov	cx,bp
	sub	cx,di
	mov	di,bp
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	mv250
mv283:	inc	ax
	add	si,ax
	sub	di,ax
	cmp	di,bp
	jae	mv281
	mov	cx,bp
	sub	cx,di
	mov	di,bp
	sub	si,cx
	shr	cx,1
	jnc	mv284
	lodsb
	std
	stosb
	cld
mv284:	jz	mv281
	dec	di
mv285:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv286
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv286
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv286
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv285
mv286:	inc	di
	jmp	mv250
mv287:	test	al,40h
	jz	mv288
	jmp	mv298
mv288:	test	al,20h
	jnz	mv291
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,bp
	jae	mv292
	mov	cx,bp
	sub	cx,di
	mov	di,bp
	dec	di
	std
	shr	cx,1
	jnc	mv289
	xchg	al,ah
mv289:	rep	stosw
	rcl	cx,1
	inc	di
	mov	al,ah
	rep	stosb
	cld
mv290:	jmp	mv250
mv291:	and	al,1Fh
	inc	ax
	sub	di,ax
	cmp	di,bp
	jb	mv290
mv292:	jmp	mv281
mv293:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	sub	ax,cx
	sub	di,cx
	cmp	di,bp
	jae	mv292
	mov	cx,bp
	sub	cx,di
	mov	di,bp
	add	ax,cx
	mov	bx,si
	sub	si,ax
	shr	cx,1
	jnc	mv294
	lodsb
	std
	stosb
	cld
mv294:	jz	mv297
	dec	di
mv295:	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv296
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv296
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	dec	cx
	jz	mv296
	lodsw
	xchg	ah,al
	std
	stosw
	cld
	loop	mv295
mv296:	inc	di
mv297:	mov	si,bx
	jmp	mv250
mv298:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,bp
	jae	mv292
	add	di,cx
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	std
mv299:	cmp	di,bp
	jbe	mv300
	dec	di
	add	al,bl
	dec	cx
	jz	mv302
	cmp	di,bp
	jbe	mv301
	dec	di
	add	al,bh
	loop	mv299
	cld
	jmp	mv250
mv300:	stosb
	add	al,bl
	dec	cx
	jz	mv302
mv301:	stosb
	add	al,bh
	loop	mv300
mv302:	cld
	jmp	mv250
mwscal:	mov	bp,dx		;=mv303
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	mov	cs:var8,cx
	lodsw
	call	ms5
	sub	cs:var8,ax
	mov	cs:var6,bp
	mov	bp,cs:var4
	lodsw
	mov	dx,ax
	dec	ax
	call	ms5
	add	cs:var8,ax
	sub	dx,ax
	shr	dx,1
	add	cs:var8,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv304
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv305
mv304:	add	bx,bx
	mov	di,cs:arr1[bx]
mv305:	mov	ax,di
	add	ax,223
	mov	cs:var7,ax
	mov	cs:var2,di
	jmp	short mv310
mv306:	retn
mv307:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	add	ax,cs:var7
	mov	cs:var7,ax
	mov	cs:var9,ax
	jmp	short mv311
mv308:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv311
mv309:	add	si,ax
mv310:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv311:	dec	cs:var3
	js	mv306
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv307
	rol	cs:var4,1
	jnc	mv308
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv309
	cmp	dx,cs:wbot
	jae	mv309
	add	di,cs:var8
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jb	mv312
	jmp	mv342
mv312:	mov	ax,di
	add	ax,216
	sub	ax,cs:var9
	mov	cs:var9,ax
	js	mv317
	jz	mv317
mv313:	cmp	dx,si
	je	mv310
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv314
	jmp	short mv324
mv314:	test	al,40h
	jz	mv319
	test	al,20h
	jz	mv315
	jmp	mv329
mv315:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	mov	ah,al
	cmp	cx,cs:var9
	ja	mv318
mv316:	sub	cs:var9,cx
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	cmp	cs:var9,cx
	jne	mv313
mv317:	mov	si,dx
	jmp	mv310
mv318:	mov	cx,cs:var9
	jmp	short mv316
mv319:	inc	ax
	mov	cx,ax
mv320:	lodsb
	rol	bp,1
	jnc	mv323
mv321:	std
	stosb
	cld
	dec	cs:var9
	jz	mv317
	loop	mv320
	jmp	short mv313
mv322:	lodsb
	rol	bp,1
	jc	mv321
mv323:	loop	mv322
	jmp	short mv313
mv324:	test	al,40h
	jz	mv325
	jmp	short mv337
mv325:	test	al,20h
	jnz	mv328
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
	std
mv326:	rol	bp,1
	jnc	mv327
	stosb
	dec	cs:var9
	jz	mv334
mv327:	xchg	al,ah
	loop	mv326
	cld
	jmp	mv313
mv328:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	sub	cs:var9,ax
	jbe	mv335
	jmp	mv313
mv329:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv330:	lodsb
	rol	bp,1
	jnc	mv333
mv331:	std
	stosb
	cld
	dec	cs:var9
	jz	mv335
	loop	mv330
	mov	si,bx
	jmp	mv313
mv332:	lodsb
	rol	bp,1
	jc	mv331
mv333:	loop	mv332
	mov	si,bx
	jmp	mv313
mv334:	cld
mv335:	mov	si,dx
mv336:	jmp	mv310
mv337:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	std
mv338:	rol	bp,1
	jnc	mv339
	stosb
	dec	cs:var9
	jz	mv334
mv339:	add	al,bl
	dec	cx
	jz	mv341
	rol	bp,1
	jnc	mv340
	stosb
	dec	cs:var9
	jz	mv334
mv340:	add	al,bh
	loop	mv338
mv341:	cld
	jmp	mv313
mv342:	cmp	dx,si
	je	mv336
	xor	ax,ax
	lodsb
	or	al,al
	js	mv351
	test	al,40h
	jz	mv344
	test	al,20h
	jz	mv343
	jmp	mv358
mv343:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,cs:var9
	jae	mv342
	mov	cx,cs:var9
	sub	cx,di
	mov	di,cs:var9
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	mv312
mv344:	inc	ax
	mov	bx,ax
	add	si,bx
	mov	cs:var10,bp
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jae	mv342
	mov	bp,cs:var10
	sub	si,bx
	add	di,ax
	mov	cx,bx
mv345:	lodsb
	rol	bp,1
	jnc	mv349
mv346:	cmp	di,cs:var9
	ja	mv350
	std
	stosb
	cld
mv347:	loop	mv345
	jmp	mv312
mv348:	lodsb
	rol	bp,1
	jc	mv346
mv349:	loop	mv348
	jmp	mv312
mv350:	dec	di
	jmp	short mv347
mv351:	test	al,40h
	jz	mv352
	jmp	mv366
mv352:	test	al,20h
	jnz	mv356
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,cs:var9
	jae	mv357
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
	std
mv353:	rol	bp,1
	jnc	mv354
	cmp	di,cs:var9
	ja	mv355
	stosb
mv354:	xchg	al,ah
	loop	mv353
	cld
	jmp	mv312
mv355:	dec	di
	jmp	short mv354
mv356:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jbe	mv362
mv357:	jmp	mv342
mv358:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,cs:var9
	jae	mv357
	add	di,cx
	mov	cx,bx
	mov	bx,si
	sub	si,ax
	mov	bp,cs:var10
mv359:	lodsb
	rol	bp,1
	jnc	mv364
mv360:	cmp	di,cs:var9
	ja	mv365
	std
	stosb
	cld
mv361:	loop	mv359
	mov	si,bx
mv362:	jmp	mv312
mv363:	lodsb
	rol	bp,1
	jc	mv360
mv364:	loop	mv363
	mov	si,bx
	jmp	mv312
mv365:	dec	di
	jmp	short mv361
mv366:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,cs:var9
	jae	mv357
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
	and	cl,7
	add	cl,3
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	std
mv367:	rol	bp,1
	jnc	mv368
	cmp	di,cs:var9
	ja	mv371
	stosb
mv368:	add	al,bl
	dec	cx
	jz	mv370
	rol	bp,1
	jnc	mv369
	cmp	di,cs:var9
	ja	mv372
	stosb
mv369:	add	al,bh
	loop	mv367
mv370:	cld
	jmp	mv312
mv371:	dec	di
	jmp	short mv368
mv372:	dec	di
	jmp	short mv369
clmod:	mov	bp,ax			;=mv373
	mov	al,cs:andc[bp]
	mov	ah,al
	mov	cs:var12,ax
	mov	al,cs:addc[bp]
	mov	ah,al
	mov	cs:var13,ax
	mov	bp,dx
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	lodsw
	mov	cs:var5,cx
	call	ms5
	add	cs:var5,ax
	mov	cs:var6,bp
	lodsw
	mov	dx,ax
	call	ms5
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv374
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv375
mv374:	add	bx,bx
	mov	di,cs:arr1[bx]
mv375:	mov	cs:var2,di
	add	di,8
	mov	cs:var7,di
	jmp	short mv379
mv376:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var7,ax
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	short mv380
mv377:	add	si,ax
	jmp	short mv380
mv378:	add	si,ax
mv379:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv380:	dec	cs:var3
	js	mv381
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv376
	rol	cs:var4,1
	jnc	mv377
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv378
	cmp	dx,cs:wbot
	jae	mv378
	add	di,cs:var5
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv382
	jmp	mv410
mv381:	retn
mv382:	add	cs:var9,216
	sub	cs:var9,di
	js	mv386
	jz	mv386
mv383:	cmp	dx,si
	je	mv379
	xor	ax,ax
	lodsb
	or	al,al
	js	mv393
	test	al,40h
	jz	mv388
	test	al,20h
	jz	mv384
	jmp	mv398
mv384:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	mov	ah,al
	cmp	cx,cs:var9
	ja	mv387
mv385:	sub	cs:var9,cx
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	cmp	cs:var9,cx
	jne	mv383
mv386:	mov	si,dx
	jmp	mv379
mv387:	mov	cx,cs:var9
	jmp	short mv385
mv388:	inc	ax
	mov	cx,ax
mv389:	lodsb
	rol	bp,1
	jnc	mv392
mv390:	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv397
	loop	mv389
	jmp	short mv383
mv391:	lodsb
	rol	bp,1
	jc	mv390
mv392:	loop	mv391
	jmp	short mv383
mv393:	test	al,40h
	jnz	mv403
	test	al,20h
	jnz	mv396
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
	and	ax,cs:var13
	add	ax,cs:var12
mv394:	rol	bp,1
	jnc	mv395
	stosb
	dec	cs:var9
	jz	mv397
mv395:	xchg	al,ah
	loop	mv394
	jmp	mv383
mv396:	and	al,1Fh
	inc	ax
	call	ms5
	sub	cs:var9,ax
	js	mv397
	jz	mv397
	add	di,ax
	jmp	mv383
mv397:	mov	si,dx
	jmp	mv379
mv398:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv399:	lodsb
	rol	bp,1
	jnc	mv402
mv400:	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv397
	loop	mv399
	mov	si,bx
	jmp	mv383
mv401:	lodsb
	rol	bp,1
	jc	mv400
mv402:	loop	mv401
	mov	si,bx
	jmp	mv383
mv403:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv404:	rol	bp,1
	jnc	mv405
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv397
mv405:	add	al,bl
	dec	cx
	jz	mv407
	rol	bp,1
	jnc	mv406
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv409
mv406:	add	al,bh
	loop	mv404
mv407:	jmp	mv383
mv408:	jmp	mv379
mv409:	mov	si,dx
	jmp	mv379
mv410:	cmp	dx,si
	je	mv408
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv411
	jmp	mv421
mv411:	test	al,40h
	jz	mv413
	test	al,20h
	jz	mv412
	jmp	mv428
mv412:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv410
	mov	cx,di
	sub	cx,cs:var9
	mov	di,cs:var9
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	mov	ah,al
	shr	cx,1
	rep	stosw
	rcl	cx,1
	rep	stosb
	jmp	mv382
mv413:	inc	ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,bx
	add	di,ax
	cmp	di,cs:var9
	jb	mv410
	jz	mv419
	mov	bp,cs:var10
	sub	si,bx
	sub	di,ax
	mov	cx,bx
mv414:	lodsb
	rol	bp,1
	jnc	mv418
mv415:	cmp	di,cs:var9
	jb	mv420
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv416:	loop	mv414
	jmp	mv382
mv417:	lodsb
	rol	bp,1
	jc	mv415
mv418:	loop	mv417
mv419:	jmp	mv382
mv420:	inc	di
	jmp	short mv416
mv421:	test	al,40h
	jz	mv422
	jmp	mv436
mv422:	test	al,20h
	jnz	mv426
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	and	ax,cs:var13
	add	ax,cs:var12
	add	di,cx
	cmp	di,cs:var9
	jb	mv427
	jz	mv419
	sub	di,cx
	mov	bp,cs:var10
	mov	cx,bx
mv423:	rol	bp,1
	jnc	mv424
	cmp	di,cs:var9
	jb	mv425
	stosb
mv424:	xchg	al,ah
	loop	mv423
	jmp	mv382
mv425:	inc	di
	jmp	short mv424
mv426:	and	al,1Fh
	inc	ax
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv419
mv427:	jmp	mv410
mv428:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,2
	add	di,ax
	cmp	di,cs:var9
	jb	mv427
	jz	mv432
	mov	bp,cs:var10
	mov	cx,bx
	mov	bx,si
	sub	si,2
	mov	si,[si]
	sub	di,ax
mv429:	lodsb
	rol	bp,1
	jnc	mv434
mv430:	cmp	di,cs:var9
	jb	mv435
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv431:	loop	mv429
	mov	si,bx
mv432:	jmp	mv382
mv433:	lodsb
	rol	bp,1
	jc	mv430
mv434:	loop	mv433
	mov	si,bx
	jmp	mv382
mv435:	inc	di
	jmp	short mv431
mv436:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var11,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv427
	jz	mv440
	sub	di,cx
	mov	cx,cs:var11
	mov	bp,cs:var10
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
mv437:	cmp	di,cs:var9
	jae	mv441
	rol	bp,1
	jnc	mv438
	inc	di
mv438:	add	al,bl
	dec	cx
	jz	mv440
	cmp	di,cs:var9
	jae	mv443
	rol	bp,1
	jnc	mv439
	inc	di
mv439:	add	al,bh
	loop	mv437
mv440:	jmp	mv382
mv441:	rol	bp,1
	jnc	mv442
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv442:	add	al,bl
	dec	cx
	jz	mv440
mv443:	rol	bp,1
	jnc	mv444
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv444:	add	al,bh
	loop	mv441
	jmp	mv382
mclmd:	mov	bp,ax		;=mv445
	mov	al,cs:andc[bp]
	mov	ah,al
	mov	cs:var12,ax
	mov	al,cs:addc[bp]
	mov	ah,al
	mov	cs:var13,ax
	mov	bp,dx
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	mov	cs:var8,cx
	lodsw
	call	ms5
	sub	cs:var8,ax
	mov	cs:var6,bp
	mov	bp,cs:var4
	lodsw
	mov	dx,ax
	dec	ax
	call	ms5
	add	cs:var8,ax
	sub	dx,ax
	shr	dx,1
	add	cs:var8,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv446
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv447
mv446:	add	bx,bx
	mov	di,cs:arr1[bx]
mv447:	mov	ax,di
	add	ax,0DFh
	mov	cs:var7,ax
	mov	cs:var2,di
	jmp	short mv452
mv448:	retn
mv449:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	add	ax,cs:var7
	mov	cs:var7,ax
	mov	cs:var9,ax
	jmp	short mv453
mv450:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv453
mv451:	add	si,ax
mv452:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv453:	dec	cs:var3
	js	mv448
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv449
	rol	cs:var4,1
	jnc	mv450
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv451
	cmp	dx,cs:wbot
	jae	mv451
	add	di,cs:var8
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jb	mv454
	jmp	mv484
mv454:	mov	ax,di
	add	ax,0D8h
	sub	ax,cs:var9
	mov	cs:var9,ax
	js	mv459
	jz	mv459
mv455:	cmp	dx,si
	je	mv452
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv456
	jmp	short mv466
mv456:	test	al,40h
	jz	mv461
	test	al,20h
	jz	mv457
	jmp	mv471
mv457:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	mov	ah,al
	cmp	cx,cs:var9
	ja	mv460
mv458:	sub	cs:var9,cx
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	cmp	cs:var9,cx
	jne	mv455
mv459:	mov	si,dx
	jmp	mv452
mv460:	mov	cx,cs:var9
	jmp	short mv458
mv461:	inc	ax
	mov	cx,ax
mv462:	lodsb
	rol	bp,1
	jnc	mv465
mv463:	std
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	cld
	dec	cs:var9
	jz	mv459
	loop	mv462
	jmp	short mv455
mv464:	lodsb
	rol	bp,1
	jc	mv463
mv465:	loop	mv464
	jmp	mv455
mv466:	test	al,40h
	jz	mv467
	jmp	mv479
mv467:	test	al,20h
	jnz	mv470
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
	and	ax,cs:var13
	add	ax,cs:var12
	std
mv468:	rol	bp,1
	jnc	mv469
	stosb
	dec	cs:var9
	jz	mv476
mv469:	xchg	al,ah
	loop	mv468
	cld
	jmp	mv455
mv470:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	sub	cs:var9,ax
	jbe	mv477
	jmp	mv455
mv471:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv472:	lodsb
	rol	bp,1
	jnc	mv475
mv473:	std
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	cld
	dec	cs:var9
	jz	mv477
	loop	mv472
	mov	si,bx
	jmp	mv455
mv474:	lodsb
	rol	bp,1
	jc	mv473
mv475:	loop	mv474
	mov	si,bx
	jmp	mv455
mv476:	cld
mv477:	mov	si,dx
mv478:	jmp	mv452
mv479:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
	std
mv480:	rol	bp,1
	jnc	mv481
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv476
mv481:	add	al,bl
	dec	cx
	jz	mv483
	rol	bp,1
	jnc	mv482
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	dec	cs:var9
	jz	mv476
mv482:	add	al,bh
	loop	mv480
mv483:	cld
	jmp	mv455
mv484:	cmp	dx,si
	je	mv478
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv485
	jmp	mv494
mv485:	test	al,40h
	jz	mv487
	test	al,20h
	jz	mv486
	jmp	mv501
mv486:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	sub	di,cx
	cmp	di,cs:var9
	jae	mv484
	mov	cx,cs:var9
	sub	cx,di
	mov	di,cs:var9
	mov	ah,al
	dec	di
	std
	shr	cx,1
	rep	stosw
	rcl	cx,1
	inc	di
	rep	stosb
	cld
	jmp	mv454
mv487:	inc	ax
	mov	bx,ax
	add	si,bx
	mov	cs:var10,bp
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jae	mv484
	mov	bp,cs:var10
	sub	si,bx
	add	di,ax
	mov	cx,bx
mv488:	lodsb
	rol	bp,1
	jnc	mv492
mv489:	cmp	di,cs:var9
	ja	mv493
	std
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	cld
mv490:	loop	mv488
	jmp	mv454
mv491:	lodsb
	rol	bp,1
	jc	mv489
mv492:	loop	mv491
	jmp	mv454
mv493:	dec	di
	jmp	short mv490
mv494:	test	al,40h
	jz	mv495
	jmp	mv509
mv495:	test	al,20h
	jnz	mv499
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	and	ax,cs:var13
	add	ax,cs:var12
	sub	di,cx
	cmp	di,cs:var9
	jae	mv500
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
	std
mv496:	rol	bp,1
	jnc	mv497
	cmp	di,cs:var9
	ja	mv498
	stosb
mv497:	xchg	al,ah
	loop	mv496
	cld
	jmp	mv454
mv498:	dec	di
	jmp	short mv497
mv499:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jbe	mv505
mv500:	jmp	mv484
mv501:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,cs:var9
	jae	mv500
	add	di,cx
	mov	cx,bx
	mov	bx,si
	sub	si,ax
	mov	bp,cs:var10
mv502:	lodsb
	rol	bp,1
	jnc	mv507
mv503:	cmp	di,cs:var9
	ja	mv508
	std
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
	cld
mv504:	loop	mv502
	mov	si,bx
mv505:	jmp	mv454
mv506:	lodsb
	rol	bp,1
	jc	mv503
mv507:	loop	mv506
	mov	si,bx
	jmp	mv454
mv508:	dec	di
	jmp	short mv504
mv509:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,cs:var9
	jae	mv500
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
	and	cl,7
	add	cl,3
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	std
mv510:	rol	bp,1
	jnc	mv511
	cmp	di,cs:var9
	ja	mv514
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv511:	add	al,bl
	dec	cx
	jz	mv513
	rol	bp,1
	jnc	mv512
	cmp	di,cs:var9
	ja	mv515
	and	al,byte ptr cs:var13
	add	al,byte ptr cs:var12
	stosb
mv512:	add	al,bh
	loop	mv510
mv513:	cld
	jmp	mv454
mv514:	dec	di
	jmp	short mv511
mv515:	dec	di
	jmp	short mv512
disper:	add	ax,ax		;=mv516
	mov	bp,ax
	mov	ax,cs:arr2[bp]
	mov	cs:var14,ax
	and	dx,0Fh
	mov	bp,dx
	add	bp,bp
	mov	ax,cs:arr3[bp]
	mov	cs:var15,ax
	mov	ax,cs:arr4[bp]
	mov	cs:var16,ax
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	push	cx
	call	mss1
	adc	cs:var17,ax
	call	mss1
	sbb	cs:var18,ax
	pop	cx
	lodsw
	mov	cs:var5,cx
	call	ms5
	add	cs:var5,ax
	mov	cs:var6,bp
	lodsw
	mov	dx,ax
	call	ms5
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv517
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv518
mv517:	add	bx,bx
	mov	di,cs:arr1[bx]
mv518:	add	di,8
	mov	cs:var7,di
	add	di,cs:var5
	sub	di,8
	mov	cs:var2,di
mv519:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var22,ax
	add	ax,216
	mov	cs:var23,ax
	add	cs:var7,320
mv520:	dec	cs:var3
	js	mv526
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv527
	rol	cs:var4,1
	jnc	mv525
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv524
	cmp	dx,cs:wbot
	jae	mv524
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	add	di,ax
mv521:	cmp	dx,si
	je	mv519
	xor	ax,ax
	lodsb
	or	al,al
	js	mv533
	test	al,40h
	jz	mv528
	test	al,20h
	jz	mv522
	jmp	mv537
mv522:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	or	cx,cx
	jz	mv521
mv523:	call	ms7
	inc	di
	loop	mv523
	jmp	short mv521
mv524:	add	si,ax
	jmp	mv519
mv525:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv520
mv526:	retn
mv527:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	mv520
mv528:	inc	ax
	mov	cx,ax
mv529:	lodsb
	rol	bp,1
	jnc	mv532
mv530:	call	ms7
	inc	di
	loop	mv529
	jmp	short mv521
mv531:	lodsb
	rol	bp,1
	jc	mv530
mv532:	loop	mv531
	jmp	mv521
mv533:	test	al,40h
	jnz	mv542
	test	al,20h
	jnz	mv536
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv534:	rol	bp,1
	jnc	mv535
	mov	cs:var24,ax
	call	ms7
	inc	di
	mov	ax,cs:var24
mv535:	xchg	al,ah
	loop	mv534
	jmp	mv521
mv536:	and	al,1Fh
	inc	ax
	call	ms5
	add	di,ax
	jmp	mv521
mv537:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	cs:var25,si
	sub	si,ax
mv538:	lodsb
	rol	bp,1
	jnc	mv541
mv539:	call	ms7
	inc	di
	loop	mv538
	mov	si,cs:var25
	jmp	mv521
mv540:	lodsb
	rol	bp,1
	jc	mv539
mv541:	loop	mv540
	mov	si,cs:var25
	jmp	mv521
mv542:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv543:	rol	bp,1
	jnc	mv544
	call	ms7
	inc	di
mv544:	add	al,bl
	dec	cx
	jz	mv546
	rol	bp,1
	jnc	mv545
	call	ms7
	inc	di
mv545:	add	al,bh
	loop	mv543
mv546:	jmp	mv521
ms7:	push	di
	push	bx
	mov	bx,cs:var17
	rcl	bx,1
	sbb	bx,cs:var18
	mov	cs:var17,bx
	rcr	cs:var18,1
	rcr	cs:var18,1
	xor	cs:var18,bx
	mov	ah,bh
	and	bx,cs:var14
	and	bx,cs:var16
	mov	bx,cs:arr5[bx]
	add	di,bx
	cmp	di,cs:var22
	jb	mv547
	cmp	di,cs:var23
	jae	mv547
	mov	bl,ah
	and	bx,cs:var14
	and	bx,cs:var16
	mov	bx,cs:arr5[bx]
	mov	bh,bl
	sub	bl,bl
	add	di,bx
	sar	bx,1
	sar	bx,1
	add	di,bx
	cmp	di,0A08h
	jb	mv547
	cmp	di,0AEA0h
	ja	mv547
	mov	es:[di],al
mv547:	pop	bx
	pop	di
	retn
mss1:	mov	ah,2Ch
	int	21h
	xor	dx,cs:var19
	adc	cx,cs:var20
	sbb	ax,cs:var21
	adc	cx,cx
	adc	ax,ax
	adc	cx,cx
	rcr	dx,1
	adc	cx,cx
	rcr	dx,1
	adc	cx,cx
	adc	ax,ax
	rcr	dx,1
	adc	cx,cx
	adc	cs:var19,dx
	sbb	cs:var20,cx
	xor	cs:var21,ax
	adc	ax,cx
	sbb	ax,dx
	retn
mdispr:	add	ax,ax		;=mv548
	mov	bp,ax
	mov	ax,cs:arr2[bp]
	mov	cs:var14,ax
	and	dx,0Fh
	mov	bp,dx
	add	bp,bp
	mov	ax,cs:arr3[bp]
	mov	cs:var15,ax
	mov	ax,cs:arr4[bp]
	mov	cs:var16,ax
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	mov	cs:var5,cx
	call	mss1
	adc	cs:var17,ax
	call	mss1
	sbb	cs:var18,ax
	lodsw
	call	ms5
	sub	cs:var5,ax
	mov	cs:var6,bp
	mov	bp,cs:var4
	lodsw
	mov	dx,ax
	dec	ax
	call	ms5
	add	cs:var5,ax
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv549
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv550
mv549:	add	bx,bx
	mov	di,cs:arr1[bx]
mv550:	add	di,8
	mov	cs:var7,di
	add	di,cs:var5
	sub	di,8
	mov	cs:var2,di
mv551:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var22,ax
	add	ax,216
	mov	cs:var23,ax
	add	cs:var7,320
mv552:	dec	cs:var3
	js	mv554
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv559
	rol	cs:var4,1
	jnc	mv558
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv557
	cmp	dx,cs:wbot
	jae	mv557
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	sub	di,ax
mv553:	cmp	dx,si
	je	mv551
	xor	ax,ax
	lodsb
	or	al,al
	js	mv565
	test	al,40h
	jz	mv560
	test	al,20h
	jz	mv555
	jmp	mv569
mv554:	retn
mv555:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	or	cx,cx
	jz	mv553
mv556:	call	ms7
	dec	di
	loop	mv556
	jmp	short mv553
mv557:	add	si,ax
	jmp	mv551
mv558:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv552
mv559:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	mv552
mv560:	inc	ax
	mov	cx,ax
mv561:	lodsb
	rol	bp,1
	jnc	mv564
mv562:	call	ms7
	dec	di
	loop	mv561
	jmp	short mv553
mv563:	lodsb
	rol	bp,1
	jc	mv562
mv564:	loop	mv563
	jmp	mv553
mv565:	test	al,40h
	jnz	mv574
	test	al,20h
	jnz	mv568
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv566:	rol	bp,1
	jnc	mv567
	mov	cs:var24,ax
	call	ms7
	dec	di
	mov	ax,cs:var24
mv567:	xchg	al,ah
	loop	mv566
	jmp	mv553
mv568:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	jmp	mv553
mv569:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	cs:var25,si
	sub	si,ax
mv570:	lodsb
	rol	bp,1
	jnc	mv573
mv571:	call	ms7
	dec	di
	loop	mv570
	mov	si,cs:var25
	jmp	mv553
mv572:	lodsb
	rol	bp,1
	jc	mv571
mv573:	loop	mv572
	mov	si,cs:var25
	jmp	mv553
mv574:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv575:	rol	bp,1
	jnc	mv576
	call	ms7
	dec	di
mv576:	add	al,bl
	dec	cx
	jz	mv578
	rol	bp,1
	jnc	mv577
	call	ms7
	dec	di
mv577:	add	al,bh
	loop	mv575
mv578:	jmp	mv553
fx3:	mov	bp,ax			;=mv579
	add	bp,bp
	mov	ax,cs:arr6[bp]
	mov	cs:var15,ax
	mov	ax,cs:arr7[bp]
	mov	cs:var26,ax
	mov	ax,offset ipp1
	jmp	short mv583
fx5:	mov	bp,ax			;=mv580
	add	bp,bp
	mov	ax,cs:arr8[bp]
	mov	cs:var15,ax
	push	dx
	push	cx
	call	mss1
	adc	cs:var17,ax
	call	mss1
	sbb	cs:var18,ax
	pop	cx
	pop	dx
	mov	ax,offset ipp3
	jmp	short mv583
fx6:	mov	bp,ax			;=mv581
	add	bp,bp
	mov	ax,cs:arr9[bp]
	mov	cs:var15,ax
	mov	ax,offset ipp4
	jmp	short mv583
fx4:	mov	bp,ax			;=mv582
	add	bp,bp
	mov	ax,cs:arr10[bp]
	mov	cs:var15,ax
	mov	ax,offset ipp2
mv583:	mov	cs:avar,ax
	mov	bp,dx
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	lodsw
	mov	cs:var5,cx
	call	ms5
	add	cs:var5,ax
	mov	cs:var6,bp
	lodsw
	mov	dx,ax
	call	ms5
	sub	dx,ax
	shr	dx,1
	add	cs:var5,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv584
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv585
mv584:	add	bx,bx
	mov	di,cs:arr1[bx]
mv585:	mov	cs:var2,di
	add	di,8
	mov	cs:var7,di
	jmp	short mv589
mv586:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var7,ax
	add	cs:var2,ax
	mov	di,cs:var2
	jmp	short mv590
mv587:	add	si,ax
	jmp	short mv590
mv588:	add	si,ax
mv589:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv590:	dec	cs:var3
	js	mv591
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv586
	rol	cs:var4,1
	jnc	mv587
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv588
	cmp	dx,cs:wbot
	jae	mv588
	add	di,cs:var5
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv592
	jmp	mv621
mv591:	retn
mv592:	add	cs:var9,216
	sub	cs:var9,di
	js	mv598
	jz	mv598
mv593:	cmp	dx,si
	je	mv589
	xor	ax,ax
	lodsb
	or	al,al
	js	mv605
	test	al,40h
	jz	mv600
	test	al,20h
	jz	mv594
	jmp	mv611
mv594:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	cmp	cx,cs:var9
	ja	mv599
mv595:	sub	cs:var9,cx
	or	cx,cx
	jz	mv597
mv596:	call	cs:avar
	inc	di
	loop	mv596
mv597:	cmp	cs:var9,cx
	jne	mv593
mv598:	mov	si,dx
	jmp	mv589
mv599:	mov	cx,cs:var9
	jmp	short mv595
mv600:	inc	ax
	mov	cx,ax
mv601:	lodsb
	rol	bp,1
	jnc	mv604
mv602:	call	cs:avar
	inc	di
	dec	cs:var9
	jz	mv609
	loop	mv601
	jmp	short mv593
mv603:	lodsb
	rol	bp,1
	jc	mv602
mv604:	loop	mv603
	jmp	short mv593
mv605:	test	al,40h
	jnz	mv616
	test	al,20h
	jnz	mv608
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv606:	rol	bp,1
	jnc	mv607
	call	cs:avar
	inc	di
	dec	cs:var9
	jz	mv609
mv607:	xchg	al,ah
	loop	mv606
	jmp	mv593
mv608:	and	al,1Fh
	inc	ax
	call	ms5
	sub	cs:var9,ax
	js	mv609
	jz	mv609
	add	di,ax
	jmp	mv593
mv609:	mov	si,dx
mv610:	jmp	mv589
mv611:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv612:	lodsb
	rol	bp,1
	jnc	mv615
mv613:	call	cs:avar
	inc	di
	dec	cs:var9
	jz	mv609
	loop	mv612
	mov	si,bx
	jmp	mv593
mv614:	lodsb
	rol	bp,1
	jc	mv613
mv615:	loop	mv614
	mov	si,bx
	jmp	mv593
mv616:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv617:	rol	bp,1
	jnc	mv618
	call	cs:avar
	inc	di
	dec	cs:var9
	jz	mv609
mv618:	add	al,bl
	dec	cx
	jz	mv620
	rol	bp,1
	jnc	mv619
	call	cs:avar
	inc	di
	dec	cs:var9
	jz	mv609
mv619:	add	al,bh
	loop	mv617
mv620:	jmp	mv593
mv621:	cmp	dx,si
	je	mv610
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv622
	jmp	mv634
mv622:	test	al,40h
	jz	mv626
	test	al,20h
	jz	mv623
	jmp	mv641
mv623:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv621
	mov	cx,di
	sub	cx,cs:var9
	mov	di,cs:var9
	or	cx,cx
	jz	mv625
mv624:	call	cs:avar
	inc	di
	loop	mv624
mv625:	jmp	mv592
mv626:	inc	ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,bx
	add	di,ax
	cmp	di,cs:var9
	jb	mv621
	jz	mv632
	mov	bp,cs:var10
	sub	si,bx
	sub	di,ax
	mov	cx,bx
mv627:	lodsb
	rol	bp,1
	jnc	mv631
mv628:	cmp	di,cs:var9
	jb	mv633
	call	cs:avar
	inc	di
mv629:	loop	mv627
	jmp	mv592
mv630:	lodsb
	rol	bp,1
	jc	mv628
mv631:	loop	mv630
mv632:	jmp	mv592
mv633:	inc	di
	jmp	short mv629
mv634:	test	al,40h
	jz	mv635
	jmp	mv649
mv635:	test	al,20h
	jnz	mv639
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	add	di,cx
	cmp	di,cs:var9
	jb	mv640
	jz	mv632
	sub	di,cx
	mov	bp,cs:var10
	mov	cx,bx
mv636:	rol	bp,1
	jnc	mv637
	cmp	di,cs:var9
	jb	mv638
	call	cs:avar
	inc	di
mv637:	xchg	al,ah
	loop	mv636
	jmp	mv592
mv638:	inc	di
	jmp	short mv637
mv639:	and	al,1Fh
	inc	ax
	call	ms5
	add	di,ax
	cmp	di,cs:var9
	jae	mv632
mv640:	jmp	mv621
mv641:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	add	si,2
	add	di,ax
	cmp	di,cs:var9
	jb	mv640
	jz	mv645
	mov	bp,cs:var10
	mov	cx,bx
	mov	bx,si
	sub	si,2
	mov	si,[si]
	sub	di,ax
mv642:	lodsb
	rol	bp,1
	jnc	mv647
mv643:	cmp	di,cs:var9
	jb	mv648
	call	cs:avar
	inc	di
mv644:	loop	mv642
	mov	si,bx
mv645:	jmp	mv592
mv646:	lodsb
	rol	bp,1
	jc	mv643
mv647:	loop	mv646
	mov	si,bx
	jmp	mv592
mv648:	inc	di
	jmp	short mv644
mv649:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var11,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	add	di,cx
	cmp	di,cs:var9
	jb	mv640
	jz	mv653
	sub	di,cx
	mov	cx,cs:var11
	mov	bp,cs:var10
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
mv650:	cmp	di,cs:var9
	jae	mv654
	rol	bp,1
	jnc	mv651
	inc	di
mv651:	add	al,bl
	dec	cx
	jz	mv653
	cmp	di,cs:var9
	jae	mv656
	rol	bp,1
	jnc	mv652
	inc	di
mv652:	add	al,bh
	loop	mv650
mv653:	jmp	mv592
mv654:	rol	bp,1
	jnc	mv655
	call	cs:avar
	inc	di
mv655:	add	al,bl
	dec	cx
	jz	mv653
mv656:	rol	bp,1
	jnc	mv657
	call	cs:avar
	inc	di
mv657:	add	al,bh
	loop	mv654
	jmp	mv592
mfx3:	mov	bp,ax			;=mv658
	add	bp,bp
	mov	ax,cs:arr6[bp]
	mov	cs:var15,ax
	mov	ax,cs:arr7[bp]
	mov	cs:var26,ax
	mov	ax,offset ipp1
	jmp	short mv662
mfx5:	mov	bp,ax			;=mv659
	add	bp,bp
	mov	ax,cs:arr8[bp]
	mov	cs:var15,ax
	push	dx
	push	cx
	call	mss1
	adc	cs:var17,ax
	call	mss1
	sbb	cs:var18,ax
	pop	cx
	pop	dx
	mov	ax,offset ipp3
	jmp	short mv662
mfx6:	mov	bp,ax			;=mv660
	add	bp,bp
	mov	ax,cs:arr9[bp]
	mov	cs:var15,ax
	mov	ax,offset ipp4
	jmp	short mv662
mfx4:	mov	bp,ax			;=mv661
	add	bp,bp
	mov	ax,cs:arr10[bp]
	mov	cs:var15,ax
	mov	ax,offset ipp2
mv662:	mov	cs:avar,ax
	mov	bp,dx
	add	bp,bp
	mov	bp,cs:scal[bp]
	mov	cs:var4,bp
	mov	cs:var8,cx
	lodsw
	call	ms5
	sub	cs:var8,ax
	mov	cs:var6,bp
	mov	bp,cs:var4
	lodsw
	mov	dx,ax
	dec	ax
	call	ms5
	add	cs:var8,ax
	sub	dx,ax
	shr	dx,1
	add	cs:var8,dx
	lodsw
	call	ms6
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	mov	cs:var1,bx
	cmp	bx,200
	jb	mv663
	mov	ax,320
	mul	bx
	mov	di,ax
	jmp	short mv664
mv663:	add	bx,bx
	mov	di,cs:arr1[bx]
mv664:	mov	ax,di
	add	ax,223
	mov	cs:var7,ax
	mov	cs:var2,di
	jmp	short mv669
mv665:	retn
mv666:	inc	cs:var1
	lodsb
	sub	cs:var3,ax
	inc	ax
	call	ms6
	add	cs:var1,ax
	mov	cx,320
	mul	cx
	add	cs:var2,ax
	mov	di,cs:var2
	add	ax,cs:var7
	mov	cs:var7,ax
	mov	cs:var9,ax
	jmp	short mv670
mv667:	add	si,ax
	mov	di,cs:var2
	sub	di,320
	jmp	short mv670
mv668:	add	si,ax
mv669:	mov	di,cs:var2
	add	cs:var2,320
	mov	ax,cs:var7
	mov	cs:var9,ax
	add	cs:var7,320
mv670:	dec	cs:var3
	js	mv665
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv666
	rol	cs:var4,1
	jnc	mv667
	mov	dx,cs:var1
	inc	cs:var1
	cmp	dx,cs:wtop
	jb	mv668
	cmp	dx,cs:wbot
	jae	mv668
	add	di,cs:var8
	mov	dx,si
	add	dx,ax
	lodsb
	mov	bp,cs:var6
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jb	mv671
	jmp	mv702
mv671:	mov	ax,di
	add	ax,216
	sub	ax,cs:var9
	mov	cs:var9,ax
	js	mv678
	jz	mv678
mv672:	cmp	dx,si
	je	mv669
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv673
	jmp	short mv685
mv673:	test	al,40h
	jz	mv680
	test	al,20h
	jz	mv674
	jmp	mv690
mv674:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	cmp	cx,cs:var9
	ja	mv679
mv675:	sub	cs:var9,cx
	or	cx,cx
	jz	mv677
mv676:	call	cs:avar
	dec	di
	loop	mv676
mv677:	cmp	cs:var9,cx
	jne	mv672
mv678:	mov	si,dx
	jmp	mv669
mv679:	mov	cx,cs:var9
	jmp	short mv675
mv680:	inc	ax
	mov	cx,ax
mv681:	lodsb
	rol	bp,1
	jnc	mv684
mv682:	call	cs:avar
	dec	di
	dec	cs:var9
	jz	mv678
	loop	mv681
	jmp	short mv672
mv683:	lodsb
	rol	bp,1
	jc	mv682
mv684:	loop	mv683
	jmp	short mv672
mv685:	test	al,40h
	jz	mv686
	jmp	short mv697
mv686:	test	al,20h
	jnz	mv689
	and	al,1Fh
	add	al,2
	mov	cx,ax
	add	cx,cx
	lodsw
mv687:	rol	bp,1
	jnc	mv688
	call	cs:avar
	dec	di
	dec	cs:var9
	jz	mv695
mv688:	xchg	al,ah
	loop	mv687
	jmp	mv672
mv689:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	sub	cs:var9,ax
	jbe	mv695
	jmp	mv672
mv690:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv691:	lodsb
	rol	bp,1
	jnc	mv694
mv692:	call	cs:avar
	dec	di
	dec	cs:var9
	jz	mv695
	loop	mv691
	mov	si,bx
	jmp	mv672
mv693:	lodsb
	rol	bp,1
	jc	mv692
mv694:	loop	mv693
	mov	si,bx
	jmp	mv672
mv695:	mov	si,dx
mv696:	jmp	mv669
mv697:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	al,7
	add	al,3
	mov	cx,ax
	lodsb
mv698:	rol	bp,1
	jnc	mv699
	call	cs:avar
	dec	di
	dec	cs:var9
	jz	mv695
mv699:	add	al,bl
	dec	cx
	jz	mv701
	rol	bp,1
	jnc	mv700
	call	cs:avar
	dec	di
	dec	cs:var9
	jz	mv695
mv700:	add	al,bh
	loop	mv698
mv701:	jmp	mv672
mv702:	cmp	dx,si
	je	mv696
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv703
	jmp	mv714
mv703:	test	al,40h
	jz	mv707
	test	al,20h
	jz	mv704
	jmp	mv721
mv704:	and	al,1Fh
	add	al,3
	call	ms5
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,cs:var9
	jae	mv702
	mov	cx,cs:var9
	sub	cx,di
	mov	di,cs:var9
	or	cx,cx
	jz	mv706
mv705:	call	cs:avar
	dec	di
	loop	mv705
mv706:	jmp	mv671
mv707:	inc	ax
	mov	bx,ax
	add	si,bx
	mov	cs:var10,bp
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jae	mv702
	mov	bp,cs:var10
	sub	si,bx
	add	di,ax
	mov	cx,bx
mv708:	lodsb
	rol	bp,1
	jnc	mv712
mv709:	cmp	di,cs:var9
	ja	mv713
	call	cs:avar
	dec	di
mv710:	loop	mv708
	jmp	mv671
mv711:	lodsb
	rol	bp,1
	jc	mv709
mv712:	loop	mv711
	jmp	mv671
mv713:	dec	di
	jmp	short mv710
mv714:	test	al,40h
	jz	mv715
	jmp	mv729
mv715:	test	al,20h
	jnz	mv719
	and	al,1Fh
	add	al,2
	add	ax,ax
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,cs:var9
	jae	mv720
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
mv716:	rol	bp,1
	jnc	mv717
	cmp	di,cs:var9
	ja	mv718
	call	cs:avar
	dec	di
mv717:	xchg	al,ah
	loop	mv716
	jmp	mv671
mv718:	dec	di
	jmp	short mv717
mv719:	and	al,1Fh
	inc	ax
	call	ms5
	sub	di,ax
	cmp	di,cs:var9
	jbe	mv725
mv720:	jmp	mv702
mv721:	and	al,1Fh
	add	al,4
	mov	bx,ax
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsw
	sub	di,cx
	cmp	di,cs:var9
	jae	mv720
	add	di,cx
	mov	cx,bx
	mov	bx,si
	sub	si,ax
	mov	bp,cs:var10
mv722:	lodsb
	rol	bp,1
	jnc	mv727
mv723:	cmp	di,cs:var9
	ja	mv728
	call	cs:avar
	dec	di
mv724:	loop	mv722
	mov	si,bx
mv725:	jmp	mv671
mv726:	lodsb
	rol	bp,1
	jc	mv723
mv727:	loop	mv726
	mov	si,bx
	jmp	mv671
mv728:	dec	di
	jmp	short mv724
mv729:	mov	bx,ax
	and	al,7
	add	al,3
	mov	cs:var10,bp
	call	ms5
	mov	cx,ax
	lodsb
	sub	di,cx
	cmp	di,cs:var9
	jae	mv720
	add	di,cx
	mov	bp,cs:var10
	mov	cx,bx
	and	cl,7
	add	cl,3
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
mv730:	rol	bp,1
	jnc	mv731
	cmp	di,cs:var9
	ja	mv734
	call	cs:avar
	dec	di
mv731:	add	al,bl
	dec	cx
	jz	mv733
	rol	bp,1
	jnc	mv732
	cmp	di,cs:var9
	ja	mv735
	call	cs:avar
	dec	di
mv732:	add	al,bh
	loop	mv730
mv733:	jmp	mv671
mv734:	dec	di
	jmp	short mv731
mv735:	dec	di
	jmp	short mv732
ipp1:	mov	cs:var24,ax
	mov	ah,es:[di]
	and	ax,cs:var15
	sub	al,byte ptr cs:var26
	add	al,ah
	js	mv736
	cmp	al,0Fh
	ja	mv737
	mov	ah,es:[di]
	and	ah,0F0h
	or	al,ah
	mov	es:[di],al
	mov	ax,cs:var24
	retn
mv736:	mov	al,es:[di]
	and	al,0F0h
	mov	es:[di],al
	mov	ax,cs:var24
	retn
mv737:	mov	al,es:[di]
	or	al,0Fh
	mov	es:[di],al
	mov	ax,cs:var24
	retn
ipp2:	mov	cs:var24,ax
	mov	ah,al
	and	ah,0Fh
	cmp	ah,byte ptr cs:var15
	jb	mv738
	mov	es:[di],al
	mov	ax,cs:var24
	retn
mv738:	mov	ax,cs:var24
	retn
ipp3:	mov	cs:var24,ax
	mov	ax,cs:var17
	rcl	ax,1
	sbb	ax,cs:var18
	mov	cs:var17,ax
	rcr	cs:var18,1
	rcr	cs:var18,1
	xor	cs:var18,ax
	cmp	ax,cs:var15
	mov	ax,cs:var24
	jbe	mv739
	mov	es:[di],al
mv739:	retn
ipp4:	mov	cs:var24,ax
	xor	al,byte ptr cs:var15
	mov	es:[di],al
	mov	ax,cs:var24
	retn
usrwin:	push	bp			;=mv740
	mov	bp,ax
	mov	dx,cx
	lodsw
	add	dx,ax
	mov	bp,dx
	mov	cs:var1,bp
	lodsw
	lodsw
	add	bx,ax
	lodsw
	mov	cs:var3,ax
	add	bx,cs:var27
	cmp	bx,cs:var27
	jge	mv741
	mov	ax,cs:var27
	sub	ax,bx
	call	ms8
	mov	bx,cs:var27
mv741:	mov	ax,320
	mul	bx
	mov	di,ax
	sub	di,320
	mov	cs:var2,di
	or	bx,bx
	jns	mv742
	call	ms8
mv742:	mov	ax,cs:var28
	mov	bx,320
	mul	bx
	mov	cs:var31,ax
	or	bp,bp
	js	mv744
	mov	ax,cs:var2
	cmp	bp,cs:var29
	jge	mv743
	add	ax,cs:var29
	mov	cs:var2,ax
	jmp	short mv744
mv743:	add	ax,bp
	mov	cs:var2,ax
mv744:	dec	cs:var3
	js	mv747
	add	cs:var2,320
	mov	di,cs:var2
	cmp	di,cs:var31
	ja	mv747
	mov	bp,cs:var1
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv746
	mov	dx,si
	add	dx,ax
	mov	bx,bp
	lodsb
	add	bp,ax
	or	bp,bp
	js	mv745
	cmp	bp,cs:var29
	jl	mv745
	add	di,ax
	or	bx,bx
	jns	mv745
	mov	ax,0FFFFh
	sub	ax,bx
	inc	ax
	sub	di,ax
mv745:	cmp	dx,si
	je	mv744
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv748
	jmp	mv758
mv746:	lodsb
	sub	cs:var3,ax
	mov	bx,320
	mul	bx
	add	cs:var2,ax
	jmp	short mv744
mv747:	pop	bp
	retn
mv748:	test	al,40h
	jz	mv752
	test	al,20h
	jz	mv749
	jmp	short mv755
mv749:	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
mv750:	or	bp,bp
	js	mv751
	cmp	di,cs:var31
	ja	mv751
	cmp	bp,cs:var30
	jge	mv751
	cmp	bp,cs:var29
	jl	mv751
	stosb
mv751:	inc	bp
	loop	mv750
	jmp	short mv745
mv752:	inc	ax
	mov	cx,ax
mv753:	lodsb
	or	bp,bp
	js	mv754
	cmp	di,cs:var31
	ja	mv754
	cmp	bp,cs:var30
	jge	mv754
	cmp	bp,cs:var29
	jl	mv754
	stosb
mv754:	inc	bp
	loop	mv753
	jmp	short mv745
mv755:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv756:	lodsb
	or	bp,bp
	js	mv757
	cmp	di,cs:var31
	ja	mv757
	cmp	bp,cs:var30
	jge	mv757
	cmp	bp,cs:var29
	jl	mv757
	stosb
mv757:	inc	bp
	loop	mv756
	mov	si,bx
	jmp	mv745
mv758:	test	al,40h
	jnz	mv762
	test	al,20h
	jnz	mv763
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	mov	bl,al
	mov	bh,ah
mv759:	or	bp,bp
	js	mv760
	cmp	di,cs:var31
	ja	mv760
	cmp	bp,cs:var30
	jge	mv760
	cmp	bp,cs:var29
	jl	mv760
	stosb
mv760:	inc	bp
	or	bp,bp
	js	mv761
	cmp	di,cs:var31
	ja	mv761
	cmp	bp,cs:var30
	jge	mv761
	cmp	bp,cs:var29
	jl	mv761
	xchg	ah,al
	stosb
	xchg	ah,al
mv761:	xchg	bx,ax
	inc	bp
	loop	mv759
	jmp	mv745
mv762:	jmp	short mv766
mv763:	and	al,1Fh
	inc	ax
	mov	bx,bp
	add	bp,ax
	or	bp,bp
	js	mv765
	or	bx,bx
	jns	mv764
	add	di,ax
	mov	ax,0FFFFh
	sub	ax,bx
	inc	ax
	sub	di,ax
	jmp	mv745
mv764:	add	di,ax
mv765:	jmp	mv745
mv766:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	ax,7
	add	al,3
	mov	cx,ax
	lodsb
mv767:	or	bp,bp
	js	mv768
	cmp	di,cs:var31
	ja	mv768
	cmp	bp,cs:var30
	jge	mv768
	cmp	bp,cs:var29
	jl	mv768
	stosb
mv768:	inc	bp
	dec	cx
	jz	mv770
	add	al,bl
	or	bp,bp
	js	mv769
	cmp	di,cs:var31
	ja	mv769
	cmp	bp,cs:var30
	jge	mv769
	cmp	bp,cs:var29
	jl	mv769
	stosb
mv769:	inc	bp
	add	al,bh
	loop	mv767
mv770:	jmp	mv745
ms8:	push	bp
	mov	bp,bx
mv771:	dec	cs:var3
	js	mv774
	inc	bp
	cmp	bp,cs:var27
	je	mv774
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv773
	mov	dx,si
	add	dx,ax
	lodsb
mv772:	cmp	dx,si
	je	mv771
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv775
	jmp	short mv780
mv773:	lodsb
	jmp	short mv771
mv774:	mov	bx,cs:var27
	mov	ax,320
	mul	bx
	mov	di,ax
	add	di,cs:var29
	sub	di,320
	mov	cs:var2,di
	pop	bp
	retn
mv775:	test	al,40h
	jz	mv777
	test	al,20h
	jz	mv776
	jmp	short mv779
mv776:	lodsb
	jmp	short mv772
mv777:	inc	ax
	mov	cx,ax
mv778:	lodsb
	loop	mv778
	jmp	short mv772
mv779:	lodsw
	jmp	short mv772
mv780:	test	al,40h
	jnz	mv782
	test	al,20h
	jnz	mv781
	lodsw
	jmp	short mv772
mv781:	jmp	short mv772
mv782:	lodsb
	jmp	short mv772
dble:	push	bp			;=mv783
	mov	dx,cx
	lodsw
	add	dx,ax
	mov	bp,dx
	mov	cs:var1,bp
	lodsw
	lodsw
	add	bx,ax
	mov	ax,320
	mul	bx
	mov	di,ax
	add	di,9
	lodsw
	mov	cs:var3,ax
	sub	di,280h
	mov	cs:var2,di
	or	bx,bx
	jns	mv784
	call	ms9
	jmp	short mv785
mv784:	cmp	bx,9
	jge	mv785
	call	ms9
mv785:	or	bp,bp
	js	mv786
	add	cs:var2,bp
mv786:	dec	cs:var3
	js	mv789
	add	cs:var2,640
	mov	di,cs:var2
	cmp	di,0AC80h
	ja	mv789
	mov	bp,cs:var1
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv788
	mov	dx,si
	add	dx,ax
	lodsb
	add	bp,ax
	add	bp,ax
	or	bp,bp
	js	mv787
	add	di,bp
mv787:	cmp	dx,si
	je	mv786
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv790
	jmp	mv803
mv788:	lodsb
	sub	cs:var3,ax
	mov	bx,320
	mul	bx
	add	cs:var2,ax
	add	cs:var2,ax
	jmp	short mv786
mv789:	pop	bp
	retn
mv790:	test	al,40h
	jz	mv795
	test	al,20h
	jz	mv791
	jmp	short mv799
mv791:	and	al,1Fh
	add	al,3
	mov	cx,ax
	lodsb
mv792:	or	bp,bp
	js	mv793
	cmp	bp,214
	jge	mv793
	stosb
	add	di,319
	stosb
	sub	di,320
mv793:	inc	bp
	or	bp,bp
	js	mv794
	cmp	bp,214
	jge	mv794
	stosb
	add	di,319
	stosb
	sub	di,320
mv794:	inc	bp
	loop	mv792
	jmp	short mv787
mv795:	inc	ax
	mov	cx,ax
mv796:	lodsb
	or	bp,bp
	js	mv797
	cmp	bp,214
	jge	mv797
	stosb
	add	di,319
	stosb
	sub	di,320
mv797:	inc	bp
	or	bp,bp
	js	mv798
	cmp	bp,214
	jge	mv798
	stosb
	add	di,319
	stosb
	sub	di,320
mv798:	inc	bp
	loop	mv796
	jmp	mv787
mv799:	and	al,1Fh
	add	al,4
	mov	cx,ax
	lodsw
	mov	bx,si
	sub	si,ax
mv800:	lodsb
	or	bp,bp
	js	mv801
	cmp	bp,214
	jge	mv801
	stosb
	add	di,319
	stosb
	sub	di,320
mv801:	inc	bp
	or	bp,bp
	js	mv802
	cmp	bp,214
	jge	mv802
	stosb
	add	di,319
	stosb
	sub	di,320
mv802:	inc	bp
	loop	mv800
	mov	si,bx
	jmp	mv787
mv803:	test	al,40h
	jnz	mv809
	test	al,20h
	jnz	mv810
	and	al,1Fh
	add	al,2
	mov	cx,ax
	lodsw
	mov	bl,al
	mov	bh,ah
mv804:	or	bp,bp
	js	mv805
	cmp	bp,214
	jge	mv805
	stosb
	add	di,319
	stosb
	sub	di,320
mv805:	inc	bp
	or	bp,bp
	js	mv806
	cmp	bp,214
	jge	mv806
	stosb
	add	di,319
	stosb
	sub	di,320
mv806:	xchg	ah,al
	inc	bp
	or	bp,bp
	js	mv807
	cmp	bp,214
	jge	mv807
	stosb
	add	di,319
	stosb
	sub	di,320
mv807:	inc	bp
	or	bp,bp
	js	mv808
	cmp	bp,214
	jge	mv808
	stosb
	add	di,319
	stosb
	sub	di,320
	xchg	bx,ax
mv808:	inc	bp
	loop	mv804
	jmp	mv787
mv809:	jmp	short mv813
mv810:	and	al,1Fh
	inc	ax
	mov	bx,bp
	add	bp,ax
	add	bp,ax
	or	bp,bp
	js	mv812
	or	bx,bx
	jns	mv811
	add	di,ax
	add	di,ax
	mov	ax,0FFFFh
	sub	ax,bx
	inc	ax
	sub	di,ax
	jmp	mv787
mv811:	add	di,ax
	add	di,ax
mv812:	jmp	mv787
mv813:	mov	bx,ax
	shr	bx,1
	shr	bx,1
	and	bl,0Eh
	mov	bx,cs:dcol[bx]
	and	ax,7
	add	al,3
	mov	cx,ax
	lodsb
mv814:	or	bp,bp
	js	mv815
	cmp	bp,214
	jge	mv815
	stosb
	add	di,319
	stosb
	sub	di,320
mv815:	inc	bp
	or	bp,bp
	js	mv816
	cmp	bp,214
	jge	mv816
	stosb
	add	di,319
	stosb
	sub	di,320
mv816:	inc	bp
	dec	cx
	jz	mv819
	add	al,bl
	or	bp,bp
	js	mv817
	cmp	bp,214
	jge	mv817
	stosb
	add	di,319
	stosb
	sub	di,320
mv817:	inc	bp
	or	bp,bp
	js	mv818
	cmp	bp,214
	jge	mv818
	stosb
	add	di,319
	stosb
	sub	di,320
mv818:	inc	bp
	add	al,bh
	loop	mv814
mv819:	jmp	mv787
ms9:	push	bp
	mov	bp,bx
mv820:	dec	cs:var3
	js	mv823
	inc	bp
	cmp	bp,9
	je	mv823
	xor	ax,ax
	lodsb
	or	ax,ax
	jz	mv822
	mov	dx,si
	add	dx,ax
	lodsb
mv821:	cmp	dx,si
	je	mv820
	xor	ax,ax
	lodsb
	or	al,al
	jns	mv824
	jmp	short mv829
mv822:	lodsb
	jmp	short mv820
mv823:	mov	bx,9
	mov	ax,320
	mul	bx
	mov	di,ax
	add	di,9
	sub	di,640
	mov	cs:var2,di
	pop	bp
	retn
mv824:	test	al,40h
	jz	mv826
	test	al,20h
	jz	mv825
	jmp	short mv828
mv825:	lodsb
	jmp	short mv821
mv826:	inc	ax
	mov	cx,ax
mv827:	lodsb
	loop	mv827
	jmp	short mv821
mv828:	lodsw
	jmp	short mv821
mv829:	test	al,40h
	jnz	mv831
	test	al,20h
	jnz	mv830
	lodsw
	jmp	short mv821
mv830:	jmp	short mv821
mv831:	lodsb
	jmp	short mv821
vgaview	endp
wjcp	db	'Might and Magic IV & V graphics viewer',13,10
	db	'Copyright (C) 1995 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:XVGAVIEW filename.VGA [filename.PAL]',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              SPACE-repaint screen & show next,',13,10
	db	'              m-toggle mirror mode & redraw,',13,10
;"mirror mode" отражает картинку относительно вертикальной оси
	db	'              w-toggle window mode & redraw,',13,10
;"window mode" обрезает картинку в окно,не позволяя сильно сдвинутым влево
;картинкам выехать справа экрана и наоборот:Xw=8..216
	db	'              l-toggle enlarged mode & redraw,',13,10
;"enlarged mode" увеличивает картинку вдвое и обрезает в окно
	db	'              1..9,a..f-set scale & redraw,',13,10
;"scale" устанавливает масштаб уменьшения(точно-16/16,11/16,7/16 и 4/16)
;по битовым картам показа(1-рисовать пиксел,0-нет) в массиве ARR2
	db	'              A..X-set colormodifier & redraw,',13,10
;"colormodifier"-число(0..17h),выбирающее базовый цвет преобразования;
;на словах это не объяснить,надо попробовать;активируется только в режиме
;преобразования цветов
	db	'              F1-toggle color modifying mode & redraw,',13,10
;а это и есть этот режим
	db	'              F2-toggle dispersing mode & redraw,',13,10
;это режим рассеивания на точки,им управляет "colormodifier":в значениях
;0..3,чем он больше,тем больше разброс,если >3,то не определено
	db	'              F3-toggle transparence mode & redraw,',13,10
	db	'              F4,F5,F6-toggle video fx & redraw,',13,10
;эффекты крутые,но зеркальный режим глючит-неверно рисует;
;диапазон:F3-F5 от 0 до 3,F6 до 15
;когда не врублено зеркало,есть режим F7-вроде бы,"пользовательское окно"
;(x=var29..var30,y=var27..var28)
	db	'              other-show next w/o repainting',13,10,'$'
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
lfg	db	0
modv	dw	0	;drawing mode
scalv	dw	0	;scaling factor
svn1	dw	?
svn2	dw	?
pbuf	db	768 dup(?)
cseg	ends
end	start
