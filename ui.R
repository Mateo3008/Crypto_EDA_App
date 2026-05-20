
library(shiny)
library(shinydashboard)
library(plotly)
library(DT)

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
  
  # Cabecera
  dashboardHeader(
    title = tagList(
      tags$img(src = "crypto.svg", height = "34",
               style = "padding-right:8px; vertical-align:middle; filter: drop-shadow(0 0 6px #F7931A);"),
      tags$span("Crypto", style = "color:#F7931A; font-weight:700; letter-spacing:1px;"),
      tags$span(" EDA", style = "color:#627EEA; font-weight:700;")
    ),
    titleWidth = 280,
    
    # Boton de GitHub en la cabecera
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
    
    # Indicador de datos en vivo
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
        "DATOS EN VIVO"
      )
    )
  ),
  
  #Barra lateral 
  dashboardSidebar(
    width = 280,
    tags$div(
      style = "padding: 12px 0 4px 0; text-align:center;",
      tags$span(
        style = "font-size:10px; color:#95a5a6; letter-spacing:2px; text-transform:uppercase;",
        "Menu de navegacion"
      )
    ),
    sidebarMenu(
      id = "main_menu",
      menuItem(" Introduccion",       tabName = "intro",       icon = icon("book")),
      menuItem(" Vision General",    tabName = "overview",    icon = icon("gauge")),
      menuItem(" Precios",           tabName = "precios",     icon = icon("chart-line")),
      menuItem(" Retornos y Riesgo", tabName = "retornos",    icon = icon("percent")),
      menuItem(" Correlaciones",     tabName = "correlacion", icon = icon("table-cells")),
      menuItem(" Comparador",        tabName = "comparador",  icon = icon("sliders")),
      menuItem(" Analisis EDA",      tabName = "analisis",    icon = icon("chart-simple")),
      menuItem(" Modelo ARIMA",      tabName = "arima",       icon = icon("chart-line")),
      menuItem(" Prediccion Optima", tabName = "optimal",     icon = icon("crown")),
      menuItem(" Valores Faltantes", tabName = "missing",     icon = icon("exclamation-triangle"))
    ),
    
    tags$hr(style = "border-color:rgba(255,255,255,0.1); margin:10px 15px;"),
    
    # Boton para cambiar entre tema claro y oscuro
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
    
    # Tarjeta con las monedas activas
    tags$div(
      style = paste0(
        "margin:14px 15px 0 15px; padding:12px;",
        "background:rgba(255,255,255,0.05);",
        "border-radius:10px; border:1px solid rgba(255,255,255,0.08);"
      ),
      tags$p(
        style = "color:#7f8c8d; font-size:10px; margin:0 0 8px; text-transform:uppercase; letter-spacing:1px;",
        "Monedas analizadas"
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
    
    # Enlaces a GitHub y YouTube
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
          "transition:all 0.3s ease; margin-bottom:8px;"
        ),
        onmouseover = "this.style.color='#fff'; this.style.borderColor='rgba(247,147,26,0.5)';",
        onmouseout  = "this.style.color='#95a5a6'; this.style.borderColor='rgba(255,255,255,0.06)';",
        icon("code-branch"),
        "Codigo en GitHub"
      ),
      tags$a(
        href = "https://www.youtube.com/watch?v=-r46zYDvENQ&t=32s",
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
        icon("youtube"),
        "Video del proyecto"
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
  # CUERPO PRINCIPAL (BODY)
  # ============================================================
  dashboardBody(
    
    # Canvas para las particulas de fondo
    tags$canvas(
      id    = "particles-canvas",
      style = "position:fixed; top:0; left:0; width:100%; height:100%; z-index:0; pointer-events:none;"
    ),
    
    tags$head(
      # Librerias para renderizar formulas matematicas (KaTeX)
      tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"),
      
      # Estilos CSS personalizados (glassmorphism, temas, etc.)
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
        
        .katex { font-size: 1.05em !important; }
        .katex-display { overflow-x: auto; overflow-y: hidden; padding: 6px 0; }
        .katex-display > .katex { font-size: 1.15em !important; }
      ")),
      
      # Script para las particulas de fondo y para renderizar formulas con KaTeX
      tags$script(HTML("
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
    # CONTENIDO DE LAS PESTANAS
    # ============================================================
    tabItems(
      # ============================================================
      # PESTANA 0 - INTRODUCCION
      # ============================================================
      tabItem(
        tabName = "intro",
        
        # Banner principal
        tags$div(
          class = "intro-hero",
          style = "background: linear-gradient(135deg, #0a0e1a 0%, #16213e 50%, #0f3460 100%); border-radius: 18px; padding: 40px; margin-bottom: 20px;",
          fluidRow(
            column(8,
                   tags$h1("Crypto EDA", style = "font-size:42px; font-weight:900; margin:0 0 8px; color:white;"),
                   tags$p("Analisis exploratorio de datos de criptomonedas con modelos ARIMA", 
                          style = "font-size:18px; color:rgba(255,255,255,0.85); margin:0 0 16px;"),
                   tags$div(
                     style = "display:flex; gap:10px; flex-wrap:wrap;",
                     tags$span(class = "neon-badge green", "Datos reales"),
                     tags$span(class = "neon-badge orange", "API de CryptoCompare"),
                     tags$span(class = "neon-badge blue", "1905 dias de historia"),
                     tags$span(class = "neon-badge green", "Modelos ARIMA"),
                     tags$a(href = "https://github.com/Mateo3008/Crypto_EDA_App", target = "_blank",
                            style = "display:inline-flex; align-items:center; gap:6px; padding:4px 14px; border-radius:20px; font-size:11px; font-weight:700; background:rgba(255,255,255,0.1); color:white; text-decoration:none;",
                            icon("github"), "GitHub")
                   )
            ),
            column(4,
                   tags$div(style = "text-align:right; padding-top:10px;",
                            tags$div(style = "display:inline-block; padding:16px 24px; background:rgba(255,255,255,0.07); border-radius:14px;",
                                     tags$div(style = "font-size:11px; color:rgba(255,255,255,0.5);", "Ultima actualizacion"),
                                     tags$div(id = "live-ticker-txt", style = "font-size:13px; color:#F7931A; font-weight:700;", "Datos en tiempo real")
                            )
                   )
            )
          )
        ),
        
        # Indicadores clave (value boxes)
        fluidRow(
          valueBoxOutput("vbox_monedas", width = 3),
          valueBoxOutput("vbox_registros", width = 3),
          valueBoxOutput("vbox_periodo", width = 3),
          valueBoxOutput("vbox_missing", width = 3)
        ),
        
        # Objetivos del proyecto (numeracion corregida)
        fluidRow(
          box(
            title = tagList(icon("bullseye"), " Objetivos del Proyecto"),
            status = "primary", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(12,
                     h4("Objetivo General", style = "color: #F7931A; margin-top: 0;"),
                     tags$p("Predecir el precio de cierre de criptomonedas usando modelos ARIMA optimizados, ofreciendo una herramienta interactiva para apoyar decisiones de inversion.", 
                            style = "font-size: 14px; line-height: 1.5; background: rgba(247,147,26,0.08); padding: 12px; border-radius: 10px; margin-bottom: 20px;")
              )
            ),
            
            fluidRow(
              column(12,
                     h4("Objetivos Especificos", style = "color: #627EEA; margin-top: 0;"),
                     tags$ol(
                       style = "font-size: 13px; line-height: 1.8; padding-left: 20px;",
                       tags$li(style = "margin-bottom: 12px;", tags$strong(" Monitoreo en tiempo real:"), " Conectarse a la API de CryptoCompare para obtener precios, capitalizacion y volumen actualizados de las 10 principales criptomonedas de forma automatica."),
                       tags$li(style = "margin-bottom: 12px;", tags$strong(" Visualizacion clara:"), " Transformar datos complejos en graficos interactivos que permitan identificar tendencias, comparar monedas y detectar patrones de comportamiento del mercado."),
                       tags$li(style = "margin-bottom: 12px;", tags$strong(" Analisis de correlaciones:"), " Estudiar como se relacionan los movimientos de precio entre distintas criptomonedas. Se mueven juntas? Cuales son independientes? Esto es clave para diversificar."),
                       tags$li(style = "margin-bottom: 12px;", tags$strong(" Prediccion de precios:"), " Determinar que monedas pueden sufrir cambios en los proximos dias, midiendo el rango de variacion de precios y comparando por tamano de capitalizacion de mercado.")
                     )
              )
            )
          )
        ),
        
        # Marco teorico (todas las formulas que usamos)
        fluidRow(
          box(
            title = tagList(icon("book"), " Marco Teorico"),
            status = "info", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(4,
                     div(class = "eq-box",
                         tags$strong("Retorno Simple:"),
                         tags$p("$$r_t = \\frac{P_t - P_{t-1}}{P_{t-1}} \\times 100$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Retorno Logaritmico:"),
                         tags$p("$$r_t^{\\log} = \\ln\\!\\left(\\frac{P_t}{P_{t-1}}\\right) \\times 100$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Volatilidad Diaria:"),
                         tags$p("$$v_t = \\frac{High_t - Low_t}{Open_t} \\times 100$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Bandas de Bollinger:"),
                         tags$p("$$BB_{\\pm} = SMA_n \\pm k \\cdot \\sigma_n$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Ancho de Banda:"),
                         tags$p("$$\\%Bw = \\frac{BB_{+} - BB_{-}}{SMA_n} \\times 100$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Valor en Riesgo (VaR 95%):"),
                         tags$p("$$\\text{VaR}_{95\\%} = Q_{0.05}(r_t)$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Modelo ARIMA(p,d,q):"),
                         tags$p("$$\\phi(B)(1-B)^d Y_t = \\theta(B) \\varepsilon_t$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Descomposicion STL:"),
                         tags$p("$$Y_t = T_t + S_t + R_t$$", style = "margin: 8px 0;")
                     ),
                     div(class = "eq-box",
                         tags$strong("Descomposicion Multiplicativa:"),
                         tags$p("$$Y_t = T_t \\times S_t \\times R_t$$", style = "margin: 8px 0;")
                     )
              )
            ),
            
            hr(),
            
            fluidRow(
              column(4,
                     div(class = "eq-box",
                         tags$strong("Criterio AIC:"),
                         tags$p("$$\\text{AIC} = 2k - 2\\ln(\\hat{L})$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Criterio BIC:"),
                         tags$p("$$\\text{BIC} = k\\ln(n) - 2\\ln(\\hat{L})$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Criterio HQIC:"),
                         tags$p("$$\\text{HQIC} = 2k\\ln(\\ln(n)) - 2\\ln(\\hat{L})$$", style = "margin: 8px 0;")
                     )
              )
            ),
            
            hr(),
            
            fluidRow(
              column(4,
                     div(class = "eq-box",
                         tags$strong("Metrica MAPE:"),
                         tags$p("$$\\text{MAPE} = \\frac{100\\%}{n} \\sum \\left|\\frac{y_t - \\hat{y}_t}{y_t}\\right|$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Metrica RMSE:"),
                         tags$p("$$\\text{RMSE} = \\sqrt{\\frac{1}{n} \\sum (y_t - \\hat{y}_t)^2}$$", style = "margin: 8px 0;")
                     )
              ),
              column(4,
                     div(class = "eq-box",
                         tags$strong("Coeficiente R²:"),
                         tags$p("$$R^2 = 1 - \\frac{\\sum (y_t - \\hat{y}_t)^2}{\\sum (y_t - \\bar{y})^2}$$", style = "margin: 8px 0;")
                     )
              )
            ),
            
            hr(),
            
            fluidRow(
              column(6,
                     div(class = "eq-box",
                         tags$strong("Test ADF (Dickey-Fuller Aumentado):"),
                         tags$p("$$H_0: \\gamma = 0 \\quad \\text{(raiz unitaria, no estacionaria)}$$", style = "margin: 8px 0;"),
                         tags$p("$$H_1: \\gamma < 0 \\quad \\text{(estacionaria)}$$", style = "margin: 8px 0;")
                     )
              ),
              column(6,
                     div(class = "eq-box",
                         tags$strong("Test de Ljung-Box (Independencia):"),
                         tags$p("$$Q = n(n+2)\\sum_{k=1}^{h}\\frac{\\hat{\\rho}_k^2}{n-k}$$", style = "margin: 8px 0;")
                     )
              )
            )
          )
        ),
        
        # Equipo de desarrollo (con fotos y enlaces)
        fluidRow(
          box(
            title = tagList(icon("users"), " Equipo de Desarrollo"),
            status = "success", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(6,
                     div(style = "display: flex; align-items: center; gap: 25px; padding: 15px; background: linear-gradient(135deg, #FFF5E6, #FFFFFF); border-radius: 15px; margin: 5px;",
                         tags$img(src = "mateo.jpeg", 
                                  style = "width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 4px solid #F7931A; box-shadow: 0 8px 20px rgba(247,147,26,0.3);"),
                         div(
                           tags$h3("Mateo Barrios", style = "color: #F7931A; margin: 0 0 5px 0;"),
                           tags$p("Estudiante de Ciencia de Datos | Uninorte", style = "color: #7f8c8d; margin: 0;"),
                           tags$a(href = "https://github.com/Mateo3008", target = "_blank", 
                                  style = "color: #F7931A; text-decoration: none;", 
                                  icon("github"), " Mateo3008")
                         )
                     )
              ),
              column(6,
                     div(style = "display: flex; align-items: center; gap: 25px; padding: 15px; background: linear-gradient(135deg, #E8F0FE, #FFFFFF); border-radius: 15px; margin: 5px;",
                         tags$img(src = "rafa.jpeg", 
                                  style = "width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 4px solid #627EEA; box-shadow: 0 8px 20px rgba(98,126,234,0.3);"),
                         div(
                           tags$h3("Rafael Romero", style = "color: #627EEA; margin: 0 0 5px 0;"),
                           tags$p("Estudiante de Ciencia de Datos | Uninorte", style = "color: #7f8c8d; margin: 0;"),
                           tags$a(href = "https://github.com/rafaelromero06", target = "_blank", 
                                  style = "color: #627EEA; text-decoration: none;", 
                                  icon("github"), " rafaelromero06")
                         )
                     )
              )
            ),
            
            hr(),
            
            h4("Tecnologias utilizadas", style = "margin-top: 10px;"),
            div(
              style = "display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px;",
              lapply(
                c("R", "Shiny", "shinydashboard", "plotly", "ggplot2", "DT", 
                  "forecast", "tseries", "tidyverse", "lubridate", "CryptoCompare API"),
                function(tech) {
                  tags$span(
                    tech,
                    style = "padding: 6px 14px; border-radius: 25px; font-size: 12px; font-weight: 600; background: linear-gradient(135deg, #1a1a2e, #16213e); color: white;"
                  )
                }
              )
            ),
            
            # Enlaces a GitHub y YouTube (proyecto)
            div(
              style = "text-align: center; margin-top: 15px;",
              tags$a(href = "https://github.com/Mateo3008/Crypto_EDA_App", target = "_blank", 
                     style = "color: #F7931A; margin-right: 20px; font-weight: 600;", 
                     icon("github"), " Repositorio en GitHub"),
              tags$a(href = "https://www.youtube.com/watch?v=-r46zYDvENQ&t=32s", target = "_blank", 
                     style = "color: #FF0000; font-weight: 600;", 
                     icon("youtube"), " Video del proyecto")
            ),
            
            p(style = "color: #7f8c8d; font-size: 12px; text-align: center; margin-top: 15px;",
              "Proyecto desarrollado para el analisis de series temporales financieras")
          )
        )
      ),
      
      # ============================================================
      # PESTANA 1 - VISION GENERAL
      # ============================================================
      tabItem(
        tabName = "overview",
        tags$h2("Vision General del Mercado"),
        tags$p("Precios actuales, capitalizacion de mercado y volumen de las 10 criptomonedas.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Precios y Mercado Actuales", status = "primary", solidHeader = TRUE, width = 12,
              DT::dataTableOutput("tabla_overview"))
        ),
        
        fluidRow(
          box(title = "Capitalizacion de Mercado", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_market_cap", height = "400px")),
          box(title = "Volumen en 24h", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_volume", height = "400px"))
        )
      ),
      
      # ============================================================
      # PESTANA 2 - PRECIOS
      # ============================================================
      tabItem(
        tabName = "precios",
        tags$h2("Analisis de Precios"),
        tags$p("Serie temporal de precios, graficos de velas y Bandas de Bollinger.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Distribucion de Precios", status = "primary", solidHeader = TRUE, width = 12,
              sliderInput("sel_dias", "Periodo (dias):", min = 30, max = 1905, value = 365, step = 30),
              plotlyOutput("plot_boxplot_precios", height = "400px"))
        ),
        
        fluidRow(
          box(title = "Serie Temporal", status = "success", solidHeader = TRUE, width = 8,
              selectInput("sel_crypto_precio", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              plotlyOutput("plot_precio_serie", height = "300px")),
          box(title = "Grafico de Velas (ultimos 60 dias)", status = "warning", solidHeader = TRUE, width = 4,
              plotlyOutput("plot_candlestick", height = "300px"))
        ),
        
        fluidRow(
          box(title = "Bandas de Bollinger", status = "info", solidHeader = TRUE, width = 12,
              fluidRow(
                column(4, selectInput("bb_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(4, sliderInput("bb_period", "Ventana (dias):", min = 5, max = 50, value = 20, step = 1)),
                column(4, sliderInput("bb_sd", "Desviaciones estandar:", min = 1, max = 3, value = 2, step = 0.5))
              ),
              plotlyOutput("plot_bollinger_bands", height = "400px"))
        )
      ),
      
      # ============================================================
      # PESTANA 3 - RETORNOS Y RIESGO
      # ============================================================
      tabItem(
        tabName = "retornos",
        tags$h2("Retornos y Riesgo"),
        tags$p("Distribucion de retornos diarios, volatilidad historica y metricas de riesgo.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Boxplot de Retornos", status = "danger", solidHeader = TRUE, width = 12,
              sliderInput("sel_dias_ret", "Periodo (dias):", min = 30, max = 1095, value = 365, step = 30),
              plotlyOutput("plot_boxplot_retornos", height = "500px"))
        ),
        
        fluidRow(
          box(title = "Visualizacion de Retornos", status = "success", solidHeader = TRUE, width = 8,
              fluidRow(
                column(6, selectInput("sel_crypto_ret", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(6, selectInput("tipo_grafico_ret", "Tipo de grafico:", 
                                      choices = c("Histograma" = "hist", "Serie temporal" = "serie", 
                                                  "Boxplot mensual" = "boxplot", "Volatilidad rodante" = "vol_rodante")))
              ),
              plotlyOutput("plot_retornos", height = "400px")),
          box(title = "Metricas de Riesgo", status = "info", solidHeader = TRUE, width = 4,
              DT::dataTableOutput("tabla_riesgo"))
        )
      ),
      
      # ============================================================
      # PESTANA 4 - CORRELACIONES
      # ============================================================
      tabItem(
        tabName = "correlacion",
        tags$h2("Matriz de Correlaciones"),
        tags$p("Analisis de correlacion entre retornos diarios de las criptomonedas.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Configuracion", status = "primary", solidHeader = TRUE, width = 3,
              sliderInput("sel_dias_corr", "Periodo (dias):", min = 30, max = 1095, value = 365, step = 30),
              selectInput("metodo_corr", "Metodo de correlacion:", choices = c("Pearson (lineal)" = "pearson", "Spearman (rangos)" = "spearman")),
              hr(),
              h5("Seleccionar monedas a comparar:"),
              checkboxGroupInput("sel_cryptos_corr", NULL, choices = CRYPTOS, selected = CRYPTOS[1:5]),
              hr(),
              h5("Grafico de dispersion:"),
              selectInput("corr_x", "Eje X:", choices = CRYPTOS, selected = "BTC"),
              selectInput("corr_y", "Eje Y:", choices = CRYPTOS, selected = "ETH")),
          box(title = "Mapa de Calor de Correlaciones", status = "warning", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_heatmap_corr", height = "550px"))
        ),
        
        fluidRow(
          box(title = "Dispersion de Retornos", status = "info", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_scatter_corr", height = "400px"))
        )
      ),
      
      # ============================================================
      # PESTANA 5 - COMPARADOR DE RENDIMIENTO
      # ============================================================
      tabItem(
        tabName = "comparador",
        tags$h2("Comparador de Rendimiento"),
        tags$p("Compara el rendimiento acumulado normalizado de multiples criptomonedas en el mismo periodo.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Configuracion", status = "primary", solidHeader = TRUE, width = 3,
              checkboxGroupInput("sel_cryptos_comp", "Monedas a comparar:", choices = CRYPTOS, selected = c("BTC", "ETH")),
              sliderInput("sel_dias_comp", "Periodo (dias):", min = 30, max = 1095, value = 365, step = 30),
              radioButtons("tipo_norm", "Normalizacion:", 
                           choices = c("Base 100 (inicio = 100)" = "base100", "Retorno acumulado (%)" = "pct"))),
          box(title = "Rendimiento Comparado", status = "success", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_comparador", height = "400px"))
        ),
        
        fluidRow(
          box(title = "Resumen Estadistico", status = "info", solidHeader = TRUE, width = 12,
              DT::dataTableOutput("tabla_comparador"))
        )
      ),
      
      # ============================================================
      # PESTANA 6 - ANALISIS EDA AVANZADO
      # ============================================================
      tabItem(
        tabName = "analisis",
        tags$h2("Analisis Exploratorio Avanzado"),
        tags$p("Series temporales, boxplots, descomposicion STL/Aditiva/Multiplicativa, funciones ACF/PACF, pruebas de estacionariedad (ADF).",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Configuracion", status = "primary", solidHeader = TRUE, width = 12,
              fluidRow(
                column(3, selectInput("analisis_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC")),
                column(3, sliderInput("analisis_dias", "Dias a analizar:", min = 90, max = 1095, value = 365, step = 30)),
                column(3, selectInput("analisis_variable", "Variable:", 
                                      choices = c("Precio de cierre" = "close", "Retorno (%)" = "retorno", 
                                                  "Retorno logaritmico (%)" = "retorno_log", "Volatilidad (%)" = "volatilidad"))),
                column(3, numericInput("arima_max_order", "Orden maximo ARIMA (p,q):", value = 5, min = 1, max = 10)),
                column(12, radioButtons("tipo_descomp", "Tipo de descomposicion:", 
                                        choices = c("STL" = "stl", "Aditiva clasica" = "additive", "Multiplicativa" = "multiplicative"), 
                                        inline = TRUE, selected = "stl"))
              )
          )
        ),
        
        fluidRow(
          box(title = "Boxplot", status = "primary", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_analisis_boxplot", height = "400px"))
        ),
        
        fluidRow(
          box(title = "Serie Temporal", status = "success", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_analisis_serie", height = "350px")),
          box(title = "Boxplot Mensual", status = "warning", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_analisis_boxplot_mensual", height = "350px"))
        ),
        
        fluidRow(
          box(title = "ACF (Autocorrelacion)", status = "info", solidHeader = TRUE, width = 6,
              helpText("Ayuda a identificar el orden MA(q). Las barras fuera del area azul indican correlacion significativa."),
              plotlyOutput("plot_analisis_acf", height = "320px")),
          box(title = "PACF (Autocorrelacion Parcial)", status = "info", solidHeader = TRUE, width = 6,
              helpText("Ayuda a identificar el orden AR(p). Las barras fuera del area azul indican correlacion parcial significativa."),
              plotlyOutput("plot_analisis_pacf", height = "320px"))
        ),
        
        fluidRow(
          box(title = "Estadisticas Descriptivas", status = "success", solidHeader = TRUE, width = 6,
              uiOutput("analisis_stats_html")),
          box(title = "Test ADF (Estacionariedad)", status = "warning", solidHeader = TRUE, width = 6,
              uiOutput("analisis_stationarity_html"))
        ),
        
        fluidRow(
          box(title = "Descomposicion de la Serie", status = "primary", solidHeader = TRUE, width = 12,
              helpText("La descomposicion separa la serie en: Tendencia (T) + Estacionalidad (S) + Residuo (R) | Y(t) = T(t) + S(t) + R(t)"),
              plotlyOutput("plot_analisis_decomposition", height = "550px"))
        ),
        
        fluidRow(
          box(title = "Estacionariedad por Criptomoneda", status = "info", solidHeader = TRUE, width = 12,
              helpText("p-value < 0.05 indica que la serie es estacionaria (se rechaza H0 de raiz unitaria)."),
              DT::dataTableOutput("tabla_analisis_stationarity"))
        )
      ),
      
      # ============================================================
      # PESTANA 7 - MODELO ARIMA
      # ============================================================
      tabItem(
        tabName = "arima",
        tags$h2("Modelado Predictivo con ARIMA"),
        tags$p("Ajuste automatico de modelos ARIMA, seleccion por criterios AIC/BIC/HQIC, pronostico rolling vs directo y diagnostico.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Configuracion", status = "primary", solidHeader = TRUE, width = 3,
              selectInput("arima_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              selectInput("arima_variable", "Variable a modelar:", choices = c("Precio de cierre" = "close", "Retorno (%)" = "retorno")),
              sliderInput("arima_train_dias", "Dias de entrenamiento:", min = 100, max = 1500, value = 800, step = 50),
              numericInput("arima_horizonte", "Horizonte de prueba (dias):", value = 28, min = 7, max = 90, step = 7),
              numericInput("arima_max_pq", "Orden maximo (p,q):", value = 3, min = 1, max = 5),
              radioButtons("arima_criterio", "Criterio de seleccion:", choices = c("AIC" = "AIC", "BIC" = "BIC", "HQIC" = "HQIC"), inline = TRUE),
              radioButtons("arima_tipo", "Tipo de pronostico:", choices = c("Rolling (reentrenando)" = "rolling", "Directo" = "directo"), inline = TRUE),
              br(),
              actionButton("btn_arima", "Ajustar modelo", class = "btn-success", width = "100%"),
              br(), br(),
              actionButton("btn_all_horizons", "Comparar horizontes (7/14/21/28 dias)", class = "btn-info", width = "100%")),
          
          box(title = "Mejor modelo encontrado", status = "success", solidHeader = TRUE, width = 3,
              uiOutput("arima_best_model_ui"),
              br(),
              h5("Mejores ordenes por AIC:", style = "margin-top:10px;"),
              DTOutput("tabla_arima_criterios")),
          
          box(title = "Ajuste y pronostico", status = "info", solidHeader = TRUE, width = 6,
              plotlyOutput("plot_arima_fit", height = "250px"),
              plotlyOutput("plot_arima_forecast", height = "250px"))
        ),
        
        fluidRow(
          box(title = "Metricas de error", status = "warning", solidHeader = TRUE, width = 6,
              DTOutput("tabla_arima_error")),
          box(title = "Diagnostico de residuos", status = "danger", solidHeader = TRUE, width = 6,
              fluidRow(column(6, plotlyOutput("plot_arima_resid_acf", height = "250px")),
                       column(6, plotlyOutput("plot_arima_resid_hist", height = "250px"))))
        ),
        
        fluidRow(
          box(title = "Comparacion por horizonte", status = "primary", solidHeader = TRUE, width = 12,
              DTOutput("tabla_comparacion_horizontes"),
              plotlyOutput("plot_comparacion_horizontes", height = "300px"))
        )
      ),
      
      # ============================================================
      # PESTANA 8 - PREDICCION OPTIMA
      # ============================================================
      tabItem(
        tabName = "optimal",
        tags$h2("Prediccion con el Mejor Modelo ARIMA"),
        tags$p("Pipeline optimizado que selecciona automaticamente el mejor modelo ARIMA y genera predicciones.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "Configuracion", 
            status = "primary", 
            solidHeader = TRUE, 
            width = 3,
            
            selectInput("optimal_crypto", "Criptomoneda:", 
                        choices = CRYPTOS, selected = "BTC"),
            
            selectInput("optimal_criterion", "Criterio de seleccion:", 
                        choices = c("AIC" = "AIC", "BIC" = "BIC", "HQIC" = "HQIC"), 
                        selected = "AIC"),
            
            numericInput("optimal_max_pq", "Orden maximo (p,q):", 
                         value = 3, min = 1, max = 5),
            
            sliderInput("optimal_horizon", "Horizonte de prediccion (dias):", 
                        min = 7, max = 60, value = 30, step = 7),
            
            br(),
            
            actionButton("btn_optimal_prediction", "Ejecutar pipeline optimizado", 
                         class = "btn-success", width = "100%",
                         style = "font-weight:bold; background: linear-gradient(135deg, #2ecc71, #27ae60);")
          ),
          
          box(
            title = "Modelo seleccionado", 
            status = "success", 
            solidHeader = TRUE, 
            width = 3,
            uiOutput("optimal_model_info")
          ),
          
          box(
            title = "Prediccion", 
            status = "warning", 
            solidHeader = TRUE, 
            width = 3,
            valueBoxOutput("prediction_tomorrow_box", width = 12)
          ),
          
          box(
            title = "Grafico de prediccion", 
            status = "info", 
            solidHeader = TRUE, 
            width = 9,
            plotlyOutput("plot_optimal_forecast", height = "400px")
          )
        ),
        
        fluidRow(
          box(
            title = "Metricas del modelo", 
            status = "warning", 
            solidHeader = TRUE, 
            width = 4,
            helpText("Metricas evaluadas sobre el conjunto de prueba (ultimo 20% de los datos)."),
            DTOutput("optimal_metrics_table")
          ),
          
          box(
            title = "Comparacion con modelos baseline", 
            status = "info", 
            solidHeader = TRUE, 
            width = 4,
            helpText("Comparacion contra modelos Naive, Drift y Seasonal Naive."),
            DTOutput("optimal_baseline_table")
          ),
          
          box(
            title = "Diagnostico de residuos", 
            status = "danger", 
            solidHeader = TRUE, 
            width = 4,
            uiOutput("optimal_residuals_diagnostic")
          )
        ),
        
        fluidRow(
          box(
            title = "Tabla de predicciones", 
            status = "primary", 
            solidHeader = TRUE, 
            width = 12,
            helpText("Predicciones dia a dia con intervalos de confianza del 80% y 95%."),
            DTOutput("optimal_forecast_table")
          )
        )
      ),
      
      # ============================================================
      # PESTANA 9 - VALORES FALTANTES
      # ============================================================
      tabItem(
        tabName = "missing",
        tags$h2("Valores Faltantes (NAs)"),
        tags$p("Analisis de datos faltantes y metodos de imputacion disponibles.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(title = "Configuracion", status = "primary", solidHeader = TRUE, width = 3,
              selectInput("miss_crypto", "Criptomoneda:", choices = CRYPTOS, selected = "BTC"),
              selectInput("miss_method", "Metodo de imputacion:", 
                          choices = c("Interpolacion lineal" = "interpolation", "Media" = "mean", "Eliminar filas" = "remove")),
              br(),
              actionButton("btn_impute", "Aplicar imputacion", class = "btn-warning", width = "100%"),
              br(), br(),
              h5("Resumen de valores faltantes:"),
              DTOutput("tabla_missing")),
          
          box(title = "Comparacion: original vs imputado", status = "warning", solidHeader = TRUE, width = 9,
              plotlyOutput("plot_missing_compare", height = "400px"))
        ),
        
        fluidRow(
          box(title = "Mapa de calor: porcentaje de NAs", status = "info", solidHeader = TRUE, width = 12,
              plotlyOutput("plot_missing_heatmap", height = "500px"))
        )
      )
      
    ) # fin de tabItems
  ) # fin de dashboardBody
) # fin de dashboardPage