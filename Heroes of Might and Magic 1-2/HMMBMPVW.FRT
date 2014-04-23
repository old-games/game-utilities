Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
0 Value Bmp
0 Value Fsz
Create WrkPal 0 $300 Loaddata .\combat.pal \ Main game palette
Variable SVGA
SVGA Off
Variable KSym
>Public KSym
Code KbdIn ;( --> )
	mov	ah,0
	int	16h
	movzx	eax,ax
	mov	[KSym],eax
	next
Endcode
Code Set13h ;( --> )
	mov	ax,13h
	int	10h
	next
Endcode
Code Set101h ;( --> )
	mov	ax,4F02h
	mov	bx,101h
	int	10h
	next
Endcode
Code SetText ;( --> )
	mov	ax,3
	int	10h
	next
Endcode
Code SetPal ;( @palette --> )
	xchg	[esp],esi
	mov	edx,3DAh
md1:	in	al,dx
	test	al,8
	jz	md1
md2:	in	al,dx
	test	al,8
	jnz	md2
	mov	dl,0C8h
	mov	al,0
	out	dx,al
	inc	edx
	mov	ecx,300h
	rep	outsb
	pop	esi
	next
Endcode
Code DispSVGA ;( BIOSsel @pic xsz ysz --> )
	mov	ax,4F05h
	xor	ebx,ebx
	xor	edx,edx
	int	10h
	pop	edx
	pop	ebx
	pop	eax
	pop	es
	push	esi
	xchg	eax,esi
	mov	edi,0A0000h
	xor	eax,eax
	push	eax
mlp:	lea	eax,[edi+640]
	sub	eax,0B0000h
	jae	short msw
	mov	ecx,ebx
mnx0:	rep	movsb
	sub	edi,ebx
	add	edi,640
mnx1:	dec	edx
	jnz	short mlp
	pop	eax
	pop	esi
	push	ds
	pop	es
	next
msw:	mov	ecx,640
	sub	ecx,eax
	mov	eax,ecx
	cmp	ebx,ecx
	jae	short msw1
	mov	ecx,ebx
msw1:	rep	movsb
	inc	dword ptr [esp]
	push	eax
	push	ebx
	push	edx
	mov	ax,4F05h
	xor	ebx,ebx
	mov	edx,[esp+12]
	int	10h
	pop	edx
	pop	ebx
	pop	eax
	mov	edi,0A0000h
	mov	ecx,ebx
	sub	ecx,eax
	ja	short mnx0
	add	edi,640
	sub	edi,eax
	jmp	short mnx1
Endcode
Code DispVGA ;( BIOSsel @pic xsz ysz --> )
	pop	edx
	pop	ebx
	pop	eax
	pop	es
	push	esi
	xchg	eax,esi
	mov	edi,0A0000h
mlp:	mov	ecx,ebx
	rep	movsb
	sub	edi,ebx
	add	edi,320
	dec	edx
	jnz	short mlp
	pop	esi
	push	ds
	pop	es
	next
Endcode
Code ClrSVGA ;( BIOSsel --> )
	pop	es
	xor	ebx,ebx
	xor	edx,edx
	call	sg1
	inc	edx
	call	sg1
	inc	edx
	call	sg1
	inc	edx
	call	sg1
	inc	edx
	mov	ecx,2C00h
	call	sg2
	push	ds
	pop	es
	next
sg1:	mov	ecx,4000h
sg2:	mov	ax,4F05h
	int	10h
	mov	edi,0A0000h
	xor	eax,eax
	rep	stosd
	ret
Endcode
: ?BlastOff ( flag --> )
   ?Exit SetText Bye
;
: MAIN ( --> )
   ." Heroes Of Might And Magic bitmap and tile files viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: HMMBMPVW file [palette]" cr
    ." Internal keys: ESC - immediate exit," cr
    ."                any other - show next." cr
    Bye
   Then >R
   R@ 2 0 FSeek Drop To Fsz R@ 0 0 FSeek 2Drop
   Here To Bmp R@ Bmp Fsz Dup Allot FRead ?Drop R> FClose Drop
   Bl Word Dup C@ If
    >ASCIIZ 0 FOpen IfNot Bye Then Dup WrkPal 768 FRead ?Drop FClose Drop
   Else Drop Then
   Bmp 2+ W@ 320 > Bmp 4+ W@ 200 > Or If SVGA On Set101h BIOSselector ClrSVGA
   Else Set13h Then
   WrkPal SetPal
   6 Begin
    Dup Fsz < ?BlastOff
    BIOSselector Over Bmp + Bmp 2+ W@ Bmp 4+ W@
    SVGA @ If DispSVGA Else DispVGA Then
    KbdIn
    KSym C@ 27 <> ?BlastOff
    SVGA @ If BIOSselector ClrSVGA Else $A0000 BIOSselector 64000 0 AFill Then
    Bmp 2+ W@ Bmp 4+ W@ * +
   Again
;
NoErrors NoTraps
1 MBytes Dup Minmem ! Maxmem !
Build .\hmmbmpvw.exe
