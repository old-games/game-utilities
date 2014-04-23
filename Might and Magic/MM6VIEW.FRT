Use disphi2.l32
0 Value ResHdl
0 Value FCnt
0 Value FDat
0 Value RBase
0 Value RType
Variable FCur FCur 0!
Variable SCur SCur 0!
0 Value CurrF
: .Nme ( addr1 --> addr2 ) ; Immediate
: .Ofs ( addr1 --> addr2 ) $10 + @ RBase + ;
: .Sze ( addr1 --> addr2 ) $14 + @ ;
: [] ( addr1 n --> addr2 ) $20 * + ;
: ConvertNames ( --> )
   FCnt 0 Do
    FDat I [] .Nme ASCIIZ> Drop
   Loop
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
   CurrF .Sze If
    ResHdl 0 CurrF .Ofs FSeek ?Drop
    ResHdl Here Dup>R 320 Dup Allot FRead ?Drop
    R> CurrF .Sze 4 RShift 20 Min 0 ?Do
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
: ExitViewer ( --> )
   True CursorSwitch WReset ResHdl FClose Drop Bye
;
Variable GrfMode
Code Set640x480 ;( --> )
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
0 Value SVGApage
Code ResetSVGApages ;( --> )
	xor	edx,edx
	mov	[pfa SVGApage],edx
	mov	eax,4F05h
	xor	ebx,ebx
	int	10h
	next
Endcode
Code NextSVGApage ;( --> )
	mov	ebx,pfa SVGApage
	mov	edx,[ebx]
	inc	edx
	mov	[ebx],edx
	mov	eax,4F05h
	xor	ebx,ebx
	int	10h
	next
Endcode
Code SetPalSh ;( @palette flag --> )
	pop	ebx
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
	test	ebx,ebx
	jz	short ml
	mov	al,0
	out	dx,al
	out	dx,al
	out	dx,al
	add	esi,3
	sub	ecx,3
ml:	lodsb
	shr	al,2
	out	dx,al
	loop	ml
	pop	esi
	next
Endcode
: ClrScrn ( --> )
   ResetSVGApages
   4 0 Do $A0000 BIOSselector $10000 0 AFill NextSVGApage Loop
   $A0000 BIOSselector $B000 0 AFill
   ResetSVGApages
;
Code DoInflate ;( source target --> flag )
	pop	edi
	xchg	[esp],esi
	xor	eax,eax
	lodsb
	shl	eax,4
	cmp	al,80h
	jne	ierr
	cmp	ah,7
	ja	ierr
	shl	eax,4
	lodsb
	xor	edx,edx
	mov	ecx,31
	div	ecx
	test	edx,edx
	jnz	ierr
	lodsd
	mov	[bstr],eax
	mov	ch,32
nxblk:	call	getbit
	push	ebx
	mov	cl,2
	call	getbits
	cmp	ebx,3
	je	ierr
	cmp	ebx,0
	je	ncomp
	push	edi
	cmp	ebx,2
	je	readc
	mov	eax,288
	push	eax
	mov	eax,32
	push	eax
	push	esi
	push	ecx
	mov	edi,offset llens
	mov	al,8
	mov	ecx,144
	rep	stosb
	mov	al,9
	mov	ecx,256-144
	rep	stosb
	mov	al,7
	mov	ecx,280-256
	rep	stosb
	mov	al,8
	mov	ecx,288-280
	rep	stosb
	mov	edi,offset dlens
	mov	al,5
	mov	ecx,32
	rep	stosb
	jmp	itrees
readc:	push	ecx
	mov	edi,offset dlens
	xor	eax,eax
	mov	ecx,5	;19/4
	rep	stosd
	pop	ecx
	mov	cl,5
	call	getbits
	add	ebx,257
	push	ebx
	mov	cl,5
	call	getbits
	inc	ebx
	push	ebx
	mov	cl,4
	call	getbits
	add	ebx,4
	mov	edx,ebx
	mov	edi,offset clseq
	mov	cl,3
ml1:	call	getbits
	movzx	eax,byte ptr [edi]
	mov	[dlens+eax],bl
	inc	edi
	dec	edx
	jnz	ml1
	push	esi
	push	ecx
	mov	esi,offset dlens
	mov	edi,offset dtree
	mov	ecx,19
	call	mktree
	pop	ecx
	pop	esi
	mov	edi,offset llens
	mov	eax,[esp]
	add	eax,[esp+4]
	add	eax,edi
	push	eax
mcl0:	call	dgetcde
	mov	eax,1
	xchg	eax,ebx
	cmp	al,16
	jb	short mc1
	je	short mc2
	cmp	al,17
	je	short mc3
	mov	cl,7
	call	getbits
	add	ebx,11
	xor	eax,eax
	jmp	short mc1
mc3:	mov	cl,3
	call	getbits
	add	ebx,3
	xor	eax,eax
	jmp	short mc1
mc2:	mov	cl,2
	call	getbits
	add	ebx,3
	mov	al,[edi-1]
mc1:	xchg	ebx,ecx
	rep	stosb
	mov	ecx,ebx
	cmp	edi,[esp]
	jb	mcl0
	pop	eax
	push	esi
	push	ecx
	std
	lea	esi,[edi-1]
	mov	edi,offset dlens+31
	xor	eax,eax
	mov	ecx,32
	sub	ecx,[esp+8]
	rep	stosb
	mov	ecx,[esp+8]
	rep	movsb
	xor	eax,eax
	mov	ecx,288
	sub	ecx,[esp+12]
	rep	stosb
	cld
itrees:	mov	esi,offset dlens
	mov	edi,offset dtree
	mov	ecx,[esp+8]
	call	mktree
	mov	esi,offset llens
	mov	edi,offset ltree
	mov	ecx,[esp+12]
	call	mktree
	pop	ecx
	pop	esi
	add	esp,8
	pop	edi
hloop:	call	lgetcde
	mov	eax,ebx
	cmp	eax,256
	je	endblk
	ja	short islz
	stosb
	jmp	short hloop
islz:	cmp	eax,286
	jae	ierr0
	sub	eax,257
	mov	cl,[cplext+eax]
	movzx	ebx,word ptr [cplens+eax+eax]
	push	ebx
	cmp	cl,0
	je	short noext
	call	getbits
	add	[esp],ebx
noext:	call	dgetcde
	cmp	ebx,30
	jae	ierr1
	mov	cl,[cpdext+ebx]
	movzx	ebx,word ptr [cpdist+ebx+ebx]
	cmp	cl,0
	je	short noext1
	push	ebx
	call	getbits
	pop	eax
	add	ebx,eax
noext1:	pop	eax
	xchg	eax,ecx
	mov	edx,esi
	mov	esi,edi
	sub	esi,ebx
	rep	movsb
	mov	esi,edx
	mov	ecx,eax
	jmp	hloop
ncomp:	movzx	ecx,ch
	shr	ecx,3
	sub	esi,ecx
	xor	eax,eax
	lodsw
	mov	ecx,eax
	add	esi,2
	shr	ecx,2
	rep	movsd
	mov	ecx,eax
	and	ecx,3
	rep	movsb
	lodsd
	mov	[bstr],eax
	mov	ch,32
endblk:	pop	eax
	test	eax,eax
	jz	nxblk
	pop	esi
	push	-1
	next
ierr1:	pop	eax
ierr0:	pop	eax
ierr:	pop	esi
	push	0
	next
getbit:	xor	ebx,ebx		;get 1 bit in EBX
	shr	dword ptr [bstr],1
	adc	ebx,0
	sub	ch,1
	ja	mg3
	lodsd
	mov	[bstr],eax
	mov	ch,32
mg3:	ret
getbits:mov	ebx,[bstr]	;get CL bits in EBX
	shr	dword ptr [bstr],cl
	sub	ch,cl
	ja	short mg1
	lodsd
	mov	[bstr],eax
	je	short mg2
	xchg	ch,cl
	add	cl,ch
	shl	eax,cl
	or	ebx,eax
	sub	cl,ch
	neg	cl
	shr	dword ptr [bstr],cl
	xchg	ch,cl
	neg	ch
mg2:	add	ch,32
mg1:	mov	eax,1
	shl	eax,cl
	dec	eax
	and	ebx,eax
	ret
mktree:	push	ecx		;build Huffman tree
	push	esi
	push	edi
	mov	edi,offset ccnt
	xor	eax,eax
	mov	cx,8
	rep	stosd
	mov	edi,offset ccnt
	mov	ecx,[esp+8]
mgl1:	lodsb
	inc	word ptr [edi+eax*2]
	loop	mgl1
	lea	esi,[edi+2]
	lea	edi,[esi+30]
	mov	ecx,15
	mov	ax,1
	mov	bx,0
mgl2:	mov	[esi+60],bx
	add	ax,ax
	add	bx,ax
	sub	ax,[esi]
	stosw
	add	esi,2
	loop	mgl2
	mov	esi,offset ccnt+2
	mov	edi,[esp]
	mov	ax,1
mgl4:	movzx	ecx,word ptr [esi]
	lea	edi,[edi+2*ecx]
	movzx	ecx,word ptr [esi+30]
	jecxz	mg4
mgl3:	stosw
	inc	ax
	loop	mgl3
	add	esi,2
	jmp	short mgl4
mg4:	pop	edi
	pop	esi
	pop	ecx
	mov	dx,0
	not	dx
mgl5:	movzx	eax,byte ptr [esi]
	test	eax,eax
	jz	short mg6
	lea	eax,[lbas+eax+eax-2]
	movzx	ebx,word ptr [eax]
	inc	word ptr [eax]
	mov	[edi+2*ebx],dx
mg6:	dec	dx
	inc	esi
	loop	mgl5
	ret
dgetcde:mov	edx,offset dtree	;get distance code in EBX
	jmp	short getcde
lgetcde:mov	edx,offset ltree	;get literal/length code in EBX
getcde:	mov	eax,[bstr]
	xor	ebx,ebx
mgl6:	shr	eax,1
	adc	ebx,ebx
	movsx	ebx,word ptr [edx+2*ebx]
	sub	ch,1
	jnz	short mg7
	lodsd
	mov	ch,20h
mg7:	test	ebx,ebx
	jns	short mgl6
	mov	[bstr],eax
	not	ebx
	ret
clseq:	db	16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15
cplens:	dw	3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99
	dw	115,131,163,195,227,258
cplext:	db	0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0
cpdist:	dw	1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025
	dw	1537,2049,3073,4097,6145,8193,12289,16385,24577
cpdext:	db	0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12
	db	13,13
	align	4
bstr:	dd	0
llens:	ds	288	;These must
dlens:	ds	32	;be sequential!
ccnt:	ds	32	;And these
lcnt:	ds	30	;must be
lbas:	ds	30	;sequential,too.
ltree:	ds	1148
dtree:	ds	124
Endcode
Code DrawBitmap ;( xsz ysz src BIOSselector --> )
	pop	es
	pop	eax
	pop	edx
	pop	ebx
	push	esi
	xchg	eax,esi
	mov	edi,0A0000h
ml:	mov	ecx,ebx
	lea	eax,[edi+ecx]
	sub	eax,0B0000h
	jb	short m1
	sub	ecx,eax
	rep	movsb
	call	nxpg
	mov	edi,0A0000h
	mov	ecx,eax
m1:	rep	movsb
	add	edi,640
	sub	edi,ebx
	cmp	edi,0B0000h
	jb	short m2
	call	nxpg
	sub	edi,10000h
m2:	dec	edx
	jnz	short ml
	pop	esi
	push	ds
	pop	es
	next
nxpg:	push	eax
	push	ebx
	push	edx
	mov	ebx,pfa SVGApage
	mov	edx,[ebx]
	inc	edx
	mov	[ebx],edx
	mov	eax,4F05h
	xor	ebx,ebx
	int	10h
	pop	edx
	pop	ebx
	pop	eax
	ret
Endcode
Code DrawSprite ;( hdr body BIOSselector --> )
	pop	es
	pop	eax
	pop	ebx
	push	esi
	push	eax
	mov	edi,0A0000h
	movzx	edx,word ptr [ebx+12h]
	add	ebx,20h
	cmp	edx,480
	jbe	short ml1
	mov	edx,480
ml1:	movsx	eax,word ptr [ebx]
	test	eax,eax
	js	short mns
	movzx	ecx,word ptr [ebx+2]
	inc	ecx
	sub	ecx,eax
	add	edi,eax
	cmp	edi,0B0000h
	jb	short m1
m4:	call	nxpg
	sub	edi,10000h
	cmp	edi,0B0000h
	jae	short m4
m1:	mov	esi,[ebx+4]
	add	esi,[esp]
ml2:	lodsb
	test	al,al
	jz	short m2
	mov	es:[edi],al
m2:	inc	edi
	cmp	edi,0B0000h
	jb	short m3
	call	nxpg
	mov	edi,0A0000h
m3:	loop	ml2
	movzx	eax,word ptr [ebx+2]
	inc	eax
	sub	edi,eax
mns:	add	edi,640
	add	ebx,8
	dec	edx
	jnz	short ml1
	pop	eax
	pop	esi
	push	ds
	pop	es
	next
nxpg:	push	eax
	push	ebx
	push	edx
	mov	ebx,pfa SVGApage
	mov	edx,[ebx]
	inc	edx
	mov	[ebx],edx
	mov	eax,4F05h
	xor	ebx,ebx
	int	10h
	pop	edx
	pop	ebx
	pop	eax
	ret
Endcode
: MkItem ( addr --> )
   Dup .Nme Bl 18 Here MkStr S! 18 Here C! .Sze 0 10 RStr Here S+!
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
      Dup MkItem $0A 2 I 2+ Here WriteCXY $20 +
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
      Dup MkItem $0A 2 I 2+ Here WriteCXY $20 +
     Loop Drop
     1 21 30 21 $1A ChangeAttr
    Then
   Then
;
: DrawFileBar ( --> )
   FDat FCur @ [] 20 0 Do
    Dup MkItem $0A 2 I 2+ Here WriteCXY $20 +
   Loop Drop
   1 2 SCur @ + 30 Over $1A ChangeAttr 
;
: DrawViewerScr ( --> )
   1 1 80 25 $07 Clr False CursorSwitch
   $0B 13 25 " Dump GraphView ReName Save VGA Save `as is' AltX - Exit"
   WriteCXY 25 $0A " \13;\18;\30;\40;\44;\57;\58;\59;\60;" ChgSymAttr
   $1A TextAttr ! DrawFileBar
;
: LoadResDir ( --> )
   ResHdl 0 $100 FSeek ?Drop
   ResHdl Here $20 2Dup Allot To FDat FRead ?Drop
   FDat $1C + @ To FCnt FDat $10 + @ To RBase
   FDat ASCIIZ> >Upper Case
    Bool " BITMAPS" SCmp 0= Of 1 Endof
    Bool " ICONS" SCmp 0= Of 2 Endof
    Bool " SPRITES08" SCmp 0= Of 3 Endof
    Drop 4
   Endcase To RType
   ResHdl FDat FCnt $20 * Dup $20 - Allot FRead ?Drop
   ConvertNames
;
Also Hidden
Create MMPalsN " MMPALS.BIN\0" (,")
Previous
0 Value PalList
0 Value PalCnt
: PrepareResource ( --> )
   ParseCommandLine Bl Word
   >ASCIIZ 0 FOpen IfNot ." File not found!" cr Bye
   Then To ResHdl
   LoadResDir
   RType 3 = If
    MMPalsN 1+ 0 FOpen ?Dup IfNot
     Here >R 256 Allot
     ExeName ASCIIZ> 1 Over '\ Swap Scan 0 Max R@ Copy MMPalsN R@ S+!
     1+ 0 FOpen Dup If RDrop -256 Allot Then
    Then
    If
     Here To PalList Dup 2 0 FSeek Drop Dup Allot Over 0 0 FSeek ?Drop
     2Dup PalList Swap FRead Drop $304 / To PalCnt FClose Drop
    Else
     R@ 1+ $20 FCreate IfNot
      ." Can't create palette file" cr ResHdl FClose Drop Bye
     Else
      >R Here To PalList
      ResHdl >R FDat >R RType >R FCnt >R RBase >R
      " BITMAPS.LOD\0" Here >R 256 Allot
      ParseCommandLine Bl Word 1 Over '\ Swap Scan 0 Max R@ Copy S+! -256 Allot
      R> 1+ 0 FOpen If
       To ResHdl LoadResDir
       Here >R
       FDat FCnt 0 Do
	Dup .Nme Here Dup>R S! " PAL" R@ >Upper Pos 1 = If
	 R@ 1 3 Del R@ Val Press If
	  Over .Sze $330 = If
	   , Dup .Ofs $30 + ResHdl 0 Rot FSeek ?Drop
	   ResHdl Here $300 Dup Allot FRead ?Drop 0
	  Then
	 Then Drop
	Then RDrop
	$20 +
       Loop Drop
       ResHdl FClose Drop
       R@ FDat Here R@ - CMove FDat R> - Allot
      Then
      R> To RBase R> To FCnt R> To RType R> To FDat R> To ResHdl
      Here PalList - $304 / ?Dup If
       Dup 1 > If
        PalList Over $304 [Sort<] Here $304 Allot Sort $304 Negate Allot
       Then Dup To PalCnt
       R@ PalList Rot $304 * FWrite ?Drop R> FClose Drop RDrop
      Else
       R> FClose Drop R> 1+ FDelete Drop
       ." Neither palette file nor bitmap resource found - exiting" cr
       ResHdl FClose Drop Bye
      Then
     Then
    Then
   Then
;
: FindPal ( pal# --> addr | 0 )
   >R PalCnt 1- 0 Begin
    2Dup + 1+ 2/
    PalList Over $304 * + Dup>R @ ROver < If 1+ Press
    Else 1- Over 2Press Then
    R@ @ ROver = If 2Drop R> 4+ RDrop Exit Then RDrop
   2Dup Swap > Until
   2Drop RDrop 0
;
: DrawPic ( type addr --> )
   Here >R
   Over Case
    Set 1 2 Of Dup $30 + Over $28 + @ Endof
    3 Of Dup $30 + 0 Endof
    4 Of Dup $12 + W@ 8 * Over + $20 + Over $1C + @ Endof
   Endcase
   ?Dup If Here Dup>R Swap Allot DoInflate Else >R True Then
   If
    Swap Case
     Set 1 2 3 Of
       Dup $14 + @ $30 + Over +
       Over $2C + @ $200 And 0<> ?Dup IfNot
        Dup @ $FCFCFC And Dup $FCFC00 = Swap $00FC00 = Or
       Then SetPalSh
       Dup $18 + W@ Swap $1A + W@ 480 Min R@ BIOSselector DrawBitmap
      Endof
     4 Of
       Dup $14 + @ FindPal ?Dup If True SetPalSh Else Beep Then
       R@ BIOSselector DrawSprite       
      Endof
    Endcase
    RDrop
   Else RDrop 2Drop Then
   R> Here - Allot
;
: ValidateGraphData ( size addr --> n )
\ 0-data,1-texture,2-icon,3-unpacked icon,4-sprite
   2>R RType Case
    1 Of
      R@ $14 + @ $330 + ROver = If
       R@ $18 + W@ R@ $1A + W@ * Dup 0> Swap R@ $10 + @ = And If 1 Else 0 Then
      Else 0 Then
     Endof
    2 Of
      R@ $2C + @ $100 And IfNot
       R@ $14 + @ $330 + ROver = If
	R@ $18 + W@ R@ $1A + W@ * Dup 0> Swap R@ $10 + @ = And If
	 R@ $28 + @ If 2 Else 3 Then
	Else 0 Then
       Else 0 Then
      Else 0 Then
     Endof
    3 Of
      R@ $C + @ $20 + R@ $12 + W@ 8 * + ROver = If
       R@ $10 + W@ R@ $12 + W@ * If 4 Else 0 Then
      Else 0 Then
     Endof
    Drop 0
   Endcase 2RDrop
;
: ?NxStr ( --> flag true )
   SCur @ 1+ FCnt = If False Else SCur 1+! True Then True
;
: LoadF ( size --> size addr )
   ResHdl 0 CurrF .Ofs FSeek ?Drop
   Dup>R Here ResHdl Over R@ R> Allot FRead ?Drop
;
: DisplayPic ( --> )
   GrfMode Off FCur @ SCur +!
   Begin
    CurrF .Sze Dup If
     LoadF 2Dup 2>R
     ValidateGraphData Dup If
      GrfMode @ IfNot Set640x480 GrfMode On Then ClrScrn
      R@ DrawPic
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
Code ShiftPal ;( src dst --> )
	pop	edi
	xchg	[esp],esi
	mov	ecx,300h
ml:	lodsb
	shr	al,2
	stosb
	loop	ml
	pop	esi
	next
Endcode
: SaveFile ( --> )
   CurrF .Sze ?Dup If
    Here >R LoadF RType Case
     Set 1 2 Of
       Press Dup $30 + Here Dup>R Over $8 - @ Dup>R
       ?Dup If Allot DoInflate Else 2Drop True Then
       If
	CurrF .Nme Here S! Here >ASCIIZ $20 FCreate If
         Over $2C + @ $100 And IfNot
          R@ If
	   2Dup Swap $30 FWrite ?Drop 
	   Dup 2R@ FWrite ?Drop
	   2Dup Swap Dup $14 + @ + $30 + $300
	  Else
	   2Dup Swap $30 + Here Tuck $300 Allot ShiftPal $300
	  Then
         Else Dup 2R@ Then
         FWrite ?Drop FClose Drop
	Else Beep Then
       Then Drop
      Endof
     4 Of
       Press 8+ Here Dup>R Over 4- @ Dup>R Allot DoInflate If
	CurrF .Nme Here S! Here >ASCIIZ $20 FCreate If
         Dup 2R@ FWrite ?Drop FClose DRop
	Else Beep Then
       Then
      Endof
     Drop
       Press Dup $12 + W@ 8 * Over + $20 + Over Here Dup>R Swap $1C + @ Dup>R
       Allot DoInflate
       If
	CurrF .Nme Here S! Here >ASCIIZ $20 FCreate If
         2Dup Swap Dup $12 + W@ 8 * $20 + FWrite ?Drop 
         Dup 2R@ FWrite ?Drop
	 2Dup Swap $14 + @ FindPal ?Dup If $300 FWrite ?Drop Else Drop Then
	 FClose Drop
	Else Beep Then
       Then Drop
    Endcase 2RDrop
    R> Here - Allot
   Then StrDown
;
: M&M6View ( --> )
   PrepareResource DrawViewerScr
   0 Begin
    FDat FCur @ SCur @ + [] To CurrF
    IfNot $0C 8 23 CurrF .Ofs DStr WriteCXY Then
    KbdIn 0
    KSym C@ Case
     Set 'D $64 Of ShowFDump Endof
     Set 'G $67 Of DisplayPic Endof
     Set 'N $6E Of ChangeFName Endof
\     Set 'A $61 Of SaveVGA Endof
     Set 'S $73 Of SaveFile Endof
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
NoErrors 4 MBytes Dup MinMem ! MaxMem !
Build .\mm6view.exe
