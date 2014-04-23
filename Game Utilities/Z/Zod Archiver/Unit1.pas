unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ExtCtrls, ShlObj, Unit2, ComCtrls;

type
  TForm1 = class(TForm)
    dlgAddFiles: TOpenDialog;
    MainMenu1: TMainMenu;
    Unpacking1: TMenuItem;
    btnUnpack: TMenuItem;
    btnOpenArchive: TMenuItem;
    Panel1: TPanel;
    lblState: TLabel;
    pnlText: TPanel;
    dlgSaveArchive: TSaveDialog;
    dlgOpenArch: TOpenDialog;
    lstFiles: TListBox;
    Packing1: TMenuItem;
    btnPack: TMenuItem;
    btnChooseFiles: TMenuItem;
    btnReplace: TMenuItem;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    btnOpenReplArch: TMenuItem;
    btnSelectReplFiles: TMenuItem;
    procedure btnUnpackClick(Sender: TObject);
    procedure btnChooseFilesClick(Sender: TObject);
    procedure btnPackClick(Sender: TObject);
    procedure lstFilesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnOpenArchiveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOpenReplArchClick(Sender: TObject);
    procedure btnSelectReplFilesClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  NullString = array [0..11] of AnsiChar;
  JMP2cell = Record
    Name: NullString;
    Reserved: LongInt;
    Offset: LongInt;
    Size: LongInt;
  end;

var
  Form1: TForm1;
  SrcName: PAnsiChar;
  DestName: PAnsiChar;
  hSrc: Integer;
  hDest: Integer;
  SrcRob: _OFSTRUCT;
  DestRob: _OFSTRUCT;
  JMP2: array of JMP2cell;
  NewJMP2: array of JMP2cell;
  Mode: Integer; //1 - Packing, 2 - Unpacking, 3 - Replacing

implementation

{$R *.dfm}

function ShowChooseDirDialog: String;
const
  TitleName = 'Choose Destination Folder';
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of Char;
  TempPath: array[0..MAX_PATH] of Char;
begin
  Result := '';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), 0);

  BrowseInfo.hwndOwner := Application.Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := @TitleName[1];

  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemID <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := String(TempPath);
    GlobalFreePtr(lpItemID);
  end;
end;

procedure CutNullString(var str: string);
var i: Cardinal;
begin
  For i := 1 to Length(str)-1 do
    if str[i] = #0 then
     begin
      SetLength(str, i);
      break;
     end;
end;

function UnJMP2: boolean;
var n,i,LastByte: cardinal; NofFiles: integer; Str: array [0..3] of AnsiChar;
begin
  SrcName := PChar(Form1.dlgOpenArch.FileName);
  hSrc := OpenFile (SrcName, SrcRob, OF_READ);

  n := SetFilePointer (hSrc, -4, nil, FILE_END);
  ReadFile(hSrc, Str[0], 4, n, nil);
  If Str <> 'JMP2' then
  begin
    Result := false;
    exit;
  end;

  n := SetFilePointer (hSrc, -8, nil, FILE_END);
  ReadFile (hSrc, NofFiles, 4, n, nil);

  LastByte := SetFilePointer (hSrc, NofFiles*(-24)-8 , nil, FILE_END);
  For i := 0 to NofFiles-1 do
  begin
    SetLength(JMP2,i+1);
    ReadFile (hSrc, JMP2[i].Name, 12, n, nil);
    ReadFile (hSrc, JMP2[i].Reserved, 4, n, nil);
    ReadFile (hSrc, JMP2[i].Offset, 4, n, nil);
    ReadFile (hSrc, JMP2[i].Size, 4, n, nil);
  end;
  SetLength(JMP2,Length(JMP2)+1);
  JMP2[Length(JMP2)-1].Offset := LastByte;
  CloseHandle (hSrc);
  Result := True;
end;

function GetNameOnly(Src: string): NullString;
var i, n: Cardinal; Buff: string;
begin
  Buff := Src;
  For i := Length(Src) downto 1 do
    if Src[i] = '\' then
     begin
      Buff := Copy(Src, i+1, Length(Src)-1);
      break;
     end;
  for i := 0 to 11 do
    Result[i] := #0;
  n := Length(Buff)-1;
  if n > 11 then n := 11;
  for i := 0 to n do
    Result[i] := UpCase(Buff[i+1]);
end;

function isSlashesExist(Src: String): boolean;
var i: cardinal;
begin
  result := false;
  for i := 1 to Length(Src) do
    if Src[i] = '\' then result := true;
end;

procedure SetMode(ChangeTo: Integer);
begin
  With Form1 do begin
    Case ChangeTo of
      0: begin
          lblState.Caption := 'Mode: none';
          btnUnpack.Enabled := False;
          btnPack.Enabled := False;
          btnReplace.Enabled := False;
          btnSelectReplFiles.Enabled := False;
        end;
      1: begin
          lblState.Caption := 'Mode: packing';
          btnUnpack.Enabled := False;
          btnPack.Enabled := True;
          btnReplace.Enabled := False;
          btnSelectReplFiles.Enabled := False;
        end;
      2: begin
          lblState.Caption := 'Mode: unpacking ('+dlgOpenArch.FileName+')';
          btnUnpack.Enabled := True;
          btnPack.Enabled := False;
          btnReplace.Enabled := False;
          btnSelectReplFiles.Enabled := False;
        end;
      3: begin
          lblState.Caption := 'Mode: modifying ('+dlgOpenArch.FileName+')';
          btnUnpack.Enabled := False;
          btnPack.Enabled := False;
          btnReplace.Enabled := False;
          btnSelectReplFiles.Enabled := True;
        end;
      end;
  end;
  Mode := ChangeTo;
end;

procedure ChangeLst();
begin
  With Form1 do begin
    if (lstFiles.Items[0] = 'Select files to pack or open archive to unpack') then
        lstFiles.Items.Delete(0)
    else
    if lstFiles.Items.Count = 0 then
    begin
      lstFiles.Items.Add ('Select files to pack or open archive to unpack');
      SetMode(0);
    end;
  end;
end;

procedure TForm1.btnUnpackClick(Sender: TObject);
var Path, Name, Temp: String; i, j, n: cardinal; IsInList: boolean;
    SrcBuff, DestBuff, WriteBuff: Pointer;
    PackedLen, MemSize: Integer;
begin;
  Path := ShowChooseDirDialog;
  If Path <= '' then exit;

  pnlText.Visible := True;
  pnlText.Caption := 'Preparing...';
  Application.ProcessMessages;

  SetLength (Temp,MAX_PATH);
  SrcName := PChar(Form1.dlgOpenArch.FileName);
  hSrc := OpenFile (SrcName, SrcRob, OF_READ);

  for i := 0 to Length(JMP2)-1 do
  begin
    IsInList := False;
    for j := 0 to lstFiles.Items.Count-1 do
      if lstFiles.Items[j] = JMP2[i].Name then IsInList := True;
    If Not IsInList then continue;

    pnlText.Caption := 'Unpacking "'+JMP2[i].Name+'"...';
    Application.ProcessMessages;

    PackedLen := JMP2[i+1].Offset-JMP2[i].Offset;
    MemSize := JMP2[i].Size + 4096;
    SrcBuff := VirtualAlloc(nil, PackedLen, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);

    DestBuff := VirtualAlloc(nil, MemSize, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);
    SetFilePointer (hSrc, JMP2[i].Offset, nil, FILE_BEGIN);

    ReadFile (hSrc, SrcBuff^, PackedLen, n, nil);
    Unpack (SrcBuff, DestBuff, PackedLen-2);
    WriteBuff := Pointer(Integer(DestBuff) + $1000);

    Name := Path + '\'+JMP2[i].Name;
    DeleteFile(PChar(Name));
    hDest := OpenFile (PChar(Name), DestRob, OF_CREATE+OF_READWRITE);
    SetFilePointer (hDest, 0, nil, FILE_BEGIN);

    WriteFile (hDest, WriteBuff^, JMP2[i].Size, n, nil);

    CloseHandle(hDest);
    VirtualFree(SrcBuff, MemSize, MEM_RELEASE);
    VirtualFree(DestBuff, JMP2[i].Size+256, MEM_RELEASE);
  end;
  CloseHandle(hSrc);
  pnlText.Caption := 'Done!';
  MessageBox(Application.Handle, 'Unpacking complete.', 'Zod Archiver 2.0b', 0);
  pnlText.Visible := False;
end;

procedure TForm1.btnChooseFilesClick(Sender: TObject);
var i, j: integer; inList: boolean;
begin
  if dlgAddFiles.Execute then
  begin
    if Mode <> 1 then lstFiles.Items.Clear;
    SetMode(1);
    for i := 0 to dlgAddFiles.Files.Count - 1 do begin
      inList := false;
      for j := 0 to lstFiles.Items.Count - 1 do
         if GetNameOnly(dlgAddFiles.Files[i]) = GetNameOnly(lstFiles.Items[j]) then begin
           if MessageDlg('File "'+lstFiles.Items[j]+'" is already in list. Replace it with "'+dlgAddFiles.Files[i]+'"?', mtInformation, [mbYes, mbNo], 0) = mrYes then begin
              lstFiles.Items.Delete(j);
              lstFiles.Items.Add (dlgAddFiles.Files[i]);
           end;
           inList := true;
           break;
         end;
      if not inList then lstFiles.Items.Add(dlgAddFiles.Files[i]);
    end;
  end;
end;

procedure TForm1.btnPackClick(Sender: TObject);
var n, NofFiles, i: Cardinal;
    Path, Name, Arch: string;
    SrcBuff, DestBuff, ReadBuff: Pointer;
    PackedLen, MemSize, PossPackedLen: Integer;
begin
 if dlgSaveArchive.Execute then Arch := dlgSaveArchive.FileName else exit;

 pnlText.Visible := True;
 pnlText.Caption := 'Preparing...';
 Application.ProcessMessages;

 DestName := PChar(Arch);

 hDest := OpenFile (DestName, DestROB, OF_CREATE+OF_READWRITE);
 WriteFile (hDest, Concat(#0,#0,#0,#0), 4, n, nil);

 NofFiles := lstFiles.Items.Count;

 for i := 0 to (NofFiles-1) do
 begin
  Path := lstFiles.Items[i];
  pnlText.Caption := 'Packing "'+Path+'"...';
  Application.ProcessMessages;
  SetLength(Name, MAX_PATH);
  n := GetShortPathName (PChar(Path),PChar(Name),MAX_PATH-1);
  SetLength(Name, n);

  SetLength (JMP2,i+1);
  JMP2[i].Name := GetNameOnly(Name);
  JMP2[i].Offset := GetFileSize(hDest, nil);
  hSrc := OpenFile (PChar(Path), SrcROB, OF_READ);
  JMP2[i].Size := GetFileSize(hSrc, nil);

  MemSize := 4096 + JMP2[i].Size + 18;
  PossPackedLen := trunc(JMP2[i].Size*1.2);

  SrcBuff := VirtualAlloc(nil, MemSize, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);
  DestBuff := VirtualAlloc(nil, PossPackedLen, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);

  ReadBuff := Pointer(Integer(SrcBuff) + $1000);
  ReadFile (hSrc, ReadBuff^, JMP2[i].Size, n, nil);
  PackedLen := Pack (SrcBuff, DestBuff, JMP2[i].Size);

  WriteFile (hDest, DestBuff^, PackedLen, n, nil);
  CloseHandle(hSrc);
  VirtualFree(SrcBuff, MemSize, MEM_RELEASE);
  VirtualFree(DestBuff, PossPackedLen, MEM_RELEASE);

  WriteFile (hDest, Concat(#0,#0), 2, n, nil);
 end;
 pnlText.Caption := 'Writing JMP2 data...';
 Application.ProcessMessages;

 WriteFile (hDest, JMP2[0], Length(JMP2)*24, n, nil);
 WriteFile (hDest, NofFiles, 4, n, nil);
 WriteFile (hDest, 'JMP2', 4, n, nil);

 CloseHandle(hDest);
 pnlText.Caption := 'Done!';
 MessageBox(Application.Handle, 'Packing complete.', 'Zod Archiver 2.0b', 0);
 pnlText.Visible := False;
end;

procedure TForm1.lstFilesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var i: integer;
begin
  if (key = 46) and (Mode > 0) then
    if ssShift in Shift then begin
      i := 0;
      While i <> lstFiles.Items.Count do begin
        if not lstFiles.Selected[i] then begin
          lstFiles.Items.Delete(i);
          Dec(i);
        end;
        Inc(i);
      end
    end else begin
      lstFiles.DeleteSelected;
    end;

  if (key = 65) and (ssCtrl in Shift) then lstFiles.SelectAll;     
end;

procedure TForm1.btnOpenArchiveClick(Sender: TObject);
var i: cardinal;
begin
   if dlgOpenArch.Execute then
   begin
     if UnJMP2 then
     begin
       lstFiles.Items.Clear;
       for i := 0 to Length(JMP2) - 2 do
         lstFiles.Items.Add (JMP2[i].Name);
       SetMode(2);
     end else ShowMessage ('This file is not JMP2 archive!');
   end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  pnlText.BringToFront;
  SetMode(0);
end;

procedure TForm1.btnOpenReplArchClick(Sender: TObject);
var i: cardinal;
begin
   if dlgOpenArch.Execute then
   begin
     if UnJMP2 then
     begin
       lstFiles.Items.Clear;
       for i := 0 to Length(JMP2) - 2 do
         lstFiles.Items.Add (JMP2[i].Name);
       SetMode(3);
     end else ShowMessage ('This file is not JMP2 archive!');
   end;
end;

procedure TForm1.btnSelectReplFilesClick(Sender: TObject);
var i, j: cardinal; doDel, inList: boolean;
begin
  if dlgAddFiles.Execute then begin
    for i := 0 to dlgAddFiles.Files.Count - 1 do begin
      doDel := false; inList := false;
      for j := 0 to lstFiles.Items.Count - 1 do
         if GetNameOnly(dlgAddFiles.Files[i]) = GetNameOnly(lstFiles.Items[j]) then begin
            if isSlashesExist(lstFiles.Items[j]) then
              doDel := (MessageDlg('File "'+lstFiles.Items[j]+'" is already in list. Replace it with "'+dlgAddFiles.Files[i]+'"?', mtInformation, [mbYes, mbNo], 0) = mrYes)
            else
              doDel := true;
            inList := true;
            break;
         end;
      if inList and doDel then begin
        lstFiles.Items.Delete(j);
        lstFiles.Items.Add (dlgAddFiles.Files[i]);
      end;
      if not inList then lstFiles.Items.Add(dlgAddFiles.Files[i]);
    end;
    btnReplace.Enabled := true;
  end;
end;

procedure TForm1.btnReplaceClick(Sender: TObject);
  var n, NofFiles, i, j, k: Cardinal;
    TempArch, Path, Name, Arch: string;
    SrcBuff, DestBuff, ReadBuff: Pointer;
    PackedLen, MemSize, PossPackedLen: Integer;
begin
 if dlgSaveArchive.Execute then Arch := dlgSaveArchive.FileName else exit;

 if FileExists(Arch) and (MessageDlg('File "'+Arch+'" exists. Continue?', mtInformation, [mbYes, mbNo], 0) = mrNo) then exit;

 pnlText.Visible := True;
 pnlText.Caption := 'Preparing...';
 Application.ProcessMessages;

 SetLength(TempArch, MAX_PATH);
 GetTempFileName(PChar(ExtractFileDir(Arch)),'~',0,PChar(TempArch));
 CutNullString(TempArch);
 DestName := PChar(TempArch);

 hDest := OpenFile (DestName, DestROB, OF_CREATE+OF_READWRITE);
 WriteFile (hDest, Concat(#0,#0,#0,#0), 4, n, nil);

 NofFiles := lstFiles.Items.Count;
 SrcName := PChar(Form1.dlgOpenArch.FileName);

 for i := 0 to (NofFiles-1) do
 begin
  Path := lstFiles.Items[i];
  if isSlashesExist(Path) then begin
    pnlText.Caption := 'Packing "'+Path+'"...';
    Application.ProcessMessages;
    SetLength(Name, MAX_PATH);
    n := GetShortPathName (PChar(Path),PChar(Name),MAX_PATH-1);
    SetLength(Name, n);

    k := Length(NewJMP2);
    SetLength(NewJMP2, k+1);
    NewJMP2[k].Name := GetNameOnly(Name);
    NewJMP2[k].Offset := GetFileSize(hDest, nil);
    hSrc := OpenFile (PChar(Path), SrcROB, OF_READ);
    NewJMP2[k].Size := GetFileSize(hSrc, nil);

    MemSize := 4096 + NewJMP2[k].Size + 18;
    PossPackedLen := trunc(NewJMP2[k].Size*1.2);

    SrcBuff := VirtualAlloc(nil, MemSize, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);
    DestBuff := VirtualAlloc(nil, PossPackedLen, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);

    ReadBuff := Pointer(Integer(SrcBuff) + $1000);
    ReadFile (hSrc, ReadBuff^, NewJMP2[k].Size, n, nil);
    PackedLen := Pack (SrcBuff, DestBuff, NewJMP2[k].Size);

    WriteFile (hDest, DestBuff^, PackedLen, n, nil);
    CloseHandle(hSrc);
    VirtualFree(SrcBuff, MemSize, MEM_RELEASE);
    VirtualFree(DestBuff, PossPackedLen, MEM_RELEASE);

    WriteFile (hDest, Concat(#0,#0), 2, n, nil);
  end else begin
    pnlText.Caption := 'Adding packed "'+Path+'"...';
    Application.ProcessMessages;

    for j := 0 to Length(JMP2) - 1 do
      if JMP2[j].Name = GetNameOnly(Path) then break;

    hSrc := OpenFile (SrcName, SrcRob, OF_READ);

    PackedLen := JMP2[j+1].Offset-JMP2[j].Offset;
    k := Length(NewJMP2);
    SetLength(NewJMP2, k+1);
    NewJMP2[k] := JMP2[j];

    ReadBuff := VirtualAlloc(nil, PackedLen, MEM_COMMIT + MEM_RESERVE, PAGE_READWRITE);
    SetFilePointer (hSrc, JMP2[j].Offset, nil, FILE_BEGIN);

    ReadFile (hSrc, ReadBuff^, PackedLen, n, nil);
    NewJMP2[k].Offset := SetFilePointer(hDest, 0, 0, FILE_CURRENT);
    WriteFile (hDest, ReadBuff^, PackedLen, n, nil);

    CloseHandle(hSrc);
    VirtualFree(ReadBuff, PackedLen, MEM_RELEASE);
  end;
 end;

 pnlText.Caption := 'Writing JMP2 data...';
 Application.ProcessMessages;

 WriteFile (hDest, NewJMP2[0], Length(NewJMP2)*24, n, nil);
 WriteFile (hDest, NofFiles, 4, n, nil);
 WriteFile (hDest, 'JMP2', 4, n, nil);

 CloseHandle(hDest);
 DeleteFile(Arch);
 RenameFile(TempArch, Arch);

 pnlText.Caption := 'Done!';
 MessageBox(Application.Handle, 'Modifying complete.', 'Zod Archiver 2.0b', 0);
 pnlText.Visible := False;
end;

end.
