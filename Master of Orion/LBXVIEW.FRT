Also Assembler Definitions
' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
Also Hidden
: SEG ( segreg ( --> )	      \ Это фикс для SEG
   ?SegReg IfNot $68 Error Then To *SegReg (Seg)
;
Previous Previous Definitions
Variable Signt
Variable FCount
0 Value StartNum
0 Value LBXHdr
0 Value WrkBuf
0 Value CurrPal
Create MasterPal 0 $300 Loaddata .\mmagic2.pal Create; \ Main game palette
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
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
: RErr? ( size True | False [Rstk:] fhdl --> )
   IfNot SetText ." Disk error!" cr ROver FClose Bye Else Drop Then
;
Code DrawPic ;( #pic @block BIOSsel --> )
	pop	es
	pop	ebx
	pop	eax
	push	esi
	push	ebp
	mov	esi,[ebx+4*eax+12h]
	lea	esi,[esi+ebx+1]
;	movzx	edx,word ptr [ebx+2]
	movzx	ebx,word ptr [ebx]
	mov	edi,0A0000h
	add	ebx,edi
mgl:	push	edi
	xor	eax,eax
	lodsb
	cmp	al,0FFh
	je	short mcx
	mov	ah,al
	lodsb
	test	ah,ah
	js	short mcblk
	lea	ebp,[eax+esi]
mslp:	xor	eax,eax
	lodsb
	mov	ecx,eax
	lodsb
	imul	ax,ax,320
	add	edi,eax
mls:	movsb
	add	edi,319
	loop	mls
	cmp	esi,ebp
	jb	short mslp
	jmp	short mcx
mcblk:	lea	ebp,[eax+esi-8000h]
mclp:	xor	eax,eax
	lodsb
	mov	ecx,eax
	lodsb
	imul	ax,ax,320
	add	edi,eax
mlc1:	lodsb
	cmp	al,0E0h
	jb	short mccp
	dec	ecx
	push	ecx
	mov	cl,al
	sub	cl,0DFh
	lodsb
mlc2:	stosb
	add	edi,319
	loop	mlc2
	pop	ecx
	loop	mlc1
	jmp	short mclx
mccp:	stosb
	add	edi,319
	loop	mlc1
mclx:	cmp	esi,ebp
	jb	short mclp
mcx:	pop	edi
	inc	edi
	cmp	edi,ebx
	jb	short mgl
	pop	ebp
	pop	esi
	push	ds
	pop	es
	next
Endcode
: ValidatePic ( --> flag )
   WrkBuf W@ 1 320 Between WrkBuf 2+ W@ 1 200 Between And
   WrkBuf 4+ W@ 0= And WrkBuf 6 + W@ 0> And
;
: .PalOff ( --> n ) WrkBuf $E + W@ ;
: .NPics ( --> n ) WrkBuf 6 + W@ ;
: .Xsz ( --> n ) WrkBuf W@ ;
: .Ysz ( --> n ) WrkBuf 2+ W@ ;
: .Flg ( --> n ) WrkBuf $10 + W@ ;
Create PCXhdr 10 C, 5 C, 1 C, 8 C, 0 , 319 W, 199 W, 320 W, 200 W,
              0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
              $13 C, 1 C, 320 W, 1 W, 0 ,
              0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 W,
Create;
: SetPCXsize ( xsz ysz --> )
   1- PCXhdr $A + W! Dup 1- PCXhdr 8 + W! PCXhdr $42 + W!
;
0 Constant PCX#
Create PCXnme A" 0000.PCX" A, Create;
Code CompressPCXstr ;( srcoff dest BIOSsel xsz --> size )
	pop	ecx
	pop	eax
	pop	edi
	xchg	[esp],esi
	push	fs
	mov	fs,ax
	mov	ebx,edi
	seg	fs
	lodsb
	mov	ah,al
	dec	ecx
	jecxz	mn9
mn6:	xor	edx,edx
mn3:	seg	fs
	lodsb
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
	pop	fs
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
    .Xsz .Ysz SetPCXsize
    Dup PCXhdr 128 FWrite ?Drop
    $A0000 .Ysz 0 Do
     2Dup Here BIOSselector .Xsz CompressPCXstr Here Swap FWrite ?Drop 320 +
    Loop Drop
    CurrPal Here MakePCXpal Dup Here 769 FWrite ?Drop
    FClose Drop
   Then 1+To PCX#
;
Variable BkView
: MAIN ( --> )
   ." Microprose .LBX files graphics viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: LBXVIEW file.LBX [/Ppalettefile] [sprite index]" cr
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
   FCount 0! R@ FCount 2 FRead ?Drop FCount @ 1- Min To StartNum
   R@ Signt 4 FRead ?Drop Signt @ $FEAD = IfNot R> FClose Drop Bye Then
   R@ 0 8 FSeek ?Drop
   R@ Here Dup To LBXHdr FCount @ 1+ 4* Dup Allot FRead RErr?
   Here To CurrPal $300 Allot
   Here To WrkBuf
   SetGraph
   1 StartNum Begin
    LBXHdr Over Cells+ 2@ 2Dup = IfNot
     Dup R@ 0 Rot FSeek ?Drop - Dup>R Allot
     ROver WrkBuf $12 FRead RErr?
     ValidatePic If
      ROver WrkBuf $12 + R> $12 - FRead RErr?
      MasterPal CurrPal $300 CMove
      .PalOff ?Dup If
       WrkBuf + Dup>R W@ WrkBuf + CurrPal R@ 2+ W@ 3 * + R> 4+ W@ 3 * CMove
      Then
      CurrPal SetPal BkView Off
      .NPics 1- 0 Begin
       Dup .Flg 1 And 0= And If
        BkView @ If
         ClrScr Dup 0 Do I WrkBuf BIOSselector DrawPic Loop
        Then
       Else ClrScr Then
       Dup WrkBuf BIOSselector DrawPic
       Begin
	KbdIn KSym W@ Case
	 $011B Of R@ FClose SetText Bye Endof
	 $3B00 Of 3Dup Rot . . . 13 Emit False Endof
	 $3C00 Of Scr2PCX Endof
	 $4B00 Of BkView On 1- 0 Max True Endof
	 $4D00 Of BkView Off 1+ Over Min True Endof
	 $4800 Of 2Drop Press -1 Swap 0 -1 True Endof
	 $5000 Of 2Drop Press 1 Swap 0 -1 True Endof
	DropFalse Endcase
       Until
      Dup -1 = Until 2Drop
     Else RDrop Then WrkBuf Here - Allot
    Else 2Drop Then
    Over + Dup 0< If 2Drop 1 0 Then
   Dup FCount @ = Until
   R> FClose SetText Bye
;
NoErrors NoTraps 2 MBytes Minmem !
Build .\lbxview.exe
