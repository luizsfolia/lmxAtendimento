unit fPainelPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, StompClient, uModeloSenha, IOUtils;

type

  TOnMostrarInfoPainel = reference to procedure(const ASenha : TSenha);

  TThreadPainelSenhas = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FOnMostrarInfoPainel : TOnMostrarInfoPainel;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; const AEndereco : string;
      const AOnInfoPainel : TOnMostrarInfoPainel); overload;

    procedure MostrarInfoPainel(const ASenha : TSenha);

    procedure MostrarPainel;

    property StompClient: IStompClient read FStompClient write FStompClient;

    property OnMostrarSenhaAtual : TOnMostrarInfoPainel read FOnMostrarInfoPainel write FOnMostrarInfoPainel;

    procedure SetOnMostrarSenhaAtual(const AOnMostrarSenhaAtual : TOnMostrarInfoPainel);
  end;

  TfrmPainelPrincipal = class(TForm)
    pnlSenhaAtual: TPanel;
    pnlHistorico: TPanel;
    memHistorico: TMemo;
    pnlIdentificacaoTerminal: TPanel;
    edtServerRabbitMq: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
//    FStompClientGerador: IStompClient;
    FThreadGerador: TThreadPainelSenhas;
//    FStompFrameGerador: IStompFrame;
//    FStompClientGeradorEnvio: IStompClient;
  public
    { Public declarations }
    procedure Inicializar;

  end;

var
  frmPainelPrincipal: TfrmPainelPrincipal;

implementation

{$R *.dfm}

{ TThreadPainelSenhas }


constructor TThreadPainelSenhas.Create(CreateSuspended: Boolean; const AEndereco : string;
  const AOnInfoPainel : TOnMostrarInfoPainel);
begin
  FStompClient := StompUtils.StompClient;
  FStompClient.SetHost(AEndereco);
  FStompClient.Connect;

  FStompClient.Subscribe('/queue/Painel', amAuto);

  FOnMostrarInfoPainel := AOnInfoPainel;

  FStompFrame := StompUtils.CreateFrame;
  inherited Create(CreateSuspended);
end;

procedure TThreadPainelSenhas.Execute;
begin
  NameThreadForDebugging('ThreadPainelSenhas');

  while not Terminated do
  begin
    if FStompClient.Receive(FStompFrame, 2000) then
    begin
      Sleep(100);
      Synchronize(MostrarPainel);
    end;
  end;
end;

procedure TThreadPainelSenhas.MostrarInfoPainel(const ASenha: TSenha);
begin
  if Assigned(FOnMostrarInfoPainel) then
    FOnMostrarInfoPainel(ASenha);
end;


procedure TThreadPainelSenhas.MostrarPainel;
var
  lSenha: TSenha;
begin
  lSenha := TSenha.Create;
  try
    lSenha.FromJsonString(StringReplace(FStompFrame.Body, #10, sLineBreak, [rfReplaceAll]));
    MostrarInfoPainel(lSenha);
  finally
    lSenha.Free;
  end;
end;

procedure TThreadPainelSenhas.SetOnMostrarSenhaAtual(
  const AOnMostrarSenhaAtual: TOnMostrarInfoPainel);
begin
  FOnMostrarInfoPainel := AOnMostrarSenhaAtual;
end;

{ TfrmPainelPrincipal }

procedure TfrmPainelPrincipal.FormCreate(Sender: TObject);
var
  lIp: string;
begin
  lIp := TFile.ReadAllText('IP.txt');
  if lIp <> '' then
    edtServerRabbitMq.Text := lIp;
end;

procedure TfrmPainelPrincipal.FormDestroy(Sender: TObject);
begin
  FThreadGerador.Free;
end;

procedure TfrmPainelPrincipal.FormShow(Sender: TObject);
begin
  Inicializar;
end;

procedure TfrmPainelPrincipal.Inicializar;
begin
  FThreadGerador := TThreadPainelSenhas.Create(True, edtServerRabbitMq.Text,
    procedure (const ASenha : TSenha)
    begin
      pnlSenhaAtual.Caption := Format('Senha [%s] - Atendente [%s]', [ASenha.Senha, ASenha.Atendente]);
      memHistorico.Lines.Add(Format('Nova senha gerada = Terminal [%s] - Senha [%s] - Atendente [%s]',[ASenha.Terminal, ASenha.Senha, ASenha.Atendente]));
    end);

  if not FThreadGerador.Started then
    FThreadGerador.Start;
end;

end.
