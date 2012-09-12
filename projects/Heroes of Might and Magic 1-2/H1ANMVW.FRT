Also Assembler ' js 6 + $78 Swap C! Previous \ Это фикс для JS SHORT
0 Value Icn
0 Value StartNum
Create WrkPal 0 $300 Loaddata .\combat.pal \ Main game palette
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
Code TestPic2 ;( @file hdr_ofs --> flag )
	pop	ebx
	pop	edi
	push	esi
	mov	esi,edi
	add	esi,[edi+ebx+8]
	add	esi,6
	movzx	ecx,word ptr [edi+ebx+6]
nx0:	mov	ah,[esi]
	xor	ah,80h
nxt:	lodsb
	cmp	al,0
	je	short nxs
	cmp	al,80h
	je	short err
	cmp	ah,0FFh
	je	short m1
	cmp	ah,07Fh
	je	short m1
	xor	ah,al
	jns	short err
m1:	mov	ah,al
	jmp	short nxt
nxs:	loop	nx0
	lodsb
	cmp	al,80h
	jne	short err
	xor	eax,eax
	dec	eax
	pop	esi
	push	eax
	next
err:	xor	eax,eax
	pop	esi
	push	eax
	next
Endcode
Code OutPic1 ;( BIOSsel @file hdr_ofs --> 0 )
	pop	ebx
	pop	edi
	pop	es
	push	esi
	mov	esi,edi
	add	esi,[edi+ebx+8]
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
	sub	al,80h
	add	edi,eax
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
	xor	eax,eax
	push	eax
	next
Endcode
Code OutPic2 ;( BIOSsel @file hdr_ofs --> 0 )
	pop	ebx
	pop	edi
	pop	es
	push	esi
	mov	esi,edi
	add	esi,[edi+ebx+8]
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
	sub	al,80h
	add	edi,eax
	jmp	short nxt
cpy:	mov	ecx,eax
	mov	al,0FFh
	rep	stosb
	jmp	short nxt
nxs:	add	ebx,320
	mov	edi,ebx
	dec	edx
	jnz	short nxt
end:	pop	esi
	push	ds
	pop	es
	xor	eax,eax
	push	eax
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
: MAIN ( --> )
   ." Heroes Of Might And Magic animation files viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr cr
   ParseCommandLine Bl Word >ASCIIZ 0 FOpen IfNot
    ." Usage: H1ANMVW file [phase index]" cr
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
    BIOSselector Icn R@ 12 * 6 +
    2Dup TestPic2 >R BoundImg R> If OutPic2 Else OutPic1 Then
    ?Dup If SetText Icn - .H cr Bye Then
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
Build .\h1anmvw.exe
