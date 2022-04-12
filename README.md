# Trybe Serverless Deploy
Action utilizada para realizar deploy, rollback ou remover aplicações serverless na Trybe.

## Entradas
* **environment** - Tipo de ambiente que a função será lançada.
* **settings** - Segredo contendo todas as configurações necessárias para realizar o deploy serverless nos ambientes da Trybe.
* **command** - Ação à ser realizada por esta action.

### Configurações disponíveis
* **SECRET_\<nome-do-secret\>** - Qualquer variável de ambiente com o prefixo **SECRET_** será incluído como **parâmetro** na hora da execução do framework serverless.
