unit uModeloSenha;

interface

uses
  System.SysUtils, System.JSON, Winapi.Windows, IOUtils;

type

  TSenha = class
  private
    FSenha: string;
    FPrioritario: Boolean;
    FTerminal: string;
    FAtendente: string;
  public
    property Prioritario : Boolean read FPrioritario write FPrioritario;
    property Terminal : string read FTerminal write FTerminal;
    property Senha : string read FSenha write FSenha;
    property Atendente : string read FAtendente write FAtendente;

    function ToJsonString : string;
    procedure FromJsonString(const ADados : string);

    function GerarNovaSenha : string;

    class function GerarsolicitacaoSenha(const ATerminal : string; const APrioritario : Boolean) : string;
  end;

implementation

var
  FGeradorSena : TMultiReadExclusiveWriteSynchronizer;


{ TSenha }

procedure TSenha.FromJsonString(const ADados: string);
var
  lJson: TJSONObject;
begin
  lJson := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(ADados), 0) as TJsonObject;
  try
    if lJson.Get('senha') <> nil then
      FSenha := lJson.Get('senha').JsonValue.Value;
    if lJson.Get('terminal') <> nil then
      FTerminal := lJson.Get('terminal').JsonValue.Value;
    if lJson.Get('prioritario') <> nil  then
      FPrioritario := StrToBoolDef(lJson.Get('prioritario').JsonValue.Value, False);
    if lJson.Get('atendente') <> nil  then
      FAtendente := lJson.Get('atendente').JsonValue.Value;
  finally
    lJson.Free;
  end;
end;

function TSenha.GerarNovaSenha: string;
var
  lArquivo : string;
  lSenha : Integer;
begin
  FGeradorSena.BeginWrite;
  try
    if FPrioritario then
      lArquivo := 'SenhaPrioritaria.txt'
    else
      lArquivo := 'SenhaNormal.txt';

    if TFile.Exists(lArquivo) then
      lSenha := StrToIntDef(TFile.ReadAllText(lArquivo), 0) + 1
    else
      lSenha := 1;
    TFile.WriteAllText(lArquivo, IntToStr(lSenha));

    if FPrioritario then
      FSenha := 'P-' + IntToStr(lSenha)
    else
      FSenha := 'N-' + IntToStr(lSenha);

  finally
    FGeradorSena.EndWrite;
  end;

  Result := FSenha;
end;

class function TSenha.GerarsolicitacaoSenha(const ATerminal : string; const APrioritario: Boolean): string;
var
  lRetorno: TSenha;
begin
  lRetorno := TSenha.Create;
  try
    lRetorno.Terminal := ATerminal;
    lRetorno.Prioritario := APrioritario;
    lRetorno.Senha := '';

    Result := lRetorno.ToJsonString;
  finally
    lRetorno.Free;
  end;
end;

function TSenha.ToJsonString: string;
var
  lJson: TJSONObject;
begin
  lJson := TJsonObject.Create;
  try
    lJson.AddPair('senha', FSenha);
    lJson.AddPair('prioritario', BoolToStr(FPrioritario));
    lJson.AddPair('terminal', FTerminal);
    lJson.AddPair('atendente', FAtendente);
    Result := lJson.ToString;
  finally
    lJson.Free;
  end;
end;


initialization
  FGeradorSena := TMultiReadExclusiveWriteSynchronizer.Create;
finalization
  FGeradorSena.Free;

end.
