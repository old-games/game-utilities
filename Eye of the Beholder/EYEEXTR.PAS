type
 DirT=record
  nxt:longint;
  fill:array[1..$80] of byte;
  adrs:array[0..$7F] of longint;
  end;
 DirAr=array[0..39] of DirT;
 DirP=^DirAr;
 LstT=array[0..$1FF] of longint;
 WrkT=array[1..65000] of byte;
 WrkP=^WrkT;
var
 f,g:file;
 t:text;
 i,j,k:integer;
 dir:DirP;
 lst0,lst1:LstT;
 ptr0,ptr1:WrkP;
 hdr:record
  unk,typ,siz:longint;
  end;
 tmp:longint;
 sz0,sz1,tp0,tp1,en0,en1,en1a,en1b,ww,ww1:word;
 s,s1,ss:string;
 s2,s3:string[80];
 buf:array[0..$7FFF] of byte;
procedure Select(idx:integer);
 begin
  Seek(f,dir^[idx div $80].adrs[idx mod $80]);
  Blockread(f,hdr,12);
 end;
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
{ if ParamCount=0 then Halt(1);
 Val(ParamStr(1),k,j);
 if (j<>0) or (k<0) then Halt(1);}
 GetDir(0,ss);
 ss:=ss+'\';
 Assign(t,'info.log');
 Rewrite(t);
 Assign(f,'eye.res');
 Reset(f,1);
 Seek(f,$18);
 Blockread(f,tmp,4);
 Seek(f,tmp);
 New(dir);
 j:=-1;
 repeat
  Inc(j);
  Blockread(f,dir^[j],644);
  Seek(f,dir^[j].nxt);
 until (dir^[j].nxt=0) or (j=39);
 if dir^[j].nxt<>0 then begin
  Writeln('Too much dirs!');
  Halt(2);
  end;
 Select(0);
 Blockread(f,tmp,2);
 Blockread(f,lst0,$800);
 for i:=0 to $1FF do
  if lst0[i]>0 then Dec(lst0[i],$801);
 GetMem(ptr0,hdr.siz-$802);
 Blockread(f,ptr0^,hdr.siz-$802);
 sz0:=hdr.siz-$801;
 Select(1);
 Blockread(f,tmp,2);
 Blockread(f,lst1,$800);
 sz1:=hdr.siz-$801;
 for i:=0 to $1FF do
  if lst1[i]>0 then Dec(lst1[i],$801);
 GetMem(ptr1,hdr.siz-$802);
 Blockread(f,ptr1^,hdr.siz-$802);
 k:=0;
 for i:=0 to $1FF do
  if (lst0[i]>0) and (lst1[i]>0) then begin
   tp0:=lst0[i];
   tp1:=lst1[i];
   j:=i+1;
   while (j<$200) and (lst0[j]=0) do
    Inc(j);
   if j=$200 then en0:=sz0
   else en0:=lst0[j];
   j:=i+1;
   while (j<$200) and (lst1[j]=0) do
    Inc(j);
   if j=$200 then en1:=sz1
   else en1:=lst1[j];
   while tp1<en1 do
    begin
    en1a:=tp1+2;
    while ptr1^[en1a]<>0 do
     Inc(en1a);
    Inc(en1a);
    en1b:=en1a+2;
    while ptr1^[en1b]<>0 do
     Inc(en1b);
    byte(s[0]):=Lo(en1a-tp1);
    for ww:=tp1 to en1a-1 do
     byte(s[ww-tp1+1]):=ptr1^[ww];
    if Pos('.sop',s)=0 then begin
     ww:=tp0;
     repeat
      while (ww<en0) and (ptr0^[ww]<>ptr1^[tp1]) do
       Inc(ww);
      ww1:=ww+1;
      while (ww1<ww+en1a-tp1) and (ptr0^[ww1]=ptr1^[ww1-ww+tp1]) do
       Inc(ww1);
      if ww1<ww+en1a-tp1 then Inc(ww)
      else ww:=0;
     until ww=0;
     Inc(en1a,2);
     byte(s1[0]):=Lo(en1b-en1a);
     for ww:=en1a to en1b-1 do
      byte(s1[ww-en1a+1]):=ptr1^[ww];
     if Copy(s1,1,5)<>'file:' then begin
      Delete(s,1,2);
      Dec(byte(s[0]));
      Writeln(t,s,#13#10,s1);
      end;
     j:=Pos(':',s1);
     if j>0 then Delete(s1,1,j);
     j:=Pos(',',s1);
     if j>0 then byte(s1[0]):=Lo(j-1);
     Write('Extracting  ',s1);
     j:=Scan('\',s1);
     s:=Copy(s1,1,j-1);
     Delete(s1,1,j);
     {$I-}
     ChDir(ss+s);
     if IOResult<>0 then begin
      s2:=s;
      s3:='';
      repeat
       j:=Pos('\',s2);
       if j=0 then j:=byte(s2[0])+1;
       s3:=s3+'\'+Copy(s2,1,j-1);
       Delete(s2,1,j);
       ChDir(ss+s3);
       if IOResult<>0 then begin
        MkDir(ss+s3);
        ChDir(ss+s3);
        end;
      until s2='';
      end;
     {$I+}
     Assign(g,s1);
     Rewrite(g,1);
     Inc(ww1,2);
     ww:=ww1;
     while ptr0^[ww]<>0 do
      begin
      byte(s[ww-ww1+1]):=ptr0^[ww];
      Inc(ww);
      end;
     byte(s[0]):=Lo(ww-ww1);
     Val(s,ww,j);
     Select(ww);
     for j:=1 to hdr.siz shr 15 do
      begin
      Blockread(f,buf,$8000);
      Blockwrite(g,buf,$8000);
      end;
     Blockread(f,buf,hdr.siz and $7FFF);
     Blockwrite(g,buf,hdr.siz and $7FFF);
     Close(g);
     Writeln(' - done!');
     end;
    while (en1b<en1) and (ptr1^[en1b]=0) do
     Inc(en1b);
    tp1:=en1b;
    end;
   end;
 Close(f);
 Close(t);
end.