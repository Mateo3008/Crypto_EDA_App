# ============================================================
# UI.R - EDA de Criptomonedas | Crypto Dashboard
# ============================================================

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)

# Definición de criptomonedas
CRYPTOS <- c(
  "Bitcoin"   = "BTC",
  "Ethereum"  = "ETH",
  "USD Coin"  = "USDC",
  "Solana"    = "SOL",
  "XRP"       = "XRP",
  "Bittensor" = "TAO",
  "Tether"    = "USDT",
  "Dogecoin"  = "DOGE",
  "USD1"      = "USD1",
  "Zcash"     = "ZEC"
)

ui <- dashboardPage(
  skin = "blue",
  
  # ============================================================
  # HEADER
  # ============================================================
  dashboardHeader(
    title = tagList(
      tags$img(src = "crypto.svg", height = "34",
               style = "padding-right:8px; vertical-align:middle; filter: drop-shadow(0 0 6px #F7931A);"),
      tags$span("Crypto", style = "color:#F7931A; font-weight:700; letter-spacing:1px;"),
      tags$span(" EDA", style = "color:#627EEA; font-weight:700;")
    ),
    titleWidth = 280,
    
    tags$li(
      class = "dropdown",
      tags$a(
        href = "https://github.com/Mateo3008/Crypto_EDA_App",
        target = "_blank",
        style = paste0(
          "display:flex; align-items:center; gap:8px; padding:10px 18px;",
          "color:#fff; text-decoration:none; font-size:13px; font-weight:600;",
          "background: linear-gradient(135deg,#1a1a2e,#16213e);",
          "border-left:1px solid rgba(255,255,255,0.1);",
          "transition: all 0.3s ease;"
        ),
        onmouseover = "this.style.background='linear-gradient(135deg,#F7931A,#627EEA)';",
        onmouseout  = "this.style.background='linear-gradient(135deg,#1a1a2e,#16213e)';",
        tags$svg(
          xmlns = "http://www.w3.org/2000/svg",
          width = "20", height = "20", viewBox = "0 0 24 24", fill = "white",
          tags$path(d = paste0(
            "M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255",
            ".825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135",
            "-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845",
            " 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3",
            "-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18",
            " 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56",
            " 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0",
            " 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895",
            "-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"
          ))
        ),
        "GitHub"
      )
    ),
    
    tags$li(
      class = "dropdown",
      tags$div(
        style = paste0(
          "display:flex; align-items:center; gap:6px; padding:10px 16px;",
          "color:#2ecc71; font-size:12px; font-weight:700;"
        ),
        tags$span(
          style = paste0(
            "width:8px; height:8px; background:#2ecc71; border-radius:50%;",
            "display:inline-block;",
            "box-shadow:0 0 6px #2ecc71;",
            "animation: pulseLed 1.5s infinite;"
          )
        ),
        "LIVE DATA"
      )
    )
  ),
  
  # ============================================================
  # SIDEBAR
  # ============================================================
  dashboardSidebar(
    width = 280,
    tags$div(
      style = "padding: 12px 0 4px 0; text-align:center;",
      tags$span(
        style = "font-size:10px; color:#95a5a6; letter-spacing:2px; text-transform:uppercase;",
        "Navegación"
      )
    ),
    sidebarMenu(
      id = "main_menu",
      menuItem(" Introducción",       tabName = "intro",       icon = icon("book")),
      menuItem(" Visión General",    tabName = "overview",    icon = icon("gauge")),
      menuItem(" Precios",           tabName = "precios",     icon = icon("chart-line")),
      menuItem(" Retornos & Riesgo", tabName = "retornos",    icon = icon("percent")),
      menuItem(" Correlaciones",     tabName = "correlacion", icon = icon("table-cells")),
      menuItem(" Comparador",        tabName = "comparador",  icon = icon("sliders")),
      menuItem(" Análisis EDA",      tabName = "analisis",    icon = icon("chart-simple")),
      menuItem(" Modelo ARIMA",      tabName = "arima",       icon = icon("chart-line")),
      menuItem(" Predicción Óptima", tabName = "optimal",     icon = icon("crown")),
      menuItem(" Valores Faltantes", tabName = "missing",     icon = icon("exclamation-triangle"))
    ),
    
    tags$hr(style = "border-color:rgba(255,255,255,0.1); margin:10px 15px;"),
    
    tags$div(
      style = "padding:0 15px;",
      actionButton(
        "cambiar_tema",
        label    = tagList(icon("moon"), " Modo Oscuro"),
        width    = "100%",
        style    = paste0(
          "background: linear-gradient(135deg,#2c3e50,#34495e);",
          "color:white; border:none; border-radius:8px;",
          "padding:10px; font-weight:600; letter-spacing:0.5px;",
          "box-shadow:0 4px 15px rgba(0,0,0,0.3);",
          "transition:all 0.3s ease;"
        )
      )
    ),
    
    tags$div(
      style = paste0(
        "margin:14px 15px 0 15px; padding:12px;",
        "background:rgba(255,255,255,0.05);",
        "border-radius:10px; border:1px solid rgba(255,255,255,0.08);"
      ),
      tags$p(
        style = "color:#7f8c8d; font-size:10px; margin:0 0 8px; text-transform:uppercase; letter-spacing:1px;",
        "🪙 Monedas Activas"
      ),
      tags$div(
        style = "display:flex; flex-wrap:wrap; gap:4px;",
        lapply(names(CRYPTOS), function(nm) {
          tags$span(
            CRYPTOS[[nm]],
            style = paste0(
              "font-size:10px; padding:2px 7px; border-radius:20px;",
              "background:rgba(247,147,26,0.15); color:#F7931A;",
              "border:1px solid rgba(247,147,26,0.3); font-weight:700;"
            )
          )
        })
      )
    ),
    
    tags$div(
      style = "padding:12px 15px 0;",
      tags$a(
        href = "https://github.com/Mateo3008/Crypto_EDA_App",
        target = "_blank",
        style = paste0(
          "display:flex; align-items:center; justify-content:center; gap:8px;",
          "padding:8px; border-radius:8px; text-decoration:none;",
          "color:#95a5a6; font-size:11px;",
          "background:rgba(255,255,255,0.03);",
          "border:1px solid rgba(255,255,255,0.06);",
          "transition:all 0.3s ease;"
        ),
        onmouseover = "this.style.color='#fff'; this.style.borderColor='rgba(247,147,26,0.5)';",
        onmouseout  = "this.style.color='#95a5a6'; this.style.borderColor='rgba(255,255,255,0.06)';",
        icon("code-branch"),
        "Ver código en GitHub"
      )
    ),
    
    tags$div(
      style = "padding:8px 15px; text-align:center;",
      tags$span(
        style = "font-size:9px; color:#636e72; letter-spacing:0.5px;",
        "Crypto EDA App · Mateo3008"
      )
    )
  ),
  
  # ============================================================
  # BODY
  # ============================================================
  dashboardBody(
    
    tags$canvas(
      id    = "particles-canvas",
      style = "position:fixed; top:0; left:0; width:100%; height:100%; z-index:0; pointer-events:none;"
    ),
    
    tags$head(
      tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"),
      
      tags$style(HTML("
        *, *::before, *::after { box-sizing: border-box; }
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); border-radius: 10px; }
        ::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #F7931A, #627EEA); border-radius: 10px; }
        body, .content-wrapper, .right-side { background-color: #F5F7FA !important; color: #2c3e50 !important; transition: all 0.4s ease; }
        .skin-blue .main-header .logo, .skin-blue .main-header .navbar { background-color: #1a1a2e !important; border-bottom: 1px solid rgba(247,147,26,0.3) !important; }
        .skin-blue .main-sidebar { background: linear-gradient(180deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%) !important; }
        .skin-blue .sidebar a, .skin-blue .sidebar-menu > li > a { color: #bdc3c7 !important; transition: all 0.25s ease; }
        .skin-blue .sidebar-menu > li.active > a, .skin-blue .sidebar-menu > li > a:hover { color: #F7931A !important; background: rgba(247,147,26,0.12) !important; border-left: 3px solid #F7931A !important; }
        body.dark-mode, body.dark-mode .content-wrapper, body.dark-mode .right-side { background: linear-gradient(135deg, #0a0e1a 0%, #0f1322 100%) !important; color: #e0e6ed !important; }
        body.dark-mode .box, body.dark-mode .small-box { background: rgba(15,19,34,0.60) !important; color: #e0e6ed !important; border-color: rgba(98,126,234,0.18) !important; }
        .box { background: rgba(255,255,255,0.55) !important; backdrop-filter: blur(8px) !important; border-radius: 14px !important; transition: all 0.3s ease; z-index: 1; }
        .box:hover { transform: translateY(-5px); box-shadow: 0 20px 50px rgba(0,0,0,0.14) !important; }
        .small-box { border-radius: 14px !important; backdrop-filter: blur(8px) !important; transition: all 0.3s ease; }
        .small-box:hover { transform: translateY(-6px); box-shadow: 0 16px 40px rgba(0,0,0,0.2) !important; }
        h2 { font-weight: 800 !important; background: linear-gradient(135deg, #F7931A, #627EEA) !important; -webkit-background-clip: text !important; -webkit-text-fill-color: transparent !important; margin-bottom: 6px !important; }
        .intro-hero { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); border-radius: 18px; padding: 40px; margin-bottom: 20px; position: relative; overflow: hidden; color: white; }
        .crypto-ticker { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 16px; }
        .ticker-card { flex: 1; min-width: 80px; padding: 10px 14px; background: linear-gradient(135deg, rgba(247,147,26,0.1), rgba(98,126,234,0.1)); border-radius: 10px; text-align: center; transition: all 0.25s ease; cursor: default; }
        .ticker-card:hover { background: linear-gradient(135deg, rgba(247,147,26,0.2), rgba(98,126,234,0.2)); transform: translateY(-3px); }
        .ticker-card .ticker-sym { font-weight: 800; font-size: 15px; color: #F7931A; }
        .eq-box { background: linear-gradient(135deg, rgba(15,19,34,0.06), rgba(98,126,234,0.06)); border-left: 4px solid #627EEA; border-radius: 10px; padding: 14px 18px; margin: 10px 0; overflow-x: auto; }
        .eq-box .katex-display { margin: 0.4em 0; }
        .katex-display { background: transparent !important; }
        .neon-badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .neon-badge.green { background: rgba(46,204,113,0.15); color: #2ecc71; border: 1px solid rgba(46,204,113,0.4); }
        .neon-badge.orange { background: rgba(247,147,26,0.15); color: #F7931A; border: 1px solid rgba(247,147,26,0.4); }
        .neon-badge.blue { background: rgba(98,126,234,0.15); color: #627EEA; border: 1px solid rgba(98,126,234,0.4); }
        .author-badge { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; background: linear-gradient(135deg, #1a1a2e, #0f3460); border-radius: 30px; color: white; font-size: 13px; font-weight: 600; text-decoration: none; transition: all 0.3s ease; }
        .author-badge:hover { background: linear-gradient(135deg, #F7931A, #627EEA); transform: translateY(-2px); }
        .def-box { background: #2ecc7120; border-left: 3px solid #2ecc71; padding: 8px; border-radius: 6px; text-align: center; }
        .obs-box { background: #3498db20; border-left: 3px solid #3498db; padding: 8px; border-radius: 6px; text-align: center; }
        .warn-box { background: #e74c3c20; border-left: 3px solid #e74c3c; padding: 8px; border-radius: 6px; text-align: center; }
        .pred-box { background: #9b59b620; border-radius: 10px; padding: 15px; text-align: center; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(24px); } to { opacity: 1; transform: translateY(0); } }
        .tab-content .tab-pane.active { animation: fadeInUp 0.5s ease-out; }
        .content-wrapper { position: relative; z-index: 1; }
        
        /* ---- KaTeX rendering overrides ---- */
        .katex { font-size: 1.05em !important; }
        .katex-display { overflow-x: auto; overflow-y: hidden; padding: 6px 0; }
        .katex-display > .katex { font-size: 1.15em !important; }
      ")),
      
      tags$script(HTML("
        /* ============================================================
           CANVAS PARTICLES - pure inline JS, sin archivos externos
           ============================================================ */
        (function() {
          function initParticles() {
            var canvas = document.getElementById('particles-canvas');
            if (!canvas) { setTimeout(initParticles, 300); return; }
            var ctx = canvas.getContext('2d');
            
            function resize() {
              canvas.width  = window.innerWidth;
              canvas.height = window.innerHeight;
            }
            resize();
            window.addEventListener('resize', resize);
            
            var PARTICLE_COUNT = 55;
            var particles = [];
            var colors = ['rgba(247,147,26,', 'rgba(98,126,234,', 'rgba(46,204,113,', 'rgba(255,255,255,'];
            
            function Particle() {
              this.x     = Math.random() * canvas.width;
              this.y     = Math.random() * canvas.height;
              this.r     = Math.random() * 2.2 + 0.6;
              this.vx    = (Math.random() - 0.5) * 0.35;
              this.vy    = (Math.random() - 0.5) * 0.35;
              this.alpha = Math.random() * 0.45 + 0.08;
              this.color = colors[Math.floor(Math.random() * colors.length)];
            }
            
            for (var i = 0; i < PARTICLE_COUNT; i++) particles.push(new Particle());
            
            function connect() {
              for (var a = 0; a < particles.length; a++) {
                for (var b = a + 1; b < particles.length; b++) {
                  var dx = particles[a].x - particles[b].x;
                  var dy = particles[a].y - particles[b].y;
                  var dist = Math.sqrt(dx*dx + dy*dy);
                  if (dist < 110) {
                    ctx.beginPath();
                    ctx.strokeStyle = 'rgba(98,126,234,' + (0.08 * (1 - dist/110)) + ')';
                    ctx.lineWidth = 0.5;
                    ctx.moveTo(particles[a].x, particles[a].y);
                    ctx.lineTo(particles[b].x, particles[b].y);
                    ctx.stroke();
                  }
                }
              }
            }
            
            function animate() {
              ctx.clearRect(0, 0, canvas.width, canvas.height);
              connect();
              particles.forEach(function(p) {
                p.x += p.vx; p.y += p.vy;
                if (p.x < 0 || p.x > canvas.width)  p.vx *= -1;
                if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
                ctx.beginPath();
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
                ctx.fillStyle = p.color + p.alpha + ')';
                ctx.fill();
              });
              requestAnimationFrame(animate);
            }
            animate();
          }
          document.addEventListener('DOMContentLoaded', initParticles);
          setTimeout(initParticles, 500);
        })();
        
        /* ============================================================
           KaTeX auto-render - convierte $...$ y $$...$$ en toda la página
           ============================================================ */
        document.addEventListener('DOMContentLoaded', function() {
          function renderMath() {
            if (typeof renderMathInElement === 'undefined') {
              setTimeout(renderMath, 400); return;
            }
            renderMathInElement(document.body, {
              delimiters: [
                {left: '$$', right: '$$', display: true},
                {left: '$',  right: '$',  display: false}
              ],
              throwOnError: false,
              strict: false
            });
          }
          renderMath();
          /* Re-render cuando Shiny cambia de tab */
          $(document).on('shown.bs.tab', function() {
            setTimeout(function() {
              if (typeof renderMathInElement !== 'undefined') {
                renderMathInElement(document.body, {
                  delimiters: [
                    {left: '$$', right: '$$', display: true},
                    {left: '$',  right: '$',  display: false}
                  ],
                  throwOnError: false,
                  strict: false
                });
              }
            }, 150);
          });
        });
      "))
    ),
    
    # ============================================================
    # TABS
    # ============================================================
    tabItems(
      
      # ============================================================
      # TAB 0 - INTRODUCCIÓN (MEJORADA CON OBJETIVOS FORMALES, LATEX E IMÁGENES)
      # ============================================================
      tabItem(
        tabName = "intro",
        
        tags$div(
          class = "intro-hero",
          style = "background: linear-gradient(135deg, #0a0e1a 0%, #16213e 50%, #0f3460 100%); border-radius: 18px; padding: 40px; margin-bottom: 20px;",
          fluidRow(
            column(8,
                   tags$h1("📊 Crypto EDA", style = "font-size:42px; font-weight:900; margin:0 0 8px; color:white; font-family: 'Georgia', serif;"),
                   tags$p("Análisis Exploratorio de Datos de Criptomonedas con Modelos ARIMA", 
                          style = "font-size:18px; color:rgba(255,255,255,0.85); margin:0 0 16px; font-family: 'Georgia', serif; font-style: italic;"),
                   tags$div(
                     style = "display:flex; gap:10px; flex-wrap:wrap;",
                     tags$span(class = "neon-badge green", "✓ Datos Reales"),
                     tags$span(class = "neon-badge orange", "⚡ CryptoCompare API"),
                     tags$span(class = "neon-badge blue", "📅 1905 Días de Historia"),
                     tags$span(class = "neon-badge green", "🤖 ARIMA Optimizado"),
                     tags$a(href = "https://github.com/Mateo3008/Crypto_EDA_App", target = "_blank",
                            style = "display:inline-flex; align-items:center; gap:6px; padding:4px 14px; border-radius:20px; font-size:11px; font-weight:700; background:rgba(255,255,255,0.1); color:white; text-decoration:none;",
                            icon("github"), "GitHub")
                   )
            ),
            column(4,
                   tags$div(style = "text-align:right; padding-top:10px;",
                            tags$div(style = "display:inline-block; padding:16px 24px; background:rgba(255,255,255,0.07); border-radius:14px;",
                                     tags$div(style = "font-size:11px; color:rgba(255,255,255,0.5);", "Última actualización"),
                                     tags$div(id = "live-ticker-txt", style = "font-size:13px; color:#F7931A; font-weight:700;", "Datos en tiempo real")
                            )
                   )
            )
          )
        ),
        
        fluidRow(
          valueBoxOutput("vbox_monedas", width = 3),
          valueBoxOutput("vbox_registros", width = 3),
          valueBoxOutput("vbox_periodo", width = 3),
          valueBoxOutput("vbox_missing", width = 3)
        ),
        
        # ============================================================
        # SECCIÓN: OBJETIVOS DEL PROYECTO (FORMALES)
        # ============================================================
        fluidRow(
          box(
            title = tagList(icon("bullseye"), " Objetivos del Proyecto"),
            status = "primary", solidHeader = TRUE, width = 12,
            style = "background: #ffffff;",
            
            div(style = "font-family: 'Georgia', serif;",
                
                h4("🎯 Objetivo General", style = "color: #1a1a2e; margin-top: 0; font-weight: 700; letter-spacing: -0.3px;"),
                div(style = "background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 18px; border-radius: 12px; border-left: 5px solid #F7931A; margin-bottom: 25px;",
                    tags$p("Desarrollar un análisis exploratorio de datos (EDA) exhaustivo y un modelo predictivo ARIMA optimizado para las principales criptomonedas del mercado, proporcionando una herramienta interactiva que facilite la toma de decisiones informadas en el ámbito de las inversiones en criptoactivos.", 
                           style = "font-size: 15px; line-height: 1.7; color: #2c3e50; margin: 0; text-align: justify;")
                ),
                
                h4("📋 Objetivos Específicos", style = "color: #1a1a2e; font-weight: 700; letter-spacing: -0.3px;"),
                tags$ol(
                  style = "font-size: 14px; line-height: 1.8; color: #2c3e50; text-align: justify;",
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Análisis Descriptivo:"), " Realizar un análisis estadístico descriptivo de las 10 principales criptomonedas del mercado, incluyendo métricas de precios, retornos, volatilidad y volúmenes de negociación, con el fin de caracterizar su comportamiento histórico."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Calidad de Datos:"), " Identificar y tratar valores faltantes en las series temporales mediante técnicas de imputación como interpolación lineal y media móvil, garantizando la integridad y consistencia del análisis."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Estacionariedad:"), " Evaluar la estacionariedad de las series mediante pruebas estadísticas ADF (Dickey-Fuller Aumentado) y KPSS (Kwiatkowski-Phillips-Schmidt-Shin), determinando el orden óptimo de diferenciación para cada activo."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Transformación de Datos:"), " Implementar la transformación a retornos logarítmicos para estabilizar la varianza y mejorar las propiedades estadísticas de las series de precios, facilitando el modelado ARIMA."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Modelado ARIMA:"), " Identificar y seleccionar los mejores modelos ARIMA para cada criptomoneda utilizando los criterios de información AIC, BIC y HQIC, priorizando órdenes reducidos para mitigar el riesgo de sobreajuste."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Validación de Modelos:"), " Validar los modelos mediante métricas de error como MAPE, RMSE, MAE, coeficiente de determinación R² y correlación entre valores reales y predichos, evaluando su capacidad predictiva."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Predicción a Corto Plazo:"), " Generar pronósticos a corto plazo (7-28 días) con intervalos de confianza del 80% y 95%, utilizando rolling forecast con reentrenamiento continuo para mantener la precisión del modelo."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Comparación con Baseline:"), " Comparar el rendimiento del modelo ARIMA contra modelos baseline (Naive, Drift y Seasonal Naive) para demostrar su valor predictivo y justificar su implementación."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Diagnóstico de Residuales:"), " Realizar un análisis completo de residuales incluyendo pruebas de normalidad (Shapiro-Wilk), independencia (Ljung-Box) y heterocedasticidad (ARCH), verificando el cumplimiento de los supuestos del modelo."),
                  tags$li(style = "margin-bottom: 12px;", tags$strong("Visualización Interactiva:"), " Desarrollar una aplicación Shiny interactiva que permita a los usuarios explorar dinámicamente los datos, ajustar parámetros de modelado y visualizar predicciones en tiempo real.")
                ),
                
                br(),
                
                h4("📊 Beneficios Esperados", style = "color: #1a1a2e; font-weight: 700; letter-spacing: -0.3px;"),
                tags$ul(
                  style = "font-size: 14px; line-height: 1.8; color: #2c3e50;",
                  tags$li("Comprensión profunda del comportamiento de las criptomonedas en diferentes condiciones de mercado."),
                  tags$li("Herramienta de apoyo para decisiones de inversión basada en datos y métodos estadísticos rigurosos."),
                  tags$li("Base metodológica para proyectos más avanzados (GARCH, LSTM, Redes Neuronales)."),
                  tags$li("Dashboard interactivo reutilizable para análisis de series temporales financieras.")
                )
            )
          )
        ),
        
        # ============================================================
        # SECCIÓN: MARCO TEÓRICO (CON LATEX)
        # ============================================================
        fluidRow(
          box(
            title = tagList(icon("book"), " Marco Teórico"),
            status = "info", solidHeader = TRUE, width = 12,
            
            div(style = "font-family: 'Georgia', serif;",
                
                h4("📐 Series de Tiempo", style = "color: #1a1a2e; margin-top: 0; font-weight: 700;"),
                tags$p("Una serie temporal se define formalmente como una realización parcial de un proceso estocástico de parámetro tiempo discreto. En el contexto financiero, representa la evolución de precios, retornos o volatilidad de un activo a lo largo del tiempo.", 
                       style = "font-size: 14px; line-height: 1.6; text-align: justify;"),
                
                br(),
                
                h4("📐 Estacionariedad", style = "color: #1a1a2e; font-weight: 700;"),
                tags$p("Un proceso estocástico es estacionario en sentido débil si cumple las siguientes condiciones:", 
                       style = "font-size: 14px; line-height: 1.6; text-align: justify;"),
                tags$ul(
                  style = "font-size: 14px; line-height: 1.6;",
                  tags$li(tags$strong("Media constante:"), " $\\mathbb{E}[X_t] = \\mu, \\quad \\forall t$"),
                  tags$li(tags$strong("Varianza constante:"), " $\\text{Var}(X_t) = \\sigma^2, \\quad \\forall t$"),
                  tags$li(tags$strong("Autocovarianza estable:"), " $\\text{Cov}(X_t, X_{t+k}) = \\gamma_k \\quad, \\forall t$")
                ),
                
                br(),
                
                h4("📐 Pruebas de Estacionariedad", style = "color: #1a1a2e; font-weight: 700;"),
                
                h5("Test ADF (Dickey-Fuller Aumentado)", style = "margin-left: 15px; color: #2c3e50;"),
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin-left: 15px; margin-bottom: 15px;",
                    tags$p("La hipótesis nula del test ADF establece que la serie tiene una raíz unitaria, es decir, no es estacionaria:", style = "margin: 0 0 10px 0;"),
                    tags$p("$$H_0: \\gamma = 0 \\quad \\text{(raíz unitaria, NO estacionaria)}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("$$H_1: \\gamma < 0 \\quad \\text{(estacionaria)}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("La decisión se basa en el valor p: se rechaza $H_0$ si $p\\text{-value} < 0.05$.", style = "margin-top: 10px; margin-bottom: 0;")
                ),
                
                h5("Test KPSS", style = "margin-left: 15px; color: #2c3e50;"),
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin-left: 15px; margin-bottom: 15px;",
                    tags$p("A diferencia del test ADF, el test KPSS tiene como hipótesis nula que la serie es estacionaria:", style = "margin: 0 0 10px 0;"),
                    tags$p("$$H_0: \\text{La serie es estacionaria}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("$$H_1: \\text{La serie NO es estacionaria}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Se rechaza $H_0$ si $p\\text{-value} < 0.05$, indicando que la serie no es estacionaria.", style = "margin-top: 10px; margin-bottom: 0;")
                ),
                
                br(),
                
                h4("📐 Retornos Logarítmicos", style = "color: #1a1a2e; font-weight: 700;"),
                tags$p("Los retornos logarítmicos se definen como la diferencia de logaritmos de precios consecutivos:", style = "font-size: 14px; line-height: 1.6;"),
                div(style = "text-align: center; background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 10px 0;",
                    tags$p("$$r_t^{\\log} = \\ln\\!\\left(\\frac{P_t}{P_{t-1}}\\right) \\times 100$$", style = "font-family: monospace; font-size: 18px; margin: 0;")
                ),
                tags$p("Las ventajas de utilizar retornos logarítmicos sobre precios brutos son:", style = "font-size: 14px; line-height: 1.6;"),
                tags$ul(
                  style = "font-size: 14px; line-height: 1.6;",
                  tags$li(tags$strong("Estacionariedad:"), " Los retornos suelen ser estacionarios, mientras que los precios no lo son."),
                  tags$li(tags$strong("Normalización:"), " Mejor aproximación a una distribución normal (Teorema Central del Límite)."),
                  tags$li(tags$strong("Aditividad:"), " Los retornos logarítmicos son aditivos en el tiempo: $\\ln(P_t/P_0) = \\sum_{i=1}^t \\ln(P_i/P_{i-1})$."),
                  tags$li(tags$strong("Invarianza:"), " Son independientes de la escala de precios.")
                ),
                
                br(),
                
                h4("📐 Modelo ARIMA", style = "color: #1a1a2e; font-weight: 700;"),
                tags$p("El modelo ARIMA (Autoregressive Integrated Moving Average) se define mediante la siguiente ecuación:", 
                       style = "font-size: 14px; line-height: 1.6;"),
                div(style = "text-align: center; background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 10px 0;",
                    tags$p("$$\\phi(B)(1-B)^d Y_t = \\theta(B) \\varepsilon_t$$", style = "font-family: monospace; font-size: 18px; margin: 0;")
                ),
                tags$p("donde:", style = "font-size: 14px; margin-bottom: 5px;"),
                tags$ul(
                  style = "font-size: 14px; line-height: 1.6;",
                  tags$li("$\\phi(B) = 1 - \\phi_1 B - \\phi_2 B^2 - \\cdots - \\phi_p B^p$ es el polinomio autorregresivo de orden $p$."),
                  tags$li("$\\theta(B) = 1 - \\theta_1 B - \\theta_2 B^2 - \\cdots - \\theta_q B^q$ es el polinomio de media móvil de orden $q$."),
                  tags$li("$(1-B)^d$ es el operador de diferenciación de orden $d$."),
                  tags$li("$\\varepsilon_t \\sim \\text{Ruido Blanco}(0, \\sigma^2)$ es el término de error no correlacionado.")
                ),
                
                tags$p("Los componentes del modelo ARIMA son:", style = "font-size: 14px; margin-top: 15px; margin-bottom: 5px;"),
                tags$ul(
                  style = "font-size: 14px; line-height: 1.6;",
                  tags$li(tags$strong("AR(p) - Autorregresivo:"), " $Y_t = \\phi_1 Y_{t-1} + \\phi_2 Y_{t-2} + \\cdots + \\phi_p Y_{t-p} + \\varepsilon_t$. Captura la dependencia lineal entre observaciones pasadas y presentes."),
                  tags$li(tags$strong("I(d) - Integrado:"), " $(1-B)^d Y_t$ representa la diferenciación que hace la serie estacionaria. El parámetro $d$ indica cuántas veces se diferencia la serie."),
                  tags$li(tags$strong("MA(q) - Media Móvil:"), " $Y_t = \\varepsilon_t + \\theta_1 \\varepsilon_{t-1} + \\theta_2 \\varepsilon_{t-2} + \\cdots + \\theta_q \\varepsilon_{t-q}$. Captura el efecto de shocks pasados sobre el valor presente.")
                ),
                
                tags$p("La metodología Box-Jenkins para la construcción de modelos ARIMA consta de cuatro etapas fundamentales:", style = "font-size: 14px; margin-top: 15px;"),
                tags$ol(
                  style = "font-size: 14px; line-height: 1.6;",
                  tags$li(tags$strong("Identificación:"), " Análisis de las funciones de autocorrelación (ACF) y autocorrelación parcial (PACF) para identificar los órdenes $p$, $d$ y $q$ del modelo."),
                  tags$li(tags$strong("Estimación:"), " Estimación de los parámetros del modelo mediante el método de máxima verosimilitud."),
                  tags$li(tags$strong("Diagnóstico:"), " Verificación de los supuestos del modelo mediante el análisis de residuales (normalidad, independencia y homocedasticidad)."),
                  tags$li(tags$strong("Predicción:"), " Generación de pronósticos con sus respectivos intervalos de confianza.")
                ),
                
                br(),
                
                h4("📐 Criterios de Selección de Modelos", style = "color: #1a1a2e; font-weight: 700;"),
                tags$p("Para seleccionar el mejor modelo ARIMA se utilizan criterios de información que penalizan la complejidad del modelo:", style = "font-size: 14px; line-height: 1.6;"),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("AIC (Akaike Information Criterion):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{AIC} = 2k - 2\\ln(\\hat{L})$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Este criterio penaliza menos la complejidad del modelo, siendo útil para predicción. $k$ representa el número de parámetros y $\\hat{L}$ la máxima verosimilitud.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("BIC (Bayesian Information Criterion):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{BIC} = k\\ln(n) - 2\\ln(\\hat{L})$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Penaliza más la complejidad que el AIC, tendiendo a seleccionar modelos más parsimoniosos. $n$ es el número de observaciones.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("HQIC (Hannan-Quinn Information Criterion):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{HQIC} = 2k\\ln(\\ln(n)) - 2\\ln(\\hat{L})$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Ofrece una penalización intermedia entre el AIC y el BIC, siendo consistente para muestras grandes.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                tags$p("El mejor modelo es aquel que presenta el **valor más bajo** del criterio seleccionado.", style = "font-size: 14px; font-weight: bold; text-align: center; margin-top: 10px;"),
                
                br(),
                
                h4("📐 Métricas de Evaluación", style = "color: #1a1a2e; font-weight: 700;"),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("MAPE (Mean Absolute Percentage Error):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{MAPE} = \\frac{100\\%}{n} \\sum_{t=1}^{n} \\left|\\frac{y_t - \\hat{y}_t}{y_t}\\right|$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Mide el error porcentual absoluto medio. Valores cercanos a 0% indican mejor precisión.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("RMSE (Root Mean Square Error):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{RMSE} = \\sqrt{\\frac{1}{n} \\sum_{t=1}^{n} (y_t - \\hat{y}_t)^2}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Penaliza los errores grandes más severamente que el MAE. Útil cuando los errores grandes son especialmente indeseables.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("MAE (Mean Absolute Error):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$\\text{MAE} = \\frac{1}{n} \\sum_{t=1}^{n} |y_t - \\hat{y}_t|$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Menos sensible a outliers que el RMSE. Representa el error absoluto promedio.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin: 10px 0;",
                    tags$p(tags$strong("R² (Coeficiente de Determinación):"), style = "margin: 0 0 5px 0;"),
                    tags$p("$$R^2 = 1 - \\frac{\\sum_{t=1}^{n} (y_t - \\hat{y}_t)^2}{\\sum_{t=1}^{n} (y_t - \\bar{y})^2}$$", style = "text-align: center; font-family: monospace; margin: 5px 0;"),
                    tags$p("Indica la proporción de la varianza de la variable dependiente que es explicada por el modelo. Valores cercanos a 1 indican un buen ajuste.", style = "margin: 5px 0 0 0; font-size: 13px;")
                ),
                
                br(),
                
                h4("📐 Pruebas de Diagnóstico de Residuales", style = "color: #1a1a2e; font-weight: 700;"),
                
                h5("Test de Normalidad (Shapiro-Wilk)", style = "margin-left: 15px; color: #2c3e50;"),
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin-left: 15px; margin-bottom: 15px;",
                    tags$p("$$H_0: \\text{Los residuales siguen una distribución normal}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("$$H_1: \\text{Los residuales NO siguen una distribución normal}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("Se rechaza $H_0$ si $p\\text{-value} < 0.05$.", style = "margin-top: 5px;")
                ),
                
                h5("Test de Independencia (Ljung-Box)", style = "margin-left: 15px; color: #2c3e50;"),
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin-left: 15px; margin-bottom: 15px;",
                    tags$p("$$H_0: \\text{Los residuales son independientes (no autocorrelación)}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("$$H_1: \\text{Existe autocorrelación en los residuales}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("Se rechaza $H_0$ si $p\\text{-value} < 0.05$.", style = "margin-top: 5px;")
                ),
                
                h5("Test de Heterocedasticidad (ARCH)", style = "margin-left: 15px; color: #2c3e50;"),
                div(style = "background: #f8f9fa; padding: 12px; border-radius: 8px; margin-left: 15px;",
                    tags$p("$$H_0: \\text{Varianza constante (homocedasticidad)}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("$$H_1: \\text{Varianza no constante (heterocedasticidad)}$$", style = "font-family: monospace; margin: 5px 0; text-align: center;"),
                    tags$p("Se rechaza $H_0$ si $p\\text{-value} < 0.05$, indicando presencia de efectos ARCH.", style = "margin-top: 5px;")
                )
            )
          )
        ),
        
        # ============================================================
        # SECCIÓN: AUTORES (CON IMÁGENES)
        # ============================================================
        fluidRow(
          box(
            title = tagList(icon("users"), " Equipo de Desarrollo"),
            status = "success", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(6,
                     div(style = "display: flex; align-items: center; gap: 25px; padding: 15px; background: linear-gradient(135deg, #FFF5E6, #FFFFFF); border-radius: 15px; margin: 5px;",
                         tags$img(src = "mateo.jpeg", 
                                  style = "width: 110px; height: 110px; border-radius: 50%; object-fit: cover; border: 4px solid #F7931A; box-shadow: 0 8px 20px rgba(247,147,26,0.3);"),
                         div(
                           tags$h3("Mateo Barrios", style = "color: #F7931A; margin: 0 0 5px 0; font-weight: 700;"),
                           tags$p("Estudiante de ciencia de Datos | Uninorte", 
                                  style = "color: #7f8c8d; margin: 0 0 10px 0; font-size: 13px;"),
                           tags$p("", 
                                  style = "font-size: 13px; color: #555; line-height: 1.5; margin-bottom: 10px;"),
                           tags$a(href = "https://github.com/Mateo3008", target = "_blank", 
                                  style = "color: #F7931A; text-decoration: none; font-weight: 600;", 
                                  icon("github"), " Mateo3008")
                         )
                     )
              ),
              
              column(6,
                     div(style = "display: flex; align-items: center; gap: 25px; padding: 15px; background: linear-gradient(135deg, #E8F0FE, #FFFFFF); border-radius: 15px; margin: 5px;",
                         tags$img(src = "rafa.jpeg", 
                                  style = "width: 110px; height: 110px; border-radius: 50%; object-fit: cover; border: 4px solid #627EEA; box-shadow: 0 8px 20px rgba(98,126,234,0.3);"),
                         div(
                           tags$h3("Rafael Romero", style = "color: #627EEA; margin: 0 0 5px 0; font-weight: 700;"),
                           tags$p("Estudiante de ciencia de Datos | Uninorte", 
                                  style = "color: #7f8c8d; margin: 0 0 10px 0; font-size: 13px;"),
                           tags$p("", 
                                  style = "font-size: 13px; color: #555; line-height: 1.5; margin-bottom: 10px;"),
                           tags$a(href = "https://github.com/rafaelromero06", target = "_blank", 
                                  style = "color: #627EEA; text-decoration: none; font-weight: 600;", 
                                  icon("github"), " rafaelromero06")
                         )
                     )
              )
            ),
            
            hr(),
            
            h4("🛠️ Stack Tecnológico", style = "margin-top: 10px; font-weight: 700; color: #1a1a2e;"),
            div(
              style = "display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px;",
              lapply(
                c("R", "Shiny", "shinydashboard", "plotly", "ggplot2", "DT", 
                  "forecast", "tseries", "tidyverse", "lubridate", "CryptoCompare API"),
                function(tech) {
                  tags$span(
                    tech,
                    style = "padding: 6px 14px; border-radius: 25px; font-size: 12px; font-weight: 600; background: linear-gradient(135deg, #1a1a2e, #16213e); color: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1);"
                  )
                }
              )
            ),
            
            p(style = "color: #7f8c8d; font-size: 12px; text-align: center; margin-top: 15px;",
              "📌 Proyecto desarrollado como parte del análisis de series temporales financieras | ", 
              tags$a(href = "https://github.com/Mateo3008/Crypto_EDA_App", target = "_blank", 
                     style = "color: #F7931A; font-weight: 600;", "Ver código completo en GitHub"))
          )
        )
      ),
      #Vison general del mercado
      tabItem(
        tabName = "overview",
        tags$h2("🌐 Visión General del Mercado"),
        tags$p("Panorama actual de las criptomonedas: precios, capitalización y volumen de mercado.",
               style = "color:#94A3B8; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "📋 Tabla de Precios Actuales", 
            status = "primary", 
            solidHeader = TRUE, 
            width = 12,
            DT::dataTableOutput("tabla_overview")
          )
        ),
        
        fluidRow(
          box(
            title = "💹 Capitalización de Mercado", 
            status = "warning", 
            solidHeader = TRUE, 
            width = 6,
            tags$div(
              style = "font-size: 12px; color: #94A3B8; margin-bottom: 10px; text-align: center;",
              "🎯 Bitcoin destacado en naranja | Resto en slate"
            ),
            plotlyOutput("plot_market_cap", height = "420px")
          ),
          box(
            title = "📊 Volumen de Negociación 24h", 
            status = "info", 
            solidHeader = TRUE, 
            width = 6,
            tags$div(
              style = "font-size: 12px; color: #94A3B8; margin-bottom: 10px; text-align: center;",
              "📈 Intensidad proporcional al volumen | Degradado azul"
            ),
            plotlyOutput("plot_volume", height = "420px")
          )
        )
      ),
      
      # ============================================================
      # TAB 2 - PRECIOS
      # ============================================================
      tabItem(
        tabName = "precios",
        tags$h2("💰 Análisis de Precios"),
        tags$p("Exploración de la distribución histórica y evolución temporal de los precios.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "🎨 Boxplot de Precios", status = "primary", solidHeader = TRUE, width = 12,
              sliderInput("sel_dias", "Período de análisis (días):", min = 30, max = 1095, value = 365, step = 30),
              plotlyOutput("plot_boxplot_precios", height = "400px"))
        ),
        
        fluidRow(
          box(title = "📈 Serie Temporal", status = "warning", solidHeader = TRUE, width = 6,
              selectInput("sel_crypto_precio", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              plotlyOutput("plot_precio_serie", height = "400px")),
          box(title = "🕯️ Candlestick (60 días)", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_candlestick", height = "400px"))
        ),
        
        fluidRow(
          box(title = "📊 Bandas de Bollinger", status = "success", solidHeader = TRUE, width = 12,
              fluidRow(
                column(4, selectInput("bb_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(3, numericInput("bb_period", "Período:", value = 20, min = 5, max = 50)),
                column(3, numericInput("bb_sd", "Desviaciones:", value = 2, min = 1, max = 3, step = 0.5))
              ),
              plotlyOutput("plot_bollinger_bands", height = "450px"))
        )
      ),
      
      # ============================================================
      # TAB 3 - RETORNOS & RIESGO
      # ============================================================
      tabItem(
        tabName = "retornos",
        tags$h2("📉 Retornos & Riesgo"),
        tags$p("Distribución de retornos diarios, volatilidad histórica y métricas de riesgo.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "🎨 Boxplot de Retornos", status = "danger", solidHeader = TRUE, width = 12,
              sliderInput("sel_dias_ret", "Período (días):", min = 30, max = 1095, value = 365, step = 30),
              plotlyOutput("plot_boxplot_retornos", height = "500px"))
        ),
        
        fluidRow(
          box(title = "📊 Visualización", status = "success", solidHeader = TRUE, width = 8,
              fluidRow(
                column(6, selectInput("sel_crypto_ret", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(6, selectInput("tipo_grafico_ret", "Tipo:", 
                                      choices = c("Histograma" = "hist", "Serie temporal" = "serie", 
                                                  "Boxplot mensual" = "boxplot", "Volatilidad rodante" = "vol_rodante")))
              ),
              plotlyOutput("plot_retornos", height = "400px")),
          box(title = "📋 Métricas de Riesgo", status = "info", solidHeader = TRUE, width = 4,
              DT::dataTableOutput("tabla_riesgo"))
        )
      ),
      
      # ============================================================
      # TAB 4 - CORRELACIONES
      # ============================================================
      tabItem(
        tabName = "correlacion",
        tags$h2("🔗 Matriz de Correlaciones"),
        tags$p("Análisis de correlación entre retornos diarios de las criptomonedas.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "⚙️ Configuración", status = "primary", solidHeader = TRUE, width = 3,
              sliderInput("sel_dias_corr", "Período (días):", min = 30, max = 1095, value = 365, step = 30),
              selectInput("metodo_corr", "Método:", choices = c("Pearson (lineal)" = "pearson", "Spearman (rangos)" = "spearman")),
              hr(),
              h5("📊 Seleccionar monedas:"),
              checkboxGroupInput("sel_cryptos_corr", NULL, choices = CRYPTOS, selected = CRYPTOS[1:5]),
              hr(),
              h5("🔵 Dispersión:"),
              selectInput("corr_x", "Eje X:", choices = CRYPTOS, selected = "BTC"),
              selectInput("corr_y", "Eje Y:", choices = CRYPTOS, selected = "ETH")),
          box(title = "🌡️ Mapa de Calor", status = "warning", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_heatmap_corr", height = "550px"))
        ),
        
        fluidRow(
          box(title = "🔵 Dispersión de Retornos", status = "info", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_scatter_corr", height = "400px"))
        )
      ),
      
      # ============================================================
      # TAB 5 - COMPARADOR
      # ============================================================
      tabItem(
        tabName = "comparador",
        tags$h2("⚖️ Comparador de Rendimiento"),
        tags$p("Compara el rendimiento acumulado normalizado de múltiples criptomonedas en el mismo período.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "⚙️ Configuración", status = "primary", solidHeader = TRUE, width = 3,
              checkboxGroupInput("sel_cryptos_comp", "Monedas:", choices = CRYPTOS, selected = c("BTC", "ETH")),
              sliderInput("sel_dias_comp", "Período (días):", min = 30, max = 1095, value = 365, step = 30),
              radioButtons("tipo_norm", "Normalización:", 
                           choices = c("Base 100" = "base100", "Retorno acumulado %" = "pct"))),
          box(title = "📈 Rendimiento Comparado", status = "success", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_comparador", height = "400px"))
        ),
        
        fluidRow(
          box(title = "📋 Resumen Estadístico", status = "info", solidHeader = TRUE, width = 12,
              DT::dataTableOutput("tabla_comparador"))
        )
      ),
      
      # ============================================================
      # TAB 6 - ANÁLISIS EDA AVANZADO
      # ============================================================
      tabItem(
        tabName = "analisis",
        tags$h2("🔬 Análisis Exploratorio Avanzado"),
        tags$p("Series temporales, boxplots, descomposición STL/Aditiva/Multiplicativa, funciones ACF/PACF, pruebas de estacionariedad (ADF).",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "⚙️ Configuración", status = "primary", solidHeader = TRUE, width = 12,
              fluidRow(
                column(3, selectInput("analisis_crypto", "🪙 Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(3, sliderInput("analisis_dias", "📅 Días:", min = 90, max = 1095, value = 365, step = 30)),
                column(3, selectInput("analisis_variable", "📊 Variable:", 
                                      choices = c("Precio Cierre" = "close", "Retorno %" = "retorno", 
                                                  "Retorno Log" = "retorno_log", "Volatilidad" = "volatilidad"))),
                column(3, numericInput("arima_max_order", "🔢 Orden ARIMA:", value = 5, min = 1, max = 10)),
                column(12, radioButtons("tipo_descomp", "🔄 Descomposición:", 
                                        choices = c("STL" = "stl", "Aditiva Clásica" = "additive", "Multiplicativa" = "multiplicative"), 
                                        inline = TRUE, selected = "stl"))
              )
          )
        ),
        
        fluidRow(
          box(title = "🎨 Boxplot", status = "primary", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_analisis_boxplot", height = "400px"))
        ),
        
        fluidRow(
          box(title = "📈 Serie Temporal", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_analisis_serie", height = "350px")),
          box(title = "📊 Boxplot Mensual", status = "warning", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_analisis_boxplot_mensual", height = "350px"))
        ),
        
        fluidRow(
          box(title = "📊 ACF (Autocorrelación)", status = "info", solidHeader = TRUE, width = 6,
              helpText("Ayuda a identificar el orden MA(q). Barras fuera del área azul indican correlación significativa."),
              plotlyOutput("plot_analisis_acf", height = "320px")),
          box(title = "📊 PACF (Autocorrelación Parcial)", status = "info", solidHeader = TRUE, width = 6,
              helpText("Ayuda a identificar el orden AR(p). Barras fuera del área azul indican correlación parcial significativa."),
              plotlyOutput("plot_analisis_pacf", height = "320px"))
        ),
        
        fluidRow(
          box(title = "📊 Estadísticas Descriptivas", status = "success", solidHeader = TRUE, width = 6,
              uiOutput("analisis_stats_html")),
          box(title = "🔬 Test ADF (Estacionariedad)", status = "warning", solidHeader = TRUE, width = 6,
              uiOutput("analisis_stationarity_html"))
        ),
        
        fluidRow(
          box(title = "🔄 Descomposición de la Serie", status = "primary", solidHeader = TRUE, width = 12,
              helpText("La descomposición separa la serie en: Tendencia (T) + Estacionalidad (S) + Residuo (R) | Y(t) = T(t) + S(t) + R(t)"),
              plotlyOutput("plot_analisis_decomposition", height = "550px"))
        ),
        
        fluidRow(
          box(title = "📋 Estacionariedad por Criptomoneda", status = "info", solidHeader = TRUE, width = 12,
              helpText("p-value < 0.05 indica que la serie es estacionaria (rechaza H₀ de raíz unitaria)."),
              DT::dataTableOutput("tabla_analisis_stationarity"))
        )
      ),
      
      # ============================================================
      # TAB 7 - MODELO ARIMA
      # ============================================================
      tabItem(
        tabName = "arima",
        tags$h2("🤖 Modelado Predictivo con ARIMA"),
        tags$p("Ajuste automático de modelos ARIMA, selección por criterios AIC/BIC/HQIC, rolling forecast y diagnóstico.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "⚙️ Configuración", status = "primary", solidHeader = TRUE, width = 3,
              selectInput("arima_crypto", "🪙 Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              selectInput("arima_variable", "📊 Variable:", choices = c("Precio Cierre" = "close", "Retorno %" = "retorno")),
              sliderInput("arima_train_dias", "📅 Entrenamiento:", min = 100, max = 1500, value = 800, step = 50),
              numericInput("arima_horizonte", "🎯 Horizonte test:", value = 28, min = 7, max = 90, step = 7),
              numericInput("arima_max_pq", "🔢 Máximo (p,q):", value = 3, min = 1, max = 5),
              radioButtons("arima_criterio", "📐 Criterio:", choices = c("AIC" = "AIC", "BIC" = "BIC", "HQIC" = "HQIC"), inline = TRUE),
              radioButtons("arima_tipo", "🔮 Pronóstico:", choices = c("Rolling" = "rolling", "Directo" = "directo"), inline = TRUE),
              br(),
              actionButton("btn_arima", "🚀 Ajustar Modelo", class = "btn-success", width = "100%"),
              br(), br(),
              actionButton("btn_all_horizons", "📊 Comparar Horizontes", class = "btn-info", width = "100%")),
          
          box(title = "🏆 Mejor Modelo", status = "success", solidHeader = TRUE, width = 3,
              uiOutput("arima_best_model_ui"),
              br(),
              h5("Top órdenes:", style = "margin-top:10px;"),
              DTOutput("tabla_arima_criterios")),
          
          box(title = "📈 Ajuste y Pronóstico", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_arima_fit", height = "250px"),
              plotlyOutput("plot_arima_forecast", height = "250px"))
        ),
        
        fluidRow(
          box(title = "📊 Métricas de Error", status = "warning", solidHeader = TRUE, width = 6,
              DTOutput("tabla_arima_error")),
          box(title = "🔬 Diagnóstico Residuales", status = "danger", solidHeader = TRUE, width = 6,
              fluidRow(column(6, plotlyOutput("plot_arima_resid_acf", height = "250px")),
                       column(6, plotlyOutput("plot_arima_resid_hist", height = "250px"))))
        ),
        
        fluidRow(
          box(title = "📊 Comparación Horizontes", status = "primary", solidHeader = TRUE, width = 12,
              DTOutput("tabla_comparacion_horizontes"),
              plotlyOutput("plot_comparacion_horizontes", height = "300px"))
        )
      ),
      
      # ============================================================
      # TAB 8 - PREDICCIÓN ÓPTIMA
      # ============================================================
      tabItem(
        tabName = "optimal",
        tags$h2("🎯 Predicción con el Mejor Modelo ARIMA"),
        tags$p("Pipeline optimizado con transformación a retornos logarítmicos y rolling forecast (h=1).",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "⚙️ Configuración", status = "primary", solidHeader = TRUE, width = 3,
              selectInput("optimal_crypto", "🪙 Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              sliderInput("optimal_horizon", "🎯 Horizonte de predicción (días):", 
                          min = 7, max = 60, value = 30, step = 7),
              br(),
              actionButton("btn_optimal_prediction", "🔍 Ejecutar Pipeline Optimizado", 
                           class = "btn-success", width = "100%",
                           style = "font-weight:bold; background: linear-gradient(135deg, #2ecc71, #27ae60);")),
          
          box(title = "🏆 Modelo Seleccionado", status = "success", solidHeader = TRUE, width = 3,
              uiOutput("optimal_model_info")),
          
          box(title = "📈 Predicción", status = "warning", solidHeader = TRUE, width = 3,
              valueBoxOutput("prediction_tomorrow_box", width = 12)),
          
          box(title = "📊 Gráfico de Predicción", status = "info", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_optimal_forecast", height = "400px"))
        ),
        
        fluidRow(
          box(title = "📋 Métricas del Modelo", status = "warning", solidHeader = TRUE, width = 4,
              helpText("Métricas evaluadas en el conjunto de test."),
              DTOutput("optimal_metrics_table")),
          
          box(title = "📊 Comparación con Baselines", status = "info", solidHeader = TRUE, width = 4,
              helpText("Comparación contra modelos Naive, Drift y Seasonal Naive."),
              DTOutput("optimal_baseline_table")),
          
          box(title = "🔬 Diagnóstico de Residuales", status = "danger", solidHeader = TRUE, width = 4,
              uiOutput("optimal_residuals_diagnostic"))
        ),
        
        fluidRow(
          box(title = "📋 Tabla de Predicciones", status = "primary", solidHeader = TRUE, width = 12,
              helpText("Predicciones con intervalos de confianza del 80% y 95%."),
              DTOutput("optimal_forecast_table"))
        )
      ),
      
      # ============================================================
      # TAB 9 - VALORES FALTANTES
      # ============================================================
      tabItem(
        tabName = "missing",
        tags$h2("⚠️ Valores Faltantes (NAs)"),
        tags$p("Análisis de datos faltantes y métodos de imputación.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "🔍 Configuración", status = "primary", solidHeader = TRUE, width = 3,
              selectInput("miss_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              selectInput("miss_method", "Método imputación:", 
                          choices = c("Interpolación lineal" = "interpolation", "Media" = "mean", "Eliminar filas" = "remove")),
              br(),
              actionButton("btn_impute", "🔄 Aplicar Imputación", class = "btn-warning", width = "100%"),
              br(), br(),
              h5("Resumen de NAs:"),
              DTOutput("tabla_missing")),
          
          box(title = "📈 Original vs Imputado", status = "warning", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_missing_compare", height = "400px"))
        ),
        
        fluidRow(
          box(title = "🌡️ Mapa de Calor: % NAs", status = "info", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_missing_heatmap", height = "500px"))
        )
      )
      
    ) # fin tabItems
  ) # fin dashboardBody
) # fin dashboardPage