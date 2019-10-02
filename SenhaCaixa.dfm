object frmAtendimento: TfrmAtendimento
  Left = 0
  Top = 0
  Caption = 'Atendimento...'
  ClientHeight = 341
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlIdentificacaoTerminal: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 45
    Align = alTop
    TabOrder = 0
    object lblNomeTerminal: TLabel
      Left = 130
      Top = 8
      Width = 3
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtServerRabbitMq: TEdit
      Left = 24
      Top = 5
      Width = 89
      Height = 21
      TabOrder = 0
      Text = '192.168.15.14'
    end
    object edtTerminal: TSpinEdit
      Left = 328
      Top = 5
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 45
    Width = 480
    Height = 187
    Align = alClient
    TabOrder = 1
    ExplicitHeight = 201
    object BitBtn1: TBitBtn
      Left = 24
      Top = 16
      Width = 425
      Height = 145
      Caption = 'Chamar Atendimento'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = BitBtn1Click
    end
  end
  object pnlSenhaGerada: TPanel
    Left = 0
    Top = 232
    Width = 480
    Height = 109
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
end
