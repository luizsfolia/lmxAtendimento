object frmPrincipalTerminal: TfrmPrincipalTerminal
  Left = 0
  Top = 0
  Caption = 'Terminal ...'
  ClientHeight = 369
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 45
    Width = 241
    Height = 203
    Align = alLeft
    TabOrder = 0
    object Image1: TImage
      Left = 48
      Top = 16
      Width = 49
      Height = 57
    end
    object Image2: TImage
      Left = 103
      Top = 16
      Width = 49
      Height = 57
    end
    object btnNormal: TBitBtn
      Left = 24
      Top = 88
      Width = 169
      Height = 97
      Caption = 'Atendimento Normal'
      Enabled = False
      TabOrder = 0
      OnClick = btnNormalClick
    end
  end
  object Panel2: TPanel
    Left = 241
    Top = 45
    Width = 239
    Height = 203
    Align = alClient
    TabOrder = 1
    object Image3: TImage
      Left = 88
      Top = 16
      Width = 49
      Height = 57
    end
    object Image4: TImage
      Left = 143
      Top = 16
      Width = 49
      Height = 57
    end
    object Image5: TImage
      Left = 33
      Top = 16
      Width = 49
      Height = 57
    end
    object btnPrioritario: TBitBtn
      Left = 38
      Top = 88
      Width = 169
      Height = 97
      Caption = 'Atendimento Priorit'#225'rio'
      Enabled = False
      TabOrder = 0
      OnClick = btnPrioritarioClick
    end
  end
  object pnlIdentificacaoTerminal: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 45
    Align = alTop
    TabOrder = 2
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
      Left = 241
      Top = 5
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 1
    end
    object btninicializar: TBitBtn
      Left = 368
      Top = 3
      Width = 97
      Height = 25
      Caption = 'Inicializar Terminal'
      TabOrder = 2
      OnClick = btninicializarClick
    end
  end
  object pnlSenhaGerada: TPanel
    Left = 0
    Top = 248
    Width = 480
    Height = 121
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -33
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
end
