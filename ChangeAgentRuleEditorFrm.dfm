object ChangeAgentRuleEditorForm: TChangeAgentRuleEditorForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'ChangeAgentRuleEditorForm'
  ClientHeight = 267
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    387
    267)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 19
    Width = 81
    Height = 13
    Caption = #1057#1084#1077#1085#1080#1090#1100' '#1072#1075#1077#1085#1090#1072
  end
  object Label2: TLabel
    Left = 52
    Top = 46
    Width = 53
    Height = 13
    Caption = #1085#1072'  '#1072#1075#1077#1085#1090#1072
  end
  object Label3: TLabel
    Left = 73
    Top = 195
    Width = 32
    Height = 13
    Caption = 'KLADR'
  end
  object Label4: TLabel
    Left = 86
    Top = 70
    Width = 19
    Height = 13
    Caption = 'Hab'
  end
  object Label5: TLabel
    Left = 80
    Top = 102
    Width = 25
    Height = 13
    Caption = 'Hab2'
  end
  object Label6: TLabel
    Left = 7
    Top = 131
    Width = 98
    Height = 13
    Caption = #1055#1088#1080#1074#1077#1083#1077#1075#1080#1088#1086#1074#1072#1085#1099#1081
  end
  object Label7: TLabel
    Left = 220
    Top = 74
    Width = 21
    Height = 13
    Caption = 'MRP'
  end
  object Label8: TLabel
    Left = 222
    Top = 102
    Width = 19
    Height = 13
    Caption = 'Nav'
  end
  object Label9: TLabel
    Left = 207
    Top = 131
    Width = 34
    Height = 13
    Caption = 'Kupivip'
  end
  object Label10: TLabel
    Left = 208
    Top = 161
    Width = 33
    Height = 13
    Caption = 'Mamsy'
  end
  object btnOk: TBitBtn
    Left = 167
    Top = 232
    Width = 95
    Height = 25
    Anchors = [akRight, akBottom]
    DoubleBuffered = True
    Kind = bkOK
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = btnOkClick
    ExplicitTop = 204
  end
  object BtnCancel: TBitBtn
    Left = 270
    Top = 232
    Width = 95
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    DoubleBuffered = True
    Kind = bkCancel
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 1
    ExplicitTop = 204
  end
  object cbAgentList_From: TComboBox
    Left = 118
    Top = 16
    Width = 246
    Height = 21
    Style = csDropDownList
    TabOrder = 2
  end
  object cbAgentList_To: TComboBox
    Left = 118
    Top = 43
    Width = 246
    Height = 21
    Style = csDropDownList
    TabOrder = 3
  end
  object eKLADR: TEdit
    Left = 118
    Top = 192
    Width = 246
    Height = 21
    TabOrder = 4
    Text = 'eKLADR'
  end
  object cbHab: TComboBox
    Left = 118
    Top = 71
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 5
  end
  object cbHab2: TComboBox
    Left = 118
    Top = 99
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 6
  end
  object cbPrivileged: TComboBox
    Left = 118
    Top = 128
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 7
  end
  object cbKupivip: TComboBox
    Left = 249
    Top = 128
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 8
  end
  object cbNav: TComboBox
    Left = 249
    Top = 99
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 9
  end
  object cbMRP: TComboBox
    Left = 249
    Top = 71
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 10
  end
  object cbMamsy: TComboBox
    Left = 249
    Top = 158
    Width = 57
    Height = 21
    Style = csDropDownList
    TabOrder = 11
  end
end
