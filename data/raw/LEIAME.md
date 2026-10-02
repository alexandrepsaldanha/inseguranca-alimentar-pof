# Dados brutos (não versionados)

Os microdados não ficam no repositório. Para reproduzir a análise:

1. Acesse a página da POF 2017-2018 no site do IBGE, aba **Microdados**:
   <https://www.ibge.gov.br/estatisticas/sociais/saude/24786-pesquisa-de-orcamentos-familiares-2.html>
2. Baixe os arquivos de dados e o programa de leitura em R.
3. Execute o programa de leitura. Ele gera os arquivos `.rds` de cada registro.
4. Copie `MORADOR.rds` e `DOMICILIO.rds` para esta pasta.

Depois, na raiz do repositório, rode `source("run_all.R")`.
