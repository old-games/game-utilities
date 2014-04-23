unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Bass, ExtCtrls, BitStream;

const PAL = 'P';
const RAW = #0;
const BTC = #1;
const FILL = #2;
const NUL = 'N';

type
  TForm1 = class(TForm)
    btnOpen: TButton;
    lblJV: TLabel;
    lbl00: TLabel;
    lblBla: TLabel;
    lblRes: TLabel;
    lblNofFrames: TLabel;
    lblRate: TLabel;
    lblMaxSize: TLabel;
    lblFreq: TLabel;
    lblFlags01: TLabel;
    lblVolume: TLabel;
    lblUnused: TLabel;
    lblName: TLabel;
    sgFrTable: TStringGrid;
    btnPlayAudio: TButton;
    btnStopAudio: TButton;
    imgPal: TImage;
    lblCurPal: TLabel;
    imgFrame: TImage;
    lblFrame: TLabel;
    btnResetCurPal: TButton;
    btnPlayVideo: TButton;
    btnStopVideo: TButton;
    btnPlayAll: TButton;
    btnStopAll: TButton;
    dlgOpen: TOpenDialog;
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPlayAudioClick(Sender: TObject);
    procedure btnStopAudioClick(Sender: TObject);
    procedure btnResetCurPalClick(Sender: TObject);
    procedure sgFrTableClick(Sender: TObject);
    procedure sgFrTableKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnPlayVideoClick(Sender: TObject);
    procedure btnStopVideoClick(Sender: TObject);
    procedure btnPlayAllClick(Sender: TObject);
    procedure btnStopAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TPlayThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;
  TFrame = Record
    FrameType: char;
    Size: cardinal;
    AudioSize: cardinal;
    VideoSize: cardinal;
    Palette: TPalette;
    VideoData: TMemoryStream;
    AudioData: TMemoryStream;
  end;

var
  Form1: TForm1;
  movie: file;
  MWidth, MHeight: word;

  block:  array of char;
  pal256: array [0..767] of byte;
  v8: byte;
  v16: word;
  v32: longword;

  FrameTable: array of TFrame;
  DataOffset: LongWord;

  AudioBuffer: TMemoryStream;
  AudioStream: HSTREAM;
  AudioSize: Cardinal;

  VideoSize: Cardinal;
  VideoFrame: VFrame;
  PlayThread: TPlayThread;
  Rate: Cardinal;

  CurPalette: TPalette;

implementation

{$R *.dfm}

procedure ShowPalette(Pal: TPalette);
var i: integer;
    Rect: TRect;
begin
  for i := 0 to 255 do
    With Form1.imgPal.Canvas do begin
      Brush.Color := TBGRA2Color(Pal[i]);
      Rect.Top := (i div 16) * 8;
      Rect.Bottom := Rect.Top + 8;
      Rect.Left := i mod 16 * 8;
      Rect.Right := Rect.Left + 8;
      Form1.imgPal.Canvas.Rectangle(Rect);
    end;
end;

procedure TForm1.btnOpenClick(Sender: TObject);
var i,j, NofFrames: cardinal;
begin
  if not dlgOpen.Execute then Exit;
  AssignFile(movie, dlgOpen.FileName);

  Reset(movie, 1);

  SetLength(block, 3);
  block[2] := #0;
  BlockRead(movie, block[0], 2);
  if PChar(@block[0]) <> 'JV' then begin
    ShowMessage('This is not a JV movie');
    CloseFile(movie);
    Exit;
  end;
  BASS_ChannelStop(AudioStream);
  BASS_StreamFree(AudioStream);
  lblName.Caption := dlgOpen.FileName;
  lblJV.Caption := PChar(@block[0]);

  BlockRead(movie, block[0], 2);
  lbl00.Caption := PChar(@block[0]);

  SetLength(block, $4C);
  BlockRead(movie, block[0], $4C);
  lblBla.Caption := PChar(@block[0]);

  BlockRead(movie, v16, 2);
  lblRes.Caption := IntToStr(v16);
  MWidth := v16;

  BlockRead(movie, v16, 2);
  lblRes.Caption := lblRes.Caption + 'x' + IntToStr(v16);
  MHeight := v16;

  BlockRead(movie, v16, 2);
  lblNofFrames.Caption := IntToStr(v16) + ' frames';
  NofFrames := v16;

  BlockRead(movie, v16, 2);
  lblRate.Caption := IntToStr(v16) + ' ms between frames';
  Rate := v16;

  BlockRead(movie, v32, 4);
  lblMaxSize.Caption := IntToStr(v32) + ' bytes per frame max';

  BlockRead(movie, v32, 4);
  lblFreq.Caption := IntToStr(v32) + ' Hz';

  BlockRead(movie, v8, 1);
  lblFlags01.Caption := IntToStr(v8);

  BlockRead(movie, v8, 1);
  lblVolume.Caption := 'Volume code: ' + IntToStr(v8);

  SetLength(block, 7);
  block[6] := #0;
  BlockRead(movie, block[0], 6);
  lblUnused.Caption := '';
  for i := 0 to 5 do
    lblUnused.Caption := lblUnused.Caption + IntToHex(Integer(block[i]), 2) + ' ';

  sgFrTable.RowCount := 0;
  sgFrTable.RowCount := NofFrames + 1;
  SetLength(FrameTable, NofFrames);

  sgFrTable.FixedRows := 1;
  sgFrTable.Rows[0].Add('Frame ¹');
  sgFrTable.Rows[0].Add('Block size');
  sgFrTable.Rows[0].Add('Audio size');
  sgFrTable.Rows[0].Add('Video size');
  sgFrTable.Rows[0].Add('Type');

  SetLength(block, 4);
  for i := 1 to NofFrames do
  begin
    sgFrTable.Rows[i].Clear;
    sgFrTable.Rows[i].Add(IntToStr(i));

    BlockRead(movie, v32, 4);
    sgFrTable.Rows[i].Add(IntToStr(v32));
    FrameTable[i-1].Size := v32;

    BlockRead(movie, v32, 4);
    sgFrTable.Rows[i].Add(IntToStr(v32));
    FrameTable[i-1].AudioSize := v32;
    FrameTable[i-1].AudioData := TMemoryStream.Create;
    FrameTable[i-1].AudioData.SetSize(v32);

    BlockRead(movie, v32, 4);
    sgFrTable.Rows[i].Add(IntToStr(v32));
    FrameTable[i-1].VideoSize := v32;
    FrameTable[i-1].VideoData := TMemoryStream.Create;
    FrameTable[i-1].VideoData.SetSize(v32);

    BlockRead(movie, block[0], 4);
    if block[0] = #1 then begin
      sgFrTable.Rows[i].Add('Palette');
      FrameTable[i-1].FrameType := PAL;
      continue;
    end;

    if v32 = 0 then begin
      sgFrTable.Rows[i].Add('Empty');
      FrameTable[i-1].FrameType := NUL;
      continue;
    end;

    FrameTable[i-1].FrameType := block[2];
    case block[2] of
      #0: sgFrTable.Rows[i].Add('Raw');
      #1: sgFrTable.Rows[i].Add('BTC');
      #2: sgFrTable.Rows[i].Add('Fill');
    end;
  end;

  DataOffset := $68 + 16*NofFrames;
  Seek(movie, DataOffset);
  AudioSize := 0;
  for i := 0 to Length(FrameTable)-1 do
  begin
    AudioSize := AudioSize + FrameTable[i].AudioSize;
    VideoSize := VideoSize + FrameTable[i].VideoSize;
    BlockRead(movie, FrameTable[i].AudioData.Memory^, FrameTable[i].AudioSize);
    if FrameTable[i].FrameType = PAL then begin
      BlockRead(movie, pal256[0], 768);
      for j := 0 to 255 do
        FrameTable[i].Palette[j] := ToBGRA(pal256[j*3]*4,pal256[j*3+1]*4,pal256[j*3+2]*4, 0);
    end;
    BlockRead(movie, FrameTable[i].VideoData.Memory^, FrameTable[i].VideoSize);
  end;

  CloseFile(movie);

  SetLength(VideoFrame, MHeight*MWidth);

  AudioBuffer.SetSize(AudioSize);
  AudioBuffer.Seek(0, 0);
  for i := 0 to Length(FrameTable)-1 do
    AudioBuffer.Write(FrameTable[i].AudioData.Memory^, FrameTable[i].AudioSize);

  btnPlayAudio.Enabled := True;
  btnStopAudio.Enabled := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  btnResetCurPalClick(Sender);
  if not BASS_Init(-1, 44100, 0, Handle, nil) then begin
    ShowMessage('Error BASS initialization!');
    Halt;
  end;
  AudioBuffer := TMemoryStream.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  btnStopVideoClick(Sender);
  BASS_StreamFree(AudioStream);
  BASS_Free;
  AudioBuffer.Free;
end;

procedure TForm1.btnPlayAudioClick(Sender: TObject);
begin
  BASS_ChannelStop(AudioStream);
  BASS_StreamFree(AudioStream);
  AudioStream := BASS_StreamCreate(22050, 1, BASS_SAMPLE_8BITS, STREAMPROC_PUSH, nil);
  BASS_ChannelPlay(AudioStream, True);
  BASS_StreamPutData(AudioStream, AudioBuffer.Memory, AudioSize);
end;

procedure TForm1.btnStopAudioClick(Sender: TObject);
begin
  BASS_ChannelStop(AudioStream);
  BASS_StreamFree(AudioStream);
end;

procedure TForm1.btnResetCurPalClick(Sender: TObject);
var i: integer;
begin
  for i := 0 to 255 do
    CurPalette[i] := Color2TBGRA(0);
  lblCurPal.Caption := 'No current palette';
  ShowPalette(CurPalette);
end;

procedure Decode(var Pal: TPalette);
var Frame: BitStream.BTCFrame;
    BTCAct: BitStream.BTC;
    NofBlocks: Cardinal;
begin
  Frame := BitStream.BTCFrame.Create(@VideoFrame, MWidth, Pal);
  BTCAct := BitStream.BTC.Create(@Frame);
  NofBlocks := MWidth*MHeight div (8*8);

   while BTCAct.GetBlockNumber <= NofBlocks do begin
      case GetNextBits(2) of
        0: BTCAct.IncBlock;
        1: BTCAct.FillBlockSolid;
        2: BTCAct.FillBlockMask;
        3: BTCAct.SetBlockSizeIn;
      end;
    end;
    //BTCAct := nil;
    //Frame := nil;
end;

procedure ShowFrame(FrameNumber: Cardinal);
var CurFrame: TFrame;
    temp: byte;
    i: Cardinal;
    lpbmi: BITMAPINFO;
    bmiHeader: BITMAPINFOHEADER;
    Handle: HDC;
begin
  CurFrame := FrameTable[FrameNumber];
  Handle := Form1.imgFrame.Canvas.Handle;

  bmiHeader.biSize := sizeof(bmiHeader);
  bmiHeader.biWidth := MWidth;
  bmiHeader.biHeight := -MHeight;
  bmiHeader.biPlanes := 1;
  bmiHeader.biBitCount := 32;
  bmiHeader.biCompression := BI_RGB;
  bmiHeader.biSizeImage := 0;
  bmiHeader.biXPelsPerMeter := 0;
  bmiHeader.biYPelsPerMeter := 0;
  bmiHeader.biClrUsed := 0;
  bmiHeader.biClrImportant := 0;
  lpbmi.bmiHeader := bmiHeader;

  if CurFrame.FrameType = FILL then begin
    temp := Integer(CurFrame.VideoData.Memory^);
    for i := 0 to (MHeight*MWidth)-1 do
      VideoFrame[i] := CurPalette[temp];
    SetDIBitsToDevice(Handle, 0, 0, MWidth, MHeight,
      0, 0, 0, MHeight, @VideoFrame[0], lpbmi, DIB_RGB_COLORS);
    Form1.imgFrame.Repaint;
    Form1.lblFrame.Caption := 'Frame #'+IntToStr(FrameNumber)+
                        ', type: Fill (by color '+IntToStr(temp)+')';
  end;

  if CurFrame.FrameType = BTC then begin
    SetBitStream(CurFrame.VideoData.Memory);
    Decode(CurPalette);
    {for i := 0 to (MHeight-1) do
      for j := 0 to (MWidth-1) do
        imgFrame.Canvas.Pixels[j,i] := VideoFrame[j+i*MWidth];}
    SetDIBitsToDevice(Handle, 0, 0, MWidth, MHeight,
      0, 0, 0, MHeight, @VideoFrame[0], lpbmi, DIB_RGB_COLORS);
    Form1.imgFrame.Repaint;
    Form1.lblFrame.Caption := 'Frame #'+IntToStr(FrameNumber)+', type: BTC)';
  end;

end;

function ActFrame(FrameNumber: Cardinal): boolean;
var CurFrame: TFrame;
begin
  Result := false;
  if Length(FrameTable) > 0 then begin
    CurFrame := FrameTable[FrameNumber];
    Result := true;

    if CurFrame.FrameType = PAL then begin
      Result := false;
      CurPalette := FrameTable[FrameNumber].Palette;
      ShowPalette(CurPalette);
      Form1.lblCurPal.Caption := 'Current palette: frame #' + IntToStr(FrameNumber+1);
    end;
    if CurFrame.FrameType <> NUL then
      ShowFrame(FrameNumber);
  end;
end;

procedure TForm1.sgFrTableClick(Sender: TObject);
begin
    ActFrame(sgFrTable.Row-1);
end;

procedure TForm1.sgFrTableKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  sgFrTableClick(Sender);
end;

procedure TForm1.btnPlayVideoClick(Sender: TObject);
begin
  btnStopVideoClick(Sender);
  PlayThread := TPlayThread.Create(false);
//  PlayThread.FreeOnTerminate := true;
  sgFrTable.Enabled := False;
end;

procedure TForm1.btnStopVideoClick(Sender: TObject);
begin
  try
    if (PlayThread <> nil) and (not PlayThread.Terminated) then begin
      PlayThread.Suspend;
      PlayThread.Terminate;
      //PlayThread.Destroy;
      PlayThread := nil;
    end;
  except
  end;
  sgFrTable.Enabled := True;
end;

{procedure TForm1.tmrPlayTimer(Sender: TObject);
begin
  if (CurFrameNumber < Length(FrameTable)) and (CurFrameNumber >= 0) then
    while not ActFrame(CurFrameNumber) do inc(CurFrameNumber);
  inc(CurFrameNumber);
end;}

procedure TForm1.btnPlayAllClick(Sender: TObject);
begin
  btnPlayVideoClick(Sender);
  btnPlayAudioClick(Sender);
end;

procedure TForm1.btnStopAllClick(Sender: TObject);
begin
  btnStopVideoClick(Sender);
  btnStopAudioClick(Sender);
end;

procedure TPlayThread.Execute;
var CurFrameNumber: Integer;
    time: Cardinal;
    NofFrames: Integer;
begin
    CurFrameNumber := 0;
    NofFrames := Length(FrameTable);
    time := GetTickCount;
    while CurFrameNumber < NofFrames do begin
      if ActFrame(CurFrameNumber) then begin
        time := GetTickCount - time;
        if time < Rate then Sleep(Rate - time);
        time := GetTickCount;
      end;
      Inc(CurFrameNumber);
    end;
    Form1.sgFrTable.Enabled := True;
end;

{procedure TForm1.btnToGifClick(Sender: TObject);
var BMPImg: TBitmap;
    i: cardinal;
    Palt: TPalette;
    CurFrame: TFrame;
    Picture: TPicture;
begin
  for i := 0 to 255 do Palt[i] := Color2TBGRA(0);
  if Length(FrameTable) > 0 then begin
    GifAnimateBegin(MWidth, MHeight);
    BMPImg := TBitmap.Create;
    BMPImg.Width := MWidth;
    BMPImg.Height := MHeight;
    for i := 0 to Length(FrameTable) - 1 do begin
      CurFrame := FrameTable[i];
      if CurFrame.FrameType = PAL then Palt := FrameTable[i].Palette;
      if CurFrame.FrameType <> NUL then begin
        ShowFrame(i, BMPImg.Canvas.Handle, false, Palt);
        BMPImg.Modified := true;
        GifAnimateAddImage(BMPImg, false, Rate);
        BMPImg.SaveToFile(ExtractFilePath(ParamStr(0)) + 'jjj\jjj'+IntToStr(i)+'.bmp');
      end;
    end;
    Picture := GifAnimateEndPicture;
    Picture.SaveToFile(ExtractFilePath(ParamStr(0)) + 'ololo.gif');
    Picture.Free;
    BMPImg.Free;
  end;
end;}

end.
