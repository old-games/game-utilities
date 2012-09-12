var
 f,g:file;
 b:array[1..768] of byte;
 i,j:integer;
 l:longint;
 s,s1:string[8];
begin
 Assign(f,ParamStr(1));
 s1:=ParamStr(2);
 Reset(f,1);
 l:=FileSize(f)-1024;
 Seek(f,1024);
 j:=0;
 while l>0 do
  begin
  Str(j:2,s);
  if s[1]=' ' then s[1]:='0';
  Inc(j);
  Dec(l,768);
  Assign(g,s1+s+'.pal');
  Rewrite(g,1);
  Blockread(f,b,768);
  for i:=1 to 768 do
   b[i]:=b[i] shr 2;
  Blockwrite(g,b,768);
  Close(g);
  end;
 Close(f);
end.
