Use disphi2.l32
0 Value WDat
0 Value WADhdl
0 Value WCnt
0 Value SMax
0 Value CurrF
Variable L1
Variable Samp
Variable WCur WCur 0!
Variable SCur SCur 0!
Also Hidden
: Cond ( --> ) ?SR 5 To VSet ; Immediate
: Of ( --> )
   ?Comp $5030F5 ?Pairs VSet 5 = If
    Compile ?Branch >Mark $5030F5 $5030F6
   Else $5030F5 [Compile] Of Then
; Immediate
Previous
: ]L ( n --> ) ] [Compile] Literal ;
: .Ofs ( addr1 --> addr2 ) ; Immediate
: .Sze ( addr1 --> addr2 ) Compile 4+ ; Immediate
: .Nme ( addr1 --> addr2 ) Compile 8+ ; Immediate
: [] ( addr1 n --> addr2 ) 4* Cells+ ;
: MkItem ( addr --> )
   10 Here ! Dup .Nme 2@ Here 1+ 2! $2020 Here 9 + ! .Sze @ 0 10 RStr Here S+!
;
: DrawFileBar ( --> )
   WDat WCur @ [] SMax 0 Do
    Dup MkItem $0A 2 I 2+ Here WriteCXY 16 +
   Loop Drop
   1 2 SCur @ + 22 Over $1A ChangeAttr 
;
: DrawViewerScr ( --> )
   1 1 80 25 $07 Clr False CursorSwitch $0B 4 25
   " Dump GraphView ReName Save WAV Save VOC Save VGA Save `as is' AltX - Exit"
   WriteCXY 25 $0A " \4;\9;\21;\31;\40;\51;\53;\66;\67;\68;\69;" ChgSymAttr
   WCnt 20 Min To SMax $1A TextAttr ! DrawFileBar
;
: StrUp ( --> )
   SCur @ If
    1 SCur @ 2+ 22 Over $0A ChangeAttr SCur 1-!
    1 SCur @ 2+ 22 Over $1A ChangeAttr
   Else
    WCur @ If
     2 2 21 2 $0A ChangeAttr 2 2 21 20 -1 Scroll WCur 1-!
     WDat WCur @ [] MkItem $1A 2 2 Here WriteCXY
    Then
   Then
;
: StrDown ( --> )
   SCur @ SMax 1- < If
    1 SCur @ 2+ 22 Over $0A ChangeAttr SCur 1+!
    1 SCur @ 2+ 22 Over $1A ChangeAttr
   Else
    WCur @ WCnt 20 - < If
     2 21 21 21 $0A ChangeAttr 2 3 21 21 1 Scroll WCur 1+!
     WDat WCur @ 19 + [] MkItem $1A 2 21 Here WriteCXY
    Then
   Then
;
: PgeUp ( --> )
   SCur @ If
    1 SCur @ 2+ 22 Over $0A ChangeAttr SCur 0!
    1 2 22 2 $1A ChangeAttr
   Else
    WCur @ If
     WCur @ 19 > If 19 WCur -! Else WCur 0! Then
     WDat WCur @ [] SMax 0 Do
      Dup MkItem $0A 2 I 2+ Here WriteCXY 16 +
     Loop Drop
     1 2 22 2 $1A ChangeAttr
    Then
   Then
;
: PgeDown ( --> )
   SCur @ SMax 1- < If
    1 SCur @ 2+ 22 Over $0A ChangeAttr SMax 1- SCur !
    1 SCur @ 2+ 22 Over $1A ChangeAttr
   Else
    WCur @ WCnt 20 - < If
     WCur @ WCnt 39 - < If 19 WCur +! Else WCnt 20 - WCur ! Then
     WDat WCur @ [] 20 0 Do
      Dup MkItem $0A 2 I 2+ Here WriteCXY 16 +
     Loop Drop
     1 21 22 21 $1A ChangeAttr
    Then
   Then
;
: DStr ( n --> str )
   Base @ >R 16 Base ! 0 8 ZStr R> Base !
;
: ShowDirItemAddr ( --> )
   $0C 26 SCur @ 2+ L1 @ WCur @ SCur @ + [] DStr WriteCXY
   KbdIn 26 SCur @ 2+ 33 Over $07 Clr
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
    WADhdl 0 CurrF .Ofs @ FSeek ?Drop
    WADhdl Here Dup>R 320 Dup Allot FRead ?Drop
    R> CurrF .Sze @ 4 RShift 20 Min 0 ?Do
     Dup Here HexStr16 "  ³ " Here S+! 16 Here +! Dup Here 36 + 16 CMove
     $0F 26 I 2+ Here WriteCXY 16 +
    Loop Drop -320 Allot
    KbdIn 26 2 76 21 $07 Clr
   Then
;
0 Constant Zero
$0C Constant Opc_OR_AL_8
$3C Constant Opc_CMP_AL_8
>Public Opc_OR_AL_8 Opc_CMP_AL_8 Zero
Code RecompressPic ;( target source buffer pictype --> size )
	pop	edx	
	pop	edi
	pop	ebx
	pop	eax
	push	esi
	push	ebp
	push	eax
	push	edi
	mov	ecx,32000
	xor	eax,eax
	rep	stosd
	pop	edi
	push	edi
	cmp	edx,1
	je	mtp1
	cmp	edx,2
	je	mtp2
	cmp	edx,3
	je	mtp3
	cmp	edx,4
	je	mtp4
	cmp	edx,5
	je	mtp5
	cmp	edx,11h
	je	mtp11
	cmp	edx,12h
	je	mtp12
	cmp	edx,13h
	je	mtp13
	cmp	edx,14h
	je	mtp14
	cmp	edx,15h
	je	short mtp15
	cmp	edx,16h
	je	short mtp16
	cmp	edx,17h
	je	short mtp17
;insert other types here
mtp17:	mov	esi,ebx
	mov	ebx,edi
	mov	edx,256
ml19:	mov	edi,ebx
	mov	ecx,200
ml18:	mov	byte ptr [edi+64000],0FFh
	movsb
	add	edi,319
	loop	ml18
	inc	ebx
	dec	edx
	jnz	short ml19
	mov	ebx,256
	mov	edx,200
	jmp	mkh1
mtp16:	mov	esi,ebx
	mov	ebx,edi
	mov	edx,64
ml17:	mov	edi,ebx
	mov	ecx,64
ml16:	lodsb
	cmp	al,0FFh
	je	short ml16n
	mov	byte ptr [edi+64000],0FFh
	mov	[edi],al
ml16n:	add	edi,320
	loop	ml16
	inc	ebx
	dec	edx
	jnz	short ml17
	mov	edx,64
	mov	ebx,edx
	jmp	mkh1
mtp15:	lea	ebp,[ebx+12]
	mov	eax,Opc_CMP_AL_8-Zero
	jmp	short ml15_
mtp14:	lea	ebp,[ebx+10]
	mov	eax,Opc_OR_AL_8-Zero
ml15_:	mov	byte ptr [mmd1],al
	movzx	edx,word ptr [ebx+2]
	add	edx,edi
	push	edx
	mov	edx,edi
	xor	eax,eax
ml15:	movzx	esi,word ptr [ebp]
	add	esi,ebx
ml14:	lodsb
	cmp	al,0FFh
	je	short ml12
	imul	edi,eax,320
	add	edi,edx
	lodsb
	mov	ecx,eax
	jecxz	ml14
	lodsb
mmd1:	cmp	al,0FEh		;var.cmd.(+0)
	je	short ml14
	dec	esi
ml13:	mov	byte ptr [edi+64000],0FFh
	movsb
	add	edi,319
	loop	ml13
	jmp	short ml14
ml12:	inc	ebp
	inc	ebp
	inc	edx
	cmp	edx,[esp]
	jb	short ml15
	pop	eax
	pop	esi
	mov	edi,[esp]
	mov	ax,1		;...
	stosw
	mov	eax,0Ah
	stosd
	mov	ax,[ebx]
	shr	ax,1
	add	ax,[ebx+8]
	shl	eax,16
	mov	ax,[ebx]
	add	ax,[ebx+6]	;insertion point as garbage
	stosd			;...file header
	xor	eax,eax		;...
	stosw
	mov	ax,[ebx]	;X-size
	stosw
	xor	eax,eax
	stosw
	mov	ax,[ebx+4]	;Y-size
	stosw			;...page header
	jmp	mcmpr
mtp13:	mov	esi,ebx
	xor	eax,eax
	lodsw
	mov	ebx,eax
	lodsw
	mov	edx,eax
	mov	ebp,edi
	lodsd
	mov	eax,ebx
ml11:	mov	edi,ebp
	mov	ecx,edx
ml10:	mov	byte ptr [edi+64000],0FFh
	movsb
	add	edi,319
	loop	ml10
	inc	ebp
	dec	eax
	jnz	short ml11
	jmp	mkh1
mtp12:	mov	esi,ebx
	xor	eax,eax
	lodsw
	mov	ebx,eax
	lodsw
	mov	edx,eax
	mov	ebp,eax
	lodsd
	mov	al,0FFh
ml9:	mov	ecx,ebx
	rep	movsb
	sub	edi,ebx
	add	edi,64000
	mov	ecx,ebx
	rep	stosb
	sub	edi,ebx
	sub	edi,64000-320
	dec	ebp
	jnz	short ml9
	jmp	mkh1
mtp11:	mov	esi,ebx
	xor	eax,eax
	lodsb
	mov	ebx,eax
	lodsb
	mov	edx,eax
	mov	ebp,edi
	lea	eax,[ebp+4]
	push	eax
ml8:	push	edx
	push	ebp
ml6:	mov	edi,ebp
	mov	ecx,ebx
ml7:	lodsb
	cmp	al,0FFh
	je	short ml7n
	mov	byte ptr [edi+64000],0FFh
	mov	[edi],al
ml7n:	add	edi,4
	loop	ml7
	add	ebp,320
	dec	edx
	jnz	short ml6
	pop	ebp
	pop	edx
	inc	ebp
	cmp	ebp,[esp]
	jb	short ml8
	pop	eax
	lea	ebx,[4*ebx]
	jmp	mkh1
mtp5:	mov	edx,128
	jmp	short mw1
mtp4:	mov	edx,65
	jmp	short mw1
mtp3:	mov	edx,64
mw1:	mov	esi,ebx
	mov	ebx,edx
	xor	eax,eax
	mov	ecx,eax
	dec	eax
ml5:	mov	cl,16
	rep	movsd
	add	edi,64000-64
	mov	cl,16
	rep	stosd
	sub	edi,64000-320+64
	dec	ebx
	jnz	short ml5
	mov	ebx,64
	jmp	short mkh1
mtp2:	mov	esi,ebx
	mov	ecx,16000
	rep	movsd
	xor	eax,eax
	dec	eax
	mov	ecx,16000
	rep	stosd
	mov	ebx,320
	mov	edx,200
mkh1:	pop	esi
	mov	edi,[esp]
	mov	ax,1		;...
	stosw
	mov	eax,6
	stosd
	xor	eax,eax		;...
	stosw
	mov	eax,ebx		;X-size
	stosw
	xor	eax,eax
	stosw
	mov	eax,edx		;Y-size
	stosw			;...page header
	jmp	mcmpr
mtp1:	movzx	edx,word ptr [ebx]
	add	edx,edi
	push	edx
	mov	edx,edi
	xor	eax,eax
	lea	ebp,[ebx+8]
ml4:	mov	esi,[ebp]
	add	esi,ebx
ml3:	lodsb
	cmp	al,0FFh
	je	short ml1
	imul	edi,eax,320
	add	edi,edx
	lodsb
	mov	ecx,eax
	lodsb
ml2:	mov	byte ptr [edi+64000],0FFh
	movsb
	add	edi,319
	loop	ml2
	lodsb
	jmp	short ml3
ml1:	add	ebp,4
	inc	edx
	cmp	edx,[esp]
	jb	short ml4
	pop	eax
	pop	esi
	mov	edi,[esp]
	mov	ax,1		;...
	stosw
	mov	eax,0Ah
	stosd
	mov	eax,[ebx+4]	;insertion point as garbage
	stosd			;...file header
	xor	eax,eax		;...
	stosw
	mov	ax,[ebx]	;X-size
	stosw
	xor	eax,eax
	stosw
	mov	ax,[ebx+2]	;Y-size
	stosw			;...page header
mcmpr:	mov	ebx,eax
msnx:	mov	edx,esi
	xor	eax,eax
	push	edi
	stosw
	add	esi,64000
	mov	ecx,320
	cmp	[esi],al
	jne	short ms1
	xchg	esi,edi
	repe	scasb
	xchg	esi,edi
	je	mssl
	dec	esi
	inc	ecx
	mov	eax,320
	sub	eax,ecx
ms1:	stosw
mslp0:	sub	esi,64000
	push	esi
mslp:	lodsb
	dec	ecx
	jz	mssx
	cmp	ecx,1
	je	short ms2
	mov	ah,al
	cmp	[esi],ax
	jne	short ms2
	cmp	word ptr [esi+64000],0FFFFh
	je	short ms3
ms2:	cmp	byte ptr [esi+64000],0FFh
	je	short mslp
	call	putc
	add	esi,64000
	xchg	esi,edi
	mov	ebp,edi
	mov	al,0
	repe	scasb
	xchg	esi,edi
	je	mssl
	dec	esi
	inc	ecx
	sub	ebp,esi
	neg	ebp
mws2:	cmp	ebp,40h
	jbe	short mws1
	mov	al,0BFh
	stosb
	sub	ebp,40h
	jmp	short mws2
mws1:	lea	eax,[ebp-1]
	or	al,80h
	stosb
	jmp	short mslp0
ms3:	dec	esi
	inc	ecx
	call	putc
	lodsw
	lodsb
	xor	ebp,ebp
	sub	ecx,3
	jz	short mwfx
mwfl:	cmp	byte ptr [esi+64000],0FFh
	jne	short mwfx
	lodsb
	cmp	al,ah
	jne	short mwfx0
	inc	ebp
	dec	ecx
	jz	short mwfx
	cmp	ebp,3Fh
	je	short mwfx
	jmp	short mwfl
mwfx0:	dec	esi
mwfx:	mov	al,ah
	xchg	ebp,eax
	or	al,0C0h
	stosb
	mov	eax,ebp
	stosb
	jecxz	mssl
	push	esi
	jmp	short ms2
mssx:	call	putc
mssl:	mov	eax,edi
	pop	ecx
	sub	eax,ecx
	sub	eax,2
	mov	[ecx],ax
	lea	esi,[edx+320]
	dec	ebx
	jnz	msnx
	pop	eax
	sub	edi,eax
	pop	ebp
	pop	esi
	push	edi
	next
putc:	mov	ebp,ecx
	mov	ecx,esi
	pop	esi
	xchg	[esp],esi
	sub	ecx,esi
	je	short mpcx
mpcl:	cmp	ecx,80h
	jbe	short mpc1
	mov	al,7Fh
	stosb
	lea	eax,[ecx-80h]
	mov	ecx,20h
	rep	movsd
	mov	ecx,eax
	jmp	short mpcl
mpc1:	lea	eax,[ecx-1]
	stosb
	rep	movsb
mpcx:	mov	ecx,ebp
	ret
Endcode
: CreateTypedFile ( mode --> fhdl True | False )
    CurrF .Nme 2@ Here 2! Here 8 + Dup 0. Rot 2!
    8 0 Do 1- Dup C@ If 1+ Leave Then Loop
    Swap Case
     1 Of [ " .WAV" 1+ @ ]L Endof
     2 Of [ " .VOC" 1+ @ ]L Endof
     3 Of [ " .VGA" 1+ @ ]L Endof
     DropFalse
    Endcase Swap !
    Here $20 FCreate
;
: DoConv2VGA ( pictype R: src --> R: src )
   R> Swap >R Here [ 64 KBytes ]L Allot Dup ROver Here 128000 Allot R>
   RecompressPic -128000 Allot
   3 CreateTypedFile If Dup>R -Rot FWrite ?Drop R> FClose Drop Then >R
   [ -64 KBytes ]L Allot
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
Create DoomPal 0 768 LoadData doom.pal
Create HticPal 0 768 LoadData heretic.pal
Create HexnPal 0 768 LoadData hexen0.pal
Create TriadPal 0 768 LoadData triad.pal
0 Value CurrPal
: ValidateGraphData_ID ( size addr --> type )
\ types: 1 - normal, 2 - raw, 3 - flat64, 4 - flat65, 5 - flat128?
   2>R Case
    Cond R@ W@ 1 320 Between R@ 2+ W@ 1 200 Between And Of
      R@ W@ 4* 8+ Dup 1- ROver U< If
       4- R@ + @ ROver U< 1 And
      Else DropFalse Then
     Endof
    Cond ROver 64000 = Of 2 Endof
    Cond ROver 4096 = Of 3 Endof
    Cond ROver 4160 = Of 4 Endof
    Cond ROver 8192 = Of 5 Endof
   False Endcase   
   2RDrop
;
: ValidateGraphData_Triad ( size addr --> type )
\ types: $11 - i_bitmap, $12 - bitmap1, $13 - bitmap2, $14 - normal10,
\ $15 - normal12, $16 - vflat64, $17 - sky
   2>R Case
    Cond R@ C@ 4* R@ 1+ C@ * 4+ ROver = Of $11 Endof
    Cond R@ W@ $80 = R@ 2+ W@ $80 = And ROver $4008 = And Of $12 Endof
    Cond R@ W@ R@ 2+ W@ * 8+ ROver = Of $13 Endof
    Cond R@ W@ 1 320 Between R@ 4+ W@ 1 200 Between And Of
      R@ 2+ W@ 2* 10 + R@ 10 + W@ = If
       R@ 2+ W@ 2* 10 + Dup 1- ROver U< $14
      Else
       R@ 2+ W@ 2* 12 + R@ 12 + W@ = If
	R@ 2+ W@ 2* 12 + Dup 1- ROver U< $15
       Else 0 False 0 Then
      Then
      Swap If
       Swap 2- R@ + W@ ROver U< And
      Else 2Drop False Then
     Endof
    Cond ROver 4096 = Of $16 Endof
    Cond ROver 51200 = Of $17 Endof
   False Endcase   
   2RDrop
;
Defer ValidateGraphData
' ValidateGraphData_ID To ValidateGraphData
Code DrawPic ;( addr BIOSsel pictype --> )
	pop	eax
	pop	es
	pop	ebx
	push	esi
	push	ebp
	cmp	eax,1
	je	mtp1
	cmp	eax,2
	je	mtp2
	cmp	eax,3
	je	mtp3
	cmp	eax,4
	je	mtp4
	cmp	eax,5
	je	mtp5
	cmp	eax,11h
	je	mtp11
	cmp	eax,12h
	je	mtp12
	cmp	eax,13h
	je	mtp13
	cmp	eax,14h
	je	short mtp14
	cmp	eax,15h
	je	short mtp15
	cmp	eax,16h
	je	short mtp16
	cmp	eax,17h
	je	short mtp17
;insert other types here
	jmp	mxx
mtp17:	mov	esi,ebx
	mov	edi,0A0000h
	mov	edx,256
ml19:	mov	ecx,200
ml18:	movsb
	add	edi,319
	loop	ml18
	sub	edi,63999 ;320*200-1
	dec	edx
	jnz	short ml19
	jmp	mxx
mtp16:	mov	esi,ebx
	mov	edi,0A0000h
	mov	edx,64
ml17:	mov	ecx,64
ml16:	lodsb
	cmp	al,0FFh
	je	ml16n
	mov	es:[edi],al
ml16n:	add	edi,320
	loop	ml16
	sub	edi,4FFFh ;320*64-1
	dec	edx
	jnz	short ml17
	jmp	mxx
mtp15:	lea	ebp,[ebx+12]
	mov	eax,Opc_CMP_AL_8-Zero
	jmp	short ml15_
mtp14:	lea	ebp,[ebx+10]
	mov	eax,Opc_OR_AL_8-Zero
ml15_:	mov	byte ptr [mmd1],al
	xor	edx,edx
	xor	eax,eax
ml15:	movzx	esi,word ptr [ebp]
	add	esi,ebx
ml14:	lodsb
	cmp	al,0FFh
	je	short ml12
	imul	edi,eax,320
	lea	edi,[edi+edx+0A0000h]
	lodsb
	mov	ecx,eax
	jecxz	ml14
	lodsb
mmd1:	cmp	al,0FEh		;var.cmd.(+0)
	je	short ml14
	dec	esi
ml13:	movsb
	add	edi,319
	loop	ml13
	jmp	short ml14
ml12:	inc	ebp
	inc	ebp
	inc	edx
	cmp	dx,[ebx+2]
	jb	short ml15
	jmp	mxx
mtp13:	mov	esi,ebx
	mov	ebx,0A0000h
	xor	eax,eax
	lodsw
	mov	edx,eax
	lodsw
	add	esi,4
ml11:	mov	edi,ebx
	mov	ecx,eax
ml10:	movsb
	add	edi,319
	loop	ml10
	inc	ebx
	dec	edx
	jnz	short ml11
	jmp	mxx
mtp12:	mov	esi,ebx
	mov	ebx,0A0000h
	xor	eax,eax
	lodsw
	mov	edx,eax
	lodsw
	add	esi,4
ml9:	mov	edi,ebx
	mov	ecx,edx
	rep	movsb
	add	ebx,320
	dec	eax
	jnz	short ml9
	jmp	mxx
mtp11:	mov	esi,ebx
	mov	ebx,0A0000h
	xor	eax,eax
	lodsb
	mov	edx,eax
	lodsb
	mov	ebp,eax
ml8:	push	ebx
	push	ebp
ml6:	mov	edi,ebx
	mov	ecx,edx
ml7:	lodsb
	cmp	al,0FFh
	je	short ml7s
	stosb
	add	edi,3
	loop	ml7
ml6nx:	add	ebx,320
	dec	ebp
	jnz	short ml6
	pop	ebp
	pop	ebx
	inc	ebx
	cmp	bl,4
	jne	ml8
	jmp	mxx
ml7s:	add	edi,4
	loop	ml7
	jmp	short ml6nx
mtp5:	mov	eax,128
	jmp	short mw1
mtp4:	mov	eax,65
	jmp	short mw1
mtp3:	mov	eax,64
mw1:	mov	esi,ebx
	mov	edi,0A0000h
ml5:	mov	ecx,16
	rep	movsd
	add	edi,320-64
	dec	eax
	jnz	short ml5
	jmp	mxx
mtp2:	mov	esi,ebx
	mov	edi,0A0000h
	mov	ecx,16000
	rep	movsd
	jmp	mxx
mtp1:	xor	edx,edx
	xor	eax,eax
	lea	ebp,[ebx+8]
ml4:	mov	esi,[ebp]
	add	esi,ebx
ml3:	lodsb
	cmp	al,0FFh
	je	short ml1
	imul	edi,eax,320
	lea	edi,[edi+edx+0A0000h]
	lodsb
	mov	ecx,eax
	lodsb
ml2:	movsb
	add	edi,319
	loop	ml2
	lodsb
	jmp	short ml3
ml1:	add	ebp,4
	inc	edx
	cmp	dx,[ebx]
	jb	short ml4
mxx:	pop	ebp
	pop	esi
	push	ds
	pop	es
	next
Endcode
: ?NxStr ( --> flag true )
   SCur @ 1+ WCnt = If False Else SCur 1+! True Then True
;
: DisplayPic ( --> )
   GrfMode Off WCur @ SCur +!
   Begin
    CurrF .Sze @ Dup If
     >R WADhdl 0 CurrF .Ofs @ FSeek ?Drop
     WADhdl Here Dup>R ROver Dup Allot FRead ?Drop
     2R@ ValidateGraphData Dup If
      >R GrfMode @ IfNot Set13h CurrPal SetPal GrfMode On
      Else $A0000 BIOSselector 64000 0 AFill Then
      ROver BIOSselector R@ DrawPic
      Begin
       KbdIn KSym C@ Case
	13 Of ?NxStr Endof
	27 Of False True Endof
	 9 Of
          CurrPal Case
           DoomPal Of HticPal Endof
           HticPal Of HexnPal Endof
           HexnPal Of DoomPal Endof
          Endcase To CurrPal
          CurrPal SetPal False
	 Endof
        Set 'V $76 Of R> Dup DoConv2VGA >R ?NxStr Endof
        DropFalse
       Endcase
      Until RDrop
     Then RDrop R> Negate Allot
    Then
    WDat SCur @ [] To CurrF
   0= Until
   GrfMode @ If SetText Then
   SCur @ WCur @ - SMax < IfNot
    SCur @ SMax 1- - WCnt 20 - Min 0 Max WCur !
   Then WCur @ SCur -! DrawViewerScr
;
: ChangeFName ( --> )
   8 Here ! CurrF .Nme 2@ Here 1+ 2!
   Here 1+ 8 0 Do Dup C@ IfNot $20 Over C! Then 1+ Loop Drop
   2 SCur @ 2+ SXY True CursorSwitch 8 1 1 Here 0 Catch False CursorSwitch
   2 < If
    Here 8 + 8 0 Do Dup C@ Bl = If 0 Over C! Then 1- Loop Drop
    Here 1+ 2@ CurrF .Nme 2!
   Then
;
: CheckSndData ( --> flag )
   WADhdl 0 CurrF .Ofs @ FSeek ?Drop WADhdl Here 2 FRead ?Drop
   Here W@ 3 = Dup IfNot Drop
    $8C 24 23 " Warning: it seems not to be a sound! Continue? Y/N" WriteCXY
    Begin
     KbdIn
     KSym C@ Case
      Set 'Y $79 13 Of True True Endof
      Set 'N $6E 27 Of False True Endof
      DropFalse
     Endcase
    Until
    1 23 80 23 $07 Clr
   Then
;
: MkWAVhdr ( size --> addr )
   Here >R [ " RIFF" 1+ @ ]L , Dup $1C + , [ " WAVEfmt " 1+ 2@ ] 2Literal 2,
   $10 , $10001 , Samp @ Dup 2, $80001 , [ " data" 1+ @ ]L , , R>
;
: MkVOChdr ( size --> addr )
   Here >R A" Creative Voice File\26;" A, -1 Allot $10A001A , $1129 W, 1 C,
   2+ , -1 Allot 256 2000000 Samp @ / 1+ 2/ - W, R>
;
: SaveSnd ( mode --> )
   >R CurrF .Sze @ If
    CheckSndData If
     Samp 0! WADhdl Samp 2 FRead ?Drop
     R@ CreateTypedFile IfNot RDrop Exit Then 0 SP@ WADhdl Swap 4 FRead ?Drop
     Tuck R@ 1 = If MkWAVhdr Else MkVOChdr Then 2Dup Here Over- FWrite ?Drop
     Here - Allot Over WADhdl Here Rot FRead ?Drop Tuck Here Rot FWrite ?Drop
     R@ 1 <> If Here 0! Dup Here 1 FWrite ?Drop Then
     FClose Drop
    Then
   Then RDrop StrDown
;
: SaveVGA ( --> )
   CurrF .Sze @ ?Dup If
    >R WADhdl 0 CurrF .Ofs @ FSeek ?Drop
    WADhdl Here Dup>R ROver Dup Allot FRead ?Drop
    2R@ ValidateGraphData ?Dup IfNot
     $8C 15 23 " Error: it seems not to be a picture! Press a key..." WriteCXY
     KbdIn
     1 23 80 23 $07 Clr
    Else DoConv2VGA Then
    RDrop R> Negate Allot
   Then StrDown
;
: SaveRaw ( --> )
   CurrF .Sze @ ?Dup If
    WADhdl 0 CurrF .Ofs @ FSeek ?Drop
    CurrF .Nme 2@ Here 2! Here 8+ 0! Here $20 FCreate If
     Over WADhdl Here Rot FRead ?Drop Tuck Here Rot FWrite ?Drop FClose
    Then Drop
   Then StrDown
;
: ExitViewer ( --> )
   True CursorSwitch WReset WADhdl FClose Drop Bye
;
: ReadWADdir ( --> )
   ParseCommandLine Bl Word Dup Here S!
   Dup 1 Over '\ Swap Scan Del >Upper " DARKWAR.WAD" SCmp 0= If
    TriadPal To CurrPal ['] ValidateGraphData_Triad To ValidateGraphData
   Then
   Here >ASCIIZ 0 FOpen IfNot
    ." WAD file not found!" cr Bye
   Then To WADhdl
   WADhdl 2 0 FSeek Drop
   WADhdl 0 8 FSeek ?Drop WADhdl L1 4 FRead ?Drop WADhdl 0 L1 @ FSeek ?Drop
   Here To WDat 16 Allot WADhdl WDat 16 FRead ?Drop
   L1 @ WDat .Ofs @ < If Drop WDat .Ofs @ Then L1 @ - >R
   WADhdl WDat 16 + R@ 16 - Dup Allot FRead ?Drop
   R> 4 RShift To WCnt
;
: WADSound ( --> )
   DoomPal To CurrPal
   ReadWADdir DrawViewerScr
   0 Begin
    WDat WCur @ SCur @ + [] To CurrF
    IfNot $0C 8 23 CurrF .Ofs @ DStr WriteCXY Then
    KbdIn 0
    KSym C@ Case
     13 Of ShowDirItemAddr Endof
     Set 'D $64 Of ShowFDump Endof
     Set 'G $67 Of DisplayPic Endof
     Set 'N $6E Of ChangeFName Endof
     Set 'W $77 Of 1 SaveSnd Endof
     Set 'V $76 Of 2 SaveSnd Endof
     Set 'A $61 Of SaveVGA Endof
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
Build .\wadvw.exe
