object MainForm: TMainForm
  Left = 204
  Top = 143
  Width = 659
  Height = 485
  Caption = 'BitBucket Reader'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 253
    Width = 651
    Height = 4
    Cursor = crVSplit
    Align = alBottom
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 651
    Height = 253
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 0
    Top = 257
    Width = 651
    Height = 201
    Align = alBottom
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Timer1: TTimer
    Interval = 300
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
