object _AreaProps: T_AreaProps
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1086#1087#1080#1089#1072#1085#1080#1103' '#1086#1073#1083#1072#1089#1090#1080
  ClientHeight = 281
  ClientWidth = 410
  Color = clBtnFace
  Constraints.MinWidth = 290
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    410
    281)
  PixelsPerInch = 96
  TextHeight = 13
  object Lab_AreaName: TLabel
    Left = 24
    Top = 8
    Width = 76
    Height = 13
    Hint = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1086#1073#1083#1072#1089#1090#1080' '#1085#1072' '#1082#1072#1088#1090#1077
    Alignment = taRightJustify
    Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '
    FocusControl = Ed_AreaName
    ParentShowHint = False
    ShowHint = True
  end
  object Label2: TLabel
    Left = 53
    Top = 54
    Width = 49
    Height = 13
    Hint = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1086#1073#1083#1072#1089#1090#1080'-'#1074#1083#1072#1076#1077#1083#1100#1094#1072
    Alignment = taRightJustify
    Caption = #1042#1083#1072#1076#1077#1083#1077#1094
    FocusControl = CB_AreaParent
    ParentShowHint = False
    ShowHint = True
  end
  object Label3: TLabel
    Left = 71
    Top = 88
    Width = 32
    Height = 13
    Alignment = taRightJustify
    Caption = #1062#1074#1077#1090#1072
  end
  object Label1: TLabel
    Left = 59
    Top = 30
    Width = 43
    Height = 13
    Hint = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1086#1073#1083#1072#1089#1090#1080'-'#1074#1083#1072#1076#1077#1083#1100#1094#1072
    Alignment = taRightJustify
    Caption = #1059#1088#1086#1074#1077#1085#1100
    FocusControl = CB_Level
    ParentShowHint = False
    ShowHint = True
  end
  object SpB_AreaProps_Info: TSpeedButton
    Left = 12
    Top = 196
    Width = 18
    Height = 22
    OnClick = SpB_AreaProps_InfoClick
  end
  object LabT_AreaProps_Info: TLabel
    Left = 36
    Top = 202
    Width = 56
    Height = 13
    Caption = #1055#1086#1076#1088#1086#1073#1085#1077#1077
  end
  object Lab_AreaID: TLabel
    Left = 9
    Top = 224
    Width = 26
    Height = 13
    Caption = 'ID : ?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Lab_Inp: TLabel
    Left = 7
    Top = 264
    Width = 27
    Height = 13
    Caption = '....%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Lab_ParentAreaID: TLabel
    Left = 9
    Top = 244
    Width = 84
    Height = 13
    Caption = 'ID '#1074#1083#1072#1076#1077#1083#1100#1094#1072' : ?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Ed_AreaName: TEdit
    Left = 108
    Top = 4
    Width = 298
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    ExplicitWidth = 170
  end
  object CB_AreaParent: TComboBox
    Left = 108
    Top = 52
    Width = 298
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    OnChange = CB_AreaParentChange
    ExplicitWidth = 170
  end
  object Pan_RGBLine: TPanel
    Left = 108
    Top = 76
    Width = 298
    Height = 41
    Cursor = crHandPoint
    Alignment = taLeftJustify
    Anchors = [akLeft, akTop, akRight]
    Caption = '  '#1083#1080#1085#1080#1080
    TabOrder = 2
    VerticalAlignment = taAlignTop
    ExplicitWidth = 170
    DesignSize = (
      298
      41)
    object Pan_RGBFill: TPanel
      Left = 5
      Top = 16
      Width = 288
      Height = 21
      Cursor = crHandPoint
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvLowered
      Caption = #1079#1072#1083#1080#1074#1082#1080
      TabOrder = 0
      ExplicitWidth = 177
    end
  end
  object CB_Level: TComboBox
    Left = 108
    Top = 28
    Width = 298
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ItemIndex = 4
    ParentCtl3D = False
    TabOrder = 3
    Text = #1047#1086#1085#1072' '#1085#1072#1079#1085#1072#1095#1077#1085#1080#1103' '#1074#1088#1077#1084#1077#1085#1080' '#1076#1086#1089#1090#1072#1074#1082#1080
    OnChange = CB_LevelChange
    Items.Strings = (
      #1054#1073#1083#1072#1089#1090#1100' ('#1082#1088#1072#1081')'
      #1056#1072#1081#1086#1085
      #1053#1072#1089#1077#1083#1077#1085#1085#1099#1081' '#1087#1091#1085#1082#1090
      #1047#1086#1085#1072' '#1076#1086#1089#1090#1072#1074#1082#1080' '#1082#1091#1088#1100#1077#1088#1072' ('#1084#1072#1088#1096#1088#1091#1090#1085#1072#1103')'
      #1047#1086#1085#1072' '#1085#1072#1079#1085#1072#1095#1077#1085#1080#1103' '#1074#1088#1077#1084#1077#1085#1080' '#1076#1086#1089#1090#1072#1074#1082#1080)
    ExplicitWidth = 170
  end
  object BB_AreaProps_Cancel: TBitBtn
    Left = 236
    Top = 192
    Width = 85
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    DoubleBuffered = True
    ModalResult = 2
    ParentDoubleBuffered = False
    TabOrder = 4
  end
  object BB_AreaProps_Ok: TBitBtn
    Left = 321
    Top = 192
    Width = 85
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    DoubleBuffered = True
    ModalResult = 1
    ParentDoubleBuffered = False
    TabOrder = 5
  end
  object IL: TImageList
    Height = 6
    Width = 7
    Left = 296
    Top = 220
    Bitmap = {
      494C010102002C002C0007000600FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000001C000000060000000100200000000000A002
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008000
      0000800000008000000080000000800000008000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000000000000000000000000000008000000080000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000000000000000
      0000000000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000080000000800000008000
      0000800000008000000080000000000000000000000000000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      280000001C000000060000000100010000000000180000000000000000000000
      000000000000000000000000FFFFFF00FFFC0000EE000000C7040000838C0000
      01DC0000FFFC000000000000000000000000000000000000000000000000}
  end
end
