uses
 Platform,HexOut;
type
 hrt=record
  flag:word;
  name:array[1..14] of char;
  offs:longint;
  end;
const
 flg:byte=0;
var
 f,g:file;
 i,j,k,cnt:integer;
 hsz,fsz:longint;
 buf:array[0..$7FFF] of byte;
 hrc:array[1..1500] of hrt absolute buf;
 hdr:array[1..1500] of record
                      name:string[12];
                      offs:longint;
                      end;
 sn:string[12];
begin
 i:=2;
 sn:=ParamStr(1);
 if sn='' then Exit;
 if sn='l' then flg:=0
 else if sn='e' then flg:=1
 else i:=1;
 Assign(f,ParamStr(i));
 sn:=ParamStr(i+1);
 if sn='' then sn:='*';
 Reset(f,1);
 fsz:=FileSize(f);
 Blockread(f,cnt,2);
 hsz:=cnt*20;
 Blockread(f,buf,hsz);
 Inc(hsz,2);
 k:=1;
 for i:=1 to cnt do
  if hrc[i].flag=1 then begin
   j:=Pos(#0,hrc[i].name);
   hdr[k].name:=Copy(hrc[i].name,1,j-1);
   hdr[k].offs:=hrc[i].offs+hsz;
   Inc(k);
   end
  else if hrc[i].flag<>0 then Writeln('Fuckup!');
 hdr[k].offs:=fsz;
 cnt:=k-1;
 if flg=0 then begin
  for i:=1 to cnt do
   if Match(hdr[i].name,sn) then
    Writeln('File ',hdr[i].name:12,' at offset ',DStr(hdr[i].offs),', size ',
    hdr[i+1].offs-hdr[i].offs:6,' bytes');
  end
 else begin
  for i:=1 to cnt do
   if Match(hdr[i].name,sn) then begin
    Write('Extracting ',hdr[i].name);
    Seek(f,hdr[i].offs);
    Assign(g,hdr[i].name);
    Rewrite(g,1);
    j:=(hdr[i+1].offs-hdr[i].offs) div $8000;
    for k:=1 to j do
     begin
     Blockread(f,buf,$8000);
     Blockwrite(g,buf,$8000);
     end;
    j:=(hdr[i+1].offs-hdr[i].offs) mod $8000;
    Blockread(f,buf,j);
    Blockwrite(g,buf,j);
    Close(g);
    Writeln(' - done!');
    end;
  end;
 Close(f);
end.