# =============================================================================
# 02 - Análise descritiva ponderada da segurança alimentar
# =============================================================================
#
# Entrada: data/processed/pof2017_domicilios.rds (gerado por 01_preparar_dados.R)
# Saídas:  output/tables/resultados.xlsx  (+ versões .csv)
#          output/figures/seguranca_por_*.png
# =============================================================================

source("R/funcoes.R")

dados   <- readRDS("data/processed/pof2017_domicilios.rds") |> recodificar()
desenho <- criar_desenho(dados)

# Variáveis cruzadas com a segurança alimentar e o título de cada gráfico
variaveis <- c(
  FAIXA_RENDA_PC           = "Segurança alimentar por renda domiciliar per capita",
  FAIXA_IDADE              = "Segurança alimentar por idade da pessoa de referência",
  SEXO_DESC                = "Segurança alimentar por sexo da pessoa de referência",
  COR_RACA_DESC            = "Segurança alimentar por cor ou raça da pessoa de referência",
  NIVEL_INSTRUCAO_DESC     = "Segurança alimentar por nível de instrução da pessoa de referência",
  COMPOSICAO_FAMILIAR_DESC = "Segurança alimentar por composição familiar",
  GRANDE_REGIAO_DESC       = "Segurança alimentar por grande região",
  UF_DESC                  = "Segurança alimentar por unidade da federação",
  URBANO_RURAL_DESC        = "Segurança alimentar por situação do domicílio"
)


# 1. Distribuições univariadas ------------------------------------------------

univariadas <- c("TIPO_SEGURANCA_ALIMENTAR", names(variaveis)) |>
  lapply(tabela_univariada, desenho = desenho) |>
  bind_rows()

univariadas |>
  filter(variavel == "TIPO_SEGURANCA_ALIMENTAR") |>
  print()


# 2. Perfis bivariados e testes de Rao-Scott ----------------------------------

resultados <- lapply(names(variaveis), perfil_seguranca, desenho = desenho)
names(resultados) <- names(variaveis)

perfis <- bind_rows(lapply(resultados, `[[`, "tabela"))
testes <- bind_rows(lapply(resultados, `[[`, "teste"))
print(testes)


# 3. Gráficos ----------------------------------------------------------------

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)

for (var in names(variaveis)) {
  tabela <- resultados[[var]]$tabela
  n_categorias <- n_distinct(tabela$categoria)

  grafico <- grafico_perfil(tabela, variaveis[[var]], ordenar = var == "UF_DESC")

  ggsave(
    filename = file.path("output/figures", paste0("seguranca_por_", tolower(var), ".png")),
    plot = grafico,
    width = 9, height = 1.6 + 0.4 * n_categorias,
    dpi = 200, bg = "white"
  )
}


# 4. Exportação das tabelas ---------------------------------------------------

dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)

writexl::write_xlsx(
  list(univariadas = univariadas, perfis = perfis, testes_rao_scott = testes),
  "output/tables/resultados.xlsx"
)
write.csv(univariadas, "output/tables/univariadas.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(perfis,      "output/tables/perfis.csv",      row.names = FALSE, fileEncoding = "UTF-8")
write.csv(testes,      "output/tables/testes_rao_scott.csv", row.names = FALSE, fileEncoding = "UTF-8")

message("Análise concluída. Resultados em output/.")
