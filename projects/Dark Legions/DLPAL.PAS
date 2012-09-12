{ Dark Legions palette converter }
var
 f:file;
 a:array[1..$300] of byte;
 i:integer;
begin
 Assign(f,ParamStr(1));
 Reset(f,1);
 Seek(f,8);
 Blockread(f,a,$300);
 Close(f);
 for i:=1 to $300 do
  a[i]:=a[i] shr 2;
 Assign(f,ParamStr(2));
 Rewrite(f,1);
 Blockwrite(f,a,$300);
 Close(f);
end.