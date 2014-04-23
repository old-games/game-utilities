0 Value Hdr
0 Value Dat
0 Value Datasz
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
Create WrkPal 0 768 LoadData sk00.pal
Code DcmData ;( addr len target --> size )
	pop	edi
	pop	ebx
	xchg	[esp],esi
	mov	edx,edi
	add	ebx,esi
	xor	eax,eax
mlp:	cmp	esi,ebx
	jae	short mqq
	lodsb
	test	al,al
	jz	short m1
	stosb
	jmp	short mlp
m1:	lodsb
	mov	ecx,eax
	mov	al,0
	rep	stosb
	jmp	short mlp
mqq:	sub	edi,edx
	pop	esi
	push	edi
	next
Endcode
Code DispData ;( addr xsz ysz dx dy BIOSsel --> )
	pop	es
	pop	edi
	lea	edi,[edi+4*edi]
	shl	edi,6
	pop	eax
	lea	edi,[edi+eax+0A0000h]
	pop	ebx
	pop	edx
	xchg	[esp],esi
ml2:	mov	ecx,edx
ml1:	lodsb
	test	al,al
	jz	short m1
	mov	es:[edi],al
m1:	inc	edi
	loop	ml1
	add	edi,320
	sub	edi,edx
	dec	ebx
	jnz	short ml2
	push	ds
	pop	es
	pop	esi
	next
Endcode
: ?DoErr ( flag --> )
   ?Exit
   ." Usage: DKLEGVW datafile header [palette]" cr
   ." Internal keys: ESC - immediate exit," cr
   ."                other - show next." cr
   ." Datafiles are files with extension .DAC, .DAT or .BDT, and headers are" cr
   ." files with the same name and extension .DMC, .DMP or .BDM accordingly." cr
   Bye
;
: ?BlastOff ( flag --> )
   ?Exit SetText Bye
;
: MAIN ( --> )
   ." Dark Legions graphics viewer" cr
   ." Copyright (C) 1999 by White Jaguar" cr cr
   ParseCommandLine
   Bl Word >Upper Dup C@ 4 - Dup 0> If
    Over + 1+ @ Case
     [ " .DAC" 1+ @ ] Literal Of 1 Endof
     [ " .DAT" 1+ @ ] Literal Of 2 Endof
     [ " .BDT" 1+ @ ] Literal Of 3 Endof
     Drop 0
    Endcase
   Else Drop 0 Then
   Dup>R ?DoErr
   >ASCIIZ 0 FOpen ?DoErr
   Dup 2 0 FSeek Drop To Datasz Dup 0 0 FSeek ?Drop
   Dup Here Dup To Dat Datasz Dup Allot FRead ?Drop FClose Drop
   Bl Word >Upper Dup C@ 4- Dup 0> If
    Over + 1+ @ R@ Case
     1 Of [ " .DMC" 1+ @ ] Literal Endof
     2 Of [ " .DMP" 1+ @ ] Literal Endof
     3 Of [ " .BDM" 1+ @ ] Literal Endof
    Endcase =
   Else DropFalse Then ?DoErr
   >ASCIIZ 0 FOpen ?DoErr
   Dup Here Dup To Hdr R@ 3 = If 1928 Else 1708 Then Dup Allot FRead ?Drop
   FClose Drop
   Bl Word Dup C@ If
    >ASCIIZ 0 FOpen ?DoErr
    Dup WrkPal 768 FRead ?Drop FClose Drop
   Else Drop Then
   R@ 1 = IfNot Dat Datasz Here Dup To Dat DcmData Allot Then
   Set13h WrkPal SetPal
   Hdr 8+
   Begin
    R@ Case
     1 Of
       Dup 4+ W@ ?BlastOff
       Dup>R @ Dat + R@ 10 + @ ?Dup IfNot Datasz Then R@ @ - Here Dup>R
       DcmData Drop
       R> R@ 4+ C@ R@ 5 + C@ Hdr @ R@ 8+ C@ - Hdr 4+ @ R@ 9 + C@ - BIOSselector
       DispData
       R> 10 +
      Endof
     2 Of
       Dup 4+ W@ ?BlastOff
       Dup>R @ Dat + R@ 4+ C@ R@ 5 + C@ Hdr @ R@ 8+ C@ - Hdr 4+ @ R@ 9 + C@ -
       BIOSselector DispData
       R> 10 +
      Endof
     3 Of
       Dup 4+ @ ?BlastOff
       Dup>R @ Dat + R@ 4+ W@ R@ 6 + W@ R@ 8+ W@ R@ 10 + W@
       BIOSselector DispData
       R> 12 +
      Endof
    Endcase
    KbdIn
    KSym C@ 27 <> ?BlastOff
    $A0000 BIOSselector 64000 0 AFill
   Again
;
NoErrors 1 MBytes MaxMem !
Build .\dklegvw.exe
