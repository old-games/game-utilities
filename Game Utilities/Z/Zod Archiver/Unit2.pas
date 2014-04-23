unit Unit2;

interface
  uses SysUtils, Windows;

  //type Buffer = array of Byte;

  function Pack (SrcBuffer, DestBuffer: Pointer; SrcBufferSize: Integer): Integer;
  function UnPack (SrcBuffer, DestBuffer: Pointer; SrcBufferSize: Integer): Integer;
implementation

  function Pack (SrcBuffer, DestBuffer: Pointer; SrcBufferSize: Integer): Integer;
  var
    SrcBufSize: Dword; Res: Integer; Flags: Word; SrcB, DestB, FlagsOffset: Pointer;
  begin
  SrcB := SrcBuffer;
  DestB := DestBuffer;
  SrcBufSize := SrcBufferSize + Integer(SrcB) + $1000;
  FlagsOffset := DestB;

  asm
    pushad
    mov edx, SrcB //BufferOffset
    add edx, $1000
    mov eax, edx  //WindowOffset
    mov edi, DestB //DestOffset
    inc edi
    push edi
    mov ebx, 128
    mov Flags, bx
    @Repeat:
    //
      mov ebx, eax
      sub ebx, edx
      and ebx, 4096
      add edx, ebx
    //
      mov edi, edx
      dec edi
      mov esi, eax
      xor ebx, ebx
      push ebp
      mov bp, [eax]
      @Cmp:
        inc edi
        cmp edi, esi
        jae @Copy
        cmp bp, [edi]
        jne @Cmp
        mov ecx, 18
        repe cmpsb
        sub esi, eax
        sub edi, esi
        mov ecx, esi
         mov esi, ebx
         and esi, $F0
         add ecx, esi
        mov esi, eax
        sub ecx, 3
        cmp cl, bl
        jna @Cmp
        and ecx, $0F
        mov ebx, edi   //Encode
        inc ebx
        sub ebx, edx
        shl ebx, 4
        add ebx, ecx
        jmp @Cmp

     @Copy:
      pop ebp
      pop edi //DestOffset
      test ebx, ebx
      jne @WrCode
      mov esi, eax
      movsb
      inc eax
      mov bx, Flags
      add bh, bl
      jmp @EndWrCode
     @WrCode:
      mov ecx, ebx
      and ecx, 15
      add eax, ecx
      add eax, 2
      mov ecx, eax
      sub ecx, SrcBufSize
      jna @Continue
      sub bl, cl
      @Continue:
      mov word [edi], bx
      add edi, 2
      mov bx, Flags
     @EndWrCode:
      shr bl, 1
      and bl, bl
      jz @WriteFlags
      cmp eax, SrcBufSize
      jae @WriteFlagsEnd
      mov Flags, bx
      push edi
      jmp @Repeat

      @WriteFlags:
      mov ecx, FlagsOffset
      mov byte [ecx], bh
      mov ebx, 128
      mov Flags, bx
      mov FlagsOffset, edi
      inc edi
      cmp eax, SrcBufSize
      jae @Exit
      push edi
      jmp @Repeat

    @WriteFlagsEnd:
      mov ecx, FlagsOffset
      mov byte [ecx], bh
      inc edi
    @Exit:
      sub edi, DestB
      mov Res, edi
      popad
  end;
    result := Res;
  end;

  function UnPack (SrcBuffer, DestBuffer: Pointer; SrcBufferSize: Integer): Integer;
  var
    SrcBufSize: Dword; SrcB, DestB: Pointer; Res: Integer;
  begin

  SrcB := SrcBuffer;
  DestB := DestBuffer;
  SrcBufSize := SrcBufferSize + Integer(SrcB);

  asm
    pushad
    mov edi, DestB
    add edi, $1000
    mov esi, SrcB
    inc esi
    mov ebx, SrcB
    mov dh, [ebx] //Flags
    mov dl, 128
    mov eax, DestB //BufferOffset

    @Repeat:
      mov cl, dh
      and cl, dl
      jz @Decode
      movsb
      cmp esi, SrcBufSize
      jae @Exit
      shr dl, 1
      jz @ReadFlags
      jmp @Repeat

     @Decode:
      mov ecx, edi
      sub ecx, eax
      and ecx, $1000
      add eax, ecx
      mov cx, [esi]
      mov ebx, ecx
      and ecx, $0F
      add ecx, 2
      shr ebx, 4
      and ebx, $0FFF
      add ebx, eax
      dec ebx
      cmp ebx, edi
      jb @Nop
      sub ebx, $1000
      @Nop:
      xchg ebx, esi
      rep movsb
      xchg ebx, esi
      add edi, ecx
      add esi, 2
      cmp esi, SrcBufSize
      jae @Exit
      shr dl, 1
      jz @ReadFlags
      jmp @Repeat

     @ReadFlags:
      mov dh, [esi]
      mov dl, 128
      inc esi
      cmp esi, SrcBufSize
      jae @Exit
      jmp @Repeat

     @Exit:
      sub edi, $1000
      mov Res, edi
      popad
  end;
  result := Res - Integer(DestB);

  end;

end.
