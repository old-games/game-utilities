Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
0 Value Icn
0 Value StartNum
Create WrkPal 0 $300 Loaddata .\kb.pal \ Main game palette
Create ShadeTbs 0 $E00 Loaddata .\hmm2shad.bin \ Shading tables
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
Code OutPic ;( BIOSsel @file hdr_ofs --> )
	pop	ebx
	pop	edi
	pop	es
	push	esi
	mov	esi,edi
	add	esi,[edi+ebx+9]
	add	esi,6
	movzx	edx,word ptr [edi+ebx+6]
	movsx	eax,word ptr [edi+ebx+2]
	test	eax,eax
	jns	short ma1
	xor	eax,eax
ma1:	imul	eax,eax,320
	movsx	ebx,word ptr [edi+ebx]
	test	ebx,ebx
	jns	short ma2
	xor	ebx,ebx
ma2:	lea	edi,[eax+ebx+0A0000h]
	mov	ebx,edi
	xor	eax,eax
nxt:	lodsb
	cmp	al,0
	je	short nxs
	cmp	al,80h
	jb	short cpy
	je	short end
	cmp	al,0C0h
	jb	short skp
	je	short shad
fil:	sub	al,0C0h
	cmp	al,1
	ja	short m1
	lodsb
m1:	mov	ecx,eax
	lodsb
	rep	stosb
	jmp	short nxt
skp:	sub	al,80h
m3:	add	edi,eax
	jmp	short nxt
shad:	lodsb
	mov	ecx,eax
	and	al,3
	jnz	short m2
	lodsb
m2:	xchg	eax,ecx
	test	al,0C0h
	jz	short m3
	js	short sh1
mzz:	and	al,3Ch
	shl	eax,6
	add	eax,pfa ShadeTbs
	push	edx
	mov	edx,eax
	xor	eax,eax
ml:	mov	al,es:[edi]
	mov	al,[edx+eax]
	stosb
	loop	ml
	pop	edx
	jmp	short nxt
sh1:	mov	al,33h
	rep	stosb
	jmp	short nxt
cpy:	mov	ecx,eax
	rep	movsb
	jmp	short nxt
nxs:	add	ebx,320
	mov	edi,ebx
	dec	edx
	jnz	short nxt
end:	pop	esi
	push	ds
	pop	es
	next
Endcode
Code IW@ ;( addr --> n )
	pop	ebx
	movsx	eax,word ptr [ebx]
	push	eax
	next
Endcode
: ClrScr ( --> )
   $A0000 BIOSselector 64000 0 AFill
;
: BoundImg ( @file hdr_ofs --> @file hdr_ofs )
   2Dup + 2+ Dup IW@ 0 Max Over 4+ W@ + 200 > If
    0 Over W! 4+ Dup W@ 200 Min Over W! Beep
   Then Drop
;
0 Value AniDX
0 Value AniDY
0 Value AniBase
0 Value AniEnd
: MAIN ( --> )
   ." Heroes Of Might And Magic II .ICN files viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: H2ICNVW file.ICN [phase index]" cr
    ." Internal keys: ESC - immediate exit," cr
    ."                F1 - display current phase index," cr
    ."                Down/Up - next/previous phase." cr
    Bye
   Then >R
   Bl Word Val If Drop 0 Max Else 2Drop 0 Then
   R@ 2 0 FSeek Drop >R ROver 0 0 FSeek 2Drop
   Here To Icn ROver Icn R> Dup Allot FRead ?Drop R> FClose Drop
   Icn W@ 1- Min To StartNum
   SetGraph WrkPal SetPal
   StartNum >R Begin
    ClrScr
    BIOSselector Icn R@ 13 * 6 +
    Dup AniBase AniEnd Between IfNot
     2Dup + 8+ C@ If
      2Dup R@ 0 ?Do
       13 - 2Dup + 8+ C@ IfNot 13 + Leave Then
      Loop
      Dup To AniBase 2Dup + 8+ C@ 13 * + To AniEnd Drop
      Icn AniBase + Dup>R IW@ R@ 2+ IW@
      R> Dup 8+ C@ 0 Do
       13 + Dup>R 2+ IW@ Min Swap R@ IW@ Min Swap R>
      Loop Drop
      0 Min Negate To AniDY 0 Min Negate To AniDX
      Icn AniBase + Dup 8+ C@ 1+ 0 Do
       Dup Dup IW@ AniDX + Swap W! Dup 2+ Dup IW@ AniDY + Swap W!
       13 +
      Loop Drop
     Else Dup To AniBase Dup To AniEnd Then
    Then
    Dup AniBase > If >R 2Dup AniBase BoundImg OutPic R> Then
    BoundImg OutPic
    Begin
     KbdIn KSym W@ Case
      $011B Of RDrop FClose SetText Bye Endof
      $3B00 Of R@ . 13 Emit False Endof
      $4800 Of R> 1- 0 Max >R True Endof
      $5000 Of R> 1+ >R True Endof
     DropFalse Endcase
    Until
   R@ Icn W@ = Until RDrop
   SetText Bye
;
NoErrors NoTraps 2 MBytes Dup Minmem ! Maxmem !
Build .\h2icnvw.exe
