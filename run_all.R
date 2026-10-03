# Executa o projeto completo, a partir da pasta raiz do repositório.
#
# Dois caminhos:
#   - Com os microdados do IBGE em data/raw/ (ver data/raw/LEIAME.md):
#     a base é refeita do zero por analysis/01_preparar_dados.R.
#   - Sem eles: usa a base já preparada em data/processed/, que vem no repositório.

pacotes <- c("dplyr", "ggplot2", "survey", "writexl")
faltando <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltando) > 0) install.packages(faltando)

microdados <- c("data/raw/MORADOR.rds", "data/raw/DOMICILIO.rds")
if (all(file.exists(microdados))) {
  source("analysis/01_preparar_dados.R")
} else {
  message("Microdados não encontrados em data/raw/: usando a base preparada em data/processed/.")
}

source("analysis/02_analise.R")
