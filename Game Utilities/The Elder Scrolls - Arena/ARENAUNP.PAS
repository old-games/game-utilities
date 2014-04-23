uses
 Platform,HexOut;
type
 hrt=record
  name:array[1..14] of char;
  sze:longint;
  end;
 bf=array[0..49999] of byte;
 hrs=array[1..2500] of hrt;
const
 flg:byte=0;
var
 f,g:file;
 i,j,k,cnt:integer;
 hsz,fsz,of0:longint;
 buf:^bf;
 hrc:^hrs absolute buf;
 hdr:array[1..2500] of record
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
 New(buf);
 Reset(f,1);
 fsz:=FileSize(f);
 Blockread(f,cnt,2);
 hsz:=longint(cnt)*18;
 Seek(f,fsz-hsz);
 Blockread(f,buf^,hsz);
 of0:=2;
 for i:=1 to cnt do
  begin
  j:=Pos(#0,hrc^[i].name);
  hdr[i].name:=Copy(hrc^[i].name,1,j-1);
  hdr[i].offs:=of0;
  Inc(of0,hrc^[i].sze);
  end;
 hdr[cnt+1].offs:=of0;
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
     Blockread(f,buf^,$8000);
     Blockwrite(g,buf^,$8000);
     end;
    j:=(hdr[i+1].offs-hdr[i].offs) mod $8000;
    Blockread(f,buf^,j);
    Blockwrite(g,buf^,j);
    Close(g);
    Writeln(' - done!');
    end;
  end;
 Close(f);
end.