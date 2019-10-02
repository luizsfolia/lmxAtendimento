object frmMostraSenhasGeradas: TfrmMostraSenhasGeradas
  Left = 0
  Top = 0
  Caption = 'Gerador de Senhas...'
  ClientHeight = 343
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object memSenhasGeradas: TMemo
    Left = 0
    Top = 45
    Width = 594
    Height = 298
    Align = alClient
    Lines.Strings = (
      'memSenhasGeradas')
    TabOrder = 0
  end
  object pnlIdentificacaoTerminal: TPanel
    Left = 0
    Top = 0
    Width = 594
    Height = 45
    Align = alTop
    TabOrder = 1
    object edtServerRabbitMq: TEdit
      Left = 24
      Top = 5
      Width = 89
      Height = 21
      TabOrder = 0
      Text = '192.168.15.14'
    end
  end
end
