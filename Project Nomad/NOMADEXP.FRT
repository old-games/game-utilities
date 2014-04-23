Use StrLib
0 Value FHdl
0 Value Mde
0 Value FDir
0 Value Src
0 Value Dst
0 Value WrkD
Variable FNm FNm 0!
Create Mask 128 Allot Mask 128 0 Fill
: .Typ@ C@ ;
: .Flg@ 1+ C@ ;
: .UnpLen@ 2+ @ ;
: .PakLen@ 6 + @ ;
: .FNme 10 + ;
: .FOfs@ 24 + @ ;
28 Constant DirISz
: ParmErr ( --> )
   ." Usage: NOMADEXP command resourcefile [filemask]" cr
   ." Commands are: l - list packed files in resource," cr
   ."               e - expand files from resource." cr
   Bye
;
Code UnpackData ;( srcaddr bufaddr imgsize --> )
	pop	edx
	pop	edi
	xchg	[esp],esi
	push	ebp
	mov	ebp,edi
	mov	ax,2020h
	mov	ecx,7F7h
	rep	stosw
	add	edx,edi
	push	edx
m1:	lodsb
	mov	bl,al
	mov	bh,1
ml:	cmp	edi,[esp]
	jae	short mq
	shr	bx,1
	jz	short m1
	jnc	short m2
	movsb
	jmp	short ml
m2:	lodsw
	movzx	ecx,ah
	shr	ecx,4
	add	ecx,3
	and	eax,0FFFh
	mov	edx,edi
	sub	edx,ebp
	and	edx,0FFFFF000h
	add	eax,edx
	add	eax,ebp
	cmp	eax,edi
	jb	short m3
	sub	eax,1000h
m3:	xchg	eax,esi
	rep	movsb
	xchg	eax,esi
	jmp	short ml
mq:	pop	edx
	pop	ebp
	pop	esi
	next
Endcode
: MAIN ( --> )
   ." PROJECT NOMAD resource unpacker" cr
   ." (C) 1995,2000 by WhiteJaguar" cr cr
   ParseCommandLine
   Bl Word Dup C@ 1 = If 1+ C@ Else DropFalse Then
   Case
    Set 'L [Char] l Of 1 Endof
    Set 'E [Char] e Of 2 Endof
    Drop ParmErr
   Endcase To Mde
   Bl Word >ASCIIZ 0 FOpen IfNot ParmErr Then To FHdl
   FHdl FNm 2 FRead ?Drop
   FNm @ IfNot ." Not a resource" cr FHdl FClose Drop Bye Then
   Here To FDir FHdl FDir FNm @ DirISz * Dup Allot Align FRead ?Drop
   Bl Word Dup C@ IfNot Drop " *.*" Then >Upper Mask S!
   Mde 1 = If
    ParseCommandLine Bl Word Drop Bl Word ." File " Print ': Emit cr
    ."      Name     Original  Packed" cr cr
    0 0 0 FNm @ DirISz * FDir + FDir Do
     I .FNme ASCIIZ> >Upper Dup Mask Match If
      Space Dup Bl 12 ExtChar Print ."   "
      I .UnpLen@ 6 .R ."   " I .PakLen@ 6 .R cr
      I .UnpLen@ + Rot 1+ Rot I .PakLen@ + Rot
     Else Drop Then
    DirISz +Loop
    ." ------------------------------" cr
    . ." original, " . ." packed bytes in " . ." files" cr
   Then
   Mde 2 = If
    Here To Src
    0 FNm @ DirISz * FDir + FDir Do
     I .FNme ASCIIZ> >Upper Dup Mask Match If
      ." Unpacking " Dup Bl 12 ExtChar Print
      I .PakLen@ Allot Align
      FHdl 0 I .FOfs@ I .Typ@ 1 = If 4+ Then FSeek ?Drop
      FHdl Src I .PakLen@ FRead ?Drop
      I .Flg@ 1 = If
       Src Here Dup $FEE + To Dst I .UnpLen@ Dup $FEE + Allot UnpackData
      Else Src To Dst Then
      I .FNme >ASCIIZ $20 FCreate If
       Dup Dst I .UnpLen@ FWrite ?Drop FClose Drop
      Then
      ."  Ok" cr 1+
      Src Here - Allot
     Else Drop Then
    DirISz +Loop
    cr . ." files,Ok" cr
   Then
   FHdl FClose Drop
;
NoErrors NoTraps 1 MBytes Dup MinMem ! MaxMem !
Build .\nomadexp.exe
