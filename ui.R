# ============================================================
# Archivo: ui.R
# Proyecto: EDA de Criptomonedas con API de Mercado
# ============================================================

library(shinydashboard)

ui <- dashboardPage(
  skin = "blue",
  
  # ── 1. Cabecera ──────────────────────────────────────────
  dashboardHeader(
    title = tagList(
      tags$img(src = "crypto.svg", height = "38", style = "padding-right:8px;"),
      "Crypto EDA"
    ),
    titleWidth = 340
  ),
  
  # ── 2. Barra lateral ─────────────────────────────────────
  dashboardSidebar(
    width = 240,
    sidebarMenu(
      menuItem("Introducción",        tabName = "intro",       icon = icon("house")),
      menuItem("Visión General",      tabName = "overview",    icon = icon("gauge")),
      menuItem("Precios & Tendencia", tabName = "precios",     icon = icon("chart-line")),
      menuItem("Retornos & Riesgo",   tabName = "retornos",    icon = icon("percent")),
      menuItem("Correlaciones",       tabName = "correlacion", icon = icon("table-cells")),
      menuItem("Comparador",          tabName = "comparador",  icon = icon("sliders"))
    )
  ),
  
  # ── 3. Cuerpo ─────────────────────────────────────────────
  dashboardBody(
    
    # CSS personalizado
    tags$head(tags$style(HTML("
      .skin-black .main-header .logo { background-color: #1a1a2e; }
      .skin-black .main-header .navbar { background-color: #16213e; }
      .skin-black .main-sidebar { background-color: #0f3460; }
      .skin-black .sidebar-menu > li.active > a,
      .skin-black .sidebar-menu > li:hover > a {
        background-color: #e94560;
        border-left: 3px solid #f0a500;
      }
      .small-box .inner { text-align: center; }
      .small-box h3, .small-box p { text-align: center; }
      .value-box-positive { color: #2ecc71 !important; }
      .value-box-negative { color: #e74c3c !important; }
      .content-wrapper, .right-side { background-color: #f4f6f9; }
    "))),
    
    tabItems(
      
      # ══════════════════════════════════════════════════════
      # TAB 0 — INTRODUCCIÓN
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "intro",
              
              # ── Banda hero ────────────────────────────────────
              div(style = "
              background: linear-gradient(135deg, #0f3460 0%, #16213e 55%, #1a1a2e 100%);
              border-radius: 12px;
              padding: 40px 48px 36px;
              margin-bottom: 24px;
              position: relative;
              overflow: hidden;
            ",
                  
                  # Etiqueta de proyecto
                  span(style = "
                display: inline-block;
                background: rgba(247,147,26,0.18);
                color: #F7931A;
                font-size: 11px;
                font-weight: 600;
                letter-spacing: 0.09em;
                text-transform: uppercase;
                padding: 4px 14px;
                border-radius: 20px;
                border: 1px solid rgba(247,147,26,0.35);
                margin-bottom: 20px;
              ",
                       "Proyecto · Visualización de Datos · 2026-10"
                  ),
                  
                  # Título principal
                  h1(style = "color:#ffffff; font-size:32px; font-weight:600;
                      margin:0 0 10px; line-height:1.25;",
                     "Análisis Exploratorio de ",
                     span(style = "color:#F7931A;", "Criptomonedas")
                  ),
                  p(style = "color:rgba(255,255,255,0.55); font-size:14px;
                     line-height:1.7; margin:0 0 32px; max-width:580px;",
                    "Dashboard interactivo para explorar el comportamiento histórico
             y actual de los principales activos digitales del mercado,
             consumiendo datos en tiempo real desde la API de CryptoCompare."
                  ),
                  
                  # Separador
                  hr(style = "border:none; border-top:1px solid rgba(255,255,255,0.1);
                      margin:0 0 28px;"),
                  
                  # Presentadores
                  p(style = "color:rgba(255,255,255,0.35); font-size:11px;
                     text-transform:uppercase; letter-spacing:0.09em;
                     margin:0 0 14px;",
                    "Presentado por"),
                  div(style = "display:flex; gap:16px; flex-wrap:wrap;",
                      
                      # Mateo Barrios
                      div(style = "
                  display:flex; align-items:center; gap:12px;
                  background:rgba(255,255,255,0.07);
                  border:1px solid rgba(255,255,255,0.13);
                  border-radius:40px; padding:8px 20px 8px 8px;
                ",
                          div(style = "
                    width:38px; height:38px; border-radius:50%;
                    background:rgba(98,126,234,0.25);
                    display:flex; align-items:center; justify-content:center;
                    color:#8FA8F5; font-size:14px; font-weight:600;
                  ", "MB"),
                          div(
                            p(style = "color:rgba(255,255,255,0.88); font-size:14px;
                           font-weight:600; margin:0 0 2px;",
                              "Mateo Barrios"),
                            p(style = "color:rgba(255,255,255,0.4); font-size:12px; margin:0;"
                              )
                          )
                      ),
                      
                      # Rafael Romero
                      div(style = "
                  display:flex; align-items:center; gap:12px;
                  background:rgba(255,255,255,0.07);
                  border:1px solid rgba(255,255,255,0.13);
                  border-radius:40px; padding:8px 20px 8px 8px;
                ",
                          div(style = "
                    width:38px; height:38px; border-radius:50%;
                    background:rgba(247,147,26,0.2);
                    display:flex; align-items:center; justify-content:center;
                    color:#F7931A; font-size:14px; font-weight:600;
                  ", "RR"),
                          div(
                            p(style = "color:rgba(255,255,255,0.88); font-size:14px;
                           font-weight:600; margin:0 0 2px;",
                              "Rafael Romero"),
                            p(style = "color:rgba(255,255,255,0.4); font-size:12px; margin:0;"
                              )
                          )
                      )
                  ) # fin presentadores
              ), # fin hero
              
              # ── Objetivo ──────────────────────────────────────
              div(style = "
              background: #ffffff;
              border: 1px solid #e0e0e0;
              border-left: 4px solid #F7931A;
              border-radius: 10px;
              padding: 24px 28px;
              margin-bottom: 24px;
            ",
                  p(style = "color:#F7931A; font-size:11px; font-weight:700;
                     text-transform:uppercase; letter-spacing:0.09em;
                     margin:0 0 12px;",
                    "Objetivo del Proyecto"),
                  p(style = "color:#2d2d2d; font-size:15px; line-height:1.8; margin:0;",
                    "Desarrollar un dashboard interactivo basado en técnicas de
             visualización de datos que permita analizar el comportamiento
             histórico y actual de criptomonedas, facilitando la exploración
             de tendencias, volatilidad y relaciones entre activos para apoyar
             la toma de decisiones informadas.")
              ),
              
              # ── Métricas rápidas ──────────────────────────────
              fluidRow(
                column(3, div(style = "background:#f7f7f7; border-radius:10px;
                                  padding:20px; text-align:center;",
                              h3(style = "margin:0 0 6px; font-size:28px; font-weight:600;
                        color:#1a1a2e;", "5"),
                              p(style = "margin:0; font-size:12px; color:#888;", "Criptomonedas")
                )),
                column(3, div(style = "background:#f7f7f7; border-radius:10px;
                                  padding:20px; text-align:center;",
                              h3(style = "margin:0 0 6px; font-size:28px; font-weight:600;
                        color:#1a1a2e;", "365"),
                              p(style = "margin:0; font-size:12px; color:#888;", "Días de historial")
                )),
                column(3, div(style = "background:#f7f7f7; border-radius:10px;
                                  padding:20px; text-align:center;",
                              h3(style = "margin:0 0 6px; font-size:28px; font-weight:600;
                        color:#1a1a2e;", "5"),
                              p(style = "margin:0; font-size:12px; color:#888;", "Módulos de análisis")
                )),
                column(3, div(style = "background:#f7f7f7; border-radius:10px;
                                  padding:20px; text-align:center;",
                              h3(style = "margin:0 0 6px; font-size:24px; font-weight:600;
                        color:#F7931A;", "API"),
                              p(style = "margin:0; font-size:12px; color:#888;", "Datos en tiempo real")
                ))
              ),
              
              br(),
              
              # ── Módulos del dashboard ─────────────────────────
              p(style = "font-size:11px; font-weight:700; text-transform:uppercase;
                   letter-spacing:0.09em; color:#888; margin:0 0 14px;",
                "Módulos del Dashboard"),
              
              fluidRow(
                column(3, div(style = "background:#fff; border:1px solid #e8e8e8;
                                  border-radius:10px; padding:20px; height:130px;",
                              div(style = "width:36px; height:36px; background:rgba(247,147,26,0.12);
                          border-radius:8px; display:flex; align-items:center;
                          justify-content:center; font-size:18px; margin-bottom:12px;",
                                  icon("gauge")),
                              strong(style = "font-size:13px; color:#1a1a2e;", "Visión General"),
                              p(style = "font-size:12px; color:#888; margin:6px 0 0; line-height:1.5;",
                                "Precios actuales, cap. de mercado y volumen 24h.")
                )),
                column(3, div(style = "background:#fff; border:1px solid #e8e8e8;
                                  border-radius:10px; padding:20px; height:130px;",
                              div(style = "width:36px; height:36px; background:rgba(98,126,234,0.12);
                          border-radius:8px; display:flex; align-items:center;
                          justify-content:center; font-size:18px; margin-bottom:12px;",
                                  icon("chart-line")),
                              strong(style = "font-size:13px; color:#1a1a2e;", "Precios & Tendencia"),
                              p(style = "font-size:12px; color:#888; margin:6px 0 0; line-height:1.5;",
                                "Serie temporal, medias móviles, Bollinger y velas.")
                )),
                column(3, div(style = "background:#fff; border:1px solid #e8e8e8;
                                  border-radius:10px; padding:20px; height:130px;",
                              div(style = "width:36px; height:36px; background:rgba(30,200,120,0.1);
                          border-radius:8px; display:flex; align-items:center;
                          justify-content:center; font-size:18px; margin-bottom:12px;",
                                  icon("percent")),
                              strong(style = "font-size:13px; color:#1a1a2e;", "Retornos & Riesgo"),
                              p(style = "font-size:12px; color:#888; margin:6px 0 0; line-height:1.5;",
                                "Distribución de retornos, volatilidad y VaR 95%.")
                )),
                column(3, div(style = "background:#fff; border:1px solid #e8e8e8;
                                  border-radius:10px; padding:20px; height:130px;",
                              div(style = "width:36px; height:36px; background:rgba(153,69,255,0.1);
                          border-radius:8px; display:flex; align-items:center;
                          justify-content:center; font-size:18px; margin-bottom:12px;",
                                  icon("table-cells")),
                              strong(style = "font-size:13px; color:#1a1a2e;", "Correlaciones & Comparador"),
                              p(style = "font-size:12px; color:#888; margin:6px 0 0; line-height:1.5;",
                                "Heatmap de correlación y rendimiento acumulado.")
                ))
              ),
              
              br(),
              
              # ── Activos analizados ────────────────────────────
              p(style = "font-size:11px; font-weight:700; text-transform:uppercase;
                   letter-spacing:0.09em; color:#888; margin:0 0 14px;",
                "Activos Analizados"),
              div(style = "display:flex; gap:10px; flex-wrap:wrap;",
                  div(style = "display:flex; align-items:center; gap:8px;
                        background:#f7f7f7; border:1px solid #e8e8e8;
                        border-radius:20px; padding:6px 16px 6px 10px;",
                      div(style = "width:10px; height:10px; border-radius:50%;
                          background:#F7931A; flex-shrink:0;"),
                      span(style = "font-size:13px; color:#1a1a2e;", "Bitcoin (BTC)")),
                  div(style = "display:flex; align-items:center; gap:8px;
                        background:#f7f7f7; border:1px solid #e8e8e8;
                        border-radius:20px; padding:6px 16px 6px 10px;",
                      div(style = "width:10px; height:10px; border-radius:50%;
                          background:#627EEA; flex-shrink:0;"),
                      span(style = "font-size:13px; color:#1a1a2e;", "Ethereum (ETH)")),
                  div(style = "display:flex; align-items:center; gap:8px;
                        background:#f7f7f7; border:1px solid #e8e8e8;
                        border-radius:20px; padding:6px 16px 6px 10px;",
                      div(style = "width:10px; height:10px; border-radius:50%;
                          background:#F3BA2F; flex-shrink:0;"),
                      span(style = "font-size:13px; color:#1a1a2e;", "BNB")),
                  div(style = "display:flex; align-items:center; gap:8px;
                        background:#f7f7f7; border:1px solid #e8e8e8;
                        border-radius:20px; padding:6px 16px 6px 10px;",
                      div(style = "width:10px; height:10px; border-radius:50%;
                          background:#9945FF; flex-shrink:0;"),
                      span(style = "font-size:13px; color:#1a1a2e;", "Solana (SOL)")),
                  div(style = "display:flex; align-items:center; gap:8px;
                        background:#f7f7f7; border:1px solid #e8e8e8;
                        border-radius:20px; padding:6px 16px 6px 10px;",
                      div(style = "width:10px; height:10px; border-radius:50%;
                          background:#00AAE4; flex-shrink:0;"),
                      span(style = "font-size:13px; color:#1a1a2e;", "XRP"))
              )
              
      ), # fin tabItem intro
      
      # ══════════════════════════════════════════════════════
      # TAB 1 — VISIÓN GENERAL
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "overview",
              h2("📊 Visión General del Mercado"),
              p("Snapshot en tiempo real de las principales criptomonedas analizadas en este estudio."),
              
              fluidRow(
                box(
                  title = "Resumen del Dataset", status = "primary",
                  solidHeader = TRUE, collapsible = TRUE, width = 12,
                  fluidRow(
                    column(3, valueBoxOutput("vbox_monedas",   width = 12)),
                    column(3, valueBoxOutput("vbox_registros", width = 12)),
                    column(3, valueBoxOutput("vbox_periodo",   width = 12)),
                    column(3, valueBoxOutput("vbox_missing",   width = 12))
                  )
                )
              ),
              
              fluidRow(
                box(
                  title = "Precios Actuales y Métricas de Mercado",
                  status = "warning", solidHeader = TRUE, width = 12,
                  DT::dataTableOutput("tabla_overview")
                )
              ),
              
              fluidRow(
                box(
                  title = "Capitalización de Mercado (USD)",
                  status = "success", solidHeader = TRUE, width = 6,
                  plotlyOutput("plot_market_cap", height = 320)
                ),
                box(
                  title = "Volumen de Negociación 24h (USD)",
                  status = "info", solidHeader = TRUE, width = 6,
                  plotlyOutput("plot_volume", height = 320)
                )
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # TAB 2 — PRECIOS & TENDENCIA
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "precios",
              h2("📈 Análisis de Precios y Tendencia"),
              p("Serie de tiempo del precio de cierre con medias móviles para identificar tendencias."),
              
              fluidRow(
                box(
                  title = "Configuración", status = "primary",
                  solidHeader = TRUE, width = 3,
                  selectInput("sel_crypto_precio", "Criptomoneda:",
                              choices = CRYPTOS, selected = "BTC"),
                  sliderInput("sel_dias", "Últimos N días:",
                              min = 30, max = 365, value = 180, step = 30),
                  checkboxInput("chk_ma7",  "Media Móvil 7 días",  value = TRUE),
                  checkboxInput("chk_ma30", "Media Móvil 30 días", value = TRUE),
                  checkboxInput("chk_bb",   "Bandas de Bollinger",  value = FALSE),
                  hr(),
                  selectInput("tipo_precio", "Mostrar precio:",
                              choices = c("Cierre" = "close",
                                          "Apertura" = "open",
                                          "Máximo" = "high",
                                          "Mínimo" = "low"))
                ),
                box(
                  title = "Serie de Tiempo del Precio",
                  status = "success", solidHeader = TRUE, width = 9,
                  plotlyOutput("plot_precio_serie", height = 380)
                )
              ),
              
              fluidRow(
                box(
                  title = "Gráfico de Velas (Candlestick) — Últimos 60 días",
                  status = "warning", solidHeader = TRUE, width = 12,
                  plotlyOutput("plot_candlestick", height = 380)
                )
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # TAB 3 — RETORNOS & RIESGO
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "retornos",
              h2("💹 Retornos Diarios y Análisis de Riesgo"),
              p("Distribución de los retornos diarios, volatilidad histórica y métricas de riesgo."),
              
              fluidRow(
                box(
                  title = "Configuración", status = "primary",
                  solidHeader = TRUE, width = 3,
                  selectInput("sel_crypto_ret", "Criptomoneda:",
                              choices = CRYPTOS, selected = "BTC"),
                  sliderInput("sel_dias_ret", "Período (días):",
                              min = 30, max = 365, value = 365, step = 30),
                  selectInput("tipo_grafico_ret", "Tipo de gráfico:",
                              choices = c(
                                "Histograma de Retornos"    = "hist",
                                "Retornos en el Tiempo"     = "serie",
                                "Box Plot por Mes"          = "boxplot",
                                "Volatilidad Rodante 30d"   = "vol_rodante"
                              ))
                ),
                box(
                  title = "Visualización de Retornos",
                  status = "success", solidHeader = TRUE, width = 9,
                  plotlyOutput("plot_retornos", height = 380)
                )
              ),
              
              fluidRow(
                box(
                  title = "Métricas de Riesgo",
                  status = "danger", solidHeader = TRUE, width = 12,
                  DT::dataTableOutput("tabla_riesgo")
                )
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # TAB 4 — CORRELACIONES
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "correlacion",
              h2("🔗 Análisis de Correlaciones"),
              p("Exploración de la correlación entre los retornos diarios de las distintas criptomonedas."),
              
              fluidRow(
                box(
                  title = "Configuración", status = "primary",
                  solidHeader = TRUE, width = 3,
                  sliderInput("sel_dias_corr", "Período (días):",
                              min = 30, max = 365, value = 365, step = 30),
                  selectInput("metodo_corr", "Método de correlación:",
                              choices = c("Pearson" = "pearson",
                                          "Spearman" = "spearman")),
                  checkboxGroupInput("sel_cryptos_corr", "Criptomonedas:",
                                     choices = CRYPTOS,
                                     selected = CRYPTOS)
                ),
                box(
                  title = "Mapa de Calor — Correlación de Retornos",
                  status = "warning", solidHeader = TRUE, width = 9,
                  plotlyOutput("plot_heatmap_corr", height = 420)
                )
              ),
              
              fluidRow(
                box(
                  title = "Dispersión de Retornos entre Dos Monedas",
                  status = "info", solidHeader = TRUE, width = 12,
                  fluidRow(
                    column(4,
                           selectInput("corr_x", "Eje X:", choices = CRYPTOS, selected = "BTC"),
                           selectInput("corr_y", "Eje Y:", choices = CRYPTOS, selected = "ETH")
                    ),
                    column(8, plotlyOutput("plot_scatter_corr", height = 340))
                  )
                )
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # TAB 5 — COMPARADOR
      # ══════════════════════════════════════════════════════
      tabItem(tabName = "comparador",
              h2("⚖️ Comparador de Rendimiento"),
              p("Compara el rendimiento acumulado normalizado de múltiples criptomonedas en el mismo período."),
              
              fluidRow(
                box(
                  title = "Configuración", status = "primary",
                  solidHeader = TRUE, width = 3,
                  checkboxGroupInput("sel_cryptos_comp", "Selecciona monedas:",
                                     choices = CRYPTOS,
                                     selected = c("BTC", "ETH", "SOL")),
                  sliderInput("sel_dias_comp", "Período (días):",
                              min = 30, max = 365, value = 365, step = 30),
                  radioButtons("tipo_norm", "Normalización:",
                               choices = c("Base 100 (inicio = 100)" = "base100",
                                           "Retorno acumulado (%)"   = "pct"),
                               selected = "base100")
                ),
                box(
                  title = "Rendimiento Acumulado Comparado",
                  status = "success", solidHeader = TRUE, width = 9,
                  plotlyOutput("plot_comparador", height = 380)
                )
              ),
              
              fluidRow(
                box(
                  title = "Resumen Estadístico Comparativo",
                  status = "info", solidHeader = TRUE, width = 12,
                  DT::dataTableOutput("tabla_comparador")
                )
              )
      )
      
    ) # fin tabItems
  )   # fin dashboardBody
)     # fin dashboardPage