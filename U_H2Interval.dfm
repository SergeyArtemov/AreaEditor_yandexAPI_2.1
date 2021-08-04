object _H2Interval: T_H2Interval
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1080#1085#1090#1077#1088#1074#1072#1083#1072
  ClientHeight = 198
  ClientWidth = 331
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    331
    198)
  PixelsPerInch = 96
  TextHeight = 13
  object LabAreaInfo: TLabel
    Left = 12
    Top = 8
    Width = 308
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1086#1073#1083#1072#1089#1090#1080'....'
    Layout = tlCenter
    WordWrap = True
  end
  object LabInterval: TLabel
    Left = 74
    Top = 50
    Width = 49
    Height = 13
    Alignment = taRightJustify
    Caption = #1048#1085#1090#1077#1088#1074#1072#1083
  end
  object LabdateBegin: TLabel
    Left = 35
    Top = 78
    Width = 88
    Height = 13
    Alignment = taRightJustify
    Caption = #1053#1072#1095#1072#1083#1086' '#1076#1077#1081#1089#1090#1074#1080#1103
  end
  object Label1: TLabel
    Left = 19
    Top = 108
    Width = 107
    Height = 13
    Alignment = taRightJustify
    Caption = #1054#1082#1086#1085#1095#1072#1085#1080#1077' '#1076#1077#1081#1089#1090#1074#1080#1103
  end
  object LabQuote: TLabel
    Left = 95
    Top = 131
    Width = 31
    Height = 13
    Alignment = taRightJustify
    Caption = #1050#1074#1086#1090#1072
  end
  object CBInterval: TComboBox
    Left = 147
    Top = 47
    Width = 173
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    OnChange = CallCheckData
  end
  object dtpDateBegin: TDateTimePicker
    Left = 147
    Top = 74
    Width = 173
    Height = 21
    Date = 43398.532175983800000000
    Time = 43398.532175983800000000
    DateFormat = dfLong
    TabOrder = 1
    OnChange = CallCheckData
  end
  object dtpDateEnd: TDateTimePicker
    Left = 147
    Top = 101
    Width = 173
    Height = 21
    Date = 43398.532175983800000000
    Time = 43398.532175983800000000
    ShowCheckbox = True
    Checked = False
    DateFormat = dfLong
    TabOrder = 2
    OnChange = CallCheckData
  end
  object BBcancel: TBitBtn
    Left = 8
    Top = 156
    Width = 100
    Height = 35
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    DoubleBuffered = True
    ModalResult = 2
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object BBOk: TBitBtn
    Left = 220
    Top = 156
    Width = 100
    Height = 35
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    DoubleBuffered = True
    Enabled = False
    ModalResult = 1
    ParentDoubleBuffered = False
    TabOrder = 4
  end
  object seQuota: TSpinEdit
    Left = 147
    Top = 128
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 0
    OnChange = CallCheckData
  end
  object BBdelete: TBitBtn
    Left = 114
    Top = 156
    Width = 100
    Height = 35
    Caption = #1059#1076#1072#1083#1080#1090#1100
    DoubleBuffered = True
    ModalResult = 3
    ParentDoubleBuffered = False
    TabOrder = 6
  end
end
