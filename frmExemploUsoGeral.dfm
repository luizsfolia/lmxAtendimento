object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 394
  ClientWidth = 1058
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
  object GroupBox1: TGroupBox
    Left = 24
    Top = 48
    Width = 233
    Height = 201
    Caption = 'Terminal'
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 24
      Top = 42
      Width = 161
      Height = 33
      Caption = 'Fila Normal'
      TabOrder = 0
      OnClick = BitBtn1Click
    end
    object BitBtn2: TBitBtn
      Left = 24
      Top = 80
      Width = 161
      Height = 33
      Caption = 'Fila Prioritaria'
      TabOrder = 1
      OnClick = BitBtn2Click
    end
    object memSenhaTerminal: TMemo
      Left = 24
      Top = 119
      Width = 185
      Height = 74
      TabOrder = 2
    end
    object edtTerminal: TEdit
      Left = 24
      Top = 15
      Width = 161
      Height = 21
      TabOrder = 3
      Text = '1'
    end
  end
  object edtServerRabbitMq: TEdit
    Left = 24
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '192.168.15.14'
  end
  object memlog: TMemo
    Left = 24
    Top = 272
    Width = 1009
    Height = 105
    Lines.Strings = (
      'memlog')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object GroupBox2: TGroupBox
    Left = 272
    Top = 48
    Width = 385
    Height = 201
    Caption = 'Mostrar Senhas'
    TabOrder = 3
    object memSenhasUsadas: TMemo
      Left = 8
      Top = 72
      Width = 353
      Height = 118
      TabOrder = 0
    end
    object edtSenhaAtual: TEdit
      Left = 8
      Top = 24
      Width = 353
      Height = 21
      TabOrder = 1
    end
  end
  object GroupBox3: TGroupBox
    Left = 679
    Top = 48
    Width = 225
    Height = 87
    Caption = 'Atendente'
    TabOrder = 4
    object edtAtendente: TEdit
      Left = 16
      Top = 24
      Width = 33
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object edtSenhaAtendente: TEdit
      Left = 16
      Top = 53
      Width = 193
      Height = 21
      TabOrder = 1
      Text = 'edtSenhaAtendente'
    end
    object BitBtn3: TBitBtn
      Left = 143
      Top = 22
      Width = 74
      Height = 25
      Caption = 'Chamar'
      TabOrder = 2
      OnClick = BitBtn3Click
    end
  end
  object GroupBox4: TGroupBox
    Left = 679
    Top = 145
    Width = 225
    Height = 104
    Caption = 'Atendente'
    TabOrder = 5
    object edtAtendente2: TEdit
      Left = 16
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '2'
    end
    object edtSenhaEtendente2: TEdit
      Left = 16
      Top = 62
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'edtSenhaAtendente'
    end
    object BitBtn4: TBitBtn
      Left = 143
      Top = 19
      Width = 74
      Height = 25
      Caption = 'Chamar'
      TabOrder = 2
      OnClick = BitBtn4Click
    end
  end
end
