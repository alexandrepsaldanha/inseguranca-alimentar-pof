# =============================================================================
# Funções do projeto: recodificação, plano amostral, tabelas e gráficos
# =============================================================================

library(dplyr)
library(ggplot2)
library(survey)

# Estratos com uma única UPA (podem surgir em subconjuntos) usam o ajuste
# conservador em vez de gerar erro.
options(survey.lonely.psu = "adjust")


# -----------------------------------------------------------------------------
# 1. Dicionários de rótulos
#    A ordem dos itens define a ordem das categorias nas tabelas e gráficos,
#    para que nada saia em ordem alfabética.
# -----------------------------------------------------------------------------

ROTULOS <- list(
  SITUACAO_SEGURANCA_ALIMENTAR = c(
    "1" = "Segurança",
    "2" = "Insegurança leve",
    "3" = "Insegurança moderada",
    "4" = "Insegurança grave"
  ),
  SEXO = c("1" = "Homem", "2" = "Mulher"),
  COR_RACA = c(
    "1" = "Branca", "2" = "Preta", "4" = "Parda",
    "3" = "Amarela", "5" = "Indígena", "9" = "Sem declaração"
  ),
  NIVEL_INSTRUCAO = c(
    "1" = "Sem instrução",
    "2" = "Fundamental incompleto",
    "3" = "Fundamental completo",
    "4" = "Médio incompleto",
    "5" = "Médio completo",
    "6" = "Superior incompleto",
    "7" = "Superior completo"
  ),
  COMPOSICAO_FAMILIAR = c(
    "1" = "Um adulto sem criança",
    "2" = "Um adulto com ao menos uma criança",
    "3" = "Mais de um adulto sem criança",
    "4" = "Mais de um adulto com ao menos uma criança",
    "5" = "Um ou mais idosos, com ou sem crianças",
    "6" = "Idosos e adultos, com ou sem crianças"
  ),
  URBANO_RURAL = c("1" = "Urbano", "2" = "Rural"),
  GRANDE_REGIAO = c(
    "1" = "Norte", "2" = "Nordeste", "3" = "Sudeste",
    "4" = "Sul", "5" = "Centro-Oeste"
  ),
  UF = c(
    "11" = "Rondônia", "12" = "Acre", "13" = "Amazonas", "14" = "Roraima",
    "15" = "Pará", "16" = "Amapá", "17" = "Tocantins",
    "21" = "Maranhão", "22" = "Piauí", "23" = "Ceará",
    "24" = "Rio Grande do Norte", "25" = "Paraíba", "26" = "Pernambuco",
    "27" = "Alagoas", "28" = "Sergipe", "29" = "Bahia",
    "31" = "Minas Gerais", "32" = "Espírito Santo", "33" = "Rio de Janeiro",
    "35" = "São Paulo",
    "41" = "Paraná", "42" = "Santa Catarina", "43" = "Rio Grande do Sul",
    "50" = "Mato Grosso do Sul", "51" = "Mato Grosso", "52" = "Goiás",
    "53" = "Distrito Federal"
  )
)

# Aplica um dicionário de rótulos e devolve um fator com a ordem do dicionário.
# Códigos fora do dicionário viram NA.
rotular <- function(x, dicionario) {
  factor(unname(dicionario[as.character(x)]), levels = unname(dicionario))
}


# -----------------------------------------------------------------------------
# 2. Limpeza e criação das variáveis de análise
# -----------------------------------------------------------------------------

recodificar <- function(dados) {
  dados |>
    mutate(
      # Códigos de "ignorado" e valores negativos viram NA
      IDADE_EM_ANOS  = if_else(IDADE_EM_ANOS %in% 999 | IDADE_EM_ANOS < 0, NA, IDADE_EM_ANOS),
      ANOS_ESTUDO    = if_else(ANOS_ESTUDO %in% c(99, 999) | ANOS_ESTUDO < 0, NA, ANOS_ESTUDO),
      RENDA_DISP_PC  = if_else(RENDA_DISP_PC < 0, NA, RENDA_DISP_PC),
      RENDA_MONET_PC = if_else(RENDA_MONET_PC < 0, NA, RENDA_MONET_PC),

      # Desfecho: Escala Brasileira de Insegurança Alimentar (EBIA)
      TIPO_SEGURANCA_ALIMENTAR = rotular(SITUACAO_SEGURANCA_ALIMENTAR,
                                         ROTULOS$SITUACAO_SEGURANCA_ALIMENTAR),

      # Faixas etárias por ciclo de vida
      FAIXA_IDADE = cut(IDADE_EM_ANOS,
                        breaks = c(-Inf, 19, 39, 59, Inf),
                        labels = c("Até 19 anos", "20–39 anos", "40–59 anos", "60 anos ou mais")),

      # Faixas de renda disponível per capita (R$ correntes de 15/01/2018)
      FAIXA_RENDA_PC = cut(RENDA_DISP_PC,
                           breaks = c(-Inf, 500, 1000, 2000, 5000, Inf),
                           labels = c("Até R$ 500", "R$ 501 a R$ 1.000",
                                      "R$ 1.001 a R$ 2.000", "R$ 2.001 a R$ 5.000",
                                      "Acima de R$ 5.000")),

      # Faixas de anos de estudo
      FAIXA_ANOS_ESTUDO = cut(ANOS_ESTUDO,
                              breaks = c(-Inf, 0, 4, 8, 11, Inf),
                              labels = c("Sem instrução", "1–4 anos", "5–8 anos",
                                         "9–11 anos", "12 anos ou mais")),

      # Descrições das variáveis codificadas
      SEXO_DESC                = rotular(SEXO, ROTULOS$SEXO),
      COR_RACA_DESC            = rotular(COR_RACA, ROTULOS$COR_RACA),
      NIVEL_INSTRUCAO_DESC     = rotular(NIVEL_INSTRUCAO, ROTULOS$NIVEL_INSTRUCAO),
      COMPOSICAO_FAMILIAR_DESC = rotular(COMPOSICAO_FAMILIAR, ROTULOS$COMPOSICAO_FAMILIAR),
      URBANO_RURAL_DESC        = rotular(URBANO_RURAL, ROTULOS$URBANO_RURAL),
      GRANDE_REGIAO_DESC       = rotular(GRANDE_REGIAO, ROTULOS$GRANDE_REGIAO),
      UF_DESC                  = rotular(UF, ROTULOS$UF)
    )
}


# -----------------------------------------------------------------------------
# 3. Plano amostral complexo da POF
#    Estratificação (ESTRATO_POF), conglomeração em UPAs (COD_UPA) e pesos
#    (PESO_FINAL). Sem isso, os erros-padrão e os testes saem subestimados.
# -----------------------------------------------------------------------------

criar_desenho <- function(dados) {
  svydesign(
    ids     = ~COD_UPA,
    strata  = ~ESTRATO_POF,
    weights = ~PESO_FINAL,
    data    = dados,
    nest    = TRUE
  )
}


# -----------------------------------------------------------------------------
# 4. Tabelas
# -----------------------------------------------------------------------------

# Distribuição percentual ponderada de uma variável, com erro-padrão,
# intervalo de confiança de 95% e coeficiente de variação.
tabela_univariada <- function(var, desenho) {
  est <- svymean(reformulate(var), desenho, na.rm = TRUE)
  ic  <- confint(est)
  tibble(
    variavel   = var,
    categoria  = substring(names(coef(est)), nchar(var) + 1),
    percentual = 100 * unname(coef(est)),
    erro_padrao = 100 * unname(SE(est)),
    ic95_inf   = 100 * unname(ic[, 1]),
    ic95_sup   = 100 * unname(ic[, 2]),
    cv_pct     = 100 * unname(SE(est) / coef(est))
  )
}

# Distribuição da segurança alimentar dentro de cada categoria de `var`
# (perfil coluna) e teste qui-quadrado de Rao-Scott, que corrige o teste
# clássico para o plano amostral.
perfil_seguranca <- function(var, desenho) {
  validos <- !is.na(desenho$variables[[var]]) &
             !is.na(desenho$variables$TIPO_SEGURANCA_ALIMENTAR)
  d <- desenho[validos, ]
  formula <- as.formula(paste("~ TIPO_SEGURANCA_ALIMENTAR +", var))

  tabela <- svytable(formula, d) |>
    prop.table(margin = 2) |>
    as.data.frame() |>
    rename(categoria = all_of(var)) |>
    mutate(variavel = var, percentual = 100 * Freq, .keep = "unused") |>
    relocate(variavel, categoria)

  teste <- svychisq(formula, d)

  list(
    tabela = tabela,
    teste = tibble(
      variavel = var,
      estatistica_F = unname(teste$statistic),
      gl_numerador = unname(teste$parameter[1]),
      gl_denominador = unname(teste$parameter[2]),
      p_valor = teste$p.value
    )
  )
}


# -----------------------------------------------------------------------------
# 5. Gráfico padronizado: barras horizontais empilhadas (100%)
#    Paleta ordinal de um só tom (claro = segurança, escuro = insegurança
#    grave): legível para daltônicos e em impressão em tons de cinza.
# -----------------------------------------------------------------------------

CORES_SEG_ALIM <- c(
  "Segurança"            = "#86b6ef",
  "Insegurança leve"     = "#3987e5",
  "Insegurança moderada" = "#1c5cab",
  "Insegurança grave"    = "#0d366b"
)

tema_artigo <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.title.position = "plot",
    plot.caption = element_text(color = "grey40", size = 8, hjust = 0),
    plot.caption.position = "plot",
    axis.title = element_text(size = 10, color = "grey30"),
    axis.text = element_text(size = 10),
    legend.position = "top",
    legend.justification = "right",   # alinha a legenda à borda direita das barras
    legend.title = element_blank(),
    legend.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    plot.margin = margin(10, 24, 10, 10)
  )

# `ordenar = TRUE` ordena as categorias pela proporção em segurança alimentar
# (útil para UF); caso contrário, mantém a ordem natural das categorias.
grafico_perfil <- function(tabela, titulo, ordenar = FALSE) {
  if (ordenar) {
    ordem <- tabela |>
      filter(TIPO_SEGURANCA_ALIMENTAR == "Segurança") |>
      arrange(percentual) |>
      pull(categoria) |>
      as.character()
    tabela$categoria <- factor(tabela$categoria, levels = ordem)
  } else {
    tabela$categoria <- factor(tabela$categoria, levels = rev(levels(droplevels(tabela$categoria))))
  }

  ggplot(tabela, aes(x = percentual, y = categoria, fill = TIPO_SEGURANCA_ALIMENTAR)) +
    geom_col(width = 0.7, color = "white", linewidth = 0.4,
             position = position_stack(reverse = TRUE)) +
    # Rótulos só nos segmentos com espaço para o número
    geom_text(
      aes(label = ifelse(percentual >= 6, sprintf("%.0f%%", percentual), ""),
          color = TIPO_SEGURANCA_ALIMENTAR == "Segurança",
          group = TIPO_SEGURANCA_ALIMENTAR),
      position = position_stack(vjust = 0.5, reverse = TRUE),
      size = 3, show.legend = FALSE
    ) +
    scale_fill_manual(values = CORES_SEG_ALIM, drop = FALSE) +
    scale_color_manual(values = c(`TRUE` = "#0d366b", `FALSE` = "white"), guide = "none") +
    scale_x_continuous(labels = function(x) paste0(x, "%"), expand = c(0, 0)) +
    labs(
      title = titulo,
      x = NULL, y = NULL,
      caption = "Fonte: IBGE, POF 2017-2018. Estimativas ponderadas, considerando o plano amostral."
    ) +
    guides(fill = guide_legend(nrow = 1)) +
    tema_artigo
}
