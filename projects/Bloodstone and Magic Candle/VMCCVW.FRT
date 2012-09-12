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
Create WrkPal 0 768 LoadData .\bld.pal
Code DispData ;( @list @base BIOSsel --> )
	pop	es
	pop	ebx
	pop	ecx
	push	esi
	mov	edi,0A0000h
mlp:	mov	esi,[ecx]
	test	esi,esi
	jnz	short mnq
	pop	esi
	push	ds
	pop	es
	next
mnq:	add	esi,ebx
	mov	edx,16
ml1:	movsd
	movsd
	movsd
	movsd
	add	edi,320-16
	dec	edx
	jnz	short ml1
	sub	edi,13F0h
	mov	eax,edi
	and	eax,3FFh
	cmp	eax,320
	jne	short m1
	add	edi,12C0h
m1:	add	ecx,4
	jmp	short mlp
Endcode
: ?BlastOff ( flag --> )
   ?Exit SetText s. Bye
;
: KbDlg ( --> 4 n1 false | n2 true )
   Begin
    KbdIn
    KSym C@ 27 <> ?BlastOff
    KSym W@ Case
     $4800 Of 8 -2 False True Endof
     $5000 Of 8 2 False True Endof
     $4900 Of -8 True True Endof
     $5100 Of 8 True True Endof
    DropFalse Endcase
   Until
;    
0 Value CurBlk
: MAIN ( --> )
   ." Bloodstone V.MCC file viewer" cr
   ." Copyright (C) 2000 by White Jaguar" cr cr
   A" V.MCC" 0 FOpen IfNot ." V.MCC not found!" cr Bye Then
   Dup 2 0 FSeek Drop To Datasz Dup 0 0 FSeek ?Drop
   Dup Here Dup To Dat Datasz Dup Allot FRead ?Drop FClose Drop
   Set13h WrkPal SetPal
   Dat Begin
    Dup @ ?Dup ?BlastOff Dat + To CurBlk
    0 CurBlk W@ 1+ 2* CurBlk + CurBlk 2+ ?Do
     Drop -8 I CurBlk = ?Leave Drop
     I W@ CurBlk + 1+ CurBlk BIOSselector DispData
     KbDlg
     $A0000 BIOSselector 64000 0 AFill
     ?Leave
    +Loop
    + Dat UMax
   Again
;
NoErrors 1 MBytes MaxMem !
Build .\vmccvw.exe
