object MainForm: TMainForm
  Left = 225
  Top = 177
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Filling Polygons with Color Gradients Demo'
  ClientHeight = 446
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 145
    Height = 446
    Align = alLeft
    TabOrder = 0
    object LblColorStopsTop: TLabel
      Left = 14
      Top = 15
      Width = 99
      Height = 15
      Caption = 'Color Stops (&Top):'
      FocusControl = MemoColorStopsTop
    end
    object LblColorStopsBottom: TLabel
      Left = 14
      Top = 193
      Width = 118
      Height = 15
      Caption = 'Color Stops (&Bottom):'
      FocusControl = MemoColorStopsBottom
    end
    object MemoColorStopsTop: TMemo
      Left = 14
      Top = 38
      Width = 108
      Height = 137
      Lines.Strings = (
        '0.0: clRed32'
        '0.1: clYellow32'
        '0.3: clLime32'
        '0.5: clAqua32'
        '0.7: clBlue32'
        '0.9: clFuchsia32'
        '1.0: clRed32')
      TabOrder = 0
      WordWrap = False
      OnChange = MemoColorStopsTopChange
    end
    object MemoColorStopsBottom: TMemo
      Left = 14
      Top = 216
      Width = 108
      Height = 137
      Lines.Strings = (
        '0.0: $FFFF0000'
        '0.2: $FFFFFF00'
        '0.3: $FF00FF00'
        '0.5: $FF00FFFF'
        '0.7: $AA0000FF'
        '0.9: $FFFF00FF'
        '1.0: $FF00FF00')
      TabOrder = 1
      WordWrap = False
      OnChange = MemoColorStopsTopChange
    end
    object rgEllipseFillStyle: TRadioGroup
      Left = 14
      Top = 365
      Width = 110
      Height = 65
      Caption = 'Radial &Fill Style'
      ItemIndex = 1
      Items.Strings = (
        'Simple'
        'SVG')
      TabOrder = 2
      OnClick = rgEllipseFillStyleClick
    end
  end
  object ImgView32: TImgView32
    Left = 145
    Top = 0
    Width = 440
    Height = 446
    Align = alClient
    Bitmap.ResamplerClassName = 'TNearestResampler'
    BitmapAlign = baCustom
    Scale = 1.000000000000000000
    ScaleMode = smScale
    ScrollBars.ShowHandleGrip = True
    ScrollBars.Style = rbsDefault
    ScrollBars.Size = 16
    ScrollBars.Visibility = svHidden
    OverSize = 0
    TabOrder = 1
    OnMouseDown = ImgView32MouseDown
    OnMouseMove = ImgView32MouseMove
    OnMouseUp = ImgView32MouseUp
  end
  object MainMenu1: TMainMenu
    Left = 193
    Top = 16
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 27
        OnClick = BtnExitClick
      end
    end
  end
end
