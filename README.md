# Insegurança alimentar e perfil socioeconômico no Brasil (POF 2017-2018)

Como a insegurança alimentar se distribui entre os domicílios brasileiros, e o que isso diz sobre onde concentrar a política de combate à fome? Análise dos microdados da Pesquisa de Orçamentos Familiares (POF/IBGE), com o plano amostral complexo da pesquisa.

![Segurança alimentar por renda domiciliar per capita](output/figures/seguranca_por_faixa_renda_pc.png)

**Resultado principal:** a insegurança alimentar grave, que corresponde à fome, é fortemente concentrada na base da distribuição de renda. Os **12% de domicílios com renda per capita de até R$ 500 concentram 35% dos casos de insegurança grave**, e os 36% com até R$ 1.000 concentram 67%. Nesse grupo mais pobre, 13% dos domicílios estão em insegurança grave; acima de R$ 5.000, 0,4%.

---

## Pergunta econômica

A insegurança alimentar medida pela EBIA é um problema de **acesso**, e não de oferta: o Brasil produz alimento suficiente. A pergunta é, portanto, distributiva: quais domicílios não conseguem transformar renda em uma alimentação regular e adequada, e o quanto a renda, sozinha, explica esse padrão?

## Mecanismo

- **Restrição orçamentária.** Pela lei de Engel, quanto mais pobre o domicílio, maior a parcela da renda gasta com alimentação. Na base da distribuição, não há margem para absorver uma alta de preços ou uma perda de renda sem reduzir a quantidade ou a qualidade do que se come.
- **Restrição de liquidez.** Sem crédito ou poupança, os domicílios pobres não conseguem suavizar o consumo diante de choques de renda; a insegurança alimentar é a forma que essa impossibilidade assume no consumo mais essencial.
- **Composição do domicílio.** Domicílios com um único adulto têm uma só fonte potencial de renda do trabalho e ninguém com quem dividir o risco de perdê-la.

## O que os dados mostram

Prevalência de insegurança alimentar **grave** nos extremos de cada dimensão, e a diferença em pontos percentuais:

| Dimensão | Grupo mais exposto | Grupo menos exposto | Diferença |
|---|---:|---:|---:|
| Renda per capita | Até R$ 500: 12,9% | Acima de R$ 5.000: 0,4% | 12,5 p.p. |
| Escolaridade da pessoa de referência | Sem instrução: 9,4% | Superior completo: 0,9% | 8,5 p.p. |
| Região | Norte: 10,2% | Sul: 2,2% | 8,0 p.p. |
| Composição do domicílio | Um único adulto: 8,0–8,2% | Idosos sem outros adultos: 2,5% | 5,7 p.p. |
| Cor ou raça | Preta ou parda: 6,1–6,2% | Branca: 2,6% | 3,5 p.p. |
| Situação | Rural: 7,1% | Urbano: 4,1% | 3,0 p.p. |
| Sexo da pessoa de referência | Mulher: 5,6% | Homem: 3,8% | 1,8 p.p. |

A renda produz o maior gradiente, mas as outras dimensões estão correlacionadas com ela: escolaridade, região e cor ou raça também são determinantes da renda. Esta análise mostra **onde** o problema está; ela não separa **quanto** de cada diferença sobrevive quando a renda é mantida constante.

## O que a análise permite concluir

- **É descritiva, não causal.** As diferenças acima são associações. Os testes de Rao-Scott confirmam que todas são estatisticamente significativas, mas, com 57.920 domicílios, isso é esperado; a informação está no **tamanho** das diferenças.
- **Implicação de política.** A concentração na base da renda sustenta a focalização por renda, que é a base de programas como o Bolsa Família: um corte de renda per capita de até R$ 1.000 (valores de 2018) alcançaria dois terços dos casos de fome com pouco mais de um terço dos domicílios. Se os gradientes por região, composição do domicílio e cor ou raça persistirem com a renda controlada, critérios complementares de focalização ganham justificativa. Essa é a pergunta do próximo passo.

## Dados

| | |
|---|---|
| **Fonte** | [POF 2017-2018, IBGE](https://www.ibge.gov.br/estatisticas/sociais/saude/24786-pesquisa-de-orcamentos-familiares-2.html) (microdados públicos) |
| **Desfecho** | Escala Brasileira de Insegurança Alimentar (EBIA): segurança, insegurança leve, moderada e grave |
| **Unidade de análise** | Domicílio; características individuais referem-se à pessoa de referência |
| **Amostra** | 57.920 domicílios |
| **Registros usados** | MORADOR e DOMICILIO |

## Método

1. **Plano amostral:** estratos (`ESTRATO_POF`), conglomerados (`COD_UPA`) e pesos (`PESO_FINAL`) declarados com o pacote `survey`. Sem isso, os erros-padrão saem subestimados.
2. **Distribuições univariadas** ponderadas, com erro-padrão, intervalo de confiança de 95% e coeficiente de variação.
3. **Perfis bivariados:** distribuição da segurança alimentar dentro de cada categoria das variáveis socioeconômicas.
4. **Teste de associação:** qui-quadrado com correção de Rao-Scott, adequado a amostras complexas.

A análise é descritiva: as associações não têm interpretação causal. Detalhes de cada etapa em [`docs/metodologia.md`](docs/metodologia.md).

## Validação

As estimativas reproduzem a divulgação oficial do IBGE para a POF 2017-2018:

| Situação do domicílio | Este repositório | IBGE |
|---|---:|---:|
| Segurança alimentar | 63,3% | 63,3% |
| Insegurança leve | 24,0% | 24,0% |
| Insegurança moderada | 8,1% | 8,1% |
| Insegurança grave | 4,6% | 4,6% |

## Outros resultados

| Recorte | Gráfico |
|---|---|
| Nível de instrução | [ver](output/figures/seguranca_por_nivel_instrucao_desc.png) |
| Cor ou raça | [ver](output/figures/seguranca_por_cor_raca_desc.png) |
| Sexo | [ver](output/figures/seguranca_por_sexo_desc.png) |
| Idade | [ver](output/figures/seguranca_por_faixa_idade.png) |
| Composição familiar | [ver](output/figures/seguranca_por_composicao_familiar_desc.png) |
| Grande região | [ver](output/figures/seguranca_por_grande_regiao_desc.png) |
| Unidade da federação | [ver](output/figures/seguranca_por_uf_desc.png) |
| Situação urbano/rural | [ver](output/figures/seguranca_por_urbano_rural_desc.png) |

Tabelas completas, com erros-padrão, intervalos de confiança, coeficientes de variação e testes: [`output/tables/resultados.xlsx`](output/tables/resultados.xlsx) (também em `.csv` na mesma pasta).

## Estrutura

```
├── run_all.R                 # executa tudo
├── R/
│   └── funcoes.R             # recodificação, plano amostral, tabelas e gráficos
├── analysis/
│   ├── 01_preparar_dados.R   # microdados → base de domicílios
│   └── 02_analise.R          # estimativas, testes, gráficos e tabelas
├── data/
│   ├── raw/                  # microdados do IBGE (não versionados)
│   └── processed/            # base analítica pronta (.rds e .csv.gz)
├── output/
│   ├── figures/
│   └── tables/
└── docs/
    └── metodologia.md
```

## Como reproduzir

**Caminho rápido.** A base analítica já vem no repositório ([`data/processed/`](data/processed/LEIAME.md)). Clone e execute, na raiz:

```r
source("run_all.R")
```

**Do zero, a partir dos microdados do IBGE.** Baixe os microdados da POF 2017-2018 e rode o programa de leitura do IBGE (passo a passo em [`data/raw/LEIAME.md`](data/raw/LEIAME.md)). Copie `MORADOR.rds` e `DOMICILIO.rds` para `data/raw/` e execute o mesmo comando: com os microdados presentes, a base é refeita antes da análise.

Requer R ≥ 4.1 e os pacotes `dplyr`, `ggplot2`, `survey` e `writexl` (instalados automaticamente se faltarem).

## Próximos passos

- **Determinantes condicionais:** logit ordenado com o plano amostral (`svyolr`), para medir quanto do gradiente por região, escolaridade, composição familiar e cor ou raça persiste com a renda constante.
- Incluir as condições de saneamento e energia elétrica, já presentes na base preparada.

## Autor

**Alexandre Saldanha**, economista e mestrando em População, Território e Estatísticas Públicas (ENCE/IBGE).
[LinkedIn](https://www.linkedin.com/in/alexandre-saldanha-202a8592/) · [Lattes](http://lattes.cnpq.br/5148309722351266)

Projeto desenvolvido em consultoria estatística para uma pesquisa de mestrado em Saúde Coletiva.

Código sob licença [MIT](LICENSE). Dados: IBGE, POF 2017-2018 (microdados públicos).
