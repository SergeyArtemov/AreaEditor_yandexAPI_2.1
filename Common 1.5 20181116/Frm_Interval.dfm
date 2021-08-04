object Interval: TInterval
  Left = 0
  Top = 0
  Width = 276
  Height = 121
  TabOrder = 0
  OnClick = FrameClick
  OnMouseDown = FrameMouseDown
  OnMouseMove = FrameMouseMove
  OnMouseUp = FrameMouseUp
  OnResize = FrameResize
  object PM_Color: TPopupMenu
    Left = 20
    Top = 8
    object NClr_Gray: TMenuItem
      Caption = #1057#1077#1088#1099#1081
      OnClick = SetSliderColor
    end
    object NClr_Red: TMenuItem
      Caption = #1050#1088#1072#1089#1085#1099#1081
      OnClick = SetSliderColor
    end
    object NClr_Yellow: TMenuItem
      Caption = #1046#1077#1083#1090#1099#1081
      OnClick = SetSliderColor
    end
    object NClr_Green: TMenuItem
      Caption = #1047#1077#1083#1077#1085#1099#1081
      OnClick = SetSliderColor
    end
    object NClr_Blue: TMenuItem
      Caption = #1057#1080#1085#1080#1081
      OnClick = SetSliderColor
    end
    object NClr_About: TMenuItem
      OnClick = SetSliderColor
    end
  end
  object PM_Interval: TPopupMenu
    Left = 20
    Top = 56
    object NInt_SetInterval: TMenuItem
      Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083' '#1074#1088#1091#1095#1085#1091#1102
      OnClick = NInt_SetIntervalClick
    end
  end
end
