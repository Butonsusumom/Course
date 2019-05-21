object Form1: TForm1
  Left = 251
  Top = 152
  Width = 1021
  Height = 655
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = 'Form1'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Head: TLabel
    Left = 208
    Top = 24
    Width = 618
    Height = 22
    Caption = 
      'This Program is designed to compare the following compression te' +
      'chniques:'
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object Types: TLabel
    Left = 384
    Top = 64
    Width = 237
    Height = 95
    Caption = 
      '1. Run-Length Encoding (RLE)'#13#10#13#10'2. Lempel-Ziv-Welch Encoding (LZ' +
      'W)'#13#10#13#10'3. Huffman Encoding '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object Label1: TLabel
    Left = 64
    Top = 176
    Width = 203
    Height = 19
    Caption = 'Please, choose a file to compress:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object select: TLabel
    Left = 64
    Top = 248
    Width = 177
    Height = 19
    Caption = 'Select, wich technique to use:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Note: TLabel
    Left = 64
    Top = 400
    Width = 657
    Height = 38
    Caption = 
      'Please, note that the output of each selected technique will be ' +
      'stored in the same folder as the sours file.'
    Font.Charset = HEBREW_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object status: TLabel
    Left = 64
    Top = 464
    Width = 89
    Height = 19
    Caption = 'Process status:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object line: TLabel
    Left = 32
    Top = 520
    Width = 945
    Height = 19
    Caption = 
      '________________________________________________________________' +
      '_________________________________________'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Know: TLabel
    Left = 688
    Top = 400
    Width = 93
    Height = 19
    Caption = 'To know more.'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = [fsUnderline]
    ParentFont = False
    Transparent = True
  end
  object Memo1: TMemo
    Left = 64
    Top = 208
    Width = 529
    Height = 25
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = [fsItalic]
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    TabOrder = 0
  end
  object RLE: TCheckBox
    Left = 64
    Top = 280
    Width = 225
    Height = 17
    Caption = 'Run-Length Encoding (RLE)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object LZW: TCheckBox
    Left = 64
    Top = 312
    Width = 249
    Height = 17
    Caption = 'Lempel-Ziv-Welch Encoding (LZW)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object Huff: TCheckBox
    Left = 64
    Top = 344
    Width = 169
    Height = 17
    Caption = 'Huffman Encoding'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object Archiv: TButton
    Left = 56
    Top = 560
    Width = 105
    Height = 33
    Caption = 'Archiv'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = ArchivClick
  end
  object Dearchiv: TButton
    Left = 848
    Top = 552
    Width = 105
    Height = 33
    Caption = 'Dearchiv'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = DearchivClick
  end
  object Browse: TButton
    Left = 600
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Browse...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = BrowseClick
  end
  object dlgOpen: TOpenDialog
    Left = 696
    Top = 208
  end
end
