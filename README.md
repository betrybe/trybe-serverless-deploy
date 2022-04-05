# Trybe Serverless Deploy
Action utilizada para realizar deploy de aplicações serverless na Trybe.

## Entradas
> Esta action não possui **nenhum** input.
> 
> Todas as entradas desta action são obtidas através de **variáveis de ambiente**. Desta maneira, a manutenção desta action fica simplificada ao utilizar sempre a versão mapeada com a branch principal.

### Configurações disponíveis
* **SECRET_\<nome-do-secret\>** - Qualquer variável de ambiente com o prefixo **SECRET_** será incluído como variável de ambiente dentro do ambiente serverless.
* **ENVIRONMENT** - Ambiente no qual este código será entregue. As opções são: `[staging, homologation e production]`.
