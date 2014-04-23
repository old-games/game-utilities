unit BitStream;

interface

  uses Graphics, Windows;

  type
    int6bit = 1..32;
    TBGRA = record b, g, r, a: byte; end;
    TPalette = array [0..255] of TBGRA;
    //Bl8 = array [0..7, 0..7] of byte;
    //Bl4 = array [0..3, 0..3] of byte;
    //Bl2 = array [0..1, 0..1] of byte;
    VFrame = array of TBGRA;
    PVFrame = ^VFrame;

  function GetNextBits(Count: int6bit): LongWord;
  procedure SetBitStream(buffer: Pointer);

  function ToBGRA(r, g, b, a: byte): TBGRA;
  function TBGRA2Color(C: TBGRA): TColor;
  function Color2TBGRA(C: TColor): TBGRA;

  type
    BTCFrame = class(TObject)
      private
        //VideoFrame: array [0..320*200-1] of TColor;
        Frame: PVFrame;
        Width: Cardinal;
        Palette: TPalette;
        c: array[0..1] of TBGRA;
      public
        constructor Create(PFrame: PVFrame; FrameWidth: Cardinal; Pal: TPalette);
        destructor Destroy; override;
        procedure Set8x8(Number: Cardinal; Block: int64);
        procedure Set4x4(Number8, Number4: Cardinal; Block: Word);
        procedure Set2x2(Number8, Number4, Number2: Cardinal; Block: byte); overload;
        procedure Set2x2(Number8, Number4, Number2: Cardinal; c1, c2, c3, c4: byte); overload;
        procedure SetColors(c0, c1: byte);
    end;
    PBTCFrame = ^BTCFrame;
    BTC = class(TObject)
      private
        blsize: byte;
        bl2num: Cardinal;
        bl4num: Cardinal;
        bl8num: Cardinal;
        Frame: PBTCFrame;
      public
        constructor Create(PFrame: PBTCFrame);
        destructor Destroy; override;
        procedure FillBlockMask;
        procedure FillBlockSolid;
        function GetBlockNumber: cardinal;
        procedure SetBlockSizeIn;
        procedure IncBlock;
    end;

implementation
  type TBitPointer = record
    BPByte: Pointer;
    BPBit: Byte;
  end;
  var BitPointer: TBitPointer;

  function ToBGRA(r, g, b, a: byte): TBGRA;
  begin
    Result.b := b;
    Result.a := a;
    Result.r := r;
    result.g := g;
  end;
  function TBGRA2Color(C: TBGRA): TColor;
  begin
    Result := RGB(C.r, C.g, C.b);
  end;
  function Color2TBGRA(C: TColor): TBGRA;
  begin
    Result.b := GetBValue(C);
    Result.g := GetGValue(C);
    Result.r := GetRValue(C);
  end;

  procedure SetBitStream(buffer: Pointer);
  begin
    BitPointer.BPByte := buffer;
    BitPointer.BPBit := $80;
  end;
  function GetNextBits(Count: int6bit): LongWord;
  asm
    push ebx
    mov ecx, eax
    xor eax, eax
    mov ebx, 1
    dec ecx
    shl ebx, cl
    @loop:  mov edx, [BitPointer.BPByte]
            mov dl, [edx]
            and dl, [BitPointer.BPBit]
            jz @go0
            add eax, ebx
            @go0: shr ebx, 1
            jz @exit
            ror byte [BitPointer.BPBit], 1
            jnc @loop
            inc dword [BitPointer.BPByte]
            jmp @loop
    @exit:
    ror byte [BitPointer.BPBit], 1
    jnc @truexit
    inc dword [BitPointer.BPByte]
    @truexit:
    pop ebx
  end;

  procedure BTC.FillBlockMask;
  var c0, c1: byte;
      //temp: LongWord;
      bl8x8: int64;
  begin
    c0 := GetNextBits(8);
    c1 := GetNextBits(8);
    Frame.SetColors(c0, c1);
    case blsize of
      2: begin
        Frame.Set2x2(bl8num, bl4num, bl2num, GetNextBits(4));
        Inc(bl2num);
      end;
      4: begin
        Frame.Set4x4(bl8num, bl4num, GetNextBits(16));
        Inc(bl4num);
      end;
      8: begin
        bl8x8 := GetNextBits(32);
        bl8x8 := bl8x8 shl 32;
        bl8x8 := bl8x8 + GetNextBits(32);
        Frame.Set8x8(bl8num, bl8x8);
        Inc(bl8num);
      end;
    end;
    if bl2num > 4 then begin
      bl2num := 1;
      Inc(bl4num);
      blsize := 4;
    end;
    if bl4num > 4 then begin
      bl4num := 1;
      Inc(bl8num);
      blsize := 8;
    end;
  end;
  procedure BTC.FillBlockSolid;
  var c: byte;
  begin
    c := GetNextBits(8);
    Frame.SetColors(c, c);
    case blsize of
      2: begin
        Frame.Set2x2(bl8num, bl4num, bl2num, 0);
        Inc(bl2num);
      end;
      4: begin
        Frame.Set4x4(bl8num, bl4num, 0);
        Inc(bl4num);
      end;
      8: begin
        Frame.Set8x8(bl8num, 0);
        Inc(bl8num);
      end;
    end;
    if bl2num > 4 then begin
      bl2num := 1;
      Inc(bl4num);
      blsize := 4;
    end;
    if bl4num > 4 then begin
      bl4num := 1;
      Inc(bl8num);
      blsize := 8;
    end;
  end;
  function BTC.GetBlockNumber: cardinal;
  begin
    GetBlockNumber := bl8num;
  end;
  procedure BTC.SetBlockSizeIn;
  var c0, c1, c2, c3: byte;
  begin
    blsize := blsize shr 1;
    if blsize = 1 then begin
      blsize := 2;
      c0 := GetNextBits(8);
      c1 := GetNextBits(8);
      c2 := GetNextBits(8);
      c3 := GetNextBits(8);
      Frame.Set2x2(bl8num, bl4num, bl2num, c0, c1, c2, c3);
      Inc(bl2num);
      if bl2num > 4 then begin
        bl2num := 1;
        Inc(bl4num);
        blsize := 4;
      end;
      if bl4num > 4 then begin
        bl4num := 1;
        Inc(bl8num);
        blsize := 8;
      end;
    end;
  end;
  constructor BTC.Create(PFrame: PBTCFrame);
  begin
    Frame := PFrame;
    blsize := 8;
    bl2num := 1;
    bl4num := 1;
    bl8num := 1;
  end;
  procedure BTC.IncBlock;
  begin
    case blsize of
      2: Inc(bl2num);
      4: Inc(bl4num);
      8: Inc(bl8num);
    end;
    if bl2num > 4 then begin
      bl2num := 1;
      Inc(bl4num);
      blsize := 4;
    end;
    if bl4num > 4 then begin
      bl4num := 1;
      Inc(bl8num);
      blsize := 8;
    end;
  end;
  destructor BTC.Destroy;
  begin
    Frame := nil;
    inherited;
  end;


  constructor BTCFrame.Create(PFrame: PVFrame; FrameWidth: Cardinal; Pal: TPalette);
  begin
    Frame := PFrame;
    Width := FrameWidth;
    Palette := Pal;
  end;
  destructor BTCFrame.Destroy;
  begin
    Frame := nil;
    inherited;
  end;
  procedure BTCFrame.Set8x8(Number: Cardinal; Block: int64);
  var i, j, n: Cardinal;
      sh: int64;
  begin
    Dec(Number);
    n := (Number mod (Width shr 3))*8 + (Number div (Width shr 3))*Width*8;
    sh := $8000000000000000;
    for j := 7 downto 0 do
      for i := 0 to 7 do begin
        Frame^[n+i + (j*Width)] := C[Integer((Block and sh) = 0)];
        sh := sh shr 1;
      end;
  end;
  procedure BTCFrame.Set4x4(Number8, Number4: Cardinal; Block: word);
  var i, j, n: Cardinal; sh: Word;
  begin
    Dec(Number8);
    Dec(Number4);
    Block := (Block shl 8) + (Block shr 8);
    n := (Number8 mod (Width shr 3))*8 + (Number8 div (Width shr 3))*Width*8 +
         (Number4 and 1)*4 + (Number4 shr 1)*Width*4;
    sh := $8000;
   for j := 0 to 3 do
      for i := 0 to 3 do begin
        Frame^[n+i + (j*Width)] := C[Integer((Block and sh) = 0)];
        sh := sh shr 1;
      end;
  end;
  procedure BTCFrame.Set2x2(Number8, Number4, Number2: Cardinal; Block: byte);
  var n: Cardinal;
  begin
    Dec(Number8);
    Dec(Number4);
    Dec(Number2);
    n := (Number8 mod (Width shr 3))*8 + (Number8 div (Width shr 3))*Width*8 +
         (Number4 and 1)*4 + (Number4 shr 1)*Width*4 +
         (Number2 and 1)*2 + (Number2 shr 1)*Width*2;
    Frame^[n] := C[Integer((Block and 8) = 0)];
    Frame^[n+1] := C[Integer((Block and 4) = 0)];
    Frame^[n+Width] := C[Integer((Block and 2) = 0)];
    Frame^[n+Width+1] := C[Integer((Block and 1) = 0)];
  end;
  procedure BTCFrame.Set2x2(Number8, Number4, Number2: Cardinal; c1, c2, c3, c4: byte);
  var n: Cardinal;
  begin
    Dec(Number8);
    Dec(Number4);
    Dec(Number2);
    n := (Number8 mod (Width shr 3))*8 + (Number8 div (Width shr 3))*Width*8 +
         (Number4 and 1)*4 + (Number4 shr 1)*Width*4 +
         (Number2 and 1)*2 + (Number2 shr 1)*Width*2;
    Frame^[n] := Palette[c1];
    Frame^[n+1] := Palette[c2];
    Frame^[n+Width] := Palette[c3];
    Frame^[n+Width+1] := Palette[c4];
  end;
  procedure BTCFrame.SetColors(c0, c1: byte);
  begin
      C[1] := Palette[c0];
      C[0] := Palette[c1];
  end;
end.
 