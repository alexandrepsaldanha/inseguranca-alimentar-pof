# =============================================================================
# 01 - Preparação da base: um registro por domicílio
# =============================================================================
#
# Entrada (não versionada, ver data/raw/LEIAME.md):
#   data/raw/MORADOR.rds   e   data/raw/DOMICILIO.rds
#   gerados pelo programa de leitura em R que o IBGE distribui junto com os
#   microdados da POF 2017-2018.
#
# Saída:
#   data/processed/pof2017_domicilios.rds
#
# Unidade de análise: o domicílio. As características individuais (idade,
# sexo, cor ou raça, escolaridade) são as da pessoa de referência.
# =============================================================================

library(dplyr)

morador   <- readRDS("data/raw/MORADOR.rds")
domicilio <- readRDS("data/raw/DOMICILIO.rds")

chaves <- c("UF", "ESTRATO_POF", "TIPO_SITUACAO_REG", "COD_UPA", "NUM_DOM")

# Pessoa de referência (V0306 == 1) da primeira unidade de consumo, para
# garantir um único registro por domicílio.
pessoa_referencia <- morador |>
  filter(V0306 == 1, NUM_UC == 1) |>
  select(
    all_of(chaves), PESO_FINAL,
    CONDICAO_NA_UC      = V0306,
    IDADE_EM_ANOS       = V0403,
    SEXO                = V0404,
    COR_RACA            = V0405,
    RENDIM_REMUN_12M    = V0407,
    LE_ESCREVE          = V0414,
    ANOS_ESTUDO,
    NIVEL_INSTRUCAO,
    RENDA_DISP_PC,
    RENDA_MONET_PC,
    COMPOSICAO_FAMILIAR = COMPOSICAO
  )

caracteristicas_domicilio <- domicilio |>
  select(
    all_of(chaves),
    FORMA_ABAST_AGUA                            = V0207,
    ESCOADOURO_DEJECOES                         = V0212,
    DESTINO_LIXO                                = V0213,
    ENERGIA_ELETRICA_REDE_GERAL                 = V02141,
    ENERGIA_ELETRICA_OUTRA_ORIGEM               = V02142,
    FREQ_ENERGIA_ELETRICA_REDE_GERAL_DISPONIVEL = V0215,
    SITUACAO_SEGURANCA_ALIMENTAR                = V6199
  )

dados <- pessoa_referencia |>
  inner_join(caracteristicas_domicilio, by = chaves) |>
  mutate(
    URBANO_RURAL  = TIPO_SITUACAO_REG,
    GRANDE_REGIAO = UF %/% 10   # 1º dígito do código da UF
  )

# Checagem: um registro por domicílio
stopifnot(!anyDuplicated(dados[chaves]))

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(dados, "data/processed/pof2017_domicilios.rds")

message("Base preparada: ", nrow(dados), " domicílios.")
