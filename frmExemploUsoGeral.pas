unit frmExemploUsoGeral;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, StompClient, uModeloSenha, ThreadTerminal;

type
  TForm4 = class(TForm)
    GroupBox1: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    memSenhaTerminal: TMemo;
    edtServerRabbitMq: TEdit;
    edtTerminal: TEdit;
    memlog: TMemo;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    edtAtendente: TEdit;
    edtSenhaAtendente: TEdit;
    BitBtn3: TBitBtn;
    GroupBox4: TGroupBox;
    edtAtendente2: TEdit;
    edtSenhaEtendente2: TEdit;
    BitBtn4: TBitBtn;
    memSenhasUsadas: TMemo;
    edtSenhaAtual: TEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
  private
    { Private declarations }
    FStompClientTerminal: IStompClient;
    FThreadTerminal: TThreadTerminal;
    FStompClientTerminalThread: IStompClient;
    FStompFrameTerminalThread: IStompFrame;

    FStompClientGerador: IStompClient;
    FThreadGerador: TThreadGeradorSenha;
    FStompFrameGerador: IStompFrame;
    FStompClientGeradorEnvio: IStompClient;

    FStompClientSolicitacao1: IStompClient;
    FStompClientSolicitacao2: IStompClient;

    FStompFrameSolicitacao1: IStompFrame;
    FStompFrameSolicitacao2: IStompFrame;
    
    FStompClientPainel: IStompClient;
    FThreadPainel: TThreadPainel;
//    FStompClientPainelThread: IStompClient;
//    FStompFramePainelThread: IStompFrame;

    function GerarsolicitacaoSenha(const APrioritario : Boolean) : string;
    procedure EnviarParaFila(const APrioritario : Boolean);
    procedure BeforeSendFrameTerminal(AFrame: IStompFrame);
    procedure InicializarTerminal;

    procedure PuxarAtendimento(const ATerminal : string);
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

{ TForm4 }

procedure TForm4.BeforeSendFrameTerminal(AFrame: IStompFrame);
begin
//  memlog.Lines.Add(StringReplace(AFrame.Output, #10, sLineBreak, [rfReplaceAll]));
end;

procedure TForm4.BitBtn1Click(Sender: TObject);
begin
  EnviarParaFila(True);
end;

procedure TForm4.BitBtn2Click(Sender: TObject);
begin
  EnviarParaFila(False);
end;

procedure TForm4.BitBtn3Click(Sender: TObject);
var
  lSenha: TSenha;
begin
//  FStompClientSolicitacao1.Subscribe('/queue/Solicitacao', amClient);
  if FStompClientSolicitacao1.Receive(FStompFrameSolicitacao1, 2000) then
  begin
    lSenha := TSenha.Create;
    try
      lSenha.FromJsonString(StringReplace(FStompFrameSolicitacao1.Body, #10, sLineBreak, [rfReplaceAll]));
      lSenha.Atendente := edtAtendente.Text;

      edtSenhaAtendente.Text := lSenha.Senha;

      FStompClientSolicitacao1.ack(FStompFrameSolicitacao1.MessageID);

      FStompClientSolicitacao1.Send('/queue/Painel', lSenha.ToJsonString);
      

      // Enviar para Painel
      
    finally
      lSenha.Free;
    end;
  end;
//  FStompClientSolicitacao1.Unsubscribe('/queue/Solicitacao');
end;

procedure TForm4.BitBtn4Click(Sender: TObject);
var
  lSenha: TSenha;
begin
//  FStompClientSolicitacao2.Subscribe('/queue/Solicitacao', amClient);
  if FStompClientSolicitacao2.Receive(FStompFrameSolicitacao2, 2000) then
  begin
    lSenha := TSenha.Create;
    try
      lSenha.FromJsonString(StringReplace(FStompFrameSolicitacao2.Body, #10, sLineBreak, [rfReplaceAll]));
      lSenha.Atendente := edtAtendente2.Text;

      edtSenhaEtendente2.Text := lSenha.Senha;

      FStompClientSolicitacao2.Ack(FStompFrameSolicitacao2.MessageID);

      FStompClientSolicitacao2.Send('/queue/Painel', lSenha.ToJsonString);

      
      // Enviar para Painel
      
    finally
      lSenha.Free;
    end;
  end;
//  FStompClientSolicitacao2.Unsubscribe('/queue/Solicitacao');

end;

procedure TForm4.EnviarParaFila(const APrioritario: Boolean);
begin
  FStompClientTerminal.Connect;
  try
    try
//      FStompClientTerminal.Send('/queue/Terminal' + edtTerminal.Text, GerarSolicitacaoSenha(APrioritario));
      FStompClientTerminal.Send('/queue/geradorsenha', GerarSolicitacaoSenha(APrioritario));
    except
      on e: Exception do
      begin
        memSenhaTerminal.Lines.Add('ERROR: ' + e.Message);
      end;
    end;
  finally
    FStompClientTerminal.Disconnect;
  end;

end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  InicializarTerminal;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  FThreadTerminal.Free;
  FThreadGerador.Free;
  FThreadPainel.Free;

end;

function TForm4.GerarsolicitacaoSenha(const APrioritario: Boolean): string;
var
  lRetorno: TSenha;
begin
  lRetorno := TSenha.Create;
  try
    lRetorno.Terminal := edtTerminal.Text;
    lRetorno.Prioritario := APrioritario;
    lRetorno.Senha := '';

    Result := lRetorno.ToJsonString;
  finally
    lRetorno.Free;
  end;
end;

procedure TForm4.InicializarTerminal;
begin
  FStompClientTerminal := StompUtils.StompClient;
  FStompClientTerminal.SetHost(edtServerRabbitMq.Text);
  FStompClientTerminal.SetOnBeforeSendFrame(BeforeSendFrameTerminal);

  FStompClientTerminalThread := StompUtils.StompClient;
  try
    FStompClientTerminalThread.SetHost(edtServerRabbitMq.Text);
    FStompClientTerminalThread.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientTerminalThread.SetOnBeforeSendFrame(BeforeSendFrameTerminal);
  FStompFrameTerminalThread := StompUtils.NewFrame();

  FThreadTerminal := TThreadTerminal.Create(True);
  FThreadTerminal.StompClient := FStompClientTerminalThread;

  FStompClientTerminalThread.Subscribe('/queue/Terminal_' + edtTerminal.Text, amAuto);
  if not FThreadTerminal.Started then
    FThreadTerminal.Start;

  FThreadTerminal.SetOnReceberSenha(
    procedure (const ASenha : string) 
    begin 
      memSenhaTerminal.Lines.Add(ASenha) 
    end);


    
//  FStompClientPainel := StompUtils.StompClient;
//  FStompClientPainel.SetHost(edtServerRabbitMq.Text);
//  FStompClientPainel.SetOnBeforeSendFrame(BeforeSendFrameTerminal);

  FStompClientPainel := StompUtils.StompClient;
  try
    FStompClientPainel.SetHost(edtServerRabbitMq.Text);
    FStompClientPainel.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientPainel.SetOnBeforeSendFrame(BeforeSendFrameTerminal);
//  FStompFrameTerminalThread := StompUtils.NewFrame();

  FThreadPainel := TThreadPainel.Create(True);
  FThreadPainel.StompClient := FStompClientPainel;

  FStompClientPainel.Subscribe('/queue/Painel', amAuto);
  if not FThreadPainel.Started then
    FThreadPainel.Start;

  FThreadPainel.SetOnReceberSenha(
    procedure (const ASenha : string) 
    begin
      if edtSenhaAtual.Text <> '' then
        memSenhasUsadas.Lines.Insert(0, edtSenhaAtual.Text);
      edtSenhaAtual.Text := ASenha; 
    end);

//    FStompClientPainel: IStompClient;
//    FThreadPainel: TThreadTerminal;

  // Gerador Senha

  FStompClientGerador := StompUtils.StompClient;
  try
    FStompClientGerador.SetHost(edtServerRabbitMq.Text);
    FStompClientGerador.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientGerador.SetOnBeforeSendFrame(BeforeSendFrameTerminal);
  FStompFrameGerador := StompUtils.NewFrame();
  
  FStompClientGeradorEnvio := StompUtils.StompClient;
  try
    FStompClientGeradorEnvio.SetHost(edtServerRabbitMq.Text);
    FStompClientGeradorEnvio.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientGeradorEnvio.SetOnBeforeSendFrame(BeforeSendFrameTerminal);

  FThreadGerador := TThreadGeradorSenha.Create(True);
  FThreadGerador.StompClient := FStompClientGerador;
  FThreadGerador.StompClientReEnvio := FStompClientGeradorEnvio;


  FStompClientGerador.Subscribe('/queue/geradorsenha', amAuto);
  if not FThreadGerador.Started then
    FThreadGerador.Start;


  FStompClientSolicitacao1 := StompUtils.StompClient;
  try
    FStompClientSolicitacao1.SetHost(edtServerRabbitMq.Text);
    FStompClientSolicitacao1.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientSolicitacao1.SetOnBeforeSendFrame(BeforeSendFrameTerminal);
  FStompFrameSolicitacao1 := StompUtils.NewFrame();

  FStompClientSolicitacao1.Subscribe('/queue/Solicitacao', amClient);

  FStompClientSolicitacao2 := StompUtils.StompClient;
  try
    FStompClientSolicitacao2.SetHost(edtServerRabbitMq.Text);
    FStompClientSolicitacao2.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Cannot connect to Apollo server. Run the server and restart the application');
    end;
  end;
  FStompClientSolicitacao2.SetOnBeforeSendFrame(BeforeSendFrameTerminal);
  FStompFrameSolicitacao2 := StompUtils.NewFrame();

  FStompClientSolicitacao2.Subscribe('/queue/Solicitacao', amClient);

    
end;

procedure TForm4.PuxarAtendimento(const ATerminal : string);
begin

//    if FStompClient.Receive(FStompFrame, 2000) then
//    begin
//      Sleep(100);
//      Synchronize(GerarSenha);
////      Synchronize(UpdateMessageIdEdit);
//    end
//    else
//    begin
////      Synchronize(UpdateMessageMemo);
//    end;

end;

end.
