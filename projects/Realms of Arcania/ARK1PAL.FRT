$15C40 Constant DS:
: 0s ( n --> )
   3 * Dup 4 / 0 ?Do 0 , Loop 3 And 0 ?Do 0 C, Loop
;
Create Pal
0 $60 Loaddata .\townpal.dat
DS: $B2BF + $60 Loaddata .\bladem.exe
DS: $B25F + $60 Loaddata .\bladem.exe
DS: $254B + $60 Loaddata .\bladem.exe
$60 $C0 Loaddata .\townpal.dat
8 0s
DS: $B256 + 9 Loaddata .\bladem.exe
13 0s
DS: $B23E + $18 Loaddata .\bladem.exe
DS: $260B + $60 Loaddata .\bladem.exe
Pal $300 Savedata .\twnpal.pal
Pal Here - Allot
DS: $25AB + $60 Loaddata .\bladem.exe
$60 0s
DS: $7DF4 + $3C Loaddata .\bladem.exe
$6C 0s
Pal $300 Savedata .\cmbpal.pal
Pal Here - Allot
$20 0s
DS: $B2BF + $60 Loaddata .\bladem.exe
$DB77 $60 Loaddata .\gen.exe
$88 0s
DS: $B256 + 9 Loaddata .\bladem.exe
13 0s
DS: $B23E + $18 Loaddata .\bladem.exe
$20 0s
Pal $300 Savedata .\chrpal.pal
Bye
