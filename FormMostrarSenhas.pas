unit FormMostrarSenhas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, StompClient, uModeloSenha,
  Vcl.ExtCtrls, IOUtils;

type

  TOnGerarSenha = reference to procedure(const ASenha : TSenha);
  TOnSolicitarAtendimento = reference to procedure(const ASenha : TSenha);

  TThreadGeradorSenha = class(TThread)
  private
    FEndereco : string;
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FFStompClientReEnvio: IStompClient;
    FOnGerarSenha: TOnGerarSenha;
    FOnSolicitarAtendimento: TOnSolicitarAtendimento;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; const AEndereco : string;
      const AOnGerarSenha : TOnGerarSenha); overload;

    procedure PostarNaFilaTerminal(const ASenha : TSenha);
    procedure PostarNaDeSolicitacao(const ASenha : TSenha);

    procedure MostrarOnGerarSenha(const ASenha : TSenha);

    procedure GerarSenha;
    property StompClient: IStompClient read FStompClient write FStompClient;
    property StompClientReEnvio : IStompClient read FFStompClientReEnvio write FFStompClientReEnvio;

    property OnGerarSenha : TOnGerarSenha read FOnGerarSenha write FOnGerarSenha;
    property OnSolicitarAtendimento : TOnSolicitarAtendimento read FOnSolicitarAtendimento write FOnSolicitarAtendimento;
  end;

  TfrmMostraSenhasGeradas = class(TForm)
    memSenhasGeradas: TMemo;
    pnlIdentificacaoTerminal: TPanel;
    edtServerRabbitMq: TEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FThreadGerador: TThreadGeradorSenha;

    procedure Inicializar;
  public
    { Public declarations }
  end;

var
  frmMostraSenhasGeradas: TfrmMostraSenhasGeradas;

implementation

{$R *.dfm}


procedure TfrmMostraSenhasGeradas.FormCreate(Sender: TObject);
var
  lIp: string;
begin
  lIp := TFile.ReadAllText('IP.txt');
  if lIp <> '' then
    edtServerRabbitMq.Text := lIp;
end;

procedure TfrmMostraSenhasGeradas.FormDestroy(Sender: TObject);
begin
  FThreadGerador.Free;
end;

procedure TfrmMostraSenhasGeradas.FormShow(Sender: TObject);
begin
  Inicializar;
end;

procedure TfrmMostraSenhasGeradas.Inicializar;
begin
  FThreadGerador := TThreadGeradorSenha.Create(True, edtServerRabbitMq.Text,
    procedure (const ASenha : TSenha)
    begin
      memSenhasGeradas.Lines.Add(Format('Nova senha gerada = Terminal [%s] - Senha [%s]',[ASenha.Terminal, ASenha.Senha]));
    end);

  if not FThreadGerador.Started then
    FThreadGerador.Start;

end;

{ TThreadGeradorSenha }

constructor TThreadGeradorSenha.Create(CreateSuspended: Boolean; const AEndereco : string;
  const AOnGerarSenha : TOnGerarSenha);
begin
  FEndereco := AEndereco;

  FStompClient := StompUtils.StompClient;
  FStompClient.SetHost(FEndereco);
  FStompClient.Connect;

  FStompClient.Subscribe('/queue/geradorsenha', amAuto);

  FFStompClientReEnvio := StompUtils.StompClient;
  FFStompClientReEnvio.SetHost(FEndereco);
  FFStompClientReEnvio.Connect;

  FStompFrame := StompUtils.CreateFrame;

  FOnGerarSenha := AOnGerarSenha;

  inherited Create(CreateSuspended);
end;

procedure TThreadGeradorSenha.Execute;
begin
  NameThreadForDebugging('ThreadGeradorSenha');
  while not Terminated do
  begin
    if FStompClient.Receive(FStompFrame, 2000) then
    begin
      Sleep(100);
      Synchronize(GerarSenha);
    end;
  end;
end;

procedure TThreadGeradorSenha.GerarSenha;
var
  lSenha: TSenha;
  lNovaSenha: string;
begin
  lSenha := TSenha.Create;
  try
    lSenha.FromJsonString(StringReplace(FStompFrame.Body, #10, sLineBreak, [rfReplaceAll]));
    lNovaSenha := lSenha.GerarNovaSenha;
    MostrarOnGerarSenha(lSenha);

    PostarNaFilaTerminal(lSenha);
    PostarNaDeSolicitacao(lSenha);

  finally
    lSenha.Free;
  end;

end;

procedure TThreadGeradorSenha.MostrarOnGerarSenha(const ASenha: TSenha);
begin
  if Assigned(FOnGerarSenha) then
    FOnGerarSenha(ASenha);
end;

procedure TThreadGeradorSenha.PostarNaDeSolicitacao(const ASenha : TSenha);
var
  lHeaders: IStompHeaders;
begin
  FFStompClientReEnvio.Connect;
  try
    if ASenha.Prioritario then
      lHeaders := StompUtils.Headers
        .Add('x-max-priority', '10')
        .Add('priority', '10')
    else
      lHeaders := StompUtils.Headers
        .Add('x-max-priority', '10')
        .Add('priority', '1');

    FFStompClientReEnvio.Send('/queue/Solicitacao', ASenha.ToJsonString, lHeaders);
  finally
    FFStompClientReEnvio.Disconnect;
  end;
end;

procedure TThreadGeradorSenha.PostarNaFilaTerminal(const ASenha : TSenha);
begin
  FFStompClientReEnvio.Connect;
  try
    FFStompClientReEnvio.Send('/queue/Terminal_' + ASenha.Terminal, ASenha.ToJsonString);
  finally
    FFStompClientReEnvio.Disconnect;
  end;
end;

end.
