program PainelSenhas;

uses
  Vcl.Forms,
  fPainelPrincipal in 'fPainelPrincipal.pas' {Form1},
  uModeloSenha in 'uModeloSenha.pas',
  StompClient in 'StompClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPainelPrincipal, frmPainelPrincipal);
  Application.Run;
end.
