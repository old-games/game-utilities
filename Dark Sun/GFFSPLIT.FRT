0 Value Fh
0 Value Pal
0 Value Fil
0 Value Fsz
0 Value Dir
0 Value DirEnd
0 Value _GFFI
0 Value Tag
0 Value BCnt
0 Value BlkTable
\ ofs size tag IDnum
" GFFI" 1+ @ Constant GFFI
18 Constant TCnt
Create Dirs
0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
Create Tags
" BMP " 1+ @ , " WALL" 1+ @ , " PORT" 1+ @ , " ICON" 1+ @ , " CMAT" 1+ @ ,
" TILE" 1+ @ , " CBMP" 1+ @ , " BMA " 1+ @ , " PAL " 1+ @ , " CPAL" 1+ @ ,
" BVOC" 1+ @ , " PSEQ" 1+ @ , " CSEQ" 1+ @ , " LSEQ" 1+ @ , " GSEQ" 1+ @ ,
" FSEQ" 1+ @ , " FONT" 1+ @ , " ACF " 1+ @ ,
7 Cells Constant #BMA
0 Cells Constant #BMP
17 Cells Constant #ACF
8 Cells Constant #PAL
Create Str4 5 C, 0 , 0 C,
Create Strr 20 Allot
: S+! ( str1 str2 --> )
   2Dup C@ Swap C@ + Dup 255 > If Drop 255 Then 2Dup 2>R
   Over C@ - >R Dup C@ + 1+ >R 1+ R> R> CMove R> R> C!
;
: MkFile ( num type --> handle true | false )     
   Str4 Strr 5 CMove '\ Strr 5 + C!
   Swap 0 8 ZStr Strr S+!
   2 RShift Case
    Range 0 7 Of " .BMP\0;" Endof
    Set 8 9 Of " .PAL\0;" Endof
    10 Of " .VOC\0;" Endof
    Range 11 15 Of " .XMI\0;" Endof
    16 Of " .FNT\0;" Endof
    17 Of " .ACF\0;" Endof
   Endcase Strr S+!
   Strr 1+ $20 FCreate Dup If ." Writing " Else ." Can't create " Then
   Strr Print cr
;
: MAIN ( --> )
   Here To Pal 768 Allot
   ParseCommandLine
   Bl Word >ASCIIZ 0 FOpen IfNot Bye Then To Fh
   Fh 2 0 FSeek Drop To Fsz Fh 0 0 FSeek ?Drop
   Here To Fil Fsz Allot Fh Fil Fsz FRead ?Drop Fh FClose Drop
   Fil $C + @ Fil + To Dir
   Here To BlkTable
   Dir $A + Dir 8 + W@ 0 Do
    Dup @ To Tag
    Tag GFFI = If Dup 8 + To _GFFI Then
    4+ Dup @ $80000000 And If
     8 + Dup @ 12 * _GFFI + 4+ @ Fil +
     Here >R
     Dup 4+ Swap @ 0 Do
      Dup @ , 4+ Dup @ , 4+ Tag , 0 ,
     Loop Drop
     4+ Dup 4+ R> Rot @ 0 Do
      Swap Dup @ Swap 4+ Dup @ Swap 4+ >R
      0 Do
       2Dup Swap 12 + ! 1+ Swap 16 + Swap
      Loop Drop R> Swap
     Loop Drop
    Else
     Dup 4+ Swap @ 0 Do
      Dup @ >R 4+ Dup @ , 4+ Dup @ , 4+ Tag , R> ,
     Loop
    Then
   Loop Drop
   Here BlkTable - 16 / Dup To BCnt . ." blocks in file" cr
   BCnt 1 > If BlkTable BCnt 16 [Sort<] Here 16 Allot Sort -16 Allot Then
   BlkTable BCnt 0 Do
    0 Over 8 + @
    TCnt 4* 0 Do Dup Tags I + @ = If 2Drop -1 I Leave Then 4 +Loop
    Swap If
     >R Dup 8 + @ Str4 1+ !
     Dirs R@ + Dup @ IfNot Str4 1+ MakeDir Drop -1 Swap ! Else Drop Then
     R@ Case
      #BMA Of
	RDrop Dup 12 + @ 1000 * Over 2@ Fil + Tuck + Swap Do
	 1+ Dup #BMP MkFile If
	  Dup I Dup @ FWrite ?Drop FClose Drop
	 Then
	I @ +Loop Drop
       Endof
      #ACF Of
        RDrop Dup 12 + @ 1000 * >R
        Pal 768 0 Fill
        Dup @ Fil + Begin
         Dup 1+ C@ While
         Dup 1+ C@ Case
          $14 Of
            Dup 3 + C@ 3 * Pal + >R
            Dup 2+ C@ R@ C!
            Dup 5 + C@ R@ 1+ C!
            Dup 4+ C@ R> 2+ C!
           Endof
          $15 Of
            R> 1+ Dup>R #PAL MkFile If
             Dup Pal 768 FWrite ?Drop FClose Drop
            Then
           Endof
         Drop Endcase
         Dup C@ +
        Repeat Drop RDrop
       Endof
      Drop
        Dup 12 + @ R> MkFile If
         2Dup Over @ Fil + Rot 4+ @ FWrite ?Drop FClose Drop
        Then
     Endcase
    Else Drop Then 16 +
   Loop Drop
;
NoErrors NoTraps
Build .\gffsplit.exe
