program ExemploUsoGeral;

uses
  Vcl.Forms,
  frmExemploUsoGeral in 'frmExemploUsoGeral.pas' {Form4},
  uModeloSenha in 'uModeloSenha.pas',
  ThreadTerminal in 'ThreadTerminal.pas',
  StompClient in 'StompClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
