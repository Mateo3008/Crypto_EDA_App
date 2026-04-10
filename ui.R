library(shinydashboard)
library(shiny)

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(
    title = tagList(
      tags$img(src = "crypto.svg", height = "38", style = "padding-right:8px;"),
      "Crypto EDA"
    ),
    titleWidth = 340
  ),
  
  dashboardSidebar(
    width = 240,
    sidebarMenu(
      menuItem("Introducción",        tabName = "intro",       icon = icon("house")),
      menuItem("Visión General",      tabName = "overview",    icon = icon("gauge")),
      menuItem("Precios",             tabName = "precios",     icon = icon("chart-line")),
      menuItem("Retornos & Riesgo",   tabName = "retornos",    icon = icon("percent")),
      menuItem("Correlaciones",       tabName = "correlacion", icon = icon("table-cells")),
      menuItem("Comparador",          tabName = "comparador",  icon = icon("sliders")),
      menuItem("Análisis",          tabName = "analisis",    icon = icon("chart-simple"))
    ),
    
    hr(),
    
    # Botón para cambiar tema
    div(style = "padding: 0 15px;",
        actionButton("cambiar_tema", 
                     label = tagList(icon("moon"), " Modo Oscuro"), 
                     width = "100%",
                     style = "background-color: #2c3e50; color: white; border: none; border-radius: 5px; margin-top: 10px;")
    ),
    
    div(style = "padding: 0 15px; margin-top: 10px;",
        p(style = "color: #7f8c8d; font-size: 10px; text-align: center;",
          "💡 Haz clic para cambiar entre tema claro/oscuro")
    )
  ),
  
  dashboardBody(
    
    # Incluir MathJax para ecuaciones LaTeX
    tags$head(
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"),
      tags$style(HTML("
        /* ===== TEMA CLARO (por defecto) ===== */
        body, .content-wrapper, .right-side {
          background-color: #f4f6f9;
          transition: all 0.3s ease;
        }
        .box {
          background-color: #ffffff;
          border: 1px solid #e0e0e0;
          transition: all 0.3s ease;
          border-radius: 12px;
        }
        .box-header {
          background-color: #f8f9fa;
          border-radius: 12px 12px 0 0 !important;
        }
        .box-title {
          color: #333333;
          font-weight: 600;
        }
        .small-box {
          background-color: #ffffff;
          border: 1px solid #e0e0e0;
          border-radius: 12px;
        }
        .small-box h3, .small-box p {
          color: #333333;
        }
        .main-header .logo {
          background-color: #1a1a2e;
        }
        .main-header .navbar {
          background-color: #16213e;
        }
        .skin-blue .main-header .logo {
          background-color: #1a1a2e;
        }
        
        /* ===== TEMA OSCURO ===== */
        body.dark-mode, .dark-mode .content-wrapper, .dark-mode .right-side {
          background: linear-gradient(135deg, #0a0e1a 0%, #0f1322 100%);
        }
        .dark-mode .box {
          background: rgba(17, 24, 39, 0.95);
          border: 1px solid #1f2937;
        }
        .dark-mode .box-header {
          background: linear-gradient(90deg, #1a1f2e 0%, #13182a 100%);
        }
        .dark-mode .box-title {
          color: #00d4ff;
        }
        .dark-mode .small-box {
          background: linear-gradient(135deg, #1a1f2e 0%, #13182a 100%);
          border: 1px solid #2d3748;
        }
        .dark-mode .small-box h3, .dark-mode .small-box p {
          color: #e5e7eb;
        }
        .dark-mode .main-header .logo {
          background: linear-gradient(90deg, #0a0e1a 0%, #111827 100%);
          border-bottom: 1px solid #1f2937;
        }
        .dark-mode .main-header .navbar {
          background: linear-gradient(90deg, #0a0e1a 0%, #111827 100%);
        }
        .dark-mode .main-sidebar {
          background: linear-gradient(180deg, #0a0e1a 0%, #0c1020 100%);
          border-right: 1px solid #1f2937;
        }
        .dark-mode .sidebar-menu > li > a {
          color: #9ca3af;
        }
        .dark-mode .sidebar-menu > li.active > a,
        .dark-mode .sidebar-menu > li:hover > a {
          background: linear-gradient(90deg, #00d4ff15 0%, #00d4ff05 100%);
          color: #00d4ff;
          border-left: 3px solid #00d4ff;
        }
        .dark-mode .box-body, .dark-mode p, .dark-mode h2, .dark-mode h3, .dark-mode .info-box-text {
          color: #e5e7eb;
        }
        .dark-mode .form-control {
          background: #1a1f2e !important;
          border: 1px solid #2d3748 !important;
          color: #e5e7eb !important;
        }
        .dark-mode .selectize-input {
          background: #1a1f2e !important;
          border: 1px solid #2d3748 !important;
        }
        .dark-mode .dataTables_wrapper .dataTables_length,
        .dark-mode .dataTables_wrapper .dataTables_filter,
        .dark-mode .dataTables_wrapper .dataTables_info,
        .dark-mode .dataTables_wrapper .dataTables_paginate {
          color: #9ca3af !important;
        }
        .dark-mode table.dataTable tbody tr {
          background: rgba(17, 24, 39, 0.5) !important;
        }
        .dark-mode table.dataTable thead th {
          background: #1a1f2e !important;
          color: #00d4ff !important;
        }
        .dark-mode .MathJax {
          color: #e5e7eb !important;
        }
        
        /* Estilos para tarjetas de autores */
        .author-card {
          display: inline-flex;
          align-items: center;
          gap: 12px;
          background: rgba(255,255,255,0.1);
          border: 1px solid rgba(255,255,255,0.2);
          border-radius: 50px;
          padding: 8px 20px 8px 8px;
          margin: 0 10px;
        }
        .author-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 16px;
        }
        .equation-box {
          background: #f0f4f8;
          padding: 15px;
          border-radius: 10px;
          font-family: monospace;
          text-align: center;
          margin: 10px 0;
        }
        .dark-mode .equation-box {
          background: #1a1f2e;
          border: 1px solid #2d3748;
        }
      "))
    ),
    
    # JavaScript para cambiar tema
    tags$script(HTML("
      Shiny.addCustomMessageHandler('cambiar_tema', function(message) {
        if(message.tema === 'oscuro') {
          document.body.classList.add('dark-mode');
          localStorage.setItem('tema', 'oscuro');
        } else {
          document.body.classList.remove('dark-mode');
          localStorage.setItem('tema', 'claro');
        }
      });
      
      $(document).ready(function() {
        var temaGuardado = localStorage.getItem('tema');
        if(temaGuardado === 'oscuro') {
          document.body.classList.add('dark-mode');
        }
      });
    ")),
    
    tabItems(
      
      # ============================================================
      # TAB 0 - INTRODUCCIÓN (con objetivo, autores y ecuaciones LaTeX)
      # ============================================================
      tabItem(tabName = "intro",
              div(style = "text-align: center; padding: 20px;",
                  
                  # Logo y título
                  icon("bitcoin", class = "fa-4x", style = "color: #F7931A;"),
                  h1(style = "font-size: 36px; font-weight: 700; margin-top: 15px;", 
                     "Análisis Exploratorio de Criptomonedas"),
                  p(style = "font-size: 16px; color: #7f8c8d;", 
                    "Dashboard interactivo para análisis de series temporales, boxplots, y modelado predictivo con ARIMA"),
                  
                  # Autores
                  div(style = "margin: 25px 0;",
                      span(class = "author-card",
                           div(class = "author-avatar", style = "background: rgba(247,147,26,0.2); color: #F7931A;", "MB"),
                           div(style = "text-align: left;",
                               p(style = "margin: 0; font-weight: 600; font-size: 14px;", "Mateo Barrios"),
                               p(style = "margin: 0; font-size: 11px; color: #7f8c8d;", "Ciencia de Datos")
                           )
                      ),
                      span(class = "author-card",
                           div(class = "author-avatar", style = "background: rgba(98,126,234,0.2); color: #627EEA;", "RR"),
                           div(style = "text-align: left;",
                               p(style = "margin: 0; font-weight: 600; font-size: 14px;", "Rafael Romero"),
                               p(style = "margin: 0; font-size: 11px; color: #7f8c8d;", "Ciencia de Datos")
                           )
                      )
                  ),
                  
                  hr(),
                  
                  # Value boxes
                  fluidRow(
                    column(3, valueBoxOutput("vbox_monedas", width = 12)),
                    column(3, valueBoxOutput("vbox_registros", width = 12)),
                    column(3, valueBoxOutput("vbox_periodo", width = 12)),
                    column(3, valueBoxOutput("vbox_missing", width = 12))
                  ),
                  
                  br(),
                  
                  # Objetivo del Proyecto
                  div(style = "background: white; border-radius: 16px; padding: 25px; margin-top: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);",
                      h2(icon("bullseye"), "🎯 Objetivo del Proyecto", style = "color: #e94560; text-align: left; margin-top: 0;"),
                      hr(),
                      p(style = "font-size: 15px; line-height: 1.8; text-align: justify;",
                        "El presente proyecto tiene como objetivo desarrollar un ", 
                        strong("análisis exploratorio de datos (EDA)"), 
                        " exhaustivo para el mercado de criptomonedas, con miras a la implementación de ",
                        strong("modelos predictivos de series temporales."), " Este dashboard interactivo permite explorar el comportamiento
              histórico de las principales criptomonedas, identificar patrones, outliers y relaciones entre activos."
                      ),
                      br(),
                      
                      # Ecuaciones con LaTeX
                      h4("📈 Ecuaciones Clave Utilizadas:", style = "color: #2c3e50;"),
                      div(style = "background: #f0f4f8; border-radius: 12px; padding: 20px; margin: 15px 0;",
                          p(style = "font-size: 14px; font-weight: bold; margin-bottom: 15px;", "📐 Retorno Simple:"),
                          p(style = "font-size: 18px; text-align: center;", 
                            "$$R_t = \\frac{P_t - P_{t-1}}{P_{t-1}} \\times 100$$"),
                          
                          p(style = "font-size: 14px; font-weight: bold; margin-top: 20px; margin-bottom: 15px;", "📐 Retorno Logarítmico:"),
                          p(style = "font-size: 18px; text-align: center;", 
                            "$$r_t = \\ln\\left(\\frac{P_t}{P_{t-1}}\\right) \\times 100$$"),
                          
                          p(style = "font-size: 14px; font-weight: bold; margin-top: 20px; margin-bottom: 15px;", "📐 Media y Desviación Estándar:"),
                          p(style = "font-size: 18px; text-align: center;", 
                            "$$\\mu = \\frac{1}{n}\\sum_{i=1}^{n} x_i \\qquad \\sigma = \\sqrt{\\frac{1}{n}\\sum_{i=1}^{n} (x_i - \\mu)^2}$$"),
                          
                          p(style = "font-size: 14px; font-weight: bold; margin-top: 20px; margin-bottom: 15px;", "📐 Descomposición STL:"),
                          p(style = "font-size: 18px; text-align: center;", 
                            "$$Y(t) = T(t) + S(t) + R(t)$$"),
                          
                          p(style = "font-size: 14px; font-weight: bold; margin-top: 20px; margin-bottom: 15px;", "📐 Modelo ARIMA(p,d,q):"),
                          p(style = "font-size: 16px; text-align: center;", 
                            "$$\\phi(B)(1-B)^d Y_t = \\theta(B) \\varepsilon_t$$"),
                          p(style = "font-size: 13px; text-align: center; color: #555; margin-top: 10px;",
                            "donde: $$\\phi(B) = 1 - \\phi_1 B - \\phi_2 B^2 - ... - \\phi_p B^p$$ es la parte autoregresiva (AR),"),
                          p(style = "font-size: 13px; text-align: center; color: #555;",
                            "$$\\theta(B) = 1 + \\theta_1 B + \\theta_2 B^2 + ... + \\theta_q B^q$$ es la parte de media móvil (MA),"),
                          p(style = "font-size: 13px; text-align: center; color: #555;",
                            "y $$(1-B)^d$$ es el operador de diferenciación."),
                          
                          p(style = "font-size: 14px; font-weight: bold; margin-top: 20px; margin-bottom: 15px;", "📐 Prueba ADF (Dickey-Fuller Aumentado):"),
                          p(style = "font-size: 16px; text-align: center;", 
                            "$$\\Delta y_t = \\alpha + \\beta t + \\gamma y_{t-1} + \\delta_1 \\Delta y_{t-1} + ... + \\varepsilon_t$$"),
                          p(style = "font-size: 13px; text-align: center; color: #555; margin-top: 10px;",
                            "H₀: γ = 0 (raíz unitaria, NO estacionaria) | H₁: γ < 0 (estacionaria)")
                      ),
                      
                      br(),
                      h4("📋 Alcance del Proyecto:", style = "color: #2c3e50;"),
                      tags$ul(style = "text-align: left; font-size: 13px; line-height: 1.8;",
                              tags$li(strong("10 criptomonedas analizadas"), ": Bitcoin (BTC), Ethereum (ETH), USD Coin (USDC), Solana (SOL), XRP, Bittensor (TAO), Tether (USDT), Dogecoin (DOGE), USD1 y Zcash (ZEC)."),
                              tags$li(strong("Período de análisis"), ": 840 días de datos históricos (aproximadamente 2.3 años)."),
                              tags$li(strong("Variables analizadas"), ": Precio de cierre, retornos diarios, retornos logarítmicos y volatilidad diaria."),
                              tags$li(strong("Técnicas estadísticas"), ": Boxplots (cajas y bigotes), pruebas ADF de estacionariedad, funciones ACF/PACF, descomposición STL."),
                              tags$li(strong("Modelado predictivo"), ": Implementación de modelos ARIMA para predicción de precios a 30 días.")
                      ),
                      
                      br(),
                      
                      # Metodología
                      h4("🔬 Metodología de Análisis", style = "color: #2c3e50;"),
                      fluidRow(
                        column(4, div(style = "text-align: center; padding: 15px;",
                                      icon("chart-bar", class = "fa-3x", style = "color: #e94560;"),
                                      h5("Análisis Descriptivo"),
                                      p(style = "font-size: 12px;", "Boxplots, histogramas y estadísticas descriptivas para entender la distribución de los datos e identificar outliers.")
                        )),
                        column(4, div(style = "text-align: center; padding: 15px;",
                                      icon("chart-line", class = "fa-3x", style = "color: #e94560;"),
                                      h5("Series Temporales"),
                                      p(style = "font-size: 12px;", "Descomposición STL, funciones ACF/PACF y pruebas de estacionariedad (ADF) para caracterizar la dependencia temporal.")
                        )),
                        column(4, div(style = "text-align: center; padding: 15px;",
                                      icon("chart-line", class = "fa-3x", style = "color: #e94560;"),
                                      h5("Modelado Predictivo"),
                                      p(style = "font-size: 12px;", "ARIMA para predicción de precios a corto plazo (30 días) con validación mediante métricas MAE, RMSE y MAPE.")
                        ))
                      ),
                      
                      br(),
                      
                      p(style = "font-style: italic; color: #7f8c8d; font-size: 12px; text-align: center;",
                        "📌 Este dashboard sienta las bases matemáticas y estadísticas para la implementación futura de modelos predictivos.")
                  )
              )
      ),
      
      # ============================================================
      # TAB 1 - VISIÓN GENERAL
      # ============================================================
      tabItem(tabName = "overview",
              h2("📊 Visión General del Mercado"),
              p("Snapshot en tiempo real de las principales criptomonedas analizadas en este estudio."),
              fluidRow(
                box(title = "Precios Actuales y Métricas de Mercado", status = "primary", solidHeader = TRUE, width = 12,
                    DT::dataTableOutput("tabla_overview"))
              ),
              fluidRow(
                box(title = "Capitalización de Mercado (USD)", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("plot_market_cap", height = 400)),
                box(title = "Volumen de Negociación 24h (USD)", status = "info", solidHeader = TRUE, width = 6,
                    plotlyOutput("plot_volume", height = 400))
              )
      ),
      
      # ============================================================
      # TAB 2 - PRECIOS
      # ============================================================
      tabItem(tabName = "precios",
              h2("📈 Análisis de Precios"),
              p("Análisis de la distribución de precios mediante boxplots y evolución temporal."),
              fluidRow(
                box(title = "🎨 Boxplot de Precios por Criptomoneda (Cajas y Bigotes)", status = "primary", solidHeader = TRUE, width = 12,
                    sliderInput("sel_dias", "Últimos N días:", min = 30, max = 840, value = 365, step = 30),
                    plotlyOutput("plot_boxplot_precios", height = 500))
              ),
              fluidRow(
                box(title = "📈 Serie Temporal del Precio", status = "warning", solidHeader = TRUE, width = 6,
                    selectInput("sel_crypto_precio", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
                    plotlyOutput("plot_precio_serie", height = 400)),
                box(title = "🕯️ Gráfico de Velas (Candlestick)", status = "info", solidHeader = TRUE, width = 6,
                    plotlyOutput("plot_candlestick", height = 400))
              )
      ),
      
      # ============================================================
      # TAB 3 - RETORNOS & RIESGO
      # ============================================================
      tabItem(tabName = "retornos",
              h2("📉 Análisis de Retornos y Riesgo"),
              p("Distribución de los retornos diarios, volatilidad histórica y métricas de riesgo."),
              fluidRow(
                box(title = "🎨 Boxplot de Retornos por Criptomoneda (Cajas y Bigotes)", status = "danger", solidHeader = TRUE, width = 12,
                    sliderInput("sel_dias_ret", "Período (días):", min = 30, max = 840, value = 365, step = 30),
                    plotlyOutput("plot_boxplot_retornos", height = 500))
              ),
              fluidRow(
                box(title = "📊 Visualización de Retornos", status = "success", solidHeader = TRUE, width = 8,
                    selectInput("sel_crypto_ret", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
                    selectInput("tipo_grafico_ret", "Tipo de gráfico:",
                                choices = c("Histograma de Retornos" = "hist", 
                                            "Retornos en el Tiempo" = "serie",
                                            "Boxplot por Mes" = "boxplot", 
                                            "Volatilidad Rodante 30d" = "vol_rodante")),
                    plotlyOutput("plot_retornos", height = 400)),
                box(title = "📋 Métricas de Riesgo", status = "info", solidHeader = TRUE, width = 4,
                    DT::dataTableOutput("tabla_riesgo"))
              )
      ),
      
      # ============================================================
      # TAB 4 - CORRELACIONES
      # ============================================================
      tabItem(tabName = "correlacion",
              h2("🔗 Matriz de Correlaciones"),
              p("Exploración de la correlación entre los retornos diarios de las distintas criptomonedas."),
              fluidRow(
                box(title = "Configuración", status = "primary", solidHeader = TRUE, width = 3,
                    sliderInput("sel_dias_corr", "Período (días):", min = 30, max = 840, value = 365),
                    selectInput("metodo_corr", "Método de correlación:", choices = c("Pearson", "Spearman")),
                    checkboxGroupInput("sel_cryptos_corr", "Criptomonedas:", choices = CRYPTOS, selected = CRYPTOS)),
                box(title = "Mapa de Calor - Correlación de Retornos", status = "warning", solidHeader = TRUE, width = 9,
                    plotlyOutput("plot_heatmap_corr", height = 500))
              ),
              fluidRow(
                box(title = "Dispersión de Retornos entre Dos Monedas", status = "info", solidHeader = TRUE, width = 12,
                    fluidRow(
                      column(3, selectInput("corr_x", "Eje X:", choices = CRYPTOS, selected = "BTC")),
                      column(3, selectInput("corr_y", "Eje Y:", choices = CRYPTOS, selected = "ETH")),
                      column(6, plotlyOutput("plot_scatter_corr", height = 350))
                    )
                )
              )
      ),
      
      # ============================================================
      # TAB 5 - COMPARADOR
      # ============================================================
      tabItem(tabName = "comparador",
              h2("⚖️ Comparador de Rendimiento"),
              p("Compara el rendimiento acumulado normalizado de múltiples criptomonedas en el mismo período."),
              fluidRow(
                box(title = "Configuración", status = "primary", solidHeader = TRUE, width = 3,
                    checkboxGroupInput("sel_cryptos_comp", "Selecciona monedas:", choices = CRYPTOS, selected = c("BTC", "ETH")),
                    sliderInput("sel_dias_comp", "Período (días):", min = 30, max = 840, value = 365, step = 30),
                    radioButtons("tipo_norm", "Normalización:", 
                                 choices = c("Base 100 (inicio = 100)" = "base100", 
                                             "Retorno acumulado (%)" = "pct"))),
                box(title = "Rendimiento Acumulado Comparado", status = "success", solidHeader = TRUE, width = 9,
                    plotlyOutput("plot_comparador", height = 400))
              ),
              fluidRow(
                box(title = "Resumen Estadístico Comparativo", status = "info", solidHeader = TRUE, width = 12,
                    DT::dataTableOutput("tabla_comparador"))
              )
      ),
      
      # ============================================================
      # TAB 6 - ANÁLISIS (EDA Avanzado)
      # ============================================================
      tabItem(tabName = "analisis",
              h2("📊 Análisis Exploratorio "),
              p("Series temporales, boxplots, descomposición STL, funciones ACF/PACF, pruebas de estacionariedad (ADF) y preparación para modelado ARIMA."),
              
              fluidRow(
                box(title = "⚙️ Configuración del Análisis", status = "primary", solidHeader = TRUE, width = 12,
                    column(3, selectInput("analisis_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                    column(3, sliderInput("analisis_dias", "Días a analizar:", min = 90, max = 840, value = 365, step = 30)),
                    column(3, selectInput("analisis_variable", "Variable:", 
                                          choices = c("Precio Cierre (USD)" = "close", 
                                                      "Retorno Diario (%)" = "retorno",
                                                      "Retorno Logarítmico (%)" = "retorno_log", 
                                                      "Volatilidad Diaria (%)" = "volatilidad"))),
                    column(3, numericInput("arima_max_order", "Orden máximo ARIMA (p,q):", value = 5, min = 1, max = 10))
                )
              ),
              
              fluidRow(
                box(title = "🎨 Boxplot (Cajas y Bigotes)", status = "primary", solidHeader = TRUE, width = 12,
                    p("El boxplot muestra la distribución de los datos: la caja representa el rango intercuartil (IQR), 
              la línea central es la mediana, los bigotes son los límites (1.5 × IQR) y los puntos son outliers."),
                    plotlyOutput("plot_analisis_boxplot", height = 400))
              ),
              
              fluidRow(
                box(title = "📈 Serie Temporal", status = "success", solidHeader = TRUE, width = 6,
                    plotlyOutput("plot_analisis_serie", height = 350)),
                box(title = "📊 Boxplot Mensual", status = "warning", solidHeader = TRUE, width = 6,
                    plotlyOutput("plot_analisis_boxplot_mensual", height = 350))
              ),
              
              fluidRow(
                box(title = "📊 ACF (Función de Autocorrelación)", status = "info", solidHeader = TRUE, width = 6,
                    p("Mide la correlación entre la serie y sus valores rezagados. Ayuda a identificar el orden MA(q)."),
                    plotlyOutput("plot_analisis_acf", height = 350)),
                box(title = "📊 PACF (Función de Autocorrelación Parcial)", status = "info", solidHeader = TRUE, width = 6,
                    p("Mide la correlación parcial entre la serie y sus rezagos. Ayuda a identificar el orden AR(p)."),
                    plotlyOutput("plot_analisis_pacf", height = 350))
              ),
              
              fluidRow(
                box(title = "🔄 Descomposición STL", status = "primary", solidHeader = TRUE, width = 12,
                    p("Descompone la serie en: Tendencia (T), Estacionalidad (S) y Residuo (R). Ecuación: $$Y(t) = T(t) + S(t) + R(t)$$"),
                    plotlyOutput("plot_analisis_decomposition", height = 500))
              ),
              
              fluidRow(
                box(title = "📊 Estadísticas Descriptivas", status = "success", solidHeader = TRUE, width = 6,
                    uiOutput("analisis_stats_html")),
                box(title = "🔬 Prueba de Estacionariedad (ADF)", status = "warning", solidHeader = TRUE, width = 6,
                    uiOutput("analisis_stationarity_html"))
              ),
              
              fluidRow(
                box(title = "📋 Comparativa de Estacionariedad entre Monedas", status = "info", solidHeader = TRUE, width = 12,
                    p("La prueba ADF (Dickey-Fuller Aumentado) evalúa si una serie temporal es estacionaria. 
              Valor p < 0.05 indica estacionariedad (apta para modelado)."),
                    DT::dataTableOutput("tabla_analisis_stationarity"))
              ),
              
              fluidRow(
                box(title = "🤖 Modelado Predictivo con ARIMA", status = "danger", solidHeader = TRUE, width = 12,
                    uiOutput("analisis_arima_info_html"))
              )
      )
      
    )
  )
)