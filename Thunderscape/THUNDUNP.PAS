uses
 Platform,HexOut;
type
 car=array[1..20] of char;
 hrt=record
  fofs,fsz:longint;
  case integer of
  0:(nof:longint;);
  1:(nme:^car);
  end;
 wbf=array[0..$FFEF] of byte;
 hra=array[0..2500] of hrt;
const
 flg:byte=0;
var
 f,g:file;
 i,j,k,cnt:integer;
 hsz,fsz:longint;
 buf:array[0..$7FFF] of byte;
 wp:^wbf;
 hp:^hra absolute wp;
 ww:array[1..2] of word absolute wp;
 sn:string[12];
function Name(idx:integer):string;
 var
  i:integer;
 begin
  with hp^[idx] do
   begin
   i:=Pos(#0,nme^);
   Name:=Copy(nme^,1,i-1);
   end;
 end;
function Fnm(s:string):string;
 var
  ss:string[12];
 begin
  ss:=s;
  if ss[0]>#8 then Insert('.',ss,9);
  Fnm:=ss;
 end;
begin
 i:=2;
 sn:=ParamStr(1);
 if sn='' then Exit;
 if sn='l' then flg:=0
 else if sn='e' then flg:=1
 else i:=1;
 Assign(f,'thunder.dat');
 sn:=ParamStr(i);
 if sn='' then sn:='*';
 Reset(f,1);
 fsz:=FileSize(f);
 Blockread(f,cnt,2);
 Blockread(f,hsz,4);
 Seek(f,hsz);
 hsz:=fsz-hsz;
 New(wp);
 Blockread(f,wp^,hsz);
 for i:=0 to cnt-1 do
  with hp^[i] do
   nme:=Ptr(ww[2],ww[1]+nof);
 if flg=0 then begin
  for i:=0 to cnt-1 do
   if Match(Name(i),sn) then
    Writeln('File ',Name(i):8,' at offset ',DStr(hp^[i].fofs),', size ',
    hp^[i].fsz:6,' bytes');
  end
 else begin
  for i:=0 to cnt-1 do
   with hp^[i] do
    if (Match(Name(i),sn)) and (fsz<>0) and (fofs<>0) then begin
     Write('Extracting ',Name(i));
     Seek(f,fofs);
     Assign(g,Fnm(Name(i)));
     Rewrite(g,1);
     j:=fsz div $8000;
     for k:=1 to j do
      begin
      Blockread(f,buf,$8000);
      Blockwrite(g,buf,$8000);
      end;
     j:=fsz mod $8000;
     Blockread(f,buf,j);
     Blockwrite(g,buf,j);
     Close(g);
     Writeln(' - done!');
     end;
  end;
 Close(f);
end.