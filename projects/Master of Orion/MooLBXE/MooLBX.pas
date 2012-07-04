unit MooLBX;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    ExtractLBX1: TMenuItem;
    PackLBX1: TMenuItem;
    procedure ExtractLBX1Click(Sender: TObject);
    procedure PackLBX1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var
  InputFile:  File;
  OutputFile: File;
  NFile:      Word;
  Unknown:    word;
  Temp:       byte;
  DAdress:    cardinal;
  DAdress2:    cardinal;
  ADAdress:   integer;
  AName:      integer;
  MooName: array[0..32] of char;
  a,b: integer;
  S: String;
  FName,BPath: String;
  Dsize: cardinal;

procedure TForm1.ExtractLBX1Click(Sender: TObject);

begin
  if OpenDialog1.Execute then
    begin
    AssignFile(InputFile,OpenDialog1.FileName);
    FName:= ExtractFileName(OpenDialog1.FileName);
    FName:= Copy(FName,1,Length(FName)-4);
    BPath:= Copy(OpenDialog1.FileName,1,length(OpenDialog1.FileName)-4);
    end
  else exit;
  Reset(InputFile,1);

  BlockRead(InputFile,NFile,2);
  BlockRead(InputFile,Unknown,2);
  BlockRead(InputFile,Temp,1);
  BlockRead(InputFile,Temp,1);
  BlockRead(InputFile,Temp,1);
  BlockRead(InputFile,Temp,1);
  createdir(BPath);

  ADAdress:= FilePos(InputFile);
  AName:= $200;
  for a:= 0 to NFile-1 do
    begin
      Seek(InputFile,AName);
      BlockRead(InputFile,MooName,32);
      AName:= FilePos(InputFile);
      if a <10 then s:= '00'+ inttostr(a)
      else if a <100 then s:= '0'+ inttostr(a)
      else s:= inttostr(a);

      AssignFile(OutputFile,BPath+'\'+FName+'.'+s);
      Rewrite(OutputFile,1);
      Seek(InputFile,ADAdress);
      BlockRead(InputFile,DAdress,4);
      ADAdress:= FilePos(InputFile);

      if a = NFile-1 then DAdress2:= FileSize(InputFile)
      else BlockRead(InputFile,DAdress2,4);
      Dsize:= DAdress2-DAdress;
      seek(InputFile,DAdress);
      while Dsize > 0 do
        begin
          BlockRead(InputFile,Temp,1);
          BlockWrite(OutputFile,Temp,1);
          Dsize:= Dsize-1;
        end;
    CloseFile(OutputFile);
    end;
  seek(InputFile,$200);
  AssignFile(OutputFile,BPath+'\'+FName+'.ini');
  Rewrite(OutputFile,1);
  BlockWrite(OutputFile,NFile,2);
      temp:=$0D;
      BlockWrite(OutputFile,temp,1);
      temp:=$0A;
      BlockWrite(OutputFile,temp,1);

  For a:=0 to NFile-1 do
    begin
      BlockRead(InputFile,MooName,32);
      BlockWrite(OutputFile,MooName,32);
      temp:=$01;
      BlockWrite(OutputFile,temp,1);
      temp:=$0D;
      BlockWrite(OutputFile,temp,1);
      temp:=$0A;
      BlockWrite(OutputFile,temp,1);

    end;
  CloseFile(OutputFile);

end;

procedure TForm1.PackLBX1Click(Sender: TObject);

begin

  if OpenDialog1.Execute then
    begin
      AssignFile(InputFile,OpenDialog1.FileName);
      AssignFile(OutputFile,Copy(OpenDialog1.FileName,1,Length(OpenDialog1.FileName)-4)+'.LBX');
      FName:= ExtractFileName(OpenDialog1.FileName);
      FName:= Copy(FName,1,Length(FName)-4);
      BPath:= Copy(OpenDialog1.FileName,1,length(OpenDialog1.FileName)-4);
    end;
  Reset(InputFile,1);
  Rewrite(OutputFile,1);
  BlockRead(InputFile,NFile,2);
  BlockWrite(OutputFile,NFile,2);
  temp:=$AD;
  BlockWrite(OutputFile,temp,1);
  temp:=$FE;
  BlockWrite(OutputFile,temp,1);
  temp:=$00;
  BlockWrite(OutputFile,temp,1);
  temp:=$00;
  BlockWrite(OutputFile,temp,1);
  temp:=$00;
  BlockWrite(OutputFile,temp,1);
  temp:=$00;
  BlockWrite(OutputFile,temp,1);

  DAdress:= FilePos(OutputFile);

  for a:=0 to 503 do
    begin
      temp:= $00;
      BlockWrite(OutputFile,temp,1);
    end;

  BlockRead(InputFile,temp,1);
  BlockRead(InputFile,temp,1);

  for a:= 0 to NFile-1 do
    begin
      BlockRead(InputFile,MooName,32);
      BlockWrite(OutputFile,MooName,32);
      BlockRead(InputFile,temp,1);
      BlockRead(InputFile,temp,1);
      BlockRead(InputFile,temp,1);
    end;
  CloseFile(InputFile);

  for a:= 0 to NFile-1 do
    begin
      if a <10 then s:= '00'+ inttostr(a)
      else if a <100 then s:= '0'+ inttostr(a)
      else s:= inttostr(a);
      AssignFile(InputFile,BPath+'.'+s);
      Reset(InputFile,1);
      
      DAdress2:= FilePos(OutputFile);
      seek(OutputFile,DAdress);
      BlockWrite(OutputFile,DAdress2,4);
      DAdress:= FilePos(OutputFile);
      seek(OutputFile,DAdress2);

      Dsize:= FileSize(InputFile);
      for b:=0 to Dsize-1 do
        begin
          BlockRead(InputFile,temp,1);
          BlockWrite(OutputFile,temp,1);
        end;
      CloseFile(InputFile);
    end;
      DAdress2:= FilePos(OutputFile);
      seek(OutputFile,DAdress);
      BlockWrite(OutputFile,DAdress2,4);
    
end;

end.
