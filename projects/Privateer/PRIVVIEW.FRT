0 Value Dat
0 Value Datasz
0 Value Tabl
0 Value TEnd
0 Value SEnd
False Value Pfg
0 Value FHdl
0 Value Fsz
2Variable HdrV
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
Create WrkPal 0 768 LoadData .\space.pal
Code BSwap ;( n1 --> n2 )
	pop	eax
	xchg	al,ah
	rol	eax,16
	xchg	al,ah
	push	eax
	next
Endcode
Code ShiftPal ;( addr --> )
	xchg	[esp],esi
	mov	edi,esi
	mov	ecx,0C0h	;768/4
m1:	lodsd
	shr	eax,2
	and	eax,3F3F3F3Fh
	stosd
	loop	m1
	pop	esi
	next
Endcode	
: ]L ( n --> ) ] [Compile] Literal ;
: ?DoErr ( flag --> )
   ?Exit
   ." Usage: PRIVVIEW file [palette] [/P]" cr
   ." Internal keys: ESC - immediate exit," cr
   ."                SPACE - repaint screen & show next," cr
   ."                other - show next w/o repainting." cr
   ." Graphics files are files with extensions .IFF, .PAK and .SHP." cr
   Bye
;
: ?BlastOff ( flag --> )
   ?Exit
   FHdl ?Dup If FClose Drop Then SetText Bye
;
: If/P ( string --> flag )
   >Upper @ $FFFFFF And [ " /P" @ $FFFFFF And ]L = Dup To Pfg
;
Create PnmA A" ppal0000.pal" A,
Create PnmB 13 Allot
PnmB 0!
0 Value PIdx
: StorePal ( addr --> )
   PnmB @ If PnmB Else PIdx 0 4 ZStr 1+ @ PnmA 4+ ! 1+To PIdx Then $20 FCreate
   If Tuck Swap 768 FWrite ?Drop FClose Then Drop
;
Code DrawPge ;( @page BIOSsel --> )
	pop	es
	xchg	esi,[esp]
	call	tstpnt
	lea	edi,[eax+ebx+0A0000h]
mnx:	add	esi,8
	push	edi
mlp:	mov	edi,[esp]
	lodsw
	movzx	ecx,ax
	jecxz	short mx
	lodsw
	movsx	eax,ax
	add	edi,eax
	lodsw
	movsx	eax,ax
	imul	eax,eax,320
	add	edi,eax
	shr	ecx,1
	jc	short mcomp
	rep	movsb	
	jmp	short mlp
mcomp:	lea	ebx,[edi+ecx]
ml1:	cmp	edi,ebx
	jae	short mlp
	lodsb
	movzx	ecx,al
	shr	ecx,1
	jc	short mfil
	rep	movsb
	jmp	short ml1
mfil:	lodsb
	rep	stosb
	jmp	short ml1
mx:	pop	eax
	push	ds
	pop	es
	pop	esi
	next
tstpnt:	cmp	word ptr [esi],160
	jge	short tst00
	cmp	word ptr [esi+2],160
	jg	short tst00
	cmp	word ptr [esi+4],100
	jg	short tst00
	cmp	word ptr [esi+6],100
	jge	short tst00
	mov	eax,32000
	mov	ebx,160
	ret
tst00:	cmp	word ptr [esi+2],0
	jg	short tst0mm0
	cmp	word ptr [esi+4],0
	jg	short tst0mm0
	xor	eax,eax
	xor	ebx,ebx
	ret
tst0mm0:xor	eax,eax
	cmp	word ptr [esi+2],0
	jle	short mt1
	cmp	word ptr [esi],160
	jge	short tstex
	mov	eax,32000
mt1:	xor	ebx,ebx
	cmp	word ptr [esi+4],0
	jle	short mt2
	cmp	word ptr [esi+6],100
	jge	short tstex
	mov	ebx,160
mt2:	ret
tstex:	mov	ax,199
	sub	ax,[esi+4]
	sub	ax,[esi+6]
	jl	short mer
	shr	ax,1
	add	ax,[esi+4]
	movzx	eax,ax
	imul	eax,eax,320
	mov	bx,319
	sub	bx,[esi]
	sub	bx,[esi+2]
	jl	short mer
	shr	bx,1
	add	bx,[esi+2]
	movzx	ebx,bx
	ret
mer:	int	19h
Endcode
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
0 Value Pict
: DispPic ( addr --> )
   Dup To Pict 4+ Dup @ $FFFFFF And Pict + >R
   Begin Dup R@ < While
    Dup @ 24 RShift Case
     0 Of Endof
     $C1 Of ClrScr Endof
    Drop Endcase
    Dup @ $FFFFFF And Pict + BIOSselector DrawPge
    KbdIn KSym C@ 27 <> ?BlastOff
    KSym C@ Bl = If ClrScr Then 4+
   Repeat Drop RDrop
   ClrScr
;
: VwPic ( mode R: sze addr-4 --> R: sze addr-4 )
   R> Swap Case
    0 Of
      R@ 25 < IfNot
       ROver 4+ Dup @ 1+ -2 And R@ < If
	Dup @ + 8+ Dup 2@ [ " PAL CMAP" 1+ 2@ ] 2Literal D= If
	 12 + Dup ShiftPal
	 Dup Pfg If StorePal
	 Else SetPal ROver 4+ DispPic WrkPal SetPal Then
	Then
       Else
	Pfg IfNot ROver 4+ DispPic Then
       Then Drop
      Then
     Endof
    1 Of Pfg IfNot ROver 4+ DispPic Then Endof
    2 Of
      ROver 5 + @ 2+ -2 And R@ = If 
       Pfg IfNot ROver 5 + DispPic Then
      Then
     Endof
    3 Of
      Pfg IfNot
       ROver 4+ Dup R@ + Swap
       Begin 2Dup 1+ > While
        Dup DispPic Dup @ +
       Repeat 2Drop
      Then   
     Endof
   Drop Endcase
   >R
;
: StartGraph ( --> )
   Set13h WrkPal SetPal
;
: DoIFF ( hdl --> )
   Dup Here Dup To Dat Datasz Dup Allot FRead ?Drop FClose Drop
   Dat +To Datasz
   StartGraph
   Dat Begin Dup Datasz < While
    Tabl If
     Dup Tabl @ Dat + = If 4+ 4 +To Tabl Tabl TEnd = If 0 To Tabl Then Then
    Then
    Dup 4+ C@ 0= If Dup 4+ >R @ 0 Else Dup 8+ >R 2@ Then
    R@ @ BSwap 1+ -2 And >R
    Swap Case
     [ " TABL" 1+ @ ]L Of ROver 4+ Dup To Tabl R@ + To TEnd Endof
     [ " FORM" 1+ @ ]L Of RDrop 0 >R Endof
     [ " SHAP" 1+ @ ]L Of
       Dup [ " CUBG" 1+ @ ]L = If
        ROver 4+ 2@ PnmB 2! PnmB 8+ 0!
        PnmB ASCIIZ> Dup C@ + 1+ [ " .pal" 1+ @ ]L Swap ! 4 PnmB +!
        PnmB >ASCIIZ
       Else Dup [ " SPRT" 1+ @ ]L = IfNot 0 VwPic Then Then
      Endof
     [ " VSHP" 1+ @ ]L Of 3 VwPic Endof
     [ " TARG" 1+ @ ]L Of Dup [ " MFDS" 1+ @ ]L = If 1 VwPic Then Endof
     [ " GUNS" 1+ @ ]L Of Dup 0= If 1 VwPic Then Endof
     Set
     [ " GRID" 1+ @ ]L
     [ " WEAP" 1+ @ ]L
     [ " BURN" 1+ @ ]L
     [ " MOUS" 1+ @ ]L
     [ " QUAD" 1+ @ ]L
     [ " NAVI" 1+ @ ]L
     [ " NEXT" 1+ @ ]L Of 1 VwPic Endof
     [ " INFO" 1+ @ ]L Of
       Dup 0= Over [ " ITRN" 1+ @ ]L = Or If 2 VwPic Then
      Endof
     [ " PALT" 1+ @ ]L Of
       R@ 7 < IfNot
	Pfg If
	 ROver 4+ WrkPal Here 768 2Dup Allot >R CMove
	 Dup W@ 3 * R@ + >R 2+ Dup W@ 3 * >R 2+ 2R> CMove
	 R> StorePal -768 Allot
	Then
       Then
      Endof
     Drop
    Endcase
    Drop 2R> + 4+
   Repeat
   SetText Bye
;
: PBlastOff ( --> )
   FHdl FClose Drop SetText Bye
;
: DoPAK ( hdl hsize --> )
   Datasz To Fsz
   To Datasz Dup Here Dup To Dat Datasz Dup Allot FRead ?Drop To FHdl
   Dat +To Datasz Fsz ,
   StartGraph
   Dat Begin 4+ Dup Datasz < While
    Dup @ $FFFFFF And FHdl 0 Rot FSeek ?Drop
    Dup 4+ @ $FFFFFF And Over @ $FFFFFF And - Dup>R
    FHdl Here Dup>R Rot Dup Allot FRead ?Drop
    R@ @ ROver = If Pfg IfNot R@ DispPic Then
    Else
     R@ 2+ W@ 3 * 4+ ROver = R@ W@ 0 256 Between And If
      WrkPal Here 768 2Dup Allot >R CMove
      ROver 4+ R@ ROver W@ 3 * + ROver 2+ W@ 3 * CMove
      R> Pfg If StorePal Else SetPal Then
      -768 Allot
     Then
    Then
    R> Here - Allot RDrop
   Repeat
   PBlastOff
;
Comment:
 В файле MID1.PAK глючит 15-я картинка (выезжает за пределы видеобуфера); глюк
 не устраняется, так что, похоже, у нее просто неверный заголовок
Comment;
: DoSHP ( hdl --> )
   Dup Here Dup>R Datasz Dup Allot FRead ?Drop FClose Drop
   StartGraph
   R> DispPic
   SetText Bye
;
: MAIN ( --> )
   ." Privateer graphics viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr
   ParseCommandLine
   Bl Word >Upper Dup C@ 4 - Dup 0> If
    Over + 1+ @ Case
     [ " .IFF" 1+ @ ] Literal Of 1 Endof
     [ " .PAK" 1+ @ ] Literal Of 2 Endof
     [ " .SHP" 1+ @ ] Literal Of 3 Endof
     Drop 0
    Endcase
   Else Drop 0 Then Dup>R ?DoErr
   >ASCIIZ 0 FOpen ?DoErr
   Bl Word Dup C@ If
    Dup If/P IfNot
     >ASCIIZ 0 FOpen ?DoErr
     Dup WrkPal 768 FRead ?Drop FClose
    Then
   Then Drop
   Pfg IfNot Bl Word If/P Drop Then
   Dup 2 0 FSeek Drop To Datasz Dup 0 0 FSeek ?Drop
   R> Case
    1 Of DoIFF Endof
    2 Of
      Dup HdrV 8 FRead ?Drop Dup 0 0 FSeek ?Drop
      HdrV 4+ @ $FFFFFF And DoPAK
     Endof
    Drop DoSHP
   Endcase
;
NoErrors 1 MBytes MaxMem !
Build .\privview.exe
