cseg	segment	para public 'code'
	assume cs:cseg,ds:cseg
	include parse.asm
	.286
	org	100h
start:	mov	dx,offset wjcp
	mov	ah,9
	int	21h
	parse	svn2
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
	mov	dx,offset fnme
	int	21h
	jc	errdd
	push	ax
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
	mov	cx,25740
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	jc	mer1
	cmp	ax,cx
	je	mlnx
mer1:	jmp	errd1
mlnx:	mov	ah,3Eh
	int	21h
	mov	ax,0A000h
	mov	es,ax
	mov	cx,33
	xor	si,si
mvw:	xor	di,di
	mov	dx,cx
	mov	bx,30
ml2:	mov	cx,26
ml1:	lodsb
	cmp	al,0FFh
	je	mm1
	stosb
	loop	ml1
	jmp	short mm2
mm1:	inc	di
	loop	ml1
mm2:	add	di,294
	dec	bx
	jnz	ml2
	mov	ah,0
	int	16h
	cmp	al,27
	mov	ax,0
	mov	di,ax
	mov	cx,4800
	rep	stosw
	mov	cx,dx
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
pbuf	db	00h,00h,00h,3Fh,3Fh,3Fh,38h,38h,38h,33h,33h,33h,2Eh,2Eh,2Eh,29h
	db	29h,29h,24h,24h,24h,20h,20h,20h,1Ch,1Ch,1Ch,18h,18h,18h,14h,14h
	db	14h,10h,10h,10h,0Dh,0Dh,0Dh,0Ah,0Ah,0Ah,07h,07h,07h,04h,04h,04h
	db	3Fh,3Ah,3Ah,3Dh,34h,34h,3Fh,2Eh,2Eh,3Fh,22h,22h,3Fh,16h,16h,3Fh
	db	10h,10h,3Fh,00h,00h,3Ah,00h,00h,35h,00h,00h,30h,00h,00h,2Bh,00h
	db	00h,26h,00h,00h,21h,00h,00h,1Ch,00h,00h,17h,00h,00h,12h,00h,00h
	db	0Eh,00h,00h,0Ah,00h,00h,06h,00h,00h,02h,00h,00h,3Fh,30h,22h,3Fh
	db	2Ah,17h,3Fh,25h,0Ch,3Fh,1Eh,00h,36h,19h,00h,2Eh,15h,00h,25h,11h
	db	00h,1Dh,0Eh,00h,3Fh,2Dh,0Bh,3Bh,29h,09h,37h,25h,07h,33h,22h,06h
	db	28h,3Fh,28h,1Ch,3Fh,1Ch,00h,3Fh,00h,00h,38h,00h,00h,30h,00h,00h
	db	28h,00h,00h,20h,00h,00h,18h,00h,00h,12h,00h,00h,0Ch,00h,00h,08h
	db	00h,2Fh,1Fh,05h,29h,1Bh,07h,23h,18h,09h,1Eh,15h,09h,18h,11h,09h
	db	35h,3Bh,18h,2Ah,38h,00h,24h,30h,00h,1Eh,28h,00h,18h,20h,00h,12h
	db	18h,00h,0Dh,12h,00h,09h,0Ch,00h,06h,08h,00h,04h,05h,00h,02h,02h
	db	00h,0Ch,34h,32h,05h,2Ah,27h,00h,20h,1Eh,00h,19h,18h,00h,12h,12h
	db	3Fh,3Dh,34h,3Fh,3Dh,2Eh,3Fh,3Dh,28h,3Fh,3Dh,1Ch,3Fh,3Dh,15h,3Fh
	db	3Dh,00h,38h,36h,00h,30h,2Eh,00h,28h,26h,00h,20h,1Eh,00h,18h,16h
	db	00h,12h,10h,00h,0Ch,0Ah,00h,08h,06h,00h,00h,20h,3Fh,00h,18h,30h
	db	36h,36h,3Ah,34h,34h,37h,31h,31h,35h,2Fh,2Fh,32h,2Dh,2Dh,30h,2Bh
	db	2Bh,2Dh,29h,29h,2Bh,26h,26h,28h,24h,24h,26h,22h,22h,23h,20h,20h
	db	21h,1Dh,1Eh,1Fh,1Bh,1Bh,1Ch,19h,19h,1Ah,16h,16h,17h,14h,14h,15h
	db	11h,11h,12h,0Eh,0Eh,10h,0Bh,0Bh,0Eh,08h,08h,0Ah,05h,06h,08h,04h
	db	04h,06h,02h,02h,04h,01h,01h,02h,17h,1Ah,1Eh,14h,16h,1Bh,11h,13h
	db	18h,0Fh,10h,15h,0Ch,0Eh,12h,0Ah,0Bh,10h,08h,08h,0Dh,06h,06h,0Ah
	db	2Eh,3Ah,3Fh,28h,37h,3Fh,22h,34h,3Fh,1Ch,31h,3Fh,15h,2Eh,3Fh,0Fh
	db	2Bh,3Fh,00h,28h,3Fh,00h,23h,38h,00h,1Eh,30h,00h,19h,28h,00h,14h
	db	20h,00h,10h,20h,00h,0Fh,18h,00h,0Bh,12h,00h,08h,0Ch,00h,05h,08h
	db	3Ah,24h,1Ch,34h,1Eh,1Ah,2Eh,18h,14h,28h,14h,10h,3Fh,28h,34h,3Fh
	db	22h,30h,3Fh,15h,28h,1Ch,1Ch,3Fh,12h,12h,3Fh,00h,00h,3Fh,00h,00h
	db	30h,00h,00h,20h,00h,00h,18h,00h,00h,12h,00h,00h,0Ch,00h,00h,08h
	db	22h,10h,0Eh,1Eh,0Eh,0Dh,18h,0Ah,0Ah,14h,08h,08h,3Fh,00h,20h,32h
	db	00h,19h,26h,00h,13h,3Fh,28h,3Fh,3Fh,19h,3Fh,3Fh,00h,3Fh,36h,00h
	db	37h,2Dh,00h,2Eh,24h,00h,25h,1Bh,00h,1Ch,12h,00h,13h,0Ah,00h,0Bh
	db	3Fh,3Ch,18h,3Eh,39h,14h,3Dh,37h,11h,3Ch,35h,0Eh,3Bh,33h,0Bh,3Ah
	db	31h,08h,38h,2Fh,07h,35h,2Ch,06h,2Bh,2Dh,38h,27h,28h,35h,22h,24h
	db	33h,1Fh,20h,31h,19h,1Ah,2Dh,14h,15h,29h,0Fh,10h,25h,0Bh,0Ch,22h
	db	32h,29h,05h,2Fh,26h,04h,2Ch,23h,03h,29h,20h,02h,26h,1Dh,02h,23h
	db	19h,01h,20h,14h,00h,1Dh,10h,00h,1Ah,0Ch,00h,16h,09h,00h,13h,08h
	db	00h,10h,06h,00h,0Dh,04h,00h,0Ah,02h,00h,07h,02h,00h,06h,01h,00h
	db	34h,2Dh,18h,34h,2Ah,14h,30h,26h,12h,2Ch,22h,11h,28h,1Eh,0Eh,22h
	db	1Ah,0Eh,1Ch,16h,0Dh,3Fh,36h,29h,3Eh,33h,26h,3Dh,30h,23h,3Ch,2Eh
	db	21h,3Bh,2Ch,1Fh,3Ah,2Ah,1Dh,39h,27h,1Ah,38h,24h,18h,33h,20h,16h
	db	18h,13h,0Eh,14h,10h,0Bh,10h,0Ch,09h,3Ah,31h,26h,32h,29h,1Eh,2Ah
	db	21h,17h,23h,19h,11h,2Eh,1Eh,13h,29h,1Ah,11h,24h,17h,0Fh,20h,14h
	db	0Dh,1Bh,11h,0Bh,16h,0Eh,09h,10h,0Ah,06h,0Ah,06h,03h,04h,02h,01h
	db	36h,1Ch,1Ch,30h,15h,15h,2Ah,10h,10h,24h,0Bh,0Bh,1Eh,07h,07h,18h
	db	04h,04h,30h,29h,3Fh,29h,19h,3Fh,20h,00h,3Fh,1Ch,00h,38h,18h,00h
	db	30h,14h,00h,28h,10h,00h,20h,0Ch,00h,18h,08h,00h,10h,18h,18h,20h
wjcp	db	'Wizardry 7 PORTDATA.VGA file viewer',13,10
	db	'Copyright (C) 1996 by WhiteJaguar',13,10,10,'$'
perr	db	'Usage:WPORTVW [filename.PAL]',13,10
	db	'Internal keys:ESC-immediate exit,',13,10
	db	'              other-show next',13,10,'$'
fnme	db	'portdata.vga',0
derr	db	'Disk error!',13,10,'$'
aerr	db	'Video error!',13,10,'$'
svn2	dw	?
cseg	ends
end	start
