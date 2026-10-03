# Base analítica: POF 2017-2018, domicílios

Base pronta para a análise, com o mesmo conteúdo que `analysis/01_preparar_dados.R` produz a partir dos microdados públicos da POF 2017-2018 (IBGE).

| | |
|---|---|
| **Arquivos** | `pof2017_domicilios.rds` (R) e `pof2017_domicilios.csv.gz` (CSV compactado, UTF-8) |
| **Registros** | 57.920 domicílios, um por linha |
| **Pessoa** | características individuais da pessoa de referência da 1ª unidade de consumo |
| **Plano amostral** | `ESTRATO_POF` (estrato), `COD_UPA` (conglomerado), `PESO_FINAL` (peso) |
| **Fonte** | IBGE, Pesquisa de Orçamentos Familiares 2017-2018, microdados |

Os nomes das variáveis e os códigos originais da POF estão no dicionário de [`docs/metodologia.md`](../../docs/metodologia.md). Os identificadores `ID_DOMICILIO` e `ID_PESSOAL` são texto; no CSV, leia-os como texto para não perder dígitos.

Ao usar esta base, cite o IBGE como fonte dos dados.
