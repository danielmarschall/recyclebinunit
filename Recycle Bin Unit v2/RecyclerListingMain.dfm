object RecyclerListingMainForm: TRecyclerListingMainForm
  Left = 348
  Top = 177
  Caption = 'Recycler Listing (ViaThinkSoft Recycle Bin Unit v2 Demo)'
  ClientHeight = 565
  ClientWidth = 987
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 987
    Height = 466
    Align = alClient
    Indent = 19
    ReadOnly = True
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 466
    Width = 987
    Height = 99
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 8
      Top = 29
      Width = 185
      Height = 52
      Caption = 'List items'
      TabOrder = 0
      OnClick = Button1Click
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 6
      Width = 129
      Height = 17
      Caption = 'Only own recyclers'
      TabOrder = 1
    end
  end
end
