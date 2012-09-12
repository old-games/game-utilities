0 Value Fh
0 Value Fsz
0 Value Fil
0 Value Dir
221 Constant Cnt
: MAIN ( --> )
   A" world.dat" 0 FOpen IfNot Bye Then To Fh
   Fh 2 0 FSeek Drop To Fsz Fh 0 0 FSeek ?Drop
   Here To Fil Fsz Allot Fh Fil Fsz FRead ?Drop Fh FClose Drop
   Here To Dir Cnt 4* Allot
   Fil $93139 + Dir Cnt 4* CMove
   Dir Cnt 4 [Sort<] Here 4 Allot Sort -4 Allot
   Dir Cnt 0 Do
    I 0 3 ZStr >ASCIIZ $20 FCreate Drop Over >R
    Dup Fil R@ @ + R@ 4+ @ R> @ - FWrite ?Drop FClose Drop
   4+ Dup @ Fsz < IfNot Leave Then
   Loop Drop
;
NoErrors NoTraps
Build .\yensplit.exe
