# Executa o projeto completo, a partir da pasta raiz do repositório.
# Pré-requisito: MORADOR.rds e DOMICILIO.rds em data/raw/ (ver data/raw/LEIAME.md)

pacotes <- c("dplyr", "ggplot2", "survey", "writexl")
faltando <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltando) > 0) install.packages(faltando)

source("analysis/01_preparar_dados.R")
source("analysis/02_analise.R")
