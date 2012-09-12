type
 dirr=record
  chk,ofsw:word;
  ofsb:byte;
  flen:word;
  t1:byte;
  end;
 ba=array[0..65534] of byte;
 ww=array[1..2] of word;
var
 f,g:file;
 i,j:integer;
 dnm,w1:word;
 dar:array[0..$4FF] of dirr;
 dcde:array[0..$27FF] of byte absolute dar;
 wp:^ba;
 qp:^ww absolute wp;
 wa:ww absolute wp;
 b:byte;
 s:string;
begin
 Assign(f,ParamStr(1));
 Reset(f,1);
 Blockread(f,dnm,2);
 if dnm>$500 then begin
  Writeln('Too many files!');
  Halt(1);
  end;
 Writeln(dnm,' files here');
 Blockread(f,dar,8*dnm);
 b:=$AC;
 for i:=0 to 8*dnm-1 do
  begin
  dcde[i]:=((dcde[i] shr 6) or ((dcde[i] and $3F) shl 2))+b;
  b:=b+$67;
  end;
 wp:=HeapPtr;
 if wa[1]<>0 then Inc(wa[2]);
 wa[1]:=0;
 for i:=0 to dnm-1 do
  begin
  Seek(f,(longint(dar[i].ofsb) shl 16)+dar[i].ofsw);
  Blockread(f,wp^,dar[i].flen);
  for w1:=0 to dar[i].flen-1 do
   wp^[w1]:=wp^[w1] xor $35;
  Str(i:4,s);
  for j:=1 to 4 do
   if s[j]=' ' then s[j]:='0';
  s:='file'+s;
  if (char(wp^[9])='V') and (char(wp^[10])='o') then s:=s+'.voc'
  else if (qp^[2]-2=qp^[1] shl 2) then s:=s+'.vga';
  Assign(g,s);
  Rewrite(g,1);
  Blockwrite(g,wp^,dar[i].flen);
  Close(g);
  Writeln('” ©« #',i);
  end;
 Close(f);
end.