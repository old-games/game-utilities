var fin,fout:file;

procedure filecopy(var fin:file;var fout:file;size:longint);
var buf:array[1..1024*8]of byte;
    i:longint;
begin
 i:=size;
 while i>1024*8 do begin
  blockread(fin,buf,1024*8);
  blockwrite(fout,buf,1024*8);
  dec(i,1024*8);
 end;
 blockread(fin,buf,i);
 blockwrite(fout,buf,i);
end;

var offset:longint;i:integer;

begin
 writeln('File update by Taralej and jaboCrack SoftWare MBK (c) 1995');
 if paramcount<3 then begin
  writeln('syntax: filedst offset filesrc');
  halt(1);
 end;

 val(paramstr(2),offset,i);
 assign(fout,paramstr(1));
 assign(fin,paramstr(3));
 reset(fin,1);
 reset(fout,1);
 seek(fout,offset);
 filecopy(fin,fout,filesize(fin));
 close(fin);
 close(fout);
end.