program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  BitStream in 'BitStream.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Z Video Tool';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
