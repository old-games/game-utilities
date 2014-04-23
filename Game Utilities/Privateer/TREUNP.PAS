uses
 Platform,HexOut;
type
 hrt=record
  case integer of
  1:(fg:byte;nme:array[1..65] of char;offs,sze:longint);
  2:(name:string[64]);
  end;
 bf=array[0..$7FFF] of byte;
 hrs=array[1..300] of hrt;
const
 flg:byte=0;
var
 f,g:file;
 i,j,k,cnt:integer;
 hsz:longint;
 buf:bf;
 hdr:hrs;
 nm:string[12];
 ws,s2,s3:string[64];
 sn,ss:string;
{$F+}
function Scan(c:char;s:string):byte;
 begin
  inline(
  $C4/$7E/$06/         {     les  di,[bp]+6  }
  $26/$8A/$0D/         {     mov  cl,es:[di] }
  $30/$ED/             {     xor  ch,ch      }
  $E3/$0C/             {     jcxz exit       }
  $01/$CF/             {     add  di,cx      }
  $FD/                 {     std             }
  $8A/$46/$0A/         {     mov  al,[bp]+10 }
  $F2/$AE/             {     repne scasb     }
  $FC/                 {     cld             }
  $75/$01/             {     jnz  exit       }
  $41/                 {     inc  cx         }
  $91/                 {exit xchg ax,cx      }
  $8B/$E5/             {     mov  sp,bp      }
  $5D/                 {     pop  bp         }
  $CA/$06/$00);        {     retf 6          }
 end;
{$F-}
begin
 i:=2;
 sn:=ParamStr(1);
 if sn='' then Exit;
 if sn='l' then flg:=0
 else if sn='e' then flg:=1
 else if sn='x' then flg:=2
 else i:=1;
 GetDir(0,ss);
 ss:=ss+'\';
 Assign(f,ParamStr(i));
 sn:=ParamStr(i+1);
 if sn='' then sn:='*';
 if Pos('\',sn)=0 then sn:='*\'+sn;
 Reset(f,1);
 Blockread(f,cnt,2);
 hsz:=longint(cnt)*$4A;
 Seek(f,8);
 Blockread(f,hdr,hsz);
 for i:=1 to cnt do
  with hdr[i] do
   begin
   j:=Pos(#0,nme);
   byte(name[0]):=Lo(j-1);
   while Copy(name,1,3)='..\' do Delete(name,1,3);
  end;
 if flg=0 then begin
  for i:=1 to cnt do
   with hdr[i] do
    if Match(name,sn) then
     Writeln('File ',name,' at offset ',DStr(offs),', size ',sze:6,' bytes');
  end
 else begin
  for i:=1 to cnt do
   with hdr[i] do
    if Match(hdr[i].name,sn) then begin
     ws:=name;
     j:=Scan('\',ws);
     nm:=Copy(ws,j+1,byte(ws[0])-j);
     if flg=1 then Write('Extracting ',nm)
     else begin
      Write('Extracting ',ws);
      byte(ws[0]):=Lo(j-1);
      {$I-}
      ChDir(ss+ws);
      if IOResult<>0 then begin
       s2:=ws;
       s3:='';
       repeat
	j:=Pos('\',s2);
	if j=0 then j:=byte(s2[0])+1;
        if s3='' then s3:=Copy(s2,1,j-1)
	else s3:=s3+'\'+Copy(s2,1,j-1);
	Delete(s2,1,j);
	ChDir(ss+s3);
	if IOResult<>0 then begin
	 MkDir(ss+s3);
	 ChDir(ss+s3);
	 end;
       until s2='';
       end;
      {$I+}
      end;
     Seek(f,offs);
     Assign(g,nm);
     Rewrite(g,1);
     j:=sze div $8000;
     for k:=1 to j do
      begin
      Blockread(f,buf,$8000);
      Blockwrite(g,buf,$8000);
      end;
     j:=sze mod $8000;
     Blockread(f,buf,j);
     Blockwrite(g,buf,j);
     Close(g);
     Writeln(' - done!');
     end;
  end;
 Close(f);
end.