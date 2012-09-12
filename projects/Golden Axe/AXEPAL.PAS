type
 c16=array[0..15,1..3] of byte;
 pr=record
  base:byte;
  cols:c16;
  end;
const
 p16:c16=(($00,$00,$00),($00,$00,$2A),($00,$2A,$00),($00,$2A,$2A),
          ($2A,$00,$00),($2A,$00,$2A),($2A,$15,$00),($2A,$2A,$2A),
          ($15,$15,$15),($15,$15,$3F),($15,$3F,$15),($15,$3F,$3F),
          ($3F,$15,$15),($3F,$15,$3F),($3F,$3F,$15),($3F,$3F,$3F));
var
 f:file;
 pa:array[1..65] of pr;
 blks:array[1..16,1..15] of byte;
 blkn:array[1..15] of byte;
 pal:array[0..15] of c16;
 i,j,k:integer;
 s:string;
begin
 Assign(f,'pal.dat');
 Reset(f,1);
 Blockread(f,pa,65*$31);
 Close(f);
 for i:=1 to 15 do
  blkn[i]:=0;
 for i:=1 to 65 do
  begin
  j:=pa[i].base shr 4;
  Inc(blkn[j]);
  blks[blkn[j],j]:=Lo(i);
  end;
 for i:=1 to 15 do
  begin
  j:=blkn[i];
  for k:=j+1 to 16 do
   blks[k,i]:=blks[j,i];
  end;
 pal[0]:=p16;
 for i:=1 to 16 do
  begin
  for j:=1 to 15 do
   pal[j]:=pa[blks[i,j]].cols;
  Str(i,s);
  Assign(f,'axe'+s+'.pal');
  Rewrite(f,1);
  Blockwrite(f,pal,768);
  Close(f);
  end;
end.
