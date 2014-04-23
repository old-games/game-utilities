Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
Variable FCount
2Variable 1stHdr
2Variable 2ndHdr
0 Constant MenzHdr
0 Constant MenzSizes
0 Constant WrkBuf
0 Constant ImgData
Create MasterPal 0 $300 Loaddata .\menz26.pal Create; \ Main game palette
0 Constant TmpScr
0 Constant StartNum
True Constant PalFlag
Variable DataFlag
Variable KSym
>Public KSym
Code KbdIn ;( --> )
	mov	ah,0
	int	16h
	movzx	eax,ax
	mov	[KSym],eax
	next
Endcode
Code SetGraph ;( --> )
	mov	eax,13h
	int	10h
	mov	dx,3D4h
	mov	ax,4009h
	out	dx,ax
	mov	ax,14h
	out	dx,ax
	mov	ax,0E317h
	out	dx,ax
	mov	dl,0C4h
	mov	ax,604h
	out	dx,ax
	mov	ax,0F02h
	out	dx,ax
	next
Endcode
Code SetText ;( --> )
	mov	eax,3
	int	10h
	next
Endcode
Code Setpal ;( @palette --> )
	xchg	[esp],esi
	mov	edx,3DAh
md1:	in	al,dx
	test	al,8
	jz	short md1
md2:	in	al,dx
	test	al,8
	jnz	short md2
	mov	dl,0C8h
	mov	al,0
	out	dx,al
	inc	edx
	mov	ecx,300h
	rep	outsb
	pop	esi
	next
Endcode
Code OutT1&2 ;( @hdr2 @page @temp --> )
	pop	edi
	pop	eax
	pop	ebx
	push	esi
	xchg	eax,esi
	movzx	ecx,byte ptr [ebx+4]
	movzx	edx,word ptr [ebx+2]
	mov	ah,[ebx+5]
	mov	ebx,ecx
	shl	ebx,3
	cmp	ah,0FFh
	jne	short ml3
ml1:	mov	ecx,ebx
	shr	ecx,1
	rep	movsw
	rcl	ecx,1
	rep	movsb
	sub	edi,ebx
	add	edi,320
	dec	edx
	jnz	short ml1
	jmp	short mq
ml3:	mov	ecx,ebx
ml2:	lodsb
	inc	edi
	cmp	al,ah
	je	short m2
	mov	[edi],al
m2:	loop	ml2
	sub	edi,ebx
	add	edi,320
	dec	edx
	jnz	short ml3
mq:	pop	esi
	next
Endcode
Code OutT5 ;( @hdr2 @data @temp --> )
	pop	edi
	pop	eax
	pop	ebx
	push	esi
	xchg	eax,esi
	xor	eax,eax
	lodsw
	mov	ebx,[ebx+1]
	and	ebx,-64
	xchg	eax,ebx
	cmp	eax,1000h
	je	m1a
	test	bh,bh
	jnz	short m1
m1a:	mov	ebx,eax
	shr	ebx,6
	dec	esi
	dec	esi
m1:	xor	edx,edx
	div	ebx
	mov	edx,edi
m2:	mov	ecx,ebx
m3:	movsb
	add	edi,319
	loop	m3
	inc	edx
	mov	edi,edx
	dec	eax
	jnz	short m2
	pop	esi
	next
Endcode
Code OutT6 ;( @data @temp --> )
	pop	edi
	xchg	esi,[esp]
	push	ebp
	xor	eax,eax
	mov	ebx,esi
	lodsw
	lodsw
	add	edi,eax
	lea	edx,[eax-1]
	lodsw
	sub	eax,edx
	mov	edx,eax
	add	esi,4
mcl:	lodsw
	push	esi
	lea	esi,[ebx+eax]
mbl:	xor	eax,eax
	lodsw
	test	eax,eax
	jz	short mcx
	shr	eax,1
	mov	ecx,eax
	lodsw
	movsx	ebp,ax
	lodsw
	shr	eax,1
	sub	ecx,eax
	push	esi
	push	edi
	lea	esi,[ebp+eax]
	add	esi,ebx
	lea	eax,[eax+4*eax]
	shl	eax,6
	add	edi,eax
ml:	movsb
	add	edi,319
	loop	ml
	pop	edi
	pop	esi
	jmp	short mbl
mcx:	pop	esi
	inc	edi
	dec	edx
	jnz	short mcl
	pop	ebp
	pop	esi
	next
Endcode
: RErr? ( size True | False [Rstk:] fhdl --> )
   IfNot SetText ." Disk error!" cr ROver FClose Bye Else Drop Then
;
: ClrScr ( --> )
   TmpScr 128000 0 Fill
;
: ReadItem ( 2ndHdrSize R: FHdl ItemSize --> R: FHdl )
   R> Swap 1stHdr 3 + W@ Tuck Over- ROver 1 Rot FSeek ?Drop
   ROver 2ndHdr Rot FRead ?Drop
   ROver WrkBuf Rot R> 5 - Swap- Dup Allot FRead ?Drop >R
;
Code UnpackImage ;( srcaddr bufaddr imgsize --> )
	pop	edx
	pop	edi
	xchg	[esp],esi
	push	ebp
	mov	ebp,edi
	mov	ax,0FEFEh
	mov	ecx,7F7h
	rep	stosw
	add	edx,edi
	push	edx
m1:	lodsb
	mov	bl,al
	mov	bh,1
ml:	cmp	edi,[esp]
	jae	short mq
	shr	bx,1
	jz	short m1
	jnc	short m2
	movsb
	jmp	short ml
m2:	xor	eax,eax
	lodsw
	mov	cl,ah
	and	ecx,0Fh
	add	ecx,3
	shr	ah,4
	mov	edx,edi
	sub	edx,ebp
	and	edx,0FFFFF000h
	add	eax,edx
	add	eax,ebp
	cmp	eax,edi
	jb	short m3
	sub	eax,1000h
m3:	xchg	eax,esi
	rep	movsb
	xchg	eax,esi
	jmp	short ml
mq:	pop	edx
	pop	ebp
	pop	esi
	next
Endcode
Code DrawScr ;( @src BIOSslc --> )
	pop	es
	pop	ebx
	push	esi
	mov	ax,102h
	mov	dx,3C4h
m2:	out	dx,ax
	mov	esi,ebx
	mov	edi,0A0000h
	mov	ecx,32000
m1:	movsb
	add	esi,3
	loop	m1
	inc	ebx
	shl	ah,1
	cmp	ah,10h
	jne	short m2
	pop	esi
	push	ds
	pop	es
	next
Endcode
: InitHdr ( --> )
   MenzSizes FCount @ 4* 0 Fill
   MenzHdr Dup 4+ FCount @ 0 ?Do
    2Dup @ ?Dup IfNot Drop 4+ Else
     Swap @ - ?Dup If Rot MenzHdr - MenzSizes + ! Else Swap 0! Then Dup 4+
    Then
   Loop 2Drop
;
: Unpack5&6 ( R: FHdl ItemSize --> R: FHdl )
   R> 5 ReadItem 2ndHdr C@ 3 = If
    WrkBuf Here Dup $FEE + To ImgData 2ndHdr 1+ @ Dup $FEE + Allot UnpackImage
   Else WrkBuf To ImgData Then >R
;
: Unpack6A&7 ( R: FHdl ItemSize --> R: FHdl )
   R> ROver 2ndHdr 2 FRead ?Drop ROver WrkBuf R> 7 - Dup Allot FRead ?Drop
   WrkBuf Here Dup $FEE + To ImgData 2ndHdr W@ Dup $FEE + Allot UnpackImage >R
;
Code OutWord ;( BIOSsel X N --> )
	pop	eax
	pop	edi
	shr	edi,2
	add	edi,0A0000h
	xor	edx,edx
	mov	ecx,80000000h
	lea	ebx,[edx+10]
m1:	div	ebx
	shrd	ecx,edx,4
	xor	edx,edx
	test	eax,eax
	jnz	short m1
	pop	es
	push	esi
	call	m2
	dw	7E3Fh,3E2h,5EBDh,7EB1h,7C87h,76B7h,76BFh,0FA1h,7EBFh,7EB7h
m2:	pop	ebx
m5:	xor	esi,esi
	shld	esi,ecx,4
	shl	ecx,4
	jz	short mq
	movzx	esi,word ptr [ebx+2*esi]
	mov	ah,1
m4:	mov	al,2
	mov	dx,3C4h
	out	dx,ax
	push	edi
	mov	dl,5
m3:	shr	esi,1
	sbb	dh,dh
	mov	es:[edi],dh
	mov	es:[edi+80],dh
	add	edi,160
	dec	dl
	jnz	short m3
	pop	edi
	shl	ah,1
	cmp	ah,10h
	jne	short m4
	inc	edi
	jmp	short m5	
mq:	pop	esi
	push	ds
	pop	es
	next
Endcode
Create PCXhdr 10 C, 5 C, 1 C, 8 C, 0 , 319 W, 399 W, 320 W, 400 W,
              0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
              $13 C, 1 C, 320 W, 1 W, 0 ,
              0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 W,
Create;
0 Constant PCX#
Create PCXnme A" 0000.PCX" A, Create;
Code CompressPCXstr ;( src dest --> size )
	pop	edi
	xchg	[esp],esi
	mov	ebx,edi
	mov	ecx,320
	lodsb
	mov	ah,al
	dec	ecx	
mn6:	xor	edx,edx
mn3:	lodsb
	cmp	edx,62
	je	short mn2
	cmp	al,ah
	jne	short mn2
	inc	edx
	loop	mn3
	inc	edx
	mov	al,dl
	or	al,0C0h
	stosw
	jmp	short mn7
mn2:	or	edx,edx
	jnz	short mn4
	cmp	ah,0C0h
	jae	short mn4
	xchg	al,ah
	stosb
	jmp	short mn5
mn4:	inc	edx
	xchg	dl,al
	or	al,0C0h
	stosw
	mov	ah,dl
mn5:	loop	mn6
	cmp	ah,0C0h
	jb	short mn9
	mov	al,0C1h
	stosb
mn9:	mov	al,ah
	stosb
mn7:	mov	ecx,edi
	sub	ecx,ebx
	pop	esi
	push	ecx
	next
Endcode
Code MakePCXpal ;( src dest --> )
	pop	edi
	xchg	[esp],esi
	mov	al,12
	stosb
	mov	ecx,768
mm0:	lodsb
	mov	ah,al
	and	ah,3
	ror	ah,2
	rol	ax,2
	stosb
	loop	mm0
	pop	esi
	next
Endcode
: Scr2PCX ( --> )
   PCX# 0 4 ZStr 1+ @ PCXnme !
   PCXnme $20 FCreate If
    Dup PCXhdr 128 FWrite ?Drop
    TmpScr 400 0 Do
     2Dup Here CompressPCXstr Here Swap FWrite ?Drop 320 +
    Loop Drop
    MasterPal Here MakePCXpal Dup Here 769 FWrite ?Drop
    FClose Drop
   Then 1+To PCX#
;
: Kbd1Frm ( StepInc CurItem --> StepInc1 CurItem )
   Begin
    KbdIn KSym W@ Case
     $011B Of ROver FClose SetText Bye Endof
     $3B00 Of Dup BIOSselector 0 Rot OutWord False Endof
     $3C00 Of Scr2PCX Endof
     $4800 Of Press -1 Swap True Endof
     $5000 Of Press 1 Swap True Endof
    DropFalse Endcase
   Until
;
: MAIN ( --> )
   ." Menzoberranzan, Ravenloft 1 & 2 graphics viewer" cr
   ." Copyright (C) 1998 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: MENZVIEW resourcefile [/Ppalettefile] [sprite index]" cr
    ." Internal keys: F1 - display current sprite and phase indices," cr
    ."                F2 - save current image into PCX file," cr
    ."                Right/Left - next/previous sprite phase," cr
    ."                Down/Up - next/previous sprite." cr
    Bye
   Then >R
   Bl Word >Upper Dup 1+ W@ [ " /P" 1+ W@ ] Literal = If
    Dup C@ 2- Swap 2+ Tuck C! >ASCIIZ 0 FOpen If
     Dup MasterPal $300 FRead ?Drop FClose Drop
    Then Bl Word
   Then Val If Drop 0 Max Else 2Drop 0 Then
   Here To TmpScr 128000 Allot ClrScr
   R@ FCount 4 FRead ?Drop FCount @ 1- Min To StartNum
   R@ Here Dup To MenzHdr FCount @ 1+ 4* Dup Allot 4- Here Dup>R To MenzSizes
   Dup Allot FRead RErr? ROver 2 0 FSeek Drop R> 4- ! InitHdr
   Here To WrkBuf
   SetGraph $A0000 BIOSselector 32000 0 AFill MasterPal SetPal
   1 StartNum Begin
    MenzHdr Over Cells+ @ ?Dup If
     R@ 0 Rot FSeek ?Drop MenzSizes Over Cells+ @ >R
     ROver 1stHdr 5 FRead RErr?
     1stHdr W@ [ " EH" 1+ W@ ] Literal = If
      1stHdr 2+ C@ Case
       Set 1 2 Of
        8 ReadItem 2ndHdr 6 + C@ 3 = If
         WrkBuf Here Dup $FEE + To ImgData 2ndHdr 4+ C@ 4* 2* 2ndHdr 2+ W@ *
         2ndHdr W@ * Dup $FEE + Allot UnpackImage
        Else WrkBuf To ImgData Then
        2ndHdr 2+ W@ 1 = If 2ndHdr W@ 2ndHdr 2+ W! 1 2ndHdr W! Then
        2ndHdr W@ 2ndHdr 2 + W@ 2ndHdr 4+ C@ 4* 2* * >R 1-
        0 Begin
         ClrScr
         2ndHdr Over R@ * ImgData + TmpScr OutT1&2 TmpScr BIOSselector DrawScr
         Begin
	  KbdIn KSym W@ Case
	   $011B Of ROver FClose SetText Bye Endof
	   $3B00 Of
	    BIOSselector 0 4 Pick OutWord
	    BIOSselector 24 2 Pick OutWord
	    BIOSselector 40 3 Pick 1+ OutWord
	   False Endof
	   $3C00 Of Scr2PCX Endof
	   $4B00 Of 1- 0 Max True Endof
	   $4D00 Of 1+ Over Min True Endof
	   $4800 Of 2Drop Press -1 Swap 0 -1 True Endof
	   $5000 Of 2Drop Press 1 Swap 0 -1 True Endof
	  DropFalse Endcase
	 Until
        Dup -1 = Until 2Drop
       Endof
       5 Of
        Unpack5&6
        ClrScr 2ndHdr ImgData TmpScr OutT5 TmpScr BIOSselector DrawScr Kbd1Frm
	0 >R
       Endof
       6 Of
        1stHdr 3 + W@ If
         Unpack5&6
         ClrScr ImgData TmpScr OutT6
        Else
         Unpack6A&7 2ndHdr W@ 2ndHdr 1+ !
         ClrScr 2ndHdr ImgData TmpScr OutT5
        Then TmpScr BIOSselector DrawScr Kbd1Frm 0 >R
       Endof
       7 Of
        Unpack6A&7
        ClrScr ImgData TmpScr OutT6 TmpScr BIOSselector DrawScr Kbd1Frm 0 >R
       Endof
      Drop Endcase
     Then WrkBuf Here - Allot RDrop
    Then
    Over + Dup 0< If 2Drop 1 0 Then
   Dup FCount @ = Until
   R> FClose SetText Bye
;
NoErrors NoTraps 2 MBytes Minmem !
Build .\menzview.exe
