object Form1: TForm1
  Left = 254
  Top = 20
  Width = 220
  Height = 674
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 210
    Height = 625
  end
  object MainMenu1: TMainMenu
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object Moo1: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' Moo '#1096#1088#1080#1092#1090#1099
        OnClick = Moo1Click
      end
      object BMP1: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' BMP'
        OnClick = BMP1Click
      end
      object BMP2: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' BMP'
        OnClick = BMP2Click
      end
      object BMP3: TMenuItem
        Caption = #1050#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1090#1100' BMP>MOO'
        OnClick = BMP3Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 32
  end
  object SaveDialog1: TSaveDialog
    Left = 64
  end
end
