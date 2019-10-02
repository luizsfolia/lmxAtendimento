program SenhasTerminal;

uses
  Vcl.Forms,
  FormPedidoSenha in 'FormPedidoSenha.pas' {frmPrincipalTerminal},
  uModeloSenha in 'uModeloSenha.pas',
  StompClient in 'StompClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipalTerminal, frmPrincipalTerminal);
  Application.Run;
end.
