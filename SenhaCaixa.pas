unit SenhaCaixa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, StompClient, uModeloSenha,
  Vcl.Samples.Spin, IOUtils;

type
  TfrmAtendimento = class(TForm)
    pnlIdentificacaoTerminal: TPanel;
    edtServerRabbitMq: TEdit;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    edtTerminal: TSpinEdit;
    lblNomeTerminal: TLabel;
    pnlSenhaGerada: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FStompClientSolicitacao: IStompClient;
    FStompFrameSolicitacao: IStompFrame;

    procedure Inicializar;
  public
    { Public declarations }
  end;

var
  frmAtendimento: TfrmAtendimento;

implementation

{$R *.dfm}

procedure TfrmAtendimento.BitBtn1Click(Sender: TObject);
var
  lSenha: TSenha;
begin
  if FStompClientSolicitacao.Receive(FStompFrameSolicitacao, 2000) then
  begin
    lSenha := TSenha.Create;
    try
      lSenha.FromJsonString(StringReplace(FStompFrameSolicitacao.Body, #10, sLineBreak, [rfReplaceAll]));
      lSenha.Atendente := IntToStr(edtTerminal.Value);

      lblNomeTerminal.Caption := 'Atendente ' + IntToStr(edtTerminal.Value);

      pnlSenhaGerada.Caption := lSenha.Senha;

      FStompClientSolicitacao.ack(FStompFrameSolicitacao.MessageID);

      FStompClientSolicitacao.Send('/queue/Painel', lSenha.ToJsonString);
    finally
      lSenha.Free;
    end;
  end;
end;

procedure TfrmAtendimento.FormCreate(Sender: TObject);
var
  lIp: string;
begin
  lIp := TFile.ReadAllText('IP.txt');
  if lIp <> '' then
    edtServerRabbitMq.Text := lIp;
end;

procedure TfrmAtendimento.FormShow(Sender: TObject);
begin
  Inicializar;
end;

procedure TfrmAtendimento.Inicializar;
var
  lHeaders: IStompHeaders;
begin
  FStompClientSolicitacao := StompUtils.StompClient;
  FStompClientSolicitacao.SetHost(edtServerRabbitMq.Text);
  FStompClientSolicitacao.Connect;

  FStompFrameSolicitacao := StompUtils.NewFrame();

  lHeaders := FStompFrameSolicitacao.Headers
    .Add('x-max-priority', '10')
    .Add(StompHeaders.PREFETCH_COUNT, '1');

  FStompClientSolicitacao.Subscribe('/queue/Solicitacao', amClient, lHeaders);
end;

end.
