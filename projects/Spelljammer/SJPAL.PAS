uses
 Dos;
type
 tpal=array[0..$FF,1..3] of byte;
var
 f:file;
 pal0,pal1:tpal;
 mpl:record
  c0,c1:byte;
  pal:tpal;
  end;
 sr:SearchRec;
 i,j,k:integer;
 s:string;
begin
 Assign(f,ParamStr(1));
 Reset(f,1);
 Blockread(f,pal0,768);
 Close(f);
 s:=ParamStr(2);
 if (s<>'') and (s[byte(s[0])]<>'\') then s:=s+'\';
 FindFirst(s+'*.mpl',Archive,sr);
 while DosError=0 do
  begin
  Assign(f,s+sr.Name);
  Reset(f,1);
  Blockread(f,mpl,770,k);
  Close(f);
  pal1:=pal0;
  for i:=mpl.c0 to mpl.c1 do
   pal1[i]:=mpl.pal[i-mpl.c0];
  Dec(byte(sr.Name[0]),3);
  Assign(f,sr.Name+'pal');
  Rewrite(f,1);
  Blockwrite(f,pal1,768);
  Close(f);
  FindNext(sr);
  end;
end.
