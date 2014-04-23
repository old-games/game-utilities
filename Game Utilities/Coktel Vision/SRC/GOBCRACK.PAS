{$X+}
{$M $9000,0,655000}
uses crt,dos,getpcx;
type arr= array [0..64000] of char;
     arrptr=^arr;
     wordptr=^word;
var fin,fout,fcommun:file;
    size,i,j:integer;
    obj:record
      Name:string[13];
      f_size,offset:longint;
      id:byte;
    end;
    ext:record
      Name:byte;
      offset:longint;
      f_size:word;
      id1:word;
      id2:byte;
    end;

    xptr,point:^word;
    yold,line,x1,x2,y1,y2,p:integer;
    bufout,buffer:pointer;
    oldofs:longint;
    fmap,fbat:text;
    tree:pointer;
    sname,fname:string;
    buf:array[1..8]of byte;
    tempofs,tempsize:word;
    temp:string;
type paltype=record
      r,g,b:byte;
     end;

type oneitemtype=string[40];
     itemtype=array[1..2]of oneitemtype;
var  j1,j2:longint;

procedure MYWindow(x1,y1,x2,y2:integer;color:byte);
begin
 asm
  mov bx,y1
  inc bx
  mov ax,160
  mul bx
  mov cx,y2
  sub cx,bx
  inc cx
  mov di,x1
  mov bx,x2
  sub bx,di
  inc di
  inc di
  shl di,1
  add di,ax

  push di
  mov ax,$b800
  mov es,ax
  cld
@loopy:
  push cx
  mov cx,bx
@loopx:
  inc di
  test byte ptr es:[di],$80
  jne @ll1
  and byte ptr es:[di],$F
@ll1:
  test byte ptr es:[di],$8
  jne @ll2
  and byte ptr es:[di],$F0
@ll2:
  and byte ptr es:[di],$77
  inc di
  loop @loopx
  add  di,160
  sub di,bx
  sub di,bx
  pop  cx
  loop @loopy
  pop di

  sub di,164
  mov ah,color
  mov  cx,y2
  sub  cx,y1
@main:
  push cx
@DA:
  mov al,$DA
  stosw
  mov cx,bx
  dec cx
  dec cx
@C4:
  mov al,$C4
  rep stosw
@BF:
  mov al,$BF
  stosw
  mov byte ptr @DA+1,$B3
  mov byte ptr @C4+1,$20
  mov byte ptr @BF+1,$B3
  pop cx
  cmp cx,2
  jne @l1
  mov byte ptr @DA+1,$C0
  mov byte ptr @C4+1,$C4
  mov byte ptr @BF+1,$D9
@l1:
  add di,160
  sub di,bx
  sub di,bx
  loop @main
  mov byte ptr @DA+1,$DA
  mov byte ptr @C4+1,$C4
  mov byte ptr @BF+1,$BF
 end;
end;

PROCEDURE WritePos(x,y:integer;name:string);
begin
 asm
  push ds
  mov di,y
  mov ax,160
  mul di
  add ax,x
  add ax,x
  mov di,ax
  mov ax,$b800
  mov es,ax
  lea si,name
  push ss
  pop ds
  lodsb
  xor ch,ch
  mov cl,al
@l1:
  movsb
  inc di
  loop @l1
  pop ds
 end;
end;


function menu(X1,Y1,X2,Y2:integer;var Items;N:integer):integer;
var i:integer;ch:char;

procedure enableitem(X1,X2,Y1,i:integer;color:byte);assembler;
asm
 mov ax,$b800
 mov es,ax
 mov cx,X2
 sub cx,X1
 dec cx
 dec cx
 mov ax,Y1
 add ax,i
 mov bx,160
 mul bx
 add ax,X1
 add ax,X1
 add ax,3
 mov di,ax
 mov al,color
 cld
@1:
 stosb
 inc di
 loop @1
end;

var npage,cpage,sizepage,nitem:integer;

begin
 cpage:=0;
 sizepage:=Y2-Y1-2;
 if N<sizepage then sizepage:=N;
 npage:=N div sizepage;
 if N mod sizepage=0 then dec(Npage);
 if cpage<>npage then Nitem:=sizepage else begin
  Nitem:=N mod sizepage;
  if nitem=0 then Nitem:=sizepage;
 end;
 mywindow(X1,Y1,X2,Y1+sizepage+2,$1E);
 for i:=1 to Nitem do
  writepos(X1+1,Y1+i,itemtype(items)[i+cpage*sizepage]);
 i:=1;
 enableitem(X1,X2,Y1,i,$71);
 repeat
  repeat
   ch:=readkey;
  until ch<>#0;
  enableitem(X1,X2,Y1,i,$1E);
  case ch of
   #72:if I>1 then dec(i) else begin
    if cpage<>0 then begin
      dec(cpage);
      if cpage<>npage then Nitem:=sizepage else begin
       Nitem:=N mod sizepage;
       if nitem=0 then Nitem:=sizepage;
      end;
      mywindow(X1,Y1,X2,Y1+sizepage+2,$1E);
      for i:=1 to Nitem do
       writepos(X1+1,Y1+i,itemtype(items)[i+cpage*sizepage]);
      i:=Nitem;
		   {Up}
    end;
   end;
   #80:begin
    if I<Nitem then inc(i) else begin
    if cpage<>npage then begin
      inc(cpage);
      if cpage<>npage then Nitem:=sizepage else begin
       Nitem:=N mod sizepage;
       if nitem=0 then Nitem:=sizepage;
      end;
      mywindow(X1,Y1,X2,Y1+sizepage+2,$1E);
      for i:=1 to Nitem do
       writepos(X1+1,Y1+i,itemtype(items)[i+cpage*sizepage]);

     i:=1;		    {Down}
    end;
    end;
   end;
   #27:begin
	menu:=0;
	exit;
       end;
  end;
  enableitem(X1,X2,Y1,i,$71);
 until ch=#13;
 menu:=i+cpage*sizepage;;
end;



var  palette:array[0..255]of paltype;
procedure SetPalette;assembler;
 asm
 {mov ah,$10
  mov al,$12
  mov bx,0
  mov cx,255
  lea dx,palette
  push ds
  pop  es
  int $10}
  lea si,palette
  mov cx,$300
  mov dx,$3DA
  cli
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
  cld
  nop
  nop
  nop
  mov dx,$3C9
@3:
  lodsb
  out dx,al
  loop @3
  sti
 end;

label err,check,err2,err4,err4_,en,err5,GetString;
{$F+}
procedure unpacktext(bufout,tree,bufin:pointer);assembler;
asm	   cld
	   push   ds
	   push   es
	   push   di
	   push   si
	   lds	  si,[bp+$06]
	   les	  di,[bp+$0E]
	   mov	  ax,[bp+$0A]
	   mov	  bx,[bp+$0C]
	   mov	  word ptr cs:[@D4],bx
	   mov	  bp,ax
	   lodsw
	   add	  si,0002
		       {size output buffer}
	   mov	  word ptr cs:[@CC],ax
	   push   di
	   mov	  cx,$07F7
	   mov	  ax,$2020
	   rep stosw			  {clear output buffer}
	   pop	  di
	   mov	  bx,$0FEE
	   mov	  cx,0000
@42:
	   shr	  ax,1
	   test   ah,01
	   jne	  @4C
	   lodsb
	   mov	  ah,$FF
@4C:
	   test   al,01
	   je	  @72
	   mov	  cl,[si]
	   inc	  si
	   push   ds
	   mov	  dx,word ptr cs:[@D4]
	   mov	  ds,dx
	   mov	  ds:[bp],cl
	   pop	  ds
	   inc	  bp
	   dec	  cs:word ptr [@CC]  {size output buffer}
	   je	  @B8
	   mov	  es:[bx+di],cl
	   inc	  bx
	   and	  bx,$0FFF
	   jmp	  @42
@72:
	   push   ax
	   lodsb
	   xor	  ah,ah
	   mov	  dx,ax
	   lodsb
	   mov	  cx,ax
	   shr	  al,1
	   shr	  al,1
	   shr	  al,1
	   shr	  al,1
	   mov	  dh,al
	   and	  cl,$F
	   add	  cl,03
	   push   ds
	   mov	  ax,word ptr cs:[@D4]
	   mov	  ds,ax
@92:
	   xchg   dx,bx
	   mov	  al,es:[bx+di]
	   inc	  bx
	   and	  bx,$FFF
	   xchg   dx,bx
	   mov	  ds:[bp],al
	   inc	  bp
	   dec	  cs:word ptr [@CC]
	   je	  @C5
	   mov	  es:[bx+di],al
	   inc	  bx
	   and	  bx,$FFF
	   loop   @92
	   pop	  ds
	   pop	  ax
	   jmp	  @42
@B8:
	   pop	  si
	   pop	  di
	   pop	  es
	   pop	  ds
	   pop	  bp
	   retf   12
@C5:
	   pop	  ds
	   pop	  cx
	   jmp	  @B8
@D4:	   DW	  0
@CC:	   DW	  0
end;
{$F-}

procedure unpackoldpicture(bufferpic,bufferpic1:pointer;size:word);
type pbyte=^byte;
var src:pbyte;
    dst:pbyte;
    i,j:word;
    color:byte;
    counter:word;
begin
 i:=1;
 src:=bufferpic;
 dst:=bufferpic1;
 repeat
   color:=src^ shr 4;
   counter:=src^ and $F;
   inc(src);
   if counter <8 then begin
    if counter=0 then
     counter:=0;
    counter:=(counter and $7) shl 8 +src^;
    inc(src);
   end else counter:=counter and 7;
   inc(counter);
   for j:=1 to counter do begin
    dst^:=color;
    inc(dst);
    inc(i);
   end;
 until i>=size;
end;

function packoldpicture(bufferpic,bufferpic1:pointer;size:word):word;
type pbyte=^byte;
var src:pbyte;
    dst:pbyte;
    i,j:word;
    color:byte;
    counter:word;
begin
 i:=1;
 j:=0;
 src:=bufferpic;
 dst:=bufferpic1;
 repeat
   counter:=1;
   color:=src^;
   inc(src);
   inc(i);
   while (color=src^) and (i<size) and (counter<$7FF) do begin
    inc(src);
    inc(i);
    inc(counter);
   end;
   dec(counter);
   if counter<8 then begin
    dst^:=(color shl 4) or counter or 8;
    inc(dst);
    inc(j);
   end else begin
    dst^:=(color shl 4) or (counter shr 8);
    inc(dst);
    dst^:=byte(counter);
    inc(dst);
    inc(j,2);
   end;

{   color:=src^ shr 4;
   counter:=src^ and $F;
   inc(src);
   if counter <8 then begin
    if counter=0 then
     counter:=0;
    counter:=(counter and $7) shl 8 +src^;
    inc(src);
   end else counter:=counter and 7;
   inc(counter);
   for j:=1 to counter do begin
    dst^:=color;
    inc(dst);
    inc(i);
   end;}
 until i>=size;
 packoldpicture:=j;
end;


procedure viewpicture;
var resources:array[1..100]of oneitemtype;
    views:array[1..100]of oneitemtype;
    Nobj:array[1..100]of integer;
    Nview:array[1..100]of integer;
    Nv:integer;
    curres,Nres:integer;
    extent:string;
    ofsres:longint;
    npicfile:integer;

procedure loadobj(i:integer);
begin
 seek(fin,(i-1)*(sizeof(obj)-1)+2);
 blockread(fin,obj.name[1],sizeof(obj)-1);
 asm
  push ds
  pop es
  lea bx,obj
  mov byte ptr es:[bx],13
  mov di,bx
  mov cl,es:[di]
  inc di
  xor al,al
  repnz scasb
  inc cl
  sub es:[bx],cl
 end;
end;

var mode:byte;
var temp:pointer;
    scr1,scr2,scr3,scr4:array[1..4000]of byte;

procedure savescreen(var buffer);
begin
 move(ptr($b800,0)^,buffer,4000);
end;

procedure restorescreen(var buffer);
begin
 move(buffer,ptr($b800,0)^,4000);
end;


function selectfunction:byte;
const items:itemtype=('Ввод палитры','Просмотр картинки');
begin
 selectfunction:=menu(50,1,70,5,items,2);
end;


procedure showoldpicture(rx,ry:integer;pic:pointer);
var temptree:pointer;
    fname:string;
    bufferpic:pointer;
    bufferpic1:pointer;
    ispacked:boolean;



begin
 savescreen(scr3);
 asm
  mov ax,$13
  int $10
 end;
 setpalette;
 ispacked:=(rx and $8000<>0);
 if ispacked then begin
  getmem(temptree,word(pic^));
  getmem(bufferpic,(rx+1)*(ry+1));
  unpacktext(temptree,bufferpic,pic);
  rx:=rx and $7FFF;
 end else bufferpic:=pic;
 getmem(bufferpic1,(rx)*(ry));
 unpackoldpicture(bufferpic,bufferpic1,rx*ry);
 asm
  push ds
  mov  cx,ry
  mov  bx,rx
  mov ax,$a000
  mov es,ax
  xor di,di
  lds si,bufferpic1
 @1:
  push cx
 @2:
  mov cx,bx
  rep movsb
  sub di,bx
  add di,320
  pop cx
  loop @1
  pop  ds
 end;
 if ispacked then begin
  freemem(bufferpic,(rx+1)*(ry+1));
  freemem(temptree,word(pic^));
 end;
 freemem(bufferpic1,(rx)*(ry));
 if readkey='s' then begin
  str(npicfile,fname);
  inc(npicfile);
  fname:='pic_'+fname+'.pcx';
  putpcx(0,0,rx,ry,fname);
 end;
 asm
  mov ax,$3
  int $10
 end;
 restorescreen(scr3);
end;



procedure showpicture(rx,ry:integer;pic:pointer);
var temptree:pointer;
    fname:string;
    bufferpic:pointer;
begin
 savescreen(scr3);
 asm
  mov ax,$13
  int $10
 end;
 getmem(temptree,word(pic^));
 setpalette;
 getmem(bufferpic,(rx+1)*(ry+1));
 unpacktext(temptree,bufferpic,pic);
 asm
  push ds
  mov  cx,ry
  mov  bx,rx
  mov ax,$a000
  mov es,ax
  xor di,di
  lds si,bufferpic
 @1:
  push cx
 @2:
  mov cx,bx
  rep movsb
  sub di,bx
  add di,320
  pop cx
  loop @1
  pop  ds
 end;
 freemem(bufferpic,(rx+1)*(ry+1));
 freemem(temptree,word(pic^));
 if readkey='s' then begin
  str(npicfile,fname);
  inc(npicfile);
  fname:='pic_'+fname+'.pcx';
  putpcx(0,0,rx,ry,fname);
 end;
 asm
  mov ax,$3
  int $10
 end;
 restorescreen(scr3);
end;

var files:array[1..20]of oneitemtype;
    sizestk,nfile,nfiles:integer;

procedure getfiles;
var base:searchrec;
begin
 findfirst('*.stk',AnyFile,base);
 nfiles:=0;
 while DosError = 0 do
 begin
   inc(nfiles);
   files[nfiles]:=base.name;
   FindNext(base);
 end;
end;

label sf;
type pword=^word;

begin
  npicfile:=0;
  getfiles;
  repeat
   nfile:=menu(50,5,79,24,files,nfiles);
   if nfile=0 then begin
    clrscr;
    halt(0);
   end;
   assign(fin,files[nfile]);
   reset(fin,1);
   blockread(fin,sizestk,2);
   savescreen(scr4);
   repeat
     Nres:=0;
     mode:=selectfunction;
     if mode=0 then begin
      restorescreen(scr4);
      goto SF;
     end;
     for i:=1 to sizestk do begin
      loadobj(i);
      with obj do begin
  {    writeln(fmap,name,' ',id);
       writeln('Name: ',name:12,' Size: ',f_size,' Offset: ',offset,' ID: ',id);}
       p:=pos('.',name);
       extent:=copy(name,p+1,length(name)-p);
       if (extent='TOT') or (extent='EXT') then begin
	inc(nres);
	resources[nres]:=name;
	nobj[nres]:=i;
       end;
      end;
     end;
     curres:=1;
     while curres<>0 do begin
      savescreen(scr1);
      curres:=menu(1,1,20,24,resources,nres);
      if curres<>0 then begin
       loadobj(nobj[curres]);
       with obj do begin
	 p:=pos('.',name);
	 extent:=copy(name,p+1,length(name)-p);
	 if ID<>0 then begin
	   p:=f_size;
	   getmem(buffer,p);
	   seek(fin,offset);
	   blockread(fin,buffer^,p);
	   getmem(bufout,word(buffer^));
	   getmem(tree,word(buffer^));

	   unpacktext(bufout,tree,buffer);
	 end;
	 if (extent='TOT') then begin
	   if ID=0 then begin
	    seek(fin,offset+$34);
	    blockread(fin,oldofs,4);
	    oldofs:=oldofs+offset;
	   end else asm
	    les di,tree
	    add di,$34
	    mov ax,es:[di]
	    mov word ptr oldofs,ax
	    mov word ptr oldofs+2,0
	   end;
	 end else if ID=0 then
	  oldofs:=offset      {oldofs-позиция в файле(памяти)}
	 else oldofs:=0;
	 if ID=0 then begin
	  seek(fin,oldofs);
	  blockread(fin,size,2);
	  ofsres:=filepos(fin);
	 end else asm
	    les di,tree
	    add di,word ptr oldofs
	    mov ax,es:[di]
	    mov word ptr size,ax
	 end;
	 NV:=0;
	 for i:=1 to size do begin
	  if ID=0 then blockread(fin,ext,sizeof(ext))
		  else move(ptr(seg(tree^),ofs(tree^)+2+oldofs+(i-1)*sizeof(ext))^,ext,sizeof(ext));
	  with ext do
	   if (mode=2) and (id1<>0) and (id2<>0) and (offset>=0) then begin
	    str(i,fname);
	    fname:='view.'+fname;
	    inc(NV);
	    views[nv]:=fname;
	    str(id1,fname);
	    views[nv]:=views[nv]+' '+fname;
	    str(id2,fname);
	    views[nv]:=views[nv]+'X'+fname;
	    nview[nv]:=i;
{	    str(f_size,fname);
	    views[nv]:=views[nv]+' '+fname;
	    str(offset,fname);
	    views[nv]:=views[nv]+' '+fname;}
		   {
	    writeln(fmap,fname);
	    writeln(fmap,name,' ',id1,' ',id2);
	    if offset>=0 then begin
	    oldofs:=filepos(fin);
	    seek(fin,offset+size*sizeof(ext)+3);
	    filecopy(fin,fout,f_size);
	    seek(fin,oldofs);
	    end else writeln(offset);
	    }
	   end else
	   if (mode=1) and (f_size=3*256) then begin
	    str(i,fname);
	    fname:='palette.'+fname;
	    inc(NV);
	    views[nv]:=fname;
	    nview[nv]:=i;
	   end;
	 end;
	 savescreen(scr2);
	 if NV=0 then begin
	  writeln('No object',^G);
	  i:=0;
	 end else i:=menu(25,1,50,24,views,NV);
	 if i<>0 then begin
	  i:=nview[i];
	  if ID=0 then begin
	    seek(fin,oldofs+2+(i-1)*sizeof(ext));
	    blockread(fin,ext,sizeof(ext))
	  end else move(ptr(seg(tree^),ofs(tree^)+2+oldofs+(i-1)*sizeof(ext))^,ext,sizeof(ext));
	  if id=0 then begin
	   if (mode=2) and (pword(temp)^=$0102) then
	    seek(fin,ext.offset+oldofs+3+size*sizeof(ext)+3)
	   else
	    seek(fin,ext.offset+oldofs+3+size*sizeof(ext));
	   getmem(temp,ext.f_size);
	   blockread(fin,temp^,ext.f_size);
	  end else if (mode=2) and (pword(temp)^=$0102)
			       then temp:=ptr(seg(tree^),ofs(tree^)+oldofs+3+ext.offset+size*sizeof(ext)+3)
			       else temp:=ptr(seg(tree^),ofs(tree^)+oldofs+3+ext.offset+size*sizeof(ext));
	  if mode=2 then
	   if pword(temp)^=$0102 then
	    showpicture(ext.id1,ext.id2,temp)
	   else
	    showoldpicture(ext.id1,ext.id2,temp)
	  else
	   move(temp^,palette,768);
	  if ID<>0 then begin
	   freemem(bufout,word(buffer^));
	   freemem(tree,word(buffer^));
	   freemem(buffer,p);
	  end else
	   freemem(temp,ext.f_size);
	 end;
	 restorescreen(scr2);
       end;
      end;
      restorescreen(scr1);
     end;
   until false;
SF:close(fin);
  until false;
end;


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

begin
 writeln('Goblins text cracker by Taralej and jaboCrack SoftWare MBK ver 1.0 (c) 1993');
 if paramcount<1 then begin
Err:
  writeln('Syntax: gobcrack /v file.stk 	 Посмотеть список объектов');
  writeln('	   gobcrack /r file.stk [ ext ]  Разделить pесуpс на объекты');
  writeln('	   gobcrack /u file.dat file.unp Распаковать запакованный объект');
  writeln('	   gobcrack /c file.map 	 Собpать pесуpс из объектов' );
  writeln('	   gobcrack /p file.unp file.dat Запаковать объект');
  writeln('	   gobcrack /t file.unp file.txt Пpеобpазовать в текстовый вид');
  writeln('	   gobcrack /t'' file.unp file.txt Пpеобpазовать для распечатки');
  writeln('	   gobcrack /e file.txt file.unp Пpеобpазовать из текстового вида');
  writeln('	   gobcrack /f file.let file.fnt Пpеобpазовать в фоpмат EVAFONT');
  writeln('	   gobcrack /l file.fnt file.let Пpеобpазовать из фоpмата EVAFONT');
  writeln('	   gobcrack /o file.ext 	 Разложить EXT на составляющие VIEWы ');
  writeln('	   gobcrack /w view.pac view.unp Распаковать каpтинку');
  writeln('	   gobcrack /s (/s1) view.unp X Y pal [file.pcx] Посмотеть VIEW ');
  writeln('	   gobcrack /a file.tot file.ext Вытащить EXT из TOT');
  writeln('	   gobcrack /b file.ext file.tot Добавить EXT к TOT');
  writeln('	   gobcrack /d file.map 	 Собрать  EXT из VIEWов');
  writeln('	   gobcrack /vp file.stk	 Просмотреть картинки');
  writeln('	   gobcrack /pv (/pv1) file.pcx view.unp Преобразовать PCX во VIEW');
  writeln('	   gobcrack /ima commun.im1      Разложить COMMUN.IM1 на VIEWы');
  halt(0);
 end;
 if (paramstr(1)='/c') or (paramstr(1)='/e') or (paramstr(1)='/d') then begin
   assign(fmap,paramstr(2));
   {$I-}
   reset(fmap);
   goto Check
 end else if (paramstr(1)<>'vp') and (paramstr(1)<>'pv') then begin
   assign(fin,paramstr(2));
   {$I-}
   reset(fin,1);
Check:
   if IOResult<>0 then begin
    writeln('File not found.');
    halt(0);
   end;
   {$I+}
 end;
 if (paramstr(1)='/r') or (paramstr(1)='/v') then begin
   assign(fmap,'map.txt');
   rewrite(fmap);
   writeln(fmap,paramstr(2));
   blockread(fin,size,2);
   writeln(fmap,size);
   for i:=1 to size do begin
    blockread(fin,obj.name[1],sizeof(obj)-1);
    asm
     push ds
     pop es
     lea bx,obj
     mov byte ptr es:[bx],13
     mov di,bx
     mov cl,es:[di]
     inc di
     xor al,al
     repnz scasb
     inc cl
     sub es:[bx],cl
    end;

    with obj do begin
     writeln(fmap,name,' ',id);
     writeln('Name: ',name:12,' Size: ',f_size,' Offset: ',offset,' ID: ',id);
     p:=pos('.',name);
     if (paramstr(1)='/r') and
	((paramcount=2) or (copy(name,p+1,length(name)-p)=paramstr(3))) then begin
      assign(fout,name);
      rewrite(fout,1);
      oldofs:=filepos(fin);
      seek(fin,offset);
      filecopy(fin,fout,f_size);
      seek(fin,oldofs);
      close(fout);
     end;
    end;
   end;
   close(fmap);
 end else
 if (paramstr(1)='/vp') then viewpicture
 else
 if (paramstr(1)='/u') or (paramstr(1)='/w')then begin
  if paramcount<3 then goto Err;
  assign(fout,paramstr(3));
  rewrite(fout,1);
  p:=filesize(fin);
  if (paramstr(1)='/w') then begin
   seek(fin,3);
   dec(p,3);
  end;
  getmem(buffer,p);
  blockread(fin,buffer^,p);
  getmem(bufout,word(buffer^));
  if word(buffer^)>$FFF7 then
   tree:=ptr(seg(heapptr^)+1,0)
  else getmem(tree,word(buffer^));

  unpacktext(bufout,tree,buffer);
  blockwrite(fout,tree^,word(buffer^));
  freemem(bufout,word(buffer^));
  freemem(buffer,p);
  if word(buffer^)<=$FFF7 then
   freemem(tree,word(buffer^));
  close(fout);
 end else
 if (paramstr(1)='/c') then begin
  readln(fmap,fname);
  assign(fout,fname);
  rewrite(fout,1);
  readln(fmap,size);
  blockwrite(fout,size,(size)*(sizeof(obj)-1)+2);
  with obj do
   for i:=1 to size do begin
    readln(fmap,temp);
    id:=ord(temp[length(temp)])-$30;
    dec(temp[0],2);
    name:=temp;
    name[length(name)+1]:=#0;
    assign(fin,name);
    {$I-}
    reset(fin,1);
    if IOresult<>0 then begin
     writeln('File not found!');
     goto err2;
    end;
    {$I+}
    f_size:=filesize(fin);
    offset:=filepos(fout);
    filecopy(fin,fout,f_size);
    oldofs:=filepos(fout);
    seek(fout,2+(i-1)*(sizeof(obj)-1));
    writeln('Name: ',name:12,' Size: ',f_size,' Offset: ',offset,' ID: ',id);
    blockwrite(fout,obj.name[1],(sizeof(obj)-1));
    seek(fout,oldofs);
    close(fin);
   end;
Err2:
  close(fout);
 end else
 if (paramstr(1)='/p') then begin
  if paramcount<3 then goto err;
  assign(fout,paramstr(3));
  rewrite(fout,1);
  oldofs:=filesize(fin)+4;
  blockwrite(fout,oldofs,4);
  i:=oldofs-4;
  p:=$FF;
  while i>8 do begin
   blockread(fin,buf,8);
   blockwrite(fout,p,1);
   blockwrite(fout,buf,8);
   dec(i,8);
  end;
  blockread(fin,buf,i);
  blockwrite(fout,buf,i);
  close(fout);
 end else
 if (paramstr(1)='/t') then begin
   if paramcount<3 then goto err;
   assign(fmap,paramstr(3));
   rewrite(fmap);
   blockread(fin,size,2);
   writeln(fmap,size);
   for i:=1 to size do begin
    blockread(fin,tempofs,2);
    blockread(fin,tempsize,2);
    if tempofs<>$FFFF then begin
      writeln(fmap,'Text');
      oldofs:=filepos(fin);
      getmem(bufout,tempsize);
      seek(fin,tempofs);
      blockread(fin,bufout^,tempsize);
      point:=bufout;
      repeat

       write(fmap,point^,' ');
       inc(word(point),2);

       write(fmap,point^,' ');
       inc(word(point),2);

       write(fmap,point^,' ');
       inc(word(point),2);

       write(fmap,point^,' ');
       inc(word(point),2);
       writeln(fmap,byte(point^));
       inc(word(point));
      until point^=$FFFF;
      write(fmap,point^);
      inc(word(point),2);
      repeat
       if byte(point^)>=$20 then begin
	write(fmap,char(point^));
	inc(word(point));
       end else begin
	writeln(fmap);
	writeln(fmap,byte(point^),' ');
	case byte(point^) of
	 1:begin
	    inc(word(point));
	    writeln(fmap,byte(point^));
	    goto err4;
	   end;
	2,5:begin
	    inc(word(point));
	    write(fmap,point^,' ');
	    inc(word(point),2);
	    writeln(fmap,point^);
	    inc(word(point),2);
	   end;
	 3:begin
	    inc(word(point));
	    writeln(fmap,byte(point^));
	    inc(word(point));
	   end;
	 else begin
	   writeln(fmap,'Error!');
	   goto Err4;
	 end;
	end;
       end;
      until false;
Err4:
      seek(fin,oldofs);
      freemem(bufout,tempsize);
    end else begin
      writeln(fmap,'Empty');
      writeln(fmap,tempsize);
    end;
   end;
   close(fmap);
 end else
 if (paramstr(1)='/t''') then begin
   if paramcount<3 then goto err;
   assign(fmap,paramstr(3));
   rewrite(fmap);
   blockread(fin,size,2);
{  writeln(fmap,size);}
   for i:=1 to size do begin
    blockread(fin,tempofs,2);
    blockread(fin,tempsize,2);
    if tempofs<>$FFFF then begin
{     writeln(fmap,'Text');}
      oldofs:=filepos(fin);
      getmem(bufout,tempsize);
      seek(fin,tempofs);
      blockread(fin,bufout^,tempsize);
      point:=bufout;
      repeat

{      write(fmap,point^,' ');}
       inc(word(point),2);

{      write(fmap,point^,' ');}
       inc(word(point),2);

{      write(fmap,point^,' ');}
       inc(word(point),2);

{      write(fmap,point^,' ');}
       inc(word(point),2);
{      writeln(fmap,byte(point^));}
       inc(word(point));
      until point^=$FFFF;
{     write(fmap,point^);}
      inc(word(point),2);
      repeat
       if byte(point^)>=$20 then begin
	write(fmap,char(point^));
	inc(word(point));
       end else begin
	writeln(fmap);
{	writeln(fmap,byte(point^),' ');}
	case byte(point^) of
	 1:begin
	    inc(word(point));
{	    writeln(fmap,byte(point^));}
	    goto err4_;
	   end;
	2,5:begin
	    inc(word(point));
{	    write(fmap,point^,' ');}
	    inc(word(point),2);
{	    writeln(fmap,point^);}
	    inc(word(point),2);
	   end;
	 3:begin
	    inc(word(point));
{	    writeln(fmap,byte(point^));}
	    inc(word(point));
	   end;
	 else begin
	   writeln(fmap,'Error!');
	   goto Err4_;
	 end;
	end;
       end;
      until false;
Err4_:
      seek(fin,oldofs);
      freemem(bufout,tempsize);
    end else begin
{     writeln(fmap,'Empty');
      writeln(fmap,tempsize);}
    end;
   end;
   close(fmap);
 end else

 if (paramstr(1)='/e') then begin
   if paramcount<3 then goto err;
   assign(fout,paramstr(3));
   rewrite(fout,1);
   line:=0;
   readln(fmap,size);
   inc(line);

   blockwrite(fout,size,2+size*4);
   getmem(bufout,$4000);
   for i:=1 to size do begin
    tempofs:=filepos(fout);
    readln(fmap,fname);
    inc(line);

    if fname='Text' then begin
      tempsize:=word(bufout);
      point:=bufout;
      repeat
       read(fmap,point^);
       if point^=$FFFF then goto En;
       x1:=point^;
       inc(word(point),2);
       read(fmap,point^);
       sname:='';
       xptr:=@p;
       y1:=point^;
       yold:=-8;
       inc(word(point),2);
       read(fmap,point^);

       x2:=point^;
       inc(word(point),2);
       read(fmap,point^);

       y2:=point^;
       inc(word(point),2);
       readln(fmap,byte(point^));
       inc(line);

       inc(word(point));
      until false;
En:
      inc(word(point),2);
      repeat
      readln(fmap,fname);
      inc(line);

      while fname[length(fname)]=' ' do begin
       dec(fname[0]);
      end;
      val(fname,byte(point^),j);
      if j<>0 then begin
GetString:
       sname:=fname;
       asm
	les di,point
	lea si,fname
	xor ch,ch
	mov cl,[si]
	inc si
	jcxz @1
	add word ptr point,cx
@2:
	lodsb
	cmp al,'р'
	jb @3
	sub al,'р'-'п'-1
@3:
	stosb
	loop @2
@1:
       end;
      end else begin
	case byte(point^) of
	 1:begin
	    inc(word(point));
	    if length(sname)*8>x2-x1 then
	      writeln('Warning! Line ',line,': too long!');
	    if y1<190 then
	     xptr^:=(x2-x1-length(sname)*8) div 2;
	    readln(fmap,byte(point^));
	    inc(line);

	    inc(word(point));
	    goto err5;
	   end;
	2,5:begin
	    inc(word(point));
	    if length(sname)*8>x2-x1 then
	      writeln('Warning! Line ',line,': too long!');
	    if y1<190 then
	     xptr^:=(x2-x1-length(sname)*8) div 2;
	    xptr:=point;
	    read(fmap,point^);
	    inc(word(point),2);
	    readln(fmap,point^);
	    if yold>integer(point^)-8 then writeln('Warning! Line ',line,': too near!');
	    yold:=point^;
	    inc(word(point),2);
	    inc(line);
	    readln(fmap,fname);
	    inc(line);
	    goto getstring;
	   end;
	 3:begin
	    inc(word(point));
	    readln(fmap,byte(point^));
	    inc(line);
	    inc(word(point));
	   end;
	 end;
	end;
      until false;
Err5: tempsize:=word(point)-tempsize;
      blockwrite(fout,bufout^,tempsize);
    end else begin
      tempofs:=$FFFF;
      readln(fmap,tempsize);
    end;
    oldofs:=filepos(fout);
    seek(fout,(i-1)*4+2);
    blockwrite(fout,tempofs,2);
    blockwrite(fout,tempsize,2);
    seek(fout,oldofs);
   end;
   freemem(bufout,$4000);
   close(fout);
 end else
 if (paramstr(1)='/f') or (paramstr(1)='/l') then begin
   if paramcount<3 then goto err;
   assign(fout,paramstr(3));
   rewrite(fout,1);
   if (paramstr(1)='/f') then begin
    seek(fin,4);
    filecopy(fin,fout,filesize(fin)-4);
    blockwrite(fout,fout,256*8-filesize(fin)+4)
   end else begin
    oldofs:=$E1200808;
    blockwrite(fout,oldofs,4);
    filecopy(fin,fout,8*($E2-$20));
   end;
   close(fout);
 end else
 if (paramstr(1)='/o') then begin
   assign(fcommun,'COMMUN.EX1');
   reset(fcommun,1);

   assign(fbat,'makeext.bat');
   rewrite(fbat);
   assign(fmap,'ext.txt');
   rewrite(fmap);
   writeln(fmap,paramstr(2));
   blockread(fin,size,2);
   writeln(fmap,size);
   for i:=1 to size do begin
    blockread(fin,ext,sizeof(ext));
    with ext do begin
      str(i,sname);
      fname:='view.'+sname;
      writeln(fmap,fname);
      writeln(fmap,name,' ',id1,' ',id2,' ',id1 and $7FFF);

      writeln(fbat,'rem -----------------------------');
      writeln(fbat,'gobcrack /pv ????? ','view'+sname+'.unp');
      writeln(fbat,'lzpack view'+sname+'.unp ',fname+'_');
      writeln(fbat,'copy /b 121 ',fname+'_ ',fname);


      assign(fout,fname);
      rewrite(fout,1);
      if offset>=0 then begin
       oldofs:=filepos(fin);
       seek(fin,offset+size*sizeof(ext)+3);
       filecopy(fin,fout,f_size);
       seek(fin,oldofs);
      end else begin
       seek(fcommun,-offset-1);
       filecopy(fcommun,fout,f_size);
      end;

      close(fout);
    end;
   end;
   close(fmap);
   writeln(fbat,'gobcrack /d ext.txt');
   close(fbat);
   close(fcommun);
 end else
 if (paramstr(1)='/ima') then begin
   assign(fcommun,paramstr(2));
   reset(fcommun,1);
   assign(fmap,'ima.txt');
   rewrite(fmap);
   blockread(fin,size,4);
   j1:=size;
   size:=size div 4;
   writeln(fmap,size);
   for i:=1 to size do begin
    str(i,sname);
    fname:='view.'+sname;
    writeln(fmap,fname);
    assign(fout,fname);
    rewrite(fout,1);
    if i=size then
     j2:=filesize(fin)
    else blockread(fin,j2,4);
    oldofs:=filepos(fin);
    seek(fin,j1);
    filecopy(fin,fout,j2-j1);
    seek(fin,oldofs);
    close(fout);
    j1:=j2;
   end;
   close(fmap);
   close(fcommun);
 end else
 if (paramstr(1)='/s') or (paramstr(1)='/s1') then begin
  if paramcount<5 then goto Err;
  val(paramstr(3),i,p);
  if (i=0) or (p<>0) then goto Err;
  val(paramstr(4),j,p);
  if (j=0) or (p<>0) then goto Err;
  p:=filesize(fin);
  assign(fout,paramstr(5));
  {$I-}
  reset(fout,1);
  if ioresult<>0 then goto Check;
  {$I+}
  blockread(fout,palette,768);
  getmem(buffer,p);
  blockread(fin,buffer^,p);
  asm
   mov ax,$13
   int $10
  end;
  setpalette;
  if (paramstr(1)='/s1') then begin
   getmem(bufout,i*j);
   unpackoldpicture(buffer,bufout,i*j);
  end else begin
   bufout:=buffer;
  end;

  asm
   push ds
   mov	cx,j
   mov	bx,i
   mov ax,$a000
   mov es,ax
   xor di,di
   lds si,bufout
@1:
   push cx
@2:
   mov cx,bx
   rep movsb
   sub di,bx
   add di,320
   pop cx
   loop @1
   pop	ds
  end;
  if paramcount=6 then putpcx(0,0,i,j,paramstr(6));
  readkey;
  freemem(buffer,p);
 end else
 if (paramstr(1)='/a') then begin
  if paramcount<3 then goto Err;
  seek(fin,$34);
  blockread(fin,oldofs,4);
  if oldofs>0 then begin
   assign(fout,paramstr(3));
   rewrite(fout,1);
   seek(fin,oldofs);
   filecopy(fin,fout,filesize(fin)-oldofs);
   close(fout);
  end;
 end else
 if (paramstr(1)='/b') then begin
  if paramcount<3 then goto Err;
   assign(fout,paramstr(3));
   reset(fout,1);
   seek(fout,$34);
   blockread(fout,oldofs,4);
   seek(fout,oldofs);
   filecopy(fin,fout,filesize(fin));
   close(fout);
 end else
 if (paramstr(1)='/d') then begin
   readln(fmap,fname);
   assign(fout,fname);
   rewrite(fout,1);
   readln(fmap,size);
   blockwrite(fout,size,3+size*sizeof(ext));
   for i:=1 to size do begin
    readln(fmap,fname);
    assign(fin,fname);
    reset(fin,1);
    with ext do begin
      readln(fmap,name,id1,id2);
      f_size:=filesize(fin);
      if f_size<>0 then begin
       offset:=filepos(fout)-size*sizeof(ext)-3;
       filecopy(fin,fout,f_size);
      end else offset:=-1;
      oldofs:=filepos(fout);
      seek(fout,(i-1)*sizeof(ext)+2);
      blockwrite(fout,ext,sizeof(ext));
      seek(fout,oldofs);
      close(fin);
    end;
   end;
   close(fout);
 end else
 if (paramstr(1)='/pv') or (paramstr(1)='/pv1') then begin
  asm
   mov ax,$13
   int $10
  end;
  getpcxrange(x1,y1,paramstr(2));
  _getpcx(0,0,paramstr(2));
  assign(fout,paramstr(3));
  rewrite(fout,1);
  if (paramstr(1)='/pv1') then begin
   getmem(buffer,(x1+1)*(y1+1));
   getmem(bufout,(x1+1)*(y1+1));
   for i:=0 to y1 do
    move(ptr($A000,i*320)^,ptr(seg(buffer^),ofs(buffer^)+i*(X1))^,x1);
   blockwrite(fout,bufout^,packoldpicture(buffer,bufout,(x1)*(y1+1)));
   freemem(bufout,(x1+1)*(y1+1));
   freemem(buffer,(x1+1)*(y1+1));
  end else
   for i:=0 to y1 do
    blockwrite(fout,ptr($A000,i*320)^,x1+1);
  close(fout);
 end;
 if (paramstr(1)='/c') or (paramstr(1)='/e')  or (paramstr(1)='/d') then
  close(fmap) else close(fin);
end.