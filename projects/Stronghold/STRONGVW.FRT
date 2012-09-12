Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
Variable HOff
0 Value Cnt
0 Value Hdr
0 Value Pal
Variable Idx
Idx 0!
0 Value VBase
0 Value Dat
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
: DoErr ( --> )
   ." Usage: STRONGVW [palette] [sprite index] | /P" cr
   ." File 'STRONG.DAT' must be in the current directory" cr
   ." Internal keys: ESC - immediate exit," cr
   ."                F1 - display current sprite index," cr
   ."                Down/Up - next/previous sprite," cr
   ."                Enter - next animation frame." cr
   Bye
;
: BlastOff ( --> )
   SetText Bye
;
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
Code UnpackN ;( src dst --> )
	pop	edi
	xchg	[esp],esi
	xor	eax,eax
	lodsw
	mov	edx,eax
	lodsw
	mul	edx
	lea	edx,[eax+edi]
	xor	eax,eax
m0:	lodsb
	test	al,al
	jns	short m1
	cmp	al,80h
	je	short m0
	neg	al
	lea	ecx,[eax+1]
	lodsb
	rep	stosb
	jmp	short mlp
m1:	lea	ecx,[eax+1]
	rep	movsb
mlp:	cmp	edi,edx
	jb	short m0
	pop	esi
	next
Endcode
Code DispUnp ;( @szs data BIOSsel --> )
	pop	es
	pop	eax
	xchg	esi,[esp]
	xchg	eax,esi
	movzx	ebx,word ptr [eax]
	movzx	edx,word ptr [eax+2]
	mov	edi,0A0000h
m3:	mov	ecx,ebx
ml:	lodsb
	test	al,al
	jz	short m1
	stosb
	loop	ml
	jmp	short m2
m1:	inc	edi
	loop	ml
m2:	add	edi,320
	sub	edi,ebx
	dec	edx
	jnz	short m3
	push	ds
	pop	es
	pop	esi
	next
Endcode
: WaitKey ( step --> step1 )
   Begin
    KbdIn
    KSym C@ Case
     27 Of Drop FClose Drop BlastOff Endof
     0 Of
       KSym 1+ C@ Case
	59 Of Idx @ . KbdIn 13 Emit Drop 0 True Endof
	72 Of Drop -1 True Endof
	80 Of Drop 1 True Endof
       DropFalse Endcase
      Endof
    DropFalse Endcase
   Until
;
: DispNPic ( step addr --> step1 )
   Dup W@ Over 2+ W@ * Here >R Allot
   Dup R@ UnpackN
   R> BIOSselector DispUnp
   WaitKey
   ClrScr
;
Code DoBlk0B ;( src dst --> )
	pop	edi
	xchg	esi,[esp]
	xor	eax,eax
	lodsw
	mov	edx,eax
m2:	dec	edx
	js	short mx
	xor	eax,eax
	lodsb
	lea	ecx,[eax+2*eax]
	add	edi,ecx
	lodsb
	test	al,al
	jnz	short m1
	mov	ah,1
m1:	lea	ecx,[eax+2*eax]
	rep	movsb
	jmp	short m2
mx:	pop	esi
	next
Endcode
Code DoBlk0C ;( src BIOSsel --> )
	pop	es
	xchg	esi,[esp]
	xor	eax,eax
	lodsw
	imul	eax,eax,320
	lea	ebx,[eax+0A0000h]
	lodsw
	mov	dh,al
	xor	eax,eax
mlp2:	mov	edi,ebx
	lodsb
	mov	dl,al
mlp1:	lodsb
	add	edi,eax
	lodsb
	test	al,al
	js	short m1
	mov	ecx,eax
	rep	movsb
	jmp	short ml1
m1:	neg	al
	mov	ecx,eax
	lodsb
	rep	stosb
ml1:	dec	dl
	jnz	mlp1
	add	ebx,320
	dec	dh
	jnz	short mlp2	
	push	ds
	pop	es
	pop	esi
	next
Endcode
Code DoBlk0F ;( src BIOSsel --> )
	pop	es
	xchg	esi,[esp]
	mov	ebx,0A0000h
	mov	dh,200
	xor	eax,eax
mlp2:	mov	edi,ebx
	lodsb
	mov	dl,al
mlp1:	lodsb
	test	al,al
	js	short m1
	mov	ecx,eax
	lodsb
	rep	stosb
	jmp	short ml1
m1:	neg	al
	mov	ecx,eax
	rep	movsb
ml1:	dec	dl
	jnz	mlp1
	add	ebx,320
	dec	dh
	jnz	short mlp2	
	push	ds
	pop	es
	pop	esi
	next
Endcode
: AnimX ( -->> )
   Pal SetPal -768 Allot ClrScr RDrop
;
0 Value APal
: DispAnim ( step addr --> step1 )
   Here To APal 768 Allot
   Pal APal 768 CMove
   Dup 6 + W@ 1+ >R
   $80 + R> -1 Do
    I -1 = If ." Animation - press ENTER" 13 Emit
    Else
     Dup 6 + W@ >R
     Dup $10 + R> 0 ?Do
      Dup 4+ W@ Case
       $0B Of Dup 6 + APal DoBlk0B APal SetPal Endof
       $0C Of Dup 6 + BIOSselector DoBlk0C Endof
       $0D Of ClrScr Endof
       $0F Of Dup 6 + BIOSselector DoBlk0F Endof
       $10 Of Dup 6 + ForthSelector $A0000 BIOSselector 64000 ACMove Endof
      Drop Endcase
      Dup @ +
     Loop Drop
     Dup @ +
    Then
    Begin
     KbdIn
     KSym C@ Case
      27 Of 2Drop FClose Drop BlastOff Endof
      13 Of True Endof
      0 Of
	KSym 1+ C@ Case
	 59 Of Idx @ . I . KbdIn 13 Emit True Endof
	 72 Of 2Drop -1 AnimX Endof
	 80 Of 2Drop 1 AnimX Endof
	DropFalse Endcase
       Endof
     DropFalse Endcase
    Until
   Loop Drop
   AnimX
;
Code DispFnt ;( data BIOSsel --> )
	pop	es
	pop	edx
	push	esi
	xor	ebx,ebx
m2:	mov	edi,ebx
	shr	edi,4
	imul	edi,edi,1180h
	mov	eax,ebx
	and	eax,0Fh
	imul	eax,eax,0Eh
	lea	edi,[edi+eax+0A0000h]
	movzx	eax,byte ptr [edx+ebx+0C1h]
	add	edi,eax
	mov	ah,0Dh
	movzx	esi,word ptr [edx+2*ebx+1]
	lea	esi,[esi+edx+0C1h+60h]
m1:	movzx	ecx,al
	sub	edi,ecx
	rep	movsb
	add	edi,320
	dec	ah
	jnz	short m1
	inc	ebx
	cmp	ebx,60h
	jb	short m2
	push	ds
	pop	es
	pop	esi
	next
Endcode
Create MainPal 0 768 LoadData .\strong.pal
: MAIN ( --> )
   ." Stronghold graphics viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr
   A" strong.dat" 0 FOpen IfNot DoErr Then
   Dup HOff 4 FRead ?Drop
   Dup 2 0 FSeek Drop HOff @ - Dup>R Here To Hdr Allot
   Dup 0 HOff @ FSeek ?Drop Dup Hdr R@ FRead ?Drop R> 21 / To Cnt
   ParseCommandLine
   Bl Word >Upper
   Dup @ $FFFFFF And [ " /P" @ $FFFFFF And ] Literal = If
    Drop
    Cnt 0 Do
     I 21 * Hdr +
     Dup 5 + @ Dup 768 = Over 144 = Or If
      >R 1+ @ >R Dup 0 R> FSeek ?Drop
      R> Here >R 768 Allot 144 = If
       MainPal R@ 768 CMove
       Dup R@ $1E0 + 144 FRead ?Drop
       R@ $1EC + @ $7C <> R@ $1E0 + C@ 4 <> Or
      Else
       Dup R@ 768 FRead ?Drop True
      Then
      If
       R> I Swap >R 0 4 ZStr 1+ @ A" strn0000.pal" Dup>R 4+ !
       R> $20 FCreate Drop Dup R> 768 FWrite ?Drop FClose Drop
      Else RDrop Then
      -768 Allot 0.
     Then 2Drop
    Loop
    FClose Drop Bye
   Then
   MainPal To Pal
   Dup C@ If
    Dup Val Press If Idx !
    Else
     Drop >ASCIIZ 0 FOpen IfNot FClose Drop DoErr Then
     Dup Here 768 2Dup Allot To Pal FRead ?Drop FClose Drop
     Bl Word Dup C@ If Val 2Drop Else Drop 0 Then Idx ! 0
    Then
   Then Drop
   Set13h Pal SetPal
   Here To VBase
   1 Begin
    Idx @ Cnt < IfNot BlastOff Then
    Idx @ 0= If Drop 1 Then
    Idx @ 21 * Hdr + 1+
    Dup 4+ @ >R @ >R 
    Over 0 R> FSeek ?Drop
    Over Here R@ 2Dup Allot To Dat FRead ?Drop
    Dat C@ 1 = Dat 1+ @ 9 + R@ = And If
     Dat 5 + DispNPic
    Else
     Dat C@ 2 = Dat 6 + @ 14 + R@ = And If
      Dat 10 + DispNPic
     Else
      Dat C@ 4 = Dat $C + @ $14 + R@ = And If
       Dat $10 + DispNPic
      Else
       Dat @ R@ = Dat 4+ W@ $AF11 = And If
	Dat DispAnim
       Else
        Dat C@ $D = If
         Dat BIOSselector DispFnt
         WaitKey
         ClrScr
        Then
       Then
      Then
     Then
    Then
    RDrop VBase Here - Allot
    Dup Idx +! 
   Again
;
NoErrors NoTraps 1 MBytes MaxMem !
Build .\strongvw.exe
