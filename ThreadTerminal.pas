unit ThreadTerminal;

interface

uses
  System.Classes,
  StompClient, System.SysUtils, uModeloSenha;

type

  TOnReceberSenha = reference to procedure(const ASenha : string);

  TThreadTerminal = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FOnReceberSenha : TOnReceberSenha;
    procedure SetStompClient(const Value: IStompClient);
  protected
    procedure Execute; override;
  public
    procedure ReceberSenha;
//    procedure UpdateMessageMemo;
//    procedure UpdateMessageIdEdit;
    constructor Create(CreateSuspended: Boolean); overload;
    property StompClient: IStompClient read FStompClient write SetStompClient;
    property OnReceberSenha : TOnReceberSenha read FOnReceberSenha write FOnReceberSenha;

    procedure SetOnReceberSenha(const AOnReceberSenha : TOnReceberSenha);
  end;

  TThreadPainel = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FOnReceberSenha : TOnReceberSenha;
    procedure SetStompClient(const Value: IStompClient);
  protected
    procedure Execute; override;
  public
    procedure ObterSenhaAtendimento;
//    procedure UpdateMessageMemo;
//    procedure UpdateMessageIdEdit;
    constructor Create(CreateSuspended: Boolean); overload;
    property StompClient: IStompClient read FStompClient write SetStompClient;
    property OnReceberSenha : TOnReceberSenha read FOnReceberSenha write FOnReceberSenha;

    procedure SetOnReceberSenha(const AOnReceberSenha : TOnReceberSenha);
  end;


  TThreadGeradorSenha = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
//    FOnReceberSenha : TOnReceberSenha;
    FFStompClientReEnvio: IStompClient;
    procedure SetStompClient(const Value: IStompClient);
    procedure SetStompClientReEnvio(const Value: IStompClient);
  protected
    procedure Execute; override;
  public
    procedure PostarNaFilaTerminal(const ASenha : TSenha);
    procedure PostarNaDeSolicitacao(const ASenha : TSenha);
    procedure GerarSenha;
//    procedure UpdateMessageMemo;
//    procedure UpdateMessageIdEdit;
    constructor Create(CreateSuspended: Boolean); overload;
    property StompClient: IStompClient read FStompClient write SetStompClient;
    property StompClientReEnvio : IStompClient read FFStompClientReEnvio write SetStompClientReEnvio;
//    property OnReceberSenha : TOnReceberSenha read FOnReceberSenha write FOnReceberSenha;

//    procedure SetOnReceberSenha(const AOnReceberSenha : TOnReceberSenha);
  end;


implementation

{ TThreadTerminal }

constructor TThreadTerminal.Create(CreateSuspended: Boolean);
begin
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
//      Synchronize(UpdateMessageIdEdit);
    end
    else
    begin
//      Synchronize(UpdateMessageMemo);
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

procedure TThreadTerminal.SetOnReceberSenha(
  const AOnReceberSenha: TOnReceberSenha);
begin
  FOnReceberSenha := AOnReceberSenha;
end;

procedure TThreadTerminal.SetStompClient(const Value: IStompClient);
begin
  FStompClient := Value;
end;

//procedure TThreadTerminal.UpdateMessageIdEdit;
//begin
//
//end;
//
//procedure TThreadTerminal.UpdateMessageMemo;
//begin
//
//end;

{ TThreadGeradorSenha }

constructor TThreadGeradorSenha.Create(CreateSuspended: Boolean);
begin
  FStompFrame := StompUtils.CreateFrame;
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
//      Synchronize(UpdateMessageIdEdit);
    end
    else
    begin
//      Synchronize(UpdateMessageMemo);
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
    lSenha.Senha := lNovaSenha;

    PostarNaFilaTerminal(lSenha);
    PostarNaDeSolicitacao(lSenha);

  finally
    lSenha.Free;
  end;



  // GerarNovaSenha
  // Postar na Fila Solicitada
  // Postar na Fila de espera
end;

procedure TThreadGeradorSenha.PostarNaDeSolicitacao(const ASenha : TSenha);
begin
  FFStompClientReEnvio.Connect;
  try
    try
      FFStompClientReEnvio.Send('/queue/Solicitacao', ASenha.ToJsonString,
        StompUtils.Headers.Add(TKeyValue.Create('durable', LowerCase(BoolToStr(True, true)))));
    except
      on e: Exception do
      begin
        //memSenhaTerminal.Lines.Add('ERROR: ' + e.Message);
      end;
    end;
  finally
    FFStompClientReEnvio.Disconnect;
  end;
end;

procedure TThreadGeradorSenha.PostarNaFilaTerminal(const ASenha : TSenha);
begin
  FFStompClientReEnvio.Connect;
  try
    try

      FFStompClientReEnvio.Send('/queue/Terminal_' + ASenha.Terminal, ASenha.ToJsonString);
    except
      on e: Exception do
      begin
        //memSenhaTerminal.Lines.Add('ERROR: ' + e.Message);
      end;
    end;
  finally
    FFStompClientReEnvio.Disconnect;
  end;
end;

//procedure TThreadGeradorSenha.SetOnReceberSenha(
//  const AOnReceberSenha: TOnReceberSenha);
//begin
//end;

procedure TThreadGeradorSenha.SetStompClient(const Value: IStompClient);
begin
  FStompClient := Value;
end;

procedure TThreadGeradorSenha.SetStompClientReEnvio(const Value: IStompClient);
begin
  FFStompClientReEnvio := Value;
end;

{ TThreadAtendente }

constructor TThreadPainel.Create(CreateSuspended: Boolean);
begin
  FStompFrame := StompUtils.CreateFrame;
  inherited Create(CreateSuspended);
end;

procedure TThreadPainel.Execute;
begin
  NameThreadForDebugging('ThreadPainel');

  while not Terminated do
  begin
    if FStompClient.Receive(FStompFrame, 2000) then
    begin
      Sleep(100);
      Synchronize(ObterSenhaAtendimento);
//      Synchronize(UpdateMessageIdEdit);
    end
    else
    begin
//      Synchronize(UpdateMessageMemo);
    end;
  end;
end;

procedure TThreadPainel.ObterSenhaAtendimento;
var
  lSenha: TSenha;
begin
  lSenha := TSenha.Create;
  try
    lSenha.FromJsonString(StringReplace(FStompFrame.Body, #10, sLineBreak, [rfReplaceAll]));
    if Assigned(FOnReceberSenha) then
      FOnReceberSenha('Senha : ' + lSenha.Senha + ' - Atendente : ' + lSenha.Atendente);
  finally
    lSenha.Free;
  end;
end;

procedure TThreadPainel.SetOnReceberSenha(
  const AOnReceberSenha: TOnReceberSenha);
begin
  FOnReceberSenha := AOnReceberSenha;
end;

procedure TThreadPainel.SetStompClient(const Value: IStompClient);
begin
  FStompClient := Value;
end;

end.

