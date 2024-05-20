object MainForm: TMainForm
  Left = 224
  Top = 149
  Caption = 'Recycle Bin Example'
  ClientHeight = 459
  ClientWidth = 636
  Color = clBtnFace
  Constraints.MinHeight = 495
  Constraints.MinWidth = 652
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object topPanel: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 81
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object rightPanel: TPanel
      Left = 404
      Top = 1
      Width = 231
      Height = 79
      Align = alRight
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object btnReadOwnRecyclers: TButton
        Left = 8
        Top = 8
        Width = 217
        Height = 25
        Caption = 'Read own recyclers'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btn_readown_click
      end
      object btnShowConfig: TButton
        Left = 8
        Top = 40
        Width = 217
        Height = 25
        Caption = 'Show configuration'
        TabOrder = 1
        OnClick = btnShowConfigClick
      end
    end
    object leftPanel: TPanel
      Left = 1
      Top = 1
      Width = 232
      Height = 79
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object btnReadRecyclerFile: TButton
        Left = 8
        Top = 8
        Width = 217
        Height = 25
        Caption = 'Read recycler file (INFO, INFO2 or $I......)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btn_read_click
      end
      object btnSaveTextDump: TButton
        Left = 8
        Top = 40
        Width = 217
        Height = 25
        Caption = 'Save Text Dump'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnSaveTextDumpClick
      end
    end
  end
  object outputPanel: TPanel
    Left = 0
    Top = 81
    Width = 636
    Height = 378
    Align = alClient
    Caption = 'Please wait...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -49
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object outputMemo: TMemo
      Left = 1
      Top = 1
      Width = 634
      Height = 376
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object openDialog: TOpenDialog
    Title = 'Select recycler file'
    Left = 592
    Top = 416
  end
  object saveDialog: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text files (*.txt)|*.txt|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 560
    Top = 416
  end
end
