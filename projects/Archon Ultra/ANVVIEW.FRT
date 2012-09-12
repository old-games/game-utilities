Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
Variable FCount
0 Constant AnvHdr
0 Constant WrkBuf
0 Constant GrfPages
Create MasterPal 0 $300 Loaddata .\anvil0.pal Create; \ Main game palette
0 Constant CurrPal
0 Constant TempBuf
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
Code OutD3GR ;( @page BIOSsel @temp --> )
	pop	edi
	pop	eax
	xchg	[esp],esi
	push	ebp
	push	es
	push	eax
	lodsd
	lodsd
	test	al,4
	lodsd
	push	eax
	lodsd
	push	eax
	push	esi
	jz	short mout
	pop	esi
	push	edi
	lodsd
	mov	ebx,eax
	lodsd
m1:	mov	eax,10000h
	lodsw
	mov	edx,eax
m3:	shr	edx,1
	jz	short m1
	dec	ebx
	js	short mout
	jc	short m2
	movsw
	jmp	short m3
m2:	lodsw
	movzx	ecx,ax
	shr	ecx,13
	add	ecx,2
	and	eax,1FFFh
	neg	eax
	mov	ebp,esi
	lea	esi,[edi+2*eax]
	rep	movsw
	mov	esi,ebp
	jmp	short m3
mout:	mov	edi,0A0000h
	pop	esi
	xor	eax,eax
	mov	ebx,eax
	mov	edx,eax
	pop	dx
	cmp	dx,200
	jbe	mnrm
	mov	dx,200	;Game map is 480*600 and so does not fit on screen
mnrm:	pop	bx
	pop	ax
	add	edi,eax
	pop	ax
	lea	eax,[eax+4*eax]
	shl	eax,6
	add	edi,eax
	pop	es
mstr:	push	edi
	mov	ecx,ebx
mlp:	lodsb
	inc	edi
	test	al,al
	jz	short mnx
	dec	edi
	stosb
mnx:	dec	ecx
	jnz	short mlp
	pop	edi
	add	edi,320
	dec	edx
	jnz	short mstr
	pop	es
	pop	ebp
	pop	esi
	next
Endcode
: RErr? ( size True | False [Rstk:] fhdl --> )
   IfNot SetText ." Disk error!" cr ROver FClose Bye Else Drop Then
;
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
: MAIN ( --> )
   ." Anvil of Dawn graphics viewer" cr
   ." Copyright (C) 1998 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: ANVVIEW resourcefile [/Ppalettefile] [sprite index]" cr
    ." Internal keys: F1 - display current sprite and phase indices," cr
    ."                Right/Left - next/previous sprite phase," cr
    ."                Down/Up - next/previous sprite." cr
    Bye
   Then >R
   Bl Word >Upper Dup 1+ W@ [ " /P" 1+ W@ ] Literal = If
    Dup C@ 2- Swap 2+ Tuck C! >ASCIIZ 0 FOpen If
     Dup MasterPal $300 FRead ?Drop FClose Drop False To PalFlag
    Then Bl Word
   Then Val If Drop 0 Max Else 2Drop 0 Then
   Here To CurrPal $300 Allot Here To TempBuf 64000 Allot
   R@ FCount 4 FRead ?Drop FCount @ 1- Min To StartNum
   R@ Here Dup To AnvHdr FCount @ 1+ 4* Dup Allot FRead RErr? Here To WrkBuf
   SetGraph
   1 StartNum Begin
    AnvHdr Over Cells+ 2@ Tuck - >R ROver 0 Rot FSeek ?Drop
    ROver WrkBuf R> Dup Allot FRead RErr?
    WrkBuf @ [ " D3GR" 1+ @ ] Literal = If
     WrkBuf 8 + @ ?Dup If
      MasterPal CurrPal $300 CMove
      WrkBuf 4+ @ $2000 And PalFlag And If
       WrkBuf Dup $C + @ + Dup W@ >R 2+ Dup W@ $100 - >R 2+ CurrPal R> 3 * +
       R> 3 * CMove
      Then CurrPal SetPal ClrScr
      WrkBuf + To GrfPages
      WrkBuf $18 + Dup 4+ >R @ 1- 1 0 DataFlag Off Begin
       R@ Over Cells+ @ GrfPages +
       Dup 4+ @ 1 And IfNot
        DataFlag On ClrScr
        BIOSselector TempBuf OutD3GR
        Begin
         KbdIn KSym W@ Case
          $011B Of 2RDrop R> FClose SetText Bye Endof
          $3B00 Of 3 Pick . Dup . 13 Emit False Endof
          $4B00 Of Press -1 Swap True Endof
          $4D00 Of Press 1 Swap True Endof
          $4800 Of 3Drop Press -1 Swap 0. 0 True Endof
          $5000 Of 3Drop Press 1 Swap 0. 0 True Endof
         DropFalse Endcase
        Until
       Else Drop Then
       3Dup + Dup 0< If 2Drop 2Drop 1 0
       Else
        2Dup < If DataFlag @ If Drop >R 2Drop -1 R> Else 2Drop 2Drop 0. Then
        Else Press Press Then
       Then
      Over 0= Until 3Drop RDrop
     Then
    Then Over + Dup 0< If 2Drop 1 0 Then WrkBuf Here - Allot
   Dup FCount @ = Until
   R> FClose SetText Bye
;
NoErrors NoTraps 2 MBytes Minmem !
Build .\anvview.exe
