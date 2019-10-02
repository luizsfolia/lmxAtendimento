program SolicitacaoSenhaCaixa;

uses
  Vcl.Forms,
  SenhaCaixa in 'SenhaCaixa.pas' {frmAtendimento},
  StompClient in 'StompClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmAtendimento, frmAtendimento);
  Application.Run;
end.
