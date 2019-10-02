# lmxAtendimento
Exemplo de uso do RabbitMQ com Delphi

Este exemplo é utilizado para verificar o funcionamento do RabbitMQ utilizando as bibliotecas do Delphi.
Existe um arquivo junto aos executáveis que define o IP onde está instalado o RabbitMQ.
Após compilados, serão criados os seguintes Executáveis :

>**1) SenhasTerminal :**
  Simula o terminal de atendimento com opção de preferencial
  
>**2) Gerador de Senhas :** 
  Responsável por gerar as senhas e devolver ao terminal que solicitou
  Após a geração da senha, o atendimento é postado na fila de Solicitação, para que um atendente consiga pegar
  
>**3) SolicitacaoSenhaCaixa :** 
  O Atendente irá solicitar um atendimento da fila
  Primeiro são retornados os atendimentos prioritários
  
>**4) PainelSenha :**
  Mostra os atendimentos que foram entregues aos atendentes
