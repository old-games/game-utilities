{$X+}
unit getpcx;
interface
{uses gluk;}
var pcxheader:record
     manuf:byte;
     hard:byte;
     encod:byte;
     bitpix:byte;
     x1,y1,x2,y2:integer;
     hres,yres:integer;
     clrma:array[1..48]of char;
     vmode:byte;
     nplanes:byte;
     bplin:integer;
     palinfo:integer;
     shres,svres:integer;
     xtra:array[1..54]of byte;
    end;
type paltype=record
      r,g,b:byte;
     end;
var  palette:array[0..255]of paltype;

procedure putpcx(rx1,ry1,rx2,ry2:integer;fname:string);
function _getpcx(x,y:integer;fname:string):boolean;
procedure getpcxrange(var x,y:integer;fname:string);
procedure setpalette;

implementation

function getpixelvga(x,y:integer):byte;assembler;
asm
 mov ax,y
 mov bx,320
 mul bx
 add ax,x
 mov si,ax
 mov ax,$a000
 mov es,ax
 mov al,es:[si]
end;

procedure putpixelvga(x,y:integer;color:byte);assembler;
asm
 mov ax,y
 mov bx,320
 mul bx
 add ax,x
 mov di,ax
 mov ax,$a000
 mov es,ax
 mov al,color
 stosb
end;


procedure getpalette;assembler;
asm
 mov ax,$1017
 xor bx,bx
 lea dx,palette
 mov cx,$100
 push ds
 pop  es
 int $10
end;

procedure SetPalette;assembler;
 asm
  lea si,palette
  mov cx,$300
  mov dx,$3DA
{  cli}
@1:
  in al,dx
  test al,8
  jne @1
@2:
  in al,dx
  test al,8
  je @2
  mov dx,$3C8
  mov al,$0
  out dx,al
  nop
  nop
  nop
  mov dx,$3C9
@3:
  lodsb
  out dx,al
  loop @3
{  sti}
 end;


procedure putpcx;
var fin,fout:file;
    i,j:integer;
    buffer:array[0..700]of byte;
    bufptr:integer;

procedure packpcxline(x1,x2,y1:integer);
var color,current,counter:byte;i:integer;
begin
 bufptr:=0;
 current:=getpixelvga(x1,y1);
 counter:=1;
 for i:=x1+1 to x2 do begin
  color:=getpixelvga(i,y1);
  if (color<>current) or (counter>=$3F) then begin
   if (counter<>1) or (current>=$C0) then begin
     buffer[bufptr]:=counter or $C0;
     inc(bufptr);
   end;
   buffer[bufptr]:=current;
   inc(bufptr);
   current:=color;
   counter:=1;
  end else begin
   inc(counter);
  end;
 end;
 if (counter<>1) or (current>=$C0) then begin
   buffer[bufptr]:=counter or $C0;
   inc(bufptr);
 end;
 buffer[bufptr]:=current;
 inc(bufptr);
end;

begin
 assign(fout,fname);
 rewrite(fout,1);
 fillchar(pcxheader,sizeof(pcxheader),0);
 with pcxheader do begin
  manuf:=$A;
  hard:=5;
  encod:=1;
  bitpix:=8;
  x1:=0;
  y1:=0;
  x2:=rx2-rx1;
  y2:=ry2-ry1;
  hres:=320;
  yres:=200;
  nplanes:=1;
  bplin:=x2-x1+1;
  blockwrite(fout,pcxheader,sizeof(pcxheader));
  for i:=ry1 to ry2 do begin
   packpcxline(rx1,rx2,i);
   blockwrite(fout,buffer,bufptr);
  end;
  buffer[0]:=$C;
  blockwrite(fout,buffer,1);
 end;
 getpalette;
 for i:=0 to 255 do
  with palette[i] do begin
   r:=r shl 2;
   g:=g shl 2;
   b:=b shl 2;
  end;
 blockwrite(fout,palette,sizeof(palette));
 for i:=0 to 255 do
  with palette[i] do begin
   r:=r shr 2;
   g:=g shr 2;
   b:=b shr 2;
  end;

 close(fout);
end;

function _getpcx;
var fin:file;
    bufptr,i,j:integer;
    buffer:array[0..1023]of byte;
    counter,color:byte;
    pos,size,maxsize:longint;
label ex;

procedure showpixel(_x,_y:integer;color:byte);
var i,j:integer;
begin
 i:=x+_x;
 j:=y+_y;
 if (i<320) and (j<400) then putpixelvga(i,j,color);
end;

begin
 assign(fin,fname);
 {$I-}
 reset(fin,1);
 {$I+}
 if ioresult<>0 then begin
  _getpcx:=false;
  exit;
 end;
 blockread(fin,pcxheader,sizeof(pcxheader));
 with pcxheader do begin
  dec(x2,x1);
  dec(y2,y1);
  x1:=0;
  y1:=0;
  if (manuf<>10) or (encod<>1) or (bitpix<>8) or (nplanes<>1) then begin
   _getpcx:=false;
   goto ex;
  end;
  bufptr:=1023;
  counter:=0;
  pos:=filepos(fin);
  maxsize:=filesize(fin);
  for i:=y1 to y2 do
   for j:=x1 to x1+bplin-1 do begin
    if counter=0 then begin
     if bufptr=1023 then begin
       inc(pos,1024);
       if pos>maxsize then begin
         size:=maxsize+1024-pos;
       end else size:=1024;
       blockread(fin,buffer,size);
       bufptr:=0;
     end else inc(bufptr);
     counter:=buffer[bufptr];
     if counter<$C0 then begin
      showpixel(j,i,counter);
      counter:=0;
     end else begin
      counter:=counter and $3F;
      if bufptr=1023 then begin
        inc(pos,1024);
        if pos>maxsize then begin
          size:=maxsize+1024-pos;
        end else size:=1024;
        blockread(fin,buffer,size);
        bufptr:=0;
      end else inc(bufptr);
      color:=buffer[bufptr];
      showpixel(j,i,color);
      dec(counter);
     end;
    end else begin
      showpixel(j,i,color);
      dec(counter);
    end;
   end;
 end;
 seek(fin,filesize(fin)-sizeof(palette));
 blockread(fin,palette,sizeof(palette));

 for i:=0 to 255 do
  with palette[i] do begin
   r:=r shr 2;
   g:=g shr 2;
   b:=b shr 2;
  end;
 setpalette;
ex:
 close(fin);
end;

procedure getpcxrange;
var fin:file;
label ex;

begin
 assign(fin,fname);
 {$I-}
 reset(fin,1);
 {$I+}
 if ioresult<>0 then begin
  x:=0;
  y:=0;
  exit;
 end;
 blockread(fin,pcxheader,sizeof(pcxheader));
 with pcxheader do begin
  if (manuf<>10) or (encod<>1) or (bitpix<>8) or (nplanes<>1) then begin
   x:=0;
   y:=0;
   goto ex;
  end;
  x:=x2-x1;
  y:=y2-y1;
 end;
ex:
 close(fin);
end;


end.