# Metodologia

Este documento descreve cada etapa do código, na ordem em que é executado.

## 1. Preparação da base (`analysis/01_preparar_dados.R`)

**Fonte.** Microdados da Pesquisa de Orçamentos Familiares (POF) 2017-2018, do IBGE, lidos com o programa oficial de leitura em R. São usados dois registros:

- **MORADOR**: características individuais e variáveis derivadas de renda e escolaridade.
- **DOMICILIO**: características do domicílio, incluindo a classificação de segurança alimentar (`V6199`).

**Unidade de análise.** O domicílio. Do registro de moradores, mantém-se apenas a pessoa de referência (`V0306 == 1`) da primeira unidade de consumo, o que garante um registro por domicílio. As características individuais da análise (idade, sexo, cor ou raça, escolaridade) são, portanto, as da pessoa de referência.

**Junção.** Os dois registros são unidos pelas chaves `UF`, `ESTRATO_POF`, `TIPO_SITUACAO_REG`, `COD_UPA` e `NUM_DOM`. O script interrompe a execução se houver domicílio duplicado.

**Renomeação.** Os códigos originais recebem nomes descritivos (por exemplo, `V0403` vira `IDADE_EM_ANOS`). A tabela completa está no fim deste documento.

## 2. Limpeza e recodificação (`recodificar()` em `R/funcoes.R`)

**Valores inválidos viram `NA`:**

- idade igual a 999 ou negativa;
- anos de estudo iguais a 99 ou 999, ou negativos;
- rendas per capita negativas.

**Desfecho.** A variável `V6199` (Escala Brasileira de Insegurança Alimentar, EBIA) vira um fator ordenado com quatro níveis: Segurança, Insegurança leve, Insegurança moderada e Insegurança grave.

**Variáveis agrupadas:**

| Variável | Categorias |
|---|---|
| Faixa etária | até 19, 20–39, 40–59, 60 anos ou mais |
| Renda disponível per capita | até R\$ 500; R\$ 501–1.000; R\$ 1.001–2.000; R\$ 2.001–5.000; acima de R\$ 5.000 |
| Anos de estudo | sem instrução; 1–4; 5–8; 9–11; 12 ou mais |

Os valores de renda estão em reais correntes da data de referência da POF (15/01/2018).

**Rótulos.** Sexo, cor ou raça, nível de instrução, composição familiar, UF, grande região e situação urbano/rural recebem descrições por meio de dicionários (`ROTULOS`). A ordem de cada dicionário define a ordem das categorias nas tabelas e nos gráficos.

## 3. Plano amostral complexo (`criar_desenho()`)

A POF usa amostragem estratificada e por conglomerados, com pesos diferentes para cada domicílio. Ignorar esse desenho produz erros-padrão subestimados e testes que rejeitam a hipótese nula com frequência excessiva. O objeto de desenho declara:

```r
svydesign(ids = ~COD_UPA, strata = ~ESTRATO_POF, weights = ~PESO_FINAL,
          data = dados, nest = TRUE)
```

- `COD_UPA`: unidade primária de amostragem (conglomerado);
- `ESTRATO_POF`: estrato;
- `PESO_FINAL`: peso amostral;
- `nest = TRUE`: os códigos de UPA se repetem entre estratos.

## 4. Distribuições univariadas (`tabela_univariada()`)

Para cada variável, `svymean()` estima a distribuição percentual ponderada. A tabela de saída traz, para cada categoria, o percentual, o erro-padrão, o intervalo de confiança de 95% e o coeficiente de variação. O CV indica a precisão da estimativa: categorias pequenas, como Amarela ou Indígena, têm CV alto e pedem cautela na interpretação.

## 5. Perfis bivariados e teste de associação (`perfil_seguranca()`)

Para cada variável explicativa:

1. `svytable()` cruza a segurança alimentar com a variável, com os pesos amostrais.
2. `prop.table(margin = 2)` calcula a distribuição da segurança alimentar **dentro** de cada categoria (perfil coluna). Exemplo: entre os domicílios com renda per capita de até R\$ 500, qual a proporção em cada nível de insegurança.
3. `svychisq()` aplica o teste qui-quadrado com a correção de Rao-Scott, que ajusta a estatística ao plano amostral. A hipótese nula é de independência entre a segurança alimentar e a variável.

Com cerca de 58 mil domicílios na amostra, praticamente toda associação é estatisticamente significativa. Por isso, a leitura relevante está no **tamanho** das diferenças entre os perfis, não só no valor-p.

## 6. Gráficos (`grafico_perfil()`)

Barras horizontais empilhadas em 100%, uma barra por categoria. Escolhas de desenho:

- **Barras horizontais**, para que rótulos longos (UF, composição familiar) fiquem legíveis sem inclinação.
- **Paleta ordinal de um só tom**, do azul claro (segurança) ao azul escuro (insegurança grave). A intensidade acompanha a gravidade, e a leitura funciona para daltônicos e em impressão em tons de cinza.
- **Percentuais escritos** nos segmentos com 6% ou mais.
- **UFs ordenadas** pela proporção de domicílios em segurança alimentar. As demais variáveis mantêm a ordem natural das categorias.

## 7. Saídas

| Arquivo | Conteúdo |
|---|---|
| `output/tables/resultados.xlsx` | três abas: univariadas, perfis e testes de Rao-Scott |
| `output/tables/*.csv` | as mesmas tabelas, em texto, para acompanhar mudanças no Git |
| `output/figures/seguranca_por_*.png` | um gráfico por variável |

## Dicionário de variáveis

| Código POF | Registro | Nome na análise |
|---|---|---|
| `V0306` | Morador | `CONDICAO_NA_UC` |
| `V0403` | Morador | `IDADE_EM_ANOS` |
| `V0404` | Morador | `SEXO` |
| `V0405` | Morador | `COR_RACA` |
| `V0407` | Morador | `RENDIM_REMUN_12M` |
| `V0414` | Morador | `LE_ESCREVE` |
| `ANOS_ESTUDO` | Morador | `ANOS_ESTUDO` |
| `NIVEL_INSTRUCAO` | Morador | `NIVEL_INSTRUCAO` |
| `RENDA_DISP_PC` | Morador | `RENDA_DISP_PC` |
| `RENDA_MONET_PC` | Morador | `RENDA_MONET_PC` |
| `COMPOSICAO` | Morador | `COMPOSICAO_FAMILIAR` |
| `TIPO_SITUACAO_REG` | ambos | `URBANO_RURAL` |
| `V0207` | Domicílio | `FORMA_ABAST_AGUA` |
| `V0212` | Domicílio | `ESCOADOURO_DEJECOES` |
| `V0213` | Domicílio | `DESTINO_LIXO` |
| `V02141` | Domicílio | `ENERGIA_ELETRICA_REDE_GERAL` |
| `V02142` | Domicílio | `ENERGIA_ELETRICA_OUTRA_ORIGEM` |
| `V0215` | Domicílio | `FREQ_ENERGIA_ELETRICA_REDE_GERAL_DISPONIVEL` |
| `V6199` | Domicílio | `SITUACAO_SEGURANCA_ALIMENTAR` |
| `PESO_FINAL` | ambos | `PESO_FINAL` |
| `COD_UPA`, `ESTRATO_POF` | ambos | variáveis do plano amostral |

As variáveis de saneamento e energia elétrica já estão na base preparada, mas ainda não entram nos cruzamentos. São a extensão natural da análise.
