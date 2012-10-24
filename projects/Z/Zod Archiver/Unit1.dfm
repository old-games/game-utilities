object Form1: TForm1
  Left = 194
  Top = 100
  Width = 645
  Height = 521
  Caption = 'Zod Archiver 2.0b'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 637
    Height = 25
    Align = alTop
    TabOrder = 0
    object lblState: TLabel
      Left = 1
      Top = 1
      Width = 635
      Height = 23
      Align = alClient
      Alignment = taCenter
      Caption = 'Mode: none'
    end
  end
  object pnlText: TPanel
    Left = 40
    Top = 184
    Width = 513
    Height = 57
    TabOrder = 1
    Visible = False
  end
  object lstFiles: TListBox
    Left = 0
    Top = 25
    Width = 637
    Height = 431
    Align = alClient
    ItemHeight = 13
    Items.Strings = (
      'Select files to pack or open archive to unpack')
    MultiSelect = True
    Sorted = True
    TabOrder = 2
    OnKeyUp = lstFilesKeyUp
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 456
    Width = 637
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 
      'Hint: press Delete to ignore selected, Shift+Delete to ignore un' +
      'selected (in Unpacking mode ignored means to be not unpacked)'
  end
  object dlgAddFiles: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofExtensionDifferent, ofEnableSizing]
    Title = 'Add Files'
    Left = 200
  end
  object MainMenu1: TMainMenu
    Left = 112
    object Packing1: TMenuItem
      Caption = 'Packing'
      object btnPack: TMenuItem
        Caption = 'Pack'
        Enabled = False
        OnClick = btnPackClick
      end
      object btnChooseFiles: TMenuItem
        Caption = 'Add Files...'
        OnClick = btnChooseFilesClick
      end
    end
    object Unpacking1: TMenuItem
      Caption = 'Unpacking'
      object btnUnpack: TMenuItem
        Caption = 'Unpack'
        Enabled = False
        OnClick = btnUnpackClick
      end
      object btnOpenArchive: TMenuItem
        Caption = 'Open Archive...'
        OnClick = btnOpenArchiveClick
      end
    end
    object N1: TMenuItem
      Caption = 'Modifying'
      object btnReplace: TMenuItem
        Caption = 'Modify'
        Enabled = False
        OnClick = btnReplaceClick
      end
      object btnOpenReplArch: TMenuItem
        Caption = 'Open Archive...'
        OnClick = btnOpenReplArchClick
      end
      object btnSelectReplFiles: TMenuItem
        Caption = 'Select Files to Add or Replace...'
        Enabled = False
        OnClick = btnSelectReplFilesClick
      end
    end
  end
  object dlgSaveArchive: TSaveDialog
    DefaultExt = 'exp'
    Filter = 
      'Z Expansion Archive (*.exp)|*.exp|Z Dos Archive (*.pac)|*.pac|Al' +
      'l files|*.*'
    Title = 'Save Archive as'
    Left = 232
  end
  object dlgOpenArch: TOpenDialog
    Filter = 
      'Z Expansion Archive (*.exp)|*.exp|Z Dos Archive (*.pac)|*.pac|Al' +
      'l files|*.*'
    Left = 344
  end
end
