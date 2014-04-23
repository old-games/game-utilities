unit MooFontConverter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, StdCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    N1: TMenuItem;
    Moo1: TMenuItem;
    Image1: TImage;
    BMP1: TMenuItem;
    BMP2: TMenuItem;
    BMP3: TMenuItem;
    procedure Moo1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BMP1Click(Sender: TObject);
    procedure BMP2Click(Sender: TObject);
    procedure BMP3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
Var
  InputFile:   File;
  OutputFile:  File;
  massivwidth: array [1..768] of byte;
  massivoffset: array [1..768] of word;

Procedure LoadWidth();
var i: integer;
begin
  seek(inputfile,$19A);
  for i:=1 to 768 do
  begin
    BlockRead(InputFile,massivwidth[i],1);
  end;

end;

Procedure loadoffset();
var i: integer;
begin
  seek(inputfile,$49A);
  for i:=1 to 768 do
  begin
    BlockRead(InputFile,massivoffset[i],2);
  end;
end;

Procedure Showfonts();
var i,a,b,c: integer;
    temp: byte;
    color,len,test: byte;
    x,y,r,n,k: integer;
    dataLen: integer;
begin
  x:= 0;
  y:= 0;
  n:= 1;
  r:= 0;
  c:=1;
for c:= 1 to 48 do
  begin
  Form1.Image1.Canvas.Pen.Color:= clYellow;
  Form1.Image1.Canvas.MoveTo(x,y);
  Form1.Image1.Canvas.LineTo(209,y);

    for i:=1 to 16 do
      begin
          Form1.Image1.Canvas.Pen.Color:= clYellow;
          Form1.Image1.Canvas.MoveTo(x,y);
          Form1.Image1.Canvas.LineTo(x,y+13);
          Form1.Image1.Canvas.Pixels[x+massivwidth[n]+1,y]:= RGB(255,0,0);
          x:=x+1;
       seek(inputfile,massivoffset[n]);
        dataLen:= massivoffset[(n+1)] - massivoffset[n];
        if (n > 250) and (n < 288)then
          begin
            dataLen:= 0;
            x:=x+massivwidth[n];
          end;
        if dataLen > 0 then
          begin
            for a:=1 to dataLen do
              begin
                BlockRead(InputFile,temp,1);
                if temp<$80 then
                  begin
                    color:= 255 -(temp or $f0)*16;
                    len:= temp shr 4;

                    for b:=1 to len do
                      begin
                        Form1.Image1.Canvas.Pixels[x,y+1]:= RGB(color,color,color);
                        y:=y+1;
                      end;
                  end
                else if temp > $80 then
                  begin
                    len:= temp - $80;
                    y:=y+len;
                  end
                else if temp = $80 then
                  begin
                    x:=x+1;
                    y:= r;
                  end;
              end;
          end;
          x:= x+ (12- massivwidth[n]);
          y:=y+1;
          n:= n+1;
          y:= r;

        end;
      x:= 0;
      r:= r+13;
      y:= r;

    end;
          Form1.Image1.Canvas.Pen.Color:= clYellow;
          Form1.Image1.Canvas.MoveTo(209,0);
          Form1.Image1.Canvas.LineTo(209,624);
          Form1.Image1.Canvas.Pen.Color:= clYellow;
          Form1.Image1.Canvas.MoveTo(0,624);
          Form1.Image1.Canvas.LineTo(209,624);

  end;

procedure TForm1.Moo1Click(Sender: TObject);
begin
 Form1.OpenDialog1.FilterIndex:= 1;
  if Form1.OpenDialog1.Execute then
    begin
      AssignFile(InputFile,Form1.OpenDialog1.FileName);
      Reset(InputFile,1);
    end
 else exit;

 loadwidth();
 loadoffset();
 Showfonts();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Form1.Image1.Canvas.Brush.Color:= clBlack;
Form1.Image1.Canvas.Rectangle(0,0,209,624);
end;

procedure TForm1.BMP1Click(Sender: TObject);
begin
  Form1.Image1.Picture.SaveToFile('MooFont.bmp');
  ShowMessage('Конвертация закончена');
end;

procedure TForm1.BMP2Click(Sender: TObject);
begin
 if Form1.OpenDialog1.Execute then
    begin

        If Copy(Form1.OpenDialog1.FileName,Length(Form1.OpenDialog1.FileName)-3,Length(Form1.OpenDialog1.FileName)) = '.bmp' then
          begin
           Form1.Image1.Picture.LoadFromFile(Form1.OpenDialog1.FileName);
           exit;
          end;
    end;
end;

procedure TForm1.BMP3Click(Sender: TObject);
var a,b,x,y,kx,ky,n,r,len: integer;
    black,white,col1,col2: byte;
    SSOffset: word;
    temp: byte;
begin
      AssignFile(OutputFile,'FONT.000.new');
      Rewrite(OutputFile,1);
  x:= 0;
  n:= 1;

  temp:= $00;
  for a:= 1 to $16a do
  begin
  blockwrite(OutputFile,temp,1);
  end;

  temp:= $06;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $07;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $05;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $09;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $0a;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $09;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $01;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $02;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $01;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $01;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $01;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $01;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $02;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $03;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $03;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $03;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $03;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $03;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);
  temp:= $00;
  blockwrite(OutputFile,temp,1);

  for a:= 1 to 48 do
  begin
    for b:=1 to 16 do
      begin
        len:=0;
        for x:= 1 to 13 do //ищем ширину символа
        begin
          if form1.Image1.Canvas.Pixels[x+(13*(b-1)),y+(13*(a-1))]= RGB(255,0,0) then len:= x-1;

        end;
        blockwrite(OutputFile,len,1);
        massivwidth[n]:= len;
        n:=n+1;
       end;
  end;

  SSOffset:= $A9A;
  massivoffset[1]:= SSOffset;

  temp:=0;
  for a:=1 to 1536 do
  begin
  blockwrite(OutputFile,temp,1);
  end;

  x:= 0;
  y:= 0;
  n:= 1;
  for a:= 1 to 48 do
  begin
    for b:=1 to 16 do
      begin
        len:=0;
        for x:= 1 to massivwidth[n] do //ищем ширину символа
        begin
          black:= 1;
          white:= 1;
          for y:=1 to 11 do//бегаем по столбцу символа
            begin
               kx:= x+(13*(b-1));
               ky:= y+(13*(a-1));
               col1:= form1.Image1.Canvas.Pixels[kx,ky];
 //              col1:= GetRValue(strtoint(floattostr((col1/16)))+255);
               col2:= form1.Image1.Canvas.Pixels[kx,ky+1];
 //              col2:= strtoint(floattostr((col2/16)))+255;

               if (col1 = col2) and (col1 = RGB(0,0,0)) then black:= black+1
               else if (col1 = col2) and (col1 <> RGB(0,0,0)) then white:= white+1
               else If (col1 <> col2) and (col1 = RGB(0,0,0)) then
                begin
                  temp:= $80 + black;
                  blockWrite(OutputFile,temp,1);
                  SSOffset:= SSOffset+1;
                  black:= 1;
                  white:= 1;
                end
               else If (col1 <> col2) and (col1 <> RGB(0,0,0)) then
                begin
                  temp:= (white shl 4)+ strtoint(floattostr((255-GetRValue(col1))/16));
                  blockWrite(OutputFile,temp,1);
                  SSOffset:= SSOffset+1;
                  white:= 1;
                  black:= 1;
                end;
            end;
            if black > 1 then      //столбец полностью чёрный
              begin
                temp:= $80;
                blockWrite(OutputFile,temp,1);
                SSOffset:= SSOffset+1;
              end;
//            if white = 12 then      //столбец полностью белый
//              begin
//              SSOffset:= SSOffset+1;
//              end;
        end;
        n:=n+1;
        massivOffset[n]:= SSOffset;
       end;
  end;
  seek(outputfile,$49a);
  for n:=1 to 768 do
  begin
  blockwrite(OutputFile,massivOffset[n],2);
  end;


end;

end.
