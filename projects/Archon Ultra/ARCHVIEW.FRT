Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
0 Value WrkPal
0 Value Hdl1
0 Value Hdl2
Variable DataX
DataX Off
0 Value FCnt
0 Value FHdr
0 Value FIdx
0 Value TBuf
0 Value FNum
Create MainPal 0 $300 Loaddata .\archon.pal \ Main game palette
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
Code ShowTile ;( idx BIOSsel buf --> )
	pop	ebx
	pop	es
	xchg	[esp],esi
	xchg	ebx,esi
	xor	eax,eax
	mov	al,[esi+8]
	mul	byte ptr [esi+9]
	shl	eax,8
	mul	ebx
	movzx	ebx,byte ptr [esi+8]
	shl	ebx,3
	movzx	edx,byte ptr [esi+9]
	shl	edx,4
	lea	esi,[esi+eax+0Ah]
	mov	edi,0A0000h
ml:	mov	ecx,ebx
	rep	movsw
	sub	edi,ebx
	sub	edi,ebx
	add	edi,320
	dec	edx
	jnz	short ml
	push	ds
	pop	es
	pop	esi
	next
Endcode
Code ShowPic ;( idx BIOSsel buf --> )
	pop	ebx
	pop	es
	xchg	[esp],esi
	shl	esi,4
	lea	esi,[esi+ebx+8]
	cmp	dword ptr [esi+8],0
	je	short mxx
	mov	edi,0A0000h
	mov	ax,[esi+8]
	sub	ax,[esi+4]
	cmp	ax,160
	jge	short mof2
	mov	ax,[esi+10]
	sub	ax,[esi+6]
	cmp	ax,100
	jge	short mof2
	mov	ax,100
	sub	ax,[esi+6]
	imul	ax,ax,320
	movsx	eax,ax
	add	edi,eax
	mov	ax,160
	sub	ax,[esi+4]
	movsx	eax,ax
	add	edi,eax
mof2:	movzx	edx,word ptr [esi+0Ah]
	test	byte ptr [esi+3],40h
	jnz	short mcomp
	movzx	ebx,word ptr [esi+8]
	add	esi,[esi+0Ch]
ml1:	mov	ecx,ebx
	rep	movsb
	sub	edi,ebx
	add	edi,320
	dec	edx
	jnz	short ml1
mxx:	push	ds
	pop	es
	pop	esi
	next
mcomp:	add	esi,[esi+0Ch]
	mov	ebx,edi
mll2:	lodsw
	cmp	ax,2
	jbe	short ml2
ml3:	lodsb
	mov	ecx,eax
	and	ecx,3Fh
	inc	ecx
	test	al,al
	jz	short ml2
	js	short mskip
	rep	movsb
	jmp	short ml3
mskip:	cmp	al,0C0h
	jae	short mshad
	add	edi,ecx
	jmp	short ml3
mshad:	lodsb
	rep	stosb
	jmp	short ml3
ml2:	add	ebx,320
	mov	edi,ebx
	dec	edx
	jnz	short mll2
	jmp	short mxx
Endcode
Defer ShowImg
' Noop To ShowImg
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
: RErr? ( size True | False --> )
   IfNot SetText ." Disk error!" cr Hdl1 FClose Hdl2 FClose Bye Else Drop Then
;
: FErr ( --> )
   ." Usage: ARCHVIEW [/Ppalettefile] [sprite index] | /D" cr
   ." Files ARCHON.PKG and TITLE.PKG must be in the current directory" cr
   ." Internal keys: F1 - display current sprite and phase indices," cr
   ."                Right/Left - next/previous sprite phase," cr
   ."                Down/Up - next/previous sprite." cr
   Bye
;
: ListPacket ( p_hdr @p_data fofs fhdl --> @p_data1 fofs1 )
   Swap 2Swap Swap Dup 21 RShift Swap $FF And 1 = DataX @ Xor If
    0 ?Do
     >R Over , Dup , R@ W@ 4* Dup , + R> 2+
    Loop
   Else
    0 ?Do
     Dup>R W@ 4* + R> 2+
    Loop
   Then
   Rot Drop Swap
;
Create FName A" 0000.bin" A,
: MkFile ( addr size --> )
   FNum 0 4 ZStr 1+ @ FName ! 1+To FNum
   Over Dup C@ Swap 1+ C@ 1+ Swap- 3 * 2+ Over = If
    [ " .pal" 1+ @ ] Literal FName 4+ !
    WrkPal $300 0 Fill ( MainPal WrkPal $300 CMove )
    2- >R Dup 2+ Swap C@ 3 * WrkPal + R> CMove
    WrkPal $300
   Then
   FName $20 FCreate IfNot 2Drop Exit Then
   Dup>R -Rot FWrite ?Drop R> FClose Drop
   [ " .bin" 1+ @ ] Literal FName 4+ !
;
: BlastOff ( --> )
   Hdl1 FClose Hdl2 FClose SetText Bye
;
: MAIN ( --> )
   ." Archon Ultra graphics viewer" cr
   ." Copyright (C) 2001 by White Jaguar" cr cr
   Here To WrkPal $300 Allot
   ParseCommandLine Bl Word
   Dup @ $FFFFFF And [ " /D" @ $FFFFFF And ] Literal = If Drop DataX On
   Else
    Dup 1+ W@ [ " /P" 1+ W@ ] Literal = If
     >ASCIIZ 2+ 0 FOpen IfNot FErr Then
     Dup WrkPal $300 FRead ?Drop FClose Drop
     Bl Word
    Else MainPal WrkPal $300 CMove Then
    Val If Drop 0 Max Else 2Drop 0 Then
   Then
   A" archon.pkg" 0 FOpen IfNot FErr Then To Hdl1
   A" title.pkg" 0 FOpen IfNot Hdl1 FClose Drop FErr Then To Hdl2
   Here To FHdr 16 Allot Hdl1 FHdr 16 FRead ?Drop
   Hdl1 FHdr 16 + FHdr 6 + @ 16 - Dup Allot FRead ?Drop Align Here To FIdx
   FHdr 2+ @ FHdr + FHdr $16 + FHdr $E + W@ 0 ?Do
    Dup 2+ W@ IfNot Hdl1 Else Hdl2 Then >R Dup 4+ @ $FF000000 - >R
    Tuck C@ 1 = If Dup @ Swap 4+
    Else Dup @ Over 8 + R> R@ ListPacket >R Swap 4+ @ Swap Then
    R> R> ListPacket Drop
    Swap 8+
   Loop 2Drop
   Here To TBuf Here FIdx - 12 / To FCnt
   DataX @ If
    FIdx FCnt 0 ?Do
     Dup>R @ 0 R@ 4+ @ FSeek ?Drop R@ @ TBuf R@ 8+ Dup Allot FRead ?Drop
     TBuf @ -1 = If
      TBuf 4+ W@ Dup>R 4* TBuf + $A + R> 0 ?Do
       TBuf $A + I Cells+ @ 2Dup MkFile +
      Loop Drop
     Else [ " .mod" 1+ @ ] Literal FName 4+ ! TBuf R@ 8+ @ MkFile Then
     TBuf Here - Allot R> 12 +
    Loop Drop
    Bye
   Then
   SetGraph WrkPal SetPal
   FCnt 1- Min 1 Swap Begin
    FIdx Over 12 * + Dup>R @ 0 R@ 4+ @ FSeek ?Drop
    R@ @ TBuf R> 8+ @ Dup Allot FRead RErr?
    TBuf @ -1 = TBuf 4+ @ $20000000 <> And If
     Dup 257 = If $64 +To TBuf $60 ['] ShowPic
     Else
      TBuf 6 + W@ Dup $3000 < If ['] ShowTile Else $3000 - 1+ ['] ShowPic Then
     Then
     To ShowImg 1 0 Begin
      ClrScr
      Dup BIOSselector TBuf ShowImg
      Begin
       KbdIn KSym W@ Case
	$011B Of BlastOff Endof
	$3B00 Of 3 Pick . Dup . 13 Emit False Endof
	$4B00 Of Press -1 Swap True Endof
	$4D00 Of Press 1 Swap True Endof
	$4800 Of 3Drop Press -1 Swap 0. 0 True Endof
	$5000 Of 3Drop Press 1 Swap 0. 0 True Endof
       DropFalse Endcase
      Until
      3Dup + Dup 0< If 2Drop 2Drop 1 0
      Else
       2Dup > IfNot 2Drop 2Drop 0. Else Press Press Then
      Then
     Over 0= Until 3Drop
     Dup 257 = If $64 -To TBuf Then
    Then Over + Dup 0< If 2Drop 1 0 Then TBuf Here - Allot
   Dup FCnt = Until
   BlastOff
;
NoErrors NoTraps 1 MBytes Minmem !
Build .\archview.exe
