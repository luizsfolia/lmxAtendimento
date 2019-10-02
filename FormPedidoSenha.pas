unit FormPedidoSenha;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, StompClient, uModeloSenha, Vcl.Samples.Spin, IOUtils;

type

  TOnReceberSenha = reference to procedure(const ASenha : string);

  TThreadTerminal = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FOnReceberSenha : TOnReceberSenha;
  protected
    procedure Execute; override;
  public
    procedure ReceberSenha;

    constructor Create(CreateSuspended: Boolean; const AEndereco : string;
      const ATerminal : string; const AOnReceberSenha : TOnReceberSenha); overload;

    property StompClient: IStompClient read FStompClient write FStompClient;
    property OnReceberSenha : TOnReceberSenha read FOnReceberSenha write FOnReceberSenha;
  end;

  TfrmPrincipalTerminal = class(TForm)
    Panel1: TPanel;
    btnNormal: TBitBtn;
    Panel2: TPanel;
    btnPrioritario: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    pnlIdentificacaoTerminal: TPanel;
    lblNomeTerminal: TLabel;
    pnlSenhaGerada: TPanel;
    edtServerRabbitMq: TEdit;
    edtTerminal: TSpinEdit;
    btninicializar: TBitBtn;
    procedure btnNormalClick(Sender: TObject);
    procedure btnPrioritarioClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btninicializarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FTerminal : string;
    FStompClientTerminal: IStompClient;
    FThreadTerminal: TThreadTerminal;

    procedure InicializarTerminal;
    procedure EnviarParaFila(const APrioritario : Boolean);
  public
    { Public declarations }
  end;

var
  frmPrincipalTerminal: TfrmPrincipalTerminal;

implementation

{$R *.dfm}

procedure TfrmPrincipalTerminal.btnNormalClick(Sender: TObject);
begin
  EnviarParaFila(False);
end;

procedure TfrmPrincipalTerminal.btnPrioritarioClick(Sender: TObject);
begin
  EnviarParaFila(True);
end;

procedure TfrmPrincipalTerminal.btninicializarClick(Sender: TObject);
begin
  FTerminal := IntToStr(edtTerminal.Value);
  lblNomeTerminal.Caption := 'Terminal = ' + FTerminal;

  InicializarTerminal;
end;

procedure TfrmPrincipalTerminal.EnviarParaFila(const APrioritario: Boolean);
begin
  if FStompClientTerminal = nil then
  begin
    FStompClientTerminal := StompUtils.StompClient;
    FStompClientTerminal.SetHost(edtServerRabbitMq.Text);
  end;

  FStompClientTerminal.Connect;
  try
    FStompClientTerminal.Send('/queue/geradorsenha', TSenha.GerarSolicitacaoSenha(FTerminal, APrioritario));
  finally
    FStompClientTerminal.Disconnect;
  end;
end;

procedure TfrmPrincipalTerminal.FormCreate(Sender: TObject);
var
  lIp: string;
begin
  lIp := TFile.ReadAllText('IP.txt');
  if lIp <> '' then
    edtServerRabbitMq.Text := lIp;
end;

procedure TfrmPrincipalTerminal.FormDestroy(Sender: TObject);
begin
  FThreadTerminal.Free;
end;

procedure TfrmPrincipalTerminal.InicializarTerminal;
begin
  FThreadTerminal := TThreadTerminal.Create(True, edtServerRabbitMq.Text, FTerminal,
    procedure (const ASenha : string)
    begin
      pnlSenhaGerada.Caption := ASenha;
    end);

  if not FThreadTerminal.Started then
    FThreadTerminal.Start;

  btnNormal.Enabled := True;
  btnPrioritario.Enabled := True;
end;

{ TThreadTerminal }

constructor TThreadTerminal.Create(CreateSuspended: Boolean; const AEndereco : string;
  const ATerminal : string; const AOnReceberSenha : TOnReceberSenha);
begin
  FStompClient := StompUtils.StompClient;
  FStompClient.SetHost(AEndereco);
  FStompClient.Connect;

  FStompClient.Subscribe('/queue/Terminal_' + ATerminal, amAuto);

  FOnReceberSenha := AOnReceberSenha;

  FStompFrame := StompUtils.CreateFrame;
  inherited Create(CreateSuspended);
end;

procedure TThreadTerminal.Execute;
begin
  NameThreadForDebugging('ThreadTerminal');

  while not Terminated do
  begin
    if FStompClient.Receive(FStompFrame, 2000) then
    begin
      Sleep(100);
      Synchronize(ReceberSenha);
    end;
  end;
end;

procedure TThreadTerminal.ReceberSenha;
var
  lSenha: TSenha;
begin
  lSenha := TSenha.Create;
  try
    lSenha.FromJsonString(StringReplace(FStompFrame.Body, #10, sLineBreak, [rfReplaceAll]));
    if Assigned(FOnReceberSenha) then
      FOnReceberSenha('Senha : ' + lSenha.Senha);
  finally
    lSenha.Free;
  end;
end;

end.
