program GeradorSenhas;

uses
  Vcl.Forms,
  FormMostrarSenhas in 'FormMostrarSenhas.pas' {frmMostraSenhasGeradas},
  StompClient in 'StompClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMostraSenhasGeradas, frmMostraSenhasGeradas);
  Application.Run;
end.
