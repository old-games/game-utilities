Use disphi2.l32
0 Value ResHdl
0 Value FCnt
0 Value FDat
0 Value FStrs
0 Value CurrF
Variable L1 L1 0!
Variable FCur FCur 0!
Variable SCur SCur 0!
: .Ofs ( addr1 --> addr2 ) ; Immediate
: .Sze ( addr1 --> addr2 ) Compile 4+ ; Immediate
: .Nme ( addr1 --> addr2 ) Compile 8+ Compile @ ; Immediate
: [] ( addr1 n --> addr2 ) 12 * + ;
: ConvertNames ( --> )
   Here To FStrs
   FCnt 0 Do
    FDat I [] .Nme ?Dup If FDat + ASCIIZ> Else NullString Then
    Here Tuck Over C@ 1+ 13 Max Allot S! FDat I [] 8+ !
   Loop
   Align
;
: ReadResDir ( --> )
   A" ravdata.dat" 0 FOpen IfNot ." RAVDATA.DAT not found!" cr Bye
   Then To ResHdl
   ResHdl L1 2 FRead ?Drop L1 @ To FCnt
   ResHdl L1 4 FRead ?Drop L1 @ >R
   ResHdl L1 4 FRead ?Drop ResHdl 0 R> FSeek ?Drop
   ResHdl Here Dup To FDat L1 @ Dup Allot FRead ?Drop
   ConvertNames
;
: MkItem ( addr --> )
   Dup .Nme Bl 18 Here MkStr S! 18 Here C! .Sze @ 0 10 RStr Here S+!
;
: DrawFileBar ( --> )
   FDat FCur @ [] 20 0 Do
    Dup MkItem $0A 2 I 2+ Here WriteCXY 12 +
   Loop Drop
   1 2 SCur @ + 30 Over $1A ChangeAttr 
;
: DrawViewerScr ( --> )
   1 1 80 25 $07 Clr False CursorSwitch
   $0B 13 25 " Dump GraphView ReName Save VGA Save `as is' AltX - Exit"
   WriteCXY 25 $0A " \13;\18;\30;\40;\44;\57;\58;\59;\60;" ChgSymAttr
   $1A TextAttr ! DrawFileBar
;
: ExitViewer ( --> )
   True CursorSwitch WReset ResHdl FClose Drop Bye
;
: StrUp ( --> )
   SCur @ If
    1 SCur @ 2+ 30 Over $0A ChangeAttr SCur 1-!
    1 SCur @ 2+ 30 Over $1A ChangeAttr
   Else
    FCur @ If
     2 2 29 2 $0A ChangeAttr 2 2 29 20 -1 Scroll FCur 1-!
     FDat FCur @ [] MkItem $1A 2 2 Here WriteCXY
    Then
   Then
;
: StrDown ( --> )
   SCur @ 19 < If
    1 SCur @ 2+ 30 Over $0A ChangeAttr SCur 1+!
    1 SCur @ 2+ 30 Over $1A ChangeAttr
   Else
    FCur @ FCnt 20 - < If
     2 21 29 21 $0A ChangeAttr 2 3 29 21 1 Scroll FCur 1+!
     FDat FCur @ 19 + [] MkItem $1A 2 21 Here WriteCXY
    Then
   Then
;
: PgeUp ( --> )
   SCur @ If
    1 SCur @ 2+ 30 Over $0A ChangeAttr SCur 0!
    1 2 30 2 $1A ChangeAttr
   Else
    FCur @ If
     FCur @ 19 > If 19 FCur -! Else FCur 0! Then
     FDat FCur @ [] 20 0 Do
      Dup MkItem $0A 2 I 2+ Here WriteCXY 12 +
     Loop Drop
     1 2 30 2 $1A ChangeAttr
    Then
   Then
;
: PgeDown ( --> )
   SCur @ 19 < If
    1 SCur @ 2+ 30 Over $0A ChangeAttr 19 SCur !
    1 SCur @ 2+ 30 Over $1A ChangeAttr
   Else
    FCur @ FCnt 20 - < If
     FCur @ FCnt 39 - < If 19 FCur +! Else FCnt 20 - FCur ! Then
     FDat FCur @ [] 20 0 Do
      Dup MkItem $0A 2 I 2+ Here WriteCXY 12 +
     Loop Drop
     1 21 30 21 $1A ChangeAttr
    Then
   Then
;
: DStr ( n --> str )
   Base @ >R 16 Base ! 0 8 ZStr R> Base !
;
Code HexStr16 ;( src strg --> )
	pop	edi
	xchg	[esp],esi
	mov	al,32
	stosb
	mov	ecx,16
m3:	call	m2
	loop	m3
	pop	esi
	next	
m2:	lodsb
	db	0D4h,10h	;AAM 16
	xchg	al,ah
	call	m1
	mov	al,ah
m1:	add	al,90h
	daa
	adc	al,40h
	daa
	stosb
	ret
Endcode
: ShowFDump ( --> )
   CurrF .Sze @ If
    ResHdl 0 CurrF .Ofs @ FSeek ?Drop
    ResHdl Here Dup>R 320 Dup Allot FRead ?Drop
    R> CurrF .Sze @ 4 RShift 20 Min 0 ?Do
     Dup Here HexStr16 " ³" Here S+! 16 Here +! Dup Here 34 + 16 CMove
     $0F 31 I 2+ Here WriteCXY 16 +
    Loop Drop -320 Allot
    KbdIn 31 2 79 21 $07 Clr
   Then
;
: ChangeFName ( --> )
   Here >R CurrF .Nme Dup C@ 12 Max Dup>R 1+ Allot ROver S!
   2 SCur @ 2+ SXY True CursorSwitch R> 1 -1 R@ 0 Catch False CursorSwitch
   2 < If R@ CutSpaces R@ CurrF .Nme S! Then R> Here - Allot
;
: SaveRaw ( --> )
   CurrF .Sze @ ?Dup If
    ResHdl 0 CurrF .Ofs @ FSeek ?Drop
    CurrF .Nme Here S! Here >ASCIIZ $20 FCreate If
     Over ResHdl Here Rot FRead ?Drop Tuck Here Rot FWrite ?Drop FClose
    Else Beep Then Drop
   Then StrDown
;
Variable GrfMode
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
Create SCasterPal 0 768 LoadData scaster.pal
: ValidateGraphData ( size addr --> n )
   2>R
   ROver 4096 = Dup If 1 Then
   Dup IfNot
    R@ W@ 1 320 Between R@ 2+ W@ 1 200 Between And If
     R@ W@ R@ 2+ W@ * 8+ ROver = If Drop 2 Then
    Then
   Then
   Dup IfNot
    R@ W@ 1 50 Between If
     R@ W@ 4* 64 * $82 + ROver = If
      R@ 2+ W@ ROver < R@ $80 + W@ ROver < And If
       R@ 4+ W@ R@ 2+ W@ - R@ W@ 4* = If Drop 3 Then
      Then
     Then
    Then
   Then
   Dup IfNot
    R@ W@ 0 199 Between R@ 2+ W@ 1 320 Between And If
     ROver $10000 < If
      R@ 2+ W@ 2* 4+ ROver < If
       R@ 2+ W@ 2* 2+ R@ + W@ ROver < If Drop 4 Then
      Then
     Then
    Then
   Then
   2RDrop
;
Code DrawPic ;( 1|2 addr BIOSsel --> )
	pop	es
	pop	ebx
	pop	eax
	push	esi
	push	ebp
	mov	ebp,0A0000h
	cmp	eax,1
	jne	short mtype2
	mov	edx,64
	mov	esi,ebx
ml7:	mov	edi,ebp
	mov	ecx,64
	rep	movsb
	add	ebp,320
	dec	edx
	jnz	short ml7
	jmp	mqq
mtype2:	cmp	eax,2
	jne	short mtype3
	movzx	edx,word ptr [ebx+2]
	lea	esi,[ebx+8]
ml2:	mov	edi,ebp
	movzx	ecx,word ptr [ebx]
ml1:	lodsb
	test	al,al
	jz	short m1
	mov	es:[edi],al
m1:	inc	edi
	loop	ml1
	add	ebp,320
	dec	edx
	jnz	short ml2
	jmp	mqq
mtype3:	cmp	eax,3
	jne	short mtype4
	mov	edx,64
	lea	esi,[ebx+82h]
ml9:	mov	edi,ebp
	movzx	ecx,word ptr [ebx]
	shl	ecx,2
ml8:	movsb
	add	edi,319
	loop	ml8
	inc	ebp
	dec	edx
	jnz	short ml9
	jmp	short mqq
mtype4:	xor	edx,edx
	xor	ecx,ecx
	xor	eax,eax
ml5:	movzx	esi,word ptr [ebx+2*edx+4]
	test	esi,esi
	jz	short m4
	add	esi,ebx
	lodsb
	cmp	eax,ecx
	jbe	short m4
	mov	ecx,eax
m4:	inc	edx
	cmp	dx,[ebx+2]
	jne	short ml5
	inc	ecx
	push	ecx
	xor	edx,edx
ml4:	movzx	esi,word ptr [ebx+2*edx+4]
	test	esi,esi
	jz	short m3
	add	esi,ebx
	mov	edi,[esp]
	xor	eax,eax
	lodsb
	lea	ecx,[eax+1]
	sub	edi,ecx
	lea	edi,[edi+4*edi]
	shl	edi,6
	add	edi,ebp
	lodsb
	sub	ecx,eax
	jecxz	m3
ml3:	lodsb
	test	al,al
	jz	short m2
	mov	es:[edi],al
m2:	add	edi,320
	loop	ml3
m3:	inc	ebp
	inc	edx
	cmp	dx,[ebx+2]
	jne	short ml4
	pop	eax
mqq:	pop	ebp
	pop	esi
	push	ds
	pop	es
	next
Endcode
: ?NxStr ( --> flag true )
   SCur @ 1+ FCnt = If False Else SCur 1+! True Then True
;
: DisplayPic ( --> )
   GrfMode Off FCur @ SCur +!
   Begin
    CurrF .Sze @ Dup If
     >R ResHdl 0 CurrF .Ofs @ FSeek ?Drop
     ResHdl Here Dup>R ROver Dup Allot FRead ?Drop
     2R@ ValidateGraphData Dup If
      GrfMode @ IfNot Set13h SCasterPal SetPal GrfMode On
      Else $A0000 BIOSselector 64000 0 AFill Then
      R@ BIOSselector DrawPic
      Begin
       KbdIn KSym C@ Case
	13 Of ?NxStr Endof
	27 Of False True Endof
\        Set 'V $76 Of DoConv2VGA ?NxStr Endof
        DropFalse
       Endcase
      Until
     Then RDrop R> Negate Allot
    Then
    FDat SCur @ [] To CurrF
   0= Until
   GrfMode @ If SetText Then
   SCur @ FCur @ - 20 < IfNot
    SCur @ 19 - FCnt 20 - Min 0 Max FCur !
   Then FCur @ SCur -! DrawViewerScr
;
: ShadowCasterView ( --> )
   ReadResDir DrawViewerScr
   0 Begin
    FDat FCur @ SCur @ + [] To CurrF
    IfNot $0C 8 23 CurrF .Ofs @ DStr WriteCXY Then
    KbdIn 0
    KSym C@ Case
     Set 'D $64 Of ShowFDump Endof
     Set 'G $67 Of DisplayPic Endof
     Set 'N $6E Of ChangeFName Endof
\     Set 'A $61 Of SaveVGA Endof
     Set 'S $73 Of SaveRaw Endof
     0 Of
      KSym 1+ C@ Case
       72 Of StrUp Endof
       80 Of StrDown Endof
       73 Of PgeUp Endof
       81 Of PgeDown Endof
       45 Of ExitViewer Endof
       2Drop True
      Endcase
     Endof
     2Drop True
    Endcase
   Again
;
' (Init) >Name Off_Attr + $20000 Swap Xor! \ For multitasking environments
NoErrors 1 MBytes MaxMem !
Build .\scasvw.exe
