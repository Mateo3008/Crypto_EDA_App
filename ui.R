# ============================================================
# UI.R - EDA de Criptomonedas | Crypto Dashboard
# ============================================================

library(shiny)
library(shinydashboard)

# Definición de criptomonedas (debe estar antes de dashboardPage)
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
    
    # Botón GitHub en el header (lado derecho)
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
    
    # Badge "Live Data"
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
    width = 260,
    tags$div(
      style = "padding: 12px 0 4px 0; text-align:center;",
      tags$span(
        style = "font-size:10px; color:#95a5a6; letter-spacing:2px; text-transform:uppercase;",
        "Navegación"
      )
    ),
    sidebarMenu(
      id = "main_menu",
      menuItem("Introducción",       tabName = "intro",       icon = icon("house")),
      menuItem("Visión General",     tabName = "overview",    icon = icon("gauge")),
      menuItem("Precios",            tabName = "precios",     icon = icon("chart-line")),
      menuItem("Retornos & Riesgo",  tabName = "retornos",    icon = icon("percent")),
      menuItem("Correlaciones",      tabName = "correlacion", icon = icon("table-cells")),
      menuItem("Comparador",         tabName = "comparador",  icon = icon("sliders")),
      menuItem("Análisis",           tabName = "analisis",    icon = icon("chart-simple"))
    ),
    
    tags$hr(style = "border-color:rgba(255,255,255,0.1); margin:10px 15px;"),
    
    # Botón tema
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
    
    # Card de monedas activas
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
    
    # Enlace GitHub en sidebar también
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
    
    # Contenedor de partículas (fondo)
    tags$div(
      id    = "particles-js",
      style = "position:fixed; top:0; left:0; width:100%; height:100%; z-index:0; pointer-events:none;"
    ),
    
    tags$head(
      # Librerías externas
      tags$script(src = "https://cdn.jsdelivr.net/particles.js/2.0.0/particles.min.js"),
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"),
      
      # ============================
      # CSS COMPLETO
      # ============================
      tags$style(HTML("

        /* ===== RESET & BASE ===== */
        *, *::before, *::after { box-sizing: border-box; }

        /* ===== SCROLLBAR PERSONALIZADA ===== */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); border-radius: 10px; }
        ::-webkit-scrollbar-thumb {
          background: linear-gradient(180deg, #F7931A, #627EEA);
          border-radius: 10px;
        }
        ::-webkit-scrollbar-thumb:hover { background: linear-gradient(180deg, #627EEA, #F7931A); }

        /* ===== TEMA CLARO (default) ===== */
        body,
        .content-wrapper,
        .right-side {
          background-color: #F5F7FA !important;
          color: #2c3e50 !important;
          transition: background 0.4s ease, color 0.4s ease;
        }

        .skin-blue .main-header .logo,
        .skin-blue .main-header .navbar {
          background-color: #1a1a2e !important;
          border-bottom: 1px solid rgba(247,147,26,0.3) !important;
        }

        .skin-blue .main-sidebar {
          background: linear-gradient(180deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%) !important;
        }

        .skin-blue .sidebar a,
        .skin-blue .sidebar-menu > li > a {
          color: #bdc3c7 !important;
          transition: all 0.25s ease;
        }

        .skin-blue .sidebar-menu > li.active > a,
        .skin-blue .sidebar-menu > li > a:hover {
          color: #F7931A !important;
          background: rgba(247,147,26,0.12) !important;
          border-left: 3px solid #F7931A !important;
        }

        /* ===== TEMA OSCURO ===== */
        body.dark-mode,
        body.dark-mode .content-wrapper,
        body.dark-mode .right-side {
          background: linear-gradient(135deg, #0a0e1a 0%, #0f1322 100%) !important;
          color: #e0e6ed !important;
        }

        body.dark-mode .box,
        body.dark-mode .small-box {
          background: rgba(15,19,34,0.60) !important;
          color: #e0e6ed !important;
          border-color: rgba(98,126,234,0.18) !important;
        }

        body.dark-mode .box .box-header .box-title,
        body.dark-mode h1, body.dark-mode h2,
        body.dark-mode h3, body.dark-mode h4,
        body.dark-mode h5, body.dark-mode p,
        body.dark-mode label, body.dark-mode .control-label {
          color: #e0e6ed !important;
        }

        body.dark-mode .dataTables_wrapper,
        body.dark-mode table.dataTable tbody tr {
          color: #bdc3c7 !important;
          background: transparent !important;
        }

        body.dark-mode .form-control,
        body.dark-mode .selectize-input,
        body.dark-mode .selectize-dropdown {
          background: rgba(26,26,46,0.9) !important;
          color: #e0e6ed !important;
          border-color: rgba(98,126,234,0.3) !important;
        }

        body.dark-mode .irs--shiny .irs-bar { background: #F7931A !important; }
        body.dark-mode .irs--shiny .irs-handle { background: #627EEA !important; }

        /* ===== GLASSMORPHISM BOXES (más transparentes para ver partículas) ===== */
        .box {
          background: rgba(255,255,255,0.55) !important;
          backdrop-filter: blur(8px) !important;
          -webkit-backdrop-filter: blur(8px) !important;
          border: 1px solid rgba(255,255,255,0.45) !important;
          border-radius: 14px !important;
          box-shadow: 0 6px 24px rgba(0,0,0,0.07), 0 1px 6px rgba(0,0,0,0.04) !important;
          transition: transform 0.3s ease, box-shadow 0.3s ease, background 0.3s ease !important;
          display: flex;
          flex-direction: column;
          overflow: visible;
          position: relative;
          z-index: 1;
        }

        .box:hover {
          transform: translateY(-5px) scale(1.01);
          box-shadow: 0 20px 50px rgba(0,0,0,0.14), 0 6px 20px rgba(247,147,26,0.08) !important;
        }

        .box-header {
          border-radius: 14px 14px 0 0 !important;
          padding: 12px 18px !important;
        }

        .box-body {
          flex: 1;
          overflow: visible;
          padding: 15px !important;
        }

        /* ===== LED ANIMADO EN TÍTULOS ===== */
        .box-header .box-title::before {
          content: '';
          display: inline-block;
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: #2ecc71;
          margin-right: 8px;
          vertical-align: middle;
          animation: pulseLed 1.8s ease-in-out infinite;
          box-shadow: 0 0 6px #2ecc71, 0 0 12px rgba(46,204,113,0.4);
        }

        @keyframes pulseLed {
          0%,100% { opacity: 1; transform: scale(1); box-shadow: 0 0 6px #2ecc71; }
          50%      { opacity: 0.4; transform: scale(0.7); box-shadow: 0 0 2px #2ecc71; }
        }

        /* ===== VALUE BOXES MEJORADOS ===== */
        .small-box {
          border-radius: 14px !important;
          overflow: hidden;
          backdrop-filter: blur(8px) !important;
          transition: transform 0.3s ease, box-shadow 0.3s ease !important;
        }

        .small-box:hover {
          transform: translateY(-6px) scale(1.02);
          box-shadow: 0 16px 40px rgba(0,0,0,0.2) !important;
        }

        .small-box h3 { font-weight: 800 !important; letter-spacing: -0.5px; }

        /* ===== TOOLTIPS FLOTANTES NEÓN ===== */
        [data-tooltip] {
          position: relative;
          cursor: help;
        }

        [data-tooltip]::before {
          content: attr(data-tooltip);
          position: absolute;
          bottom: calc(100% + 10px);
          left: 50%;
          transform: translateX(-50%) translateY(5px);
          background: linear-gradient(135deg, #1a1a2e, #0f3460);
          color: #00d4ff;
          padding: 7px 14px;
          border-radius: 8px;
          font-size: 12px;
          font-weight: 600;
          white-space: nowrap;
          pointer-events: none;
          opacity: 0;
          border: 1px solid rgba(0,212,255,0.4);
          box-shadow: 0 0 14px rgba(0,212,255,0.3);
          transition: all 0.25s ease;
          z-index: 9999;
          letter-spacing: 0.3px;
        }

        [data-tooltip]:hover::before {
          opacity: 1;
          transform: translateX(-50%) translateY(0);
        }

        /* ===== PLOTLY CONTAINERS ===== */
        .plotly, .js-plotly-plot {
          width: 100% !important;
          overflow: visible !important;
        }

        /* ===== ANIMACIÓN DE ENTRADA ===== */
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(24px); }
          to   { opacity: 1; transform: translateY(0); }
        }

        .tab-content .tab-pane.active {
          animation: fadeInUp 0.5s ease-out;
        }

        /* ===== INPUTS ESTILIZADOS ===== */
        .form-control, .selectize-input {
          border-radius: 8px !important;
          border: 1px solid rgba(0,0,0,0.12) !important;
          transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-control:focus, .selectize-input.focus {
          border-color: #627EEA !important;
          box-shadow: 0 0 0 3px rgba(98,126,234,0.15) !important;
          outline: none !important;
        }

        .irs--shiny .irs-bar {
          background: linear-gradient(90deg, #F7931A, #627EEA) !important;
          border-color: transparent !important;
        }

        .irs--shiny .irs-handle {
          background: white !important;
          border: 2px solid #F7931A !important;
          box-shadow: 0 2px 8px rgba(247,147,26,0.4) !important;
        }

        /* ===== CHECKBOXES PERSONALIZADOS ===== */
        .checkbox input[type='checkbox']:checked + span::before {
          background: #F7931A;
          border-color: #F7931A;
        }

        /* ===== DATATABLES ===== */
        table.dataTable {
          border-radius: 8px;
          overflow: hidden;
        }

        table.dataTable thead {
          background: linear-gradient(135deg, #1a1a2e, #0f3460) !important;
          color: white !important;
        }

        table.dataTable thead th {
          color: white !important;
          font-weight: 700 !important;
          letter-spacing: 0.3px;
        }

        table.dataTable tbody tr:hover {
          background: rgba(247,147,26,0.06) !important;
        }

        /* ===== BOTÓN TEMA ===== */
        #cambiar_tema:hover {
          background: linear-gradient(135deg, #F7931A, #627EEA) !important;
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(247,147,26,0.4) !important;
        }

        /* ===== CARD CRYPTO TICKER (Intro) ===== */
        .crypto-ticker {
          display: flex;
          gap: 10px;
          flex-wrap: wrap;
          margin-bottom: 16px;
        }

        .ticker-card {
          flex: 1;
          min-width: 80px;
          padding: 10px 14px;
          background: linear-gradient(135deg, rgba(247,147,26,0.1), rgba(98,126,234,0.1));
          border-radius: 10px;
          border: 1px solid rgba(247,147,26,0.2);
          text-align: center;
          transition: all 0.25s ease;
          cursor: default;
        }

        .ticker-card:hover {
          background: linear-gradient(135deg, rgba(247,147,26,0.2), rgba(98,126,234,0.2));
          border-color: rgba(247,147,26,0.5);
          transform: translateY(-3px);
        }

        .ticker-card .ticker-sym {
          font-weight: 800;
          font-size: 15px;
          color: #F7931A;
          letter-spacing: 0.5px;
        }

        .ticker-card .ticker-name {
          font-size: 10px;
          color: #7f8c8d;
          margin-top: 2px;
        }

        /* ===== BADGE DE AUTORÍA ===== */
        .author-badge {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 8px 16px;
          background: linear-gradient(135deg, #1a1a2e, #0f3460);
          border-radius: 30px;
          color: white;
          font-size: 13px;
          font-weight: 600;
          border: 1px solid rgba(247,147,26,0.3);
          text-decoration: none;
          transition: all 0.3s ease;
        }

        .author-badge:hover {
          background: linear-gradient(135deg, #F7931A, #627EEA);
          color: white;
          text-decoration: none;
          box-shadow: 0 6px 20px rgba(247,147,26,0.4);
          transform: translateY(-2px);
        }

        /* ===== EQUATION BOX ===== */
        .eq-box {
          background: linear-gradient(135deg, rgba(15,19,34,0.06), rgba(98,126,234,0.06));
          border: 1px solid rgba(98,126,234,0.2);
          border-left: 4px solid #627EEA;
          border-radius: 10px;
          padding: 14px 18px;
          margin: 10px 0;
          font-family: 'Courier New', monospace;
          font-size: 13px;
          overflow-x: auto;
        }

        body.dark-mode .eq-box {
          background: rgba(98,126,234,0.08);
          color: #a8c4ff;
        }

        /* ===== SECTION HEADERS ===== */
        h2 {
          font-weight: 800 !important;
          letter-spacing: -0.5px !important;
          background: linear-gradient(135deg, #F7931A, #627EEA) !important;
          -webkit-background-clip: text !important;
          -webkit-text-fill-color: transparent !important;
          background-clip: text !important;
          margin-bottom: 6px !important;
        }

        body.dark-mode h2 {
          -webkit-text-fill-color: transparent !important;
        }

        /* ===== STATUS BAR COLORES ===== */
        .box.box-primary   > .box-header { background: linear-gradient(135deg,#2980b9,#3498db) !important; }
        .box.box-success   > .box-header { background: linear-gradient(135deg,#27ae60,#2ecc71) !important; }
        .box.box-warning   > .box-header { background: linear-gradient(135deg,#e67e22,#F7931A) !important; }
        .box.box-danger    > .box-header { background: linear-gradient(135deg,#c0392b,#e74c3c) !important; }
        .box.box-info      > .box-header { background: linear-gradient(135deg,#16a085,#1abc9c) !important; }

        .box.box-primary   > .box-header .box-title,
        .box.box-success   > .box-header .box-title,
        .box.box-warning   > .box-header .box-title,
        .box.box-danger    > .box-header .box-title,
        .box.box-info      > .box-header .box-title {
          color: white !important;
        }

        /* ===== NOTIFICATION BADGE ===== */
        .neon-badge {
          display: inline-block;
          padding: 3px 10px;
          border-radius: 20px;
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 0.5px;
          text-transform: uppercase;
        }

        .neon-badge.green {
          background: rgba(46,204,113,0.15);
          color: #2ecc71;
          border: 1px solid rgba(46,204,113,0.4);
          box-shadow: 0 0 8px rgba(46,204,113,0.2);
        }

        .neon-badge.orange {
          background: rgba(247,147,26,0.15);
          color: #F7931A;
          border: 1px solid rgba(247,147,26,0.4);
          box-shadow: 0 0 8px rgba(247,147,26,0.2);
        }

        .neon-badge.blue {
          background: rgba(98,126,234,0.15);
          color: #627EEA;
          border: 1px solid rgba(98,126,234,0.4);
          box-shadow: 0 0 8px rgba(98,126,234,0.2);
        }

        /* ===== CONTENT WRAPPER z-index ===== */
        .content-wrapper {
          position: relative;
          z-index: 1;
        }

        /* ===== LINK STYLES ===== */
        a { transition: color 0.2s ease; }

        /* ===== INTRO HERO ===== */
        .intro-hero {
          background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
          border-radius: 18px;
          padding: 40px;
          margin-bottom: 20px;
          position: relative;
          overflow: hidden;
          color: white;
        }

        .intro-hero::before {
          content: '';
          position: absolute;
          top: -50%;
          right: -10%;
          width: 300px;
          height: 300px;
          background: radial-gradient(circle, rgba(247,147,26,0.15) 0%, transparent 70%);
          border-radius: 50%;
        }

        .intro-hero::after {
          content: '';
          position: absolute;
          bottom: -30%;
          left: 20%;
          width: 200px;
          height: 200px;
          background: radial-gradient(circle, rgba(98,126,234,0.15) 0%, transparent 70%);
          border-radius: 50%;
        }
      ")),
      
      # ============================
      # JAVASCRIPT
      # ============================
      tags$script(HTML("

        // ============================================================
        // CAMBIO DE TEMA
        // ============================================================
        Shiny.addCustomMessageHandler('cambiar_tema', function(msg) {
          if(msg.tema === 'oscuro') {
            document.body.classList.add('dark-mode');
            localStorage.setItem('crypto_eda_tema', 'oscuro');
          } else {
            document.body.classList.remove('dark-mode');
            localStorage.setItem('crypto_eda_tema', 'claro');
          }
        });

        document.addEventListener('DOMContentLoaded', function() {
          var temaGuardado = localStorage.getItem('crypto_eda_tema');
          if(temaGuardado === 'oscuro') document.body.classList.add('dark-mode');
        });

        // ============================================================
        // PARTICLES.JS
        // ============================================================
        document.addEventListener('DOMContentLoaded', function() {
          if(typeof particlesJS !== 'undefined') {
            particlesJS('particles-js', {
              particles: {
                number: { value: 80, density: { enable: true, value_area: 800 } },
                color: { value: ['#F7931A','#627EEA','#00d4ff','#e94560','#2ecc71'] },
                shape: { type: 'circle' },
                opacity: {
                  value: 0.5, random: true,
                  anim: { enable: true, speed: 0.8, opacity_min: 0.15, sync: false }
                },
                size: {
                  value: 3.5, random: true,
                  anim: { enable: true, speed: 1.5, size_min: 1, sync: false }
                },
                line_linked: {
                  enable: true, distance: 140,
                  color: '#627EEA', opacity: 0.35, width: 1
                },
                move: {
                  enable: true, speed: 1.2, direction: 'none',
                  random: true, straight: false, out_mode: 'out',
                  bounce: false,
                  attract: { enable: true, rotateX: 600, rotateY: 1200 }
                }
              },
              interactivity: {
                detect_on: 'canvas',
                events: {
                  onhover: { enable: true, mode: 'grab' },
                  onclick:  { enable: false },
                  resize: true
                },
                modes: { grab: { distance: 140, line_linked: { opacity: 0.7 } } }
              },
              retina_detect: true
            });
          }
        });

        // ============================================================
        // PARALLAX CON MOUSE
        // ============================================================
        document.addEventListener('mousemove', function(e) {
          var px = (e.clientX / window.innerWidth  - 0.5) * 12;
          var py = (e.clientY / window.innerHeight - 0.5) * 12;
          var pd = document.getElementById('particles-js');
          if(pd) pd.style.transform = 'translate(' + px + 'px,' + py + 'px)';
        });

        // ============================================================
        // ANIMACIÓN DE TRAZADO (DRAW ANIMATION) EN GRÁFICOS PLOTLY
        // Se activa al aparecer el gráfico y al cambiar sliders/selects
        // ============================================================

        // Función principal: anima líneas, barras, etc. usando Plotly.animate
        function animatePlotlyDraw(plotDiv) {
          if(!plotDiv || !plotDiv._fullData) return;

          var data = plotDiv._fullData;
          var isLine  = data.some(function(t){ return t.type === 'scatter' || t.type === 'scattergl'; });
          var isBar   = data.some(function(t){ return t.type === 'bar'; });
          var isCandle = data.some(function(t){ return t.type === 'candlestick'; });

          // ---- Animación de líneas: dibujar de izquierda a derecha ----
          if(isLine && !isCandle) {
            var traces = [];
            data.forEach(function(trace, i) {
              if((trace.type === 'scatter' || trace.type === 'scattergl') && trace.x && trace.y) {
                var n = trace.x.length;
                var steps = Math.min(n, 60);
                var frames = [];
                for(var s = 1; s <= steps; s++) {
                  var idx = Math.floor((s / steps) * n);
                  frames.push({
                    data: [{ x: trace.x.slice(0,idx), y: trace.y.slice(0,idx) }],
                    traces: [i]
                  });
                }
                traces.push({ frames: frames, traceIdx: i });
              }
            });

            if(traces.length > 0) {
              // Construir frames combinados (todos los traces a la vez)
              var maxFrames = 0;
              traces.forEach(function(t){ maxFrames = Math.max(maxFrames, t.frames.length); });
              var combinedFrames = [];
              for(var f = 0; f < maxFrames; f++) {
                var frameData = [];
                var frameTraces = [];
                traces.forEach(function(t) {
                  var fi = Math.min(f, t.frames.length - 1);
                  frameData.push(t.frames[fi].data[0]);
                  frameTraces.push(t.traceIdx);
                });
                combinedFrames.push({ data: frameData, traces: frameTraces });
              }
              try {
                Plotly.addFrames(plotDiv, combinedFrames);
                Plotly.animate(plotDiv, null, {
                  transition: { duration: 0 },
                  frame: { duration: 18, redraw: false },
                  mode: 'immediate'
                });
              } catch(e) {}
            }
          }

          // ---- Animación de barras: crecer desde 0 ----
          if(isBar) {
            var barFrames = [];
            var steps = 30;
            for(var s = 1; s <= steps; s++) {
              var frac = s / steps;
              var fd = [];
              var ft = [];
              data.forEach(function(trace, i) {
                if(trace.type === 'bar' && trace.y) {
                  fd.push({ y: trace.y.map(function(v){ return v * frac; }) });
                  ft.push(i);
                }
              });
              if(fd.length) barFrames.push({ data: fd, traces: ft });
            }
            if(barFrames.length) {
              try {
                Plotly.addFrames(plotDiv, barFrames);
                Plotly.animate(plotDiv, null, {
                  transition: { duration: 0 },
                  frame: { duration: 20, redraw: false },
                  mode: 'immediate'
                });
              } catch(e) {}
            }
          }
        }

        // ---- Fade-in + animación de trazado al aparecer ----
        function onChartAppear(el) {
          if(!el || el.dataset.cryptoAnimated) return;
          el.dataset.cryptoAnimated = '1';
          el.style.opacity = '0';
          el.style.transform = 'translateY(18px)';
          el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          setTimeout(function() {
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
            // Esperar a que Plotly termine de renderizar antes de animar
            setTimeout(function(){ animatePlotlyDraw(el); }, 300);
          }, 80);
        }

        // ---- Observer para detectar nuevos gráficos ----
        var chartObserver = new MutationObserver(function(mutations) {
          mutations.forEach(function(m) {
            m.addedNodes.forEach(function(node) {
              if(node.nodeType !== 1) return;
              if(node.classList && node.classList.contains('js-plotly-plot')) {
                onChartAppear(node);
              }
              node.querySelectorAll && node.querySelectorAll('.js-plotly-plot').forEach(onChartAppear);
            });
          });
        });

        document.addEventListener('DOMContentLoaded', function() {
          chartObserver.observe(document.body, { childList: true, subtree: true });
        });

        // ---- Re-animar cuando un gráfico Shiny se actualiza (output re-render) ----
        // Shiny dispara shiny:value en cada output re-renderizado
        document.addEventListener('shiny:value', function(e) {
          // Pequeño delay para que el DOM se actualice
          setTimeout(function() {
            var outputId = e.target && e.target.id;
            if(!outputId) return;
            var container = document.getElementById(outputId);
            if(!container) return;
            var plots = container.querySelectorAll('.js-plotly-plot');
            plots.forEach(function(plot) {
              // Reset la marca para que se reanime
              delete plot.dataset.cryptoAnimated;
              onChartAppear(plot);
            });
          }, 150);
        });

        // ---- Ticker animado ----
        window.addEventListener('load', function() {
          var badge = document.getElementById('live-ticker-txt');
          if(!badge) return;
          var msgs = ['Datos en tiempo real', 'CryptoCompare API', '10 monedas \u00b7 1905 d\u00edas'];
          var idx = 0;
          setInterval(function() {
            idx = (idx + 1) % msgs.length;
            badge.style.opacity = '0';
            setTimeout(function() {
              badge.textContent = msgs[idx];
              badge.style.opacity = '1';
            }, 300);
          }, 3000);
        });
      "))
    ), # fin tags$head
    
    # ============================================================
    # TABS
    # ============================================================
    tabItems(
      
      # ----------------------------------------------------------------
      # TAB 0 - INTRODUCCIÓN
      # ----------------------------------------------------------------
      tabItem(
        tabName = "intro",
        
        # Hero banner
        tags$div(
          class = "intro-hero",
          fluidRow(
            column(8,
                   tags$h1(
                     "📊 Crypto EDA",
                     style = "font-size:36px; font-weight:900; margin:0 0 8px; color:white; -webkit-text-fill-color:white !important;"
                   ),
                   tags$p(
                     "Análisis Exploratorio de Datos de Criptomonedas",
                     style = "font-size:16px; color:rgba(255,255,255,0.75); margin:0 0 16px;"
                   ),
                   tags$div(
                     style = "display:flex; gap:10px; flex-wrap:wrap;",
                     tags$span(class = "neon-badge green", "✓ Datos Reales"),
                     tags$span(class = "neon-badge orange", "⚡ CryptoCompare API"),
                     tags$span(class = "neon-badge blue", "📅 1905 Días de Historia"),
                     tags$a(
                       href = "https://github.com/Mateo3008/Crypto_EDA_App",
                       target = "_blank",
                       style = paste0(
                         "display:inline-flex; align-items:center; gap:6px;",
                         "padding:4px 14px; border-radius:20px; font-size:11px;",
                         "font-weight:700; text-transform:uppercase; letter-spacing:0.5px;",
                         "background:rgba(255,255,255,0.1); color:white;",
                         "border:1px solid rgba(255,255,255,0.3); text-decoration:none;",
                         "transition:all 0.3s ease;"
                       ),
                       onmouseover = "this.style.background='rgba(247,147,26,0.3)'; this.style.borderColor='#F7931A';",
                       onmouseout  = "this.style.background='rgba(255,255,255,0.1)'; this.style.borderColor='rgba(255,255,255,0.3)';",
                       icon("github"), "GitHub"
                     )
                   )
            ),
            column(4,
                   tags$div(
                     style = "text-align:right; padding-top:10px;",
                     tags$div(
                       style = paste0(
                         "display:inline-block; padding:16px 24px;",
                         "background:rgba(255,255,255,0.07); border-radius:14px;",
                         "border:1px solid rgba(255,255,255,0.12);"
                       ),
                       tags$div(
                         style = "font-size:11px; color:rgba(255,255,255,0.5); margin-bottom:6px;",
                         "Última actualización"
                       ),
                       tags$div(
                         id = "live-ticker-txt",
                         style = "font-size:13px; color:#F7931A; font-weight:700; transition:opacity 0.3s;",
                         "Datos en tiempo real"
                       )
                     )
                   )
            )
          )
        ),
        
        # Value boxes
        fluidRow(
          valueBoxOutput("vbox_monedas",   width = 3),
          valueBoxOutput("vbox_registros", width = 3),
          valueBoxOutput("vbox_periodo",   width = 3),
          valueBoxOutput("vbox_missing",   width = 3)
        ),
        
        # Ticker de monedas
        fluidRow(
          box(
            title = "🪙 Criptomonedas Analizadas", status = "warning",
            solidHeader = TRUE, width = 12,
            tags$div(
              class = "crypto-ticker",
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "BTC"),  tags$div(class = "ticker-name", "Bitcoin")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "ETH"),  tags$div(class = "ticker-name", "Ethereum")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "USDC"), tags$div(class = "ticker-name", "USD Coin")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "SOL"),  tags$div(class = "ticker-name", "Solana")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "XRP"),  tags$div(class = "ticker-name", "Ripple")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "TAO"),  tags$div(class = "ticker-name", "Bittensor")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "USDT"), tags$div(class = "ticker-name", "Tether")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "DOGE"), tags$div(class = "ticker-name", "Dogecoin")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "USD1"), tags$div(class = "ticker-name", "USD1")),
              tags$div(class = "ticker-card", tags$div(class = "ticker-sym", "ZEC"),  tags$div(class = "ticker-name", "Zcash"))
            )
          )
        ),
        
        fluidRow(
          # Objetivo
          box(
            title = "🎯 Objetivo del Proyecto", status = "primary",
            solidHeader = TRUE, width = 6,
            tags$p(
              "El presente proyecto tiene como objetivo desarrollar un",
              tags$strong("Análisis Exploratorio de Datos (EDA) exhaustivo"),
              " para el mercado de criptomonedas, con miras a la implementación de modelos",
              " predictivos de series temporales.",
              style = "line-height:1.75; margin-bottom:12px;"
            ),
            tags$p(
              "Este dashboard interactivo permite explorar el comportamiento histórico de las",
              " principales criptomonedas, identificar patrones, outliers y relaciones entre activos,",
              " utilizando datos reales obtenidos desde la API de CryptoCompare (1905 días históricos).",
              style = "line-height:1.75; margin-bottom:12px;"
            ),
            tags$p(
              "Se analizan precios, retornos, correlaciones y se aplican técnicas avanzadas de",
              " series temporales: descomposición STL, pruebas de estacionariedad ADF y modelado ARIMA.",
              style = "line-height:1.75;"
            ),
            tags$hr(style = "border-color:rgba(0,0,0,0.08);"),
            tags$div(
              style = "display:flex; align-items:center; gap:12px;",
              tags$a(
                href = "https://github.com/Mateo3008/Crypto_EDA_App",
                target = "_blank",
                class = "author-badge",
                icon("github"), "Ver en GitHub"
              ),
              tags$span(
                style = "font-size:12px; color:#7f8c8d;",
                "Mateo3008 · Crypto EDA App"
              )
            )
          ),
          
          # Ecuaciones LaTeX (MathJax)
          box(
            title = "📐 Ecuaciones Principales", status = "info",
            solidHeader = TRUE, width = 6,
            tags$div(
              class = "eq-box",
              tags$strong("Retorno simple:"),
              tags$div(
                style = "text-align:center; padding:6px 0;",
                tags$span("$$r_t = \\frac{P_t - P_{t-1}}{P_{t-1}} \\times 100$$")
              )
            ),
            tags$div(
              class = "eq-box",
              tags$strong("Retorno logarítmico:"),
              tags$div(
                style = "text-align:center; padding:6px 0;",
                tags$span("$$r_t^{\\log} = \\ln\\!\\left(\\frac{P_t}{P_{t-1}}\\right) \\times 100$$")
              )
            ),
            tags$div(
              class = "eq-box",
              tags$strong("Descomposición STL:"),
              tags$div(
                style = "text-align:center; padding:6px 0;",
                tags$span("$$Y(t) = T(t) + S(t) + R(t)$$")
              )
            ),
            tags$div(
              class = "eq-box",
              tags$strong("Modelo ARIMA(p,d,q):"),
              tags$div(
                style = "text-align:center; padding:6px 0;",
                tags$span("$$\\varphi(B)(1-B)^d\\, y_t = \\theta(B)\\,\\varepsilon_t$$")
              )
            ),
            tags$div(
              class = "eq-box",
              tags$strong("Value at Risk (VaR 95%):"),
              tags$div(
                style = "text-align:center; padding:6px 0;",
                tags$span("$$\\text{VaR}_{95\\%} = Q_{0.05}\\,(r_t)$$")
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "👥 Autores & Tecnologías", status = "success",
            solidHeader = TRUE, width = 12,
            fluidRow(
              column(6,
                     tags$h5("👨‍💻 Equipo de Desarrollo", style = "font-weight:700; margin-bottom:14px;"),
                     
                     # Autor 1 - Mateo Barrios
                     tags$div(
                       style = "display:flex; align-items:center; gap:12px; margin-bottom:14px;",
                       tags$div(
                         style = paste0(
                           "width:46px; height:46px; border-radius:50%; flex-shrink:0;",
                           "background:linear-gradient(135deg,#F7931A,#627EEA);",
                           "display:flex; align-items:center; justify-content:center;",
                           "font-size:18px; color:white; font-weight:900;",
                           "box-shadow:0 4px 12px rgba(247,147,26,0.35);"
                         ),
                         "MB"
                       ),
                       tags$div(
                         tags$div(tags$strong("Mateo Barrios"), style = "font-size:14px; margin-bottom:2px;"),
                         tags$div(
                           style = "font-size:11px; color:#7f8c8d; margin-bottom:3px;",
                           "Ciencia de Datos"
                         ),
                         tags$a(
                           href = "https://github.com/Mateo3008/Crypto_EDA_App",
                           target = "_blank",
                           style = "color:#627EEA; font-size:11px; text-decoration:none;",
                           icon("github"), " Mateo3008"
                         )
                       )
                     ),
                     
                     # Autor 2 - Rafael Romero
                     tags$div(
                       style = "display:flex; align-items:center; gap:12px;",
                       tags$div(
                         style = paste0(
                           "width:46px; height:46px; border-radius:50%; flex-shrink:0;",
                           "background:linear-gradient(135deg,#627EEA,#00d4ff);",
                           "display:flex; align-items:center; justify-content:center;",
                           "font-size:18px; color:white; font-weight:900;",
                           "box-shadow:0 4px 12px rgba(98,126,234,0.35);"
                         ),
                         "RR"
                       ),
                       tags$div(
                         tags$div(tags$strong("Rafael Romero"), style = "font-size:14px; margin-bottom:2px;"),
                         tags$div(
                           style = "font-size:11px; color:#7f8c8d; margin-bottom:3px;",
                           "Ciencia de Datos"
                         ),
                         tags$a(
                           href = "https://github.com/rafaelromero06",
                           target = "_blank",
                           style = "color:#627EEA; font-size:11px; text-decoration:none;",
                           icon("github"), " rafaelromero06"
                         )
                       )
                     )
              ),
              column(6,
                     tags$h5("🛠️ Stack Tecnológico", style = "font-weight:700; margin-bottom:10px;"),
                     tags$div(
                       style = "display:flex; flex-wrap:wrap; gap:8px;",
                       lapply(
                         c("R", "Shiny", "shinydashboard", "plotly", "ggplot2",
                           "DT", "forecast", "tseries", "tidyverse", "CryptoCompare API"),
                         function(tech) {
                           tags$span(
                             tech,
                             style = paste0(
                               "padding:4px 12px; border-radius:20px; font-size:11px;",
                               "font-weight:700; background:rgba(98,126,234,0.12);",
                               "color:#627EEA; border:1px solid rgba(98,126,234,0.25);"
                             )
                           )
                         }
                       )
                     )
              )
            )
          )
        )
      ), # fin intro
      
      # ----------------------------------------------------------------
      # TAB 1 - VISIÓN GENERAL
      # ----------------------------------------------------------------
      tabItem(
        tabName = "overview",
        tags$h2("🌐 Visión General del Mercado"),
        tags$p("Panorama actual de las criptomonedas: precios, capitalización y volumen de mercado.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "📋 Tabla de Precios Actuales", status = "primary",
            solidHeader = TRUE, width = 12,
            DT::dataTableOutput("tabla_overview")
          )
        ),
        
        fluidRow(
          box(
            title = "💹 Capitalización de Mercado (USD)", status = "warning",
            solidHeader = TRUE, width = 6,
            plotlyOutput("plot_market_cap", height = "400px", width = "100%")
          ),
          box(
            title = "📊 Volumen de Negociación 24h (USD)", status = "info",
            solidHeader = TRUE, width = 6,
            plotlyOutput("plot_volume", height = "400px", width = "100%")
          )
        )
      ), # fin overview
      
      # ----------------------------------------------------------------
      # TAB 2 - PRECIOS
      # ----------------------------------------------------------------
      tabItem(
        tabName = "precios",
        tags$h2("💰 Análisis de Precios"),
        tags$p("Exploración de la distribución histórica y evolución temporal de los precios.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "🎨 Boxplot de Precios por Criptomoneda (Cajas y Bigotes)",
            status = "primary", solidHeader = TRUE, width = 12,
            sliderInput(
              "sel_dias", "Período de análisis (días):",
              min = 30, max = 1095, value = 365, step = 30,
              width = "100%"
            ),
            plotlyOutput("plot_boxplot_precios", height = "400px", width = "100%")
          )
        ),
        
        fluidRow(
          box(
            title = "📈 Serie Temporal del Precio de Cierre", status = "warning",
            solidHeader = TRUE, width = 6,
            selectInput(
              "sel_crypto_precio", "Criptomoneda:",
              choices = CRYPTOS, selected = "BTC"
            ),
            plotlyOutput("plot_precio_serie", height = "400px", width = "100%")
          ),
          box(
            title = "🕯️ Gráfico de Velas (Candlestick) — Últimos 60 días",
            status = "info", solidHeader = TRUE, width = 6,
            plotlyOutput("plot_candlestick", height = "400px", width = "100%")
          )
        )
      ), # fin precios
      
      # ----------------------------------------------------------------
      # TAB 3 - RETORNOS & RIESGO
      # ----------------------------------------------------------------
      tabItem(
        tabName = "retornos",
        tags$h2("📉 Retornos & Riesgo"),
        tags$p("Distribución de retornos diarios, volatilidad histórica y métricas de riesgo.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "🎨 Boxplot de Retornos por Criptomoneda (Cajas y Bigotes)",
            status = "danger", solidHeader = TRUE, width = 12,
            sliderInput(
              "sel_dias_ret", "Período (días):",
              min = 30, max = 1095, value = 365, step = 30,
              width = "100%"
            ),
            plotlyOutput("plot_boxplot_retornos", height = "500px", width = "100%")
          )
        ),
        
        fluidRow(
          box(
            title = "📊 Visualización de Retornos", status = "success",
            solidHeader = TRUE, width = 8,
            fluidRow(
              column(6,
                     selectInput(
                       "sel_crypto_ret", "Criptomoneda:",
                       choices = CRYPTOS, selected = "BTC"
                     )
              ),
              column(6,
                     selectInput(
                       "tipo_grafico_ret", "Tipo de gráfico:",
                       choices = c(
                         "Histograma de Retornos"   = "hist",
                         "Retornos en el Tiempo"    = "serie",
                         "Boxplot por Mes"          = "boxplot",
                         "Volatilidad Rodante 30d"  = "vol_rodante"
                       )
                     )
              )
            ),
            plotlyOutput("plot_retornos", height = "400px", width = "100%")
          ),
          box(
            title = "📋 Métricas de Riesgo", status = "info",
            solidHeader = TRUE, width = 4,
            tags$p(
              "VaR 95%: máxima pérdida esperada en el 95% de los días.",
              style = "font-size:12px; color:#7f8c8d; margin-bottom:10px;"
            ),
            DT::dataTableOutput("tabla_riesgo")
          )
        )
      ), # fin retornos
      
      # ----------------------------------------------------------------
      # TAB 4 - CORRELACIONES
      # ----------------------------------------------------------------
      tabItem(
        tabName = "correlacion",
        tags$h2("🔗 Matriz de Correlaciones"),
        tags$p("Correlación entre retornos diarios de las distintas criptomonedas.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "⚙️ Configuración", status = "primary",
            solidHeader = TRUE, width = 3,
            sliderInput(
              "sel_dias_corr", "Período (días):",
              min = 30, max = 1095, value = 365, step = 30
            ),
            selectInput(
              "metodo_corr", "Método:",
              choices = c("Pearson", "Spearman")
            ),
            tags$hr(style = "border-color:rgba(0,0,0,0.08);"),
            checkboxGroupInput(
              "sel_cryptos_corr", "Criptomonedas:",
              choices = CRYPTOS, selected = CRYPTOS
            )
          ),
          box(
            title = "🌡️ Mapa de Calor — Correlación de Retornos",
            status = "warning", solidHeader = TRUE, width = 9,
            plotlyOutput("plot_heatmap_corr", height = "500px", width = "100%")
          )
        ),
        
        fluidRow(
          box(
            title = "🔵 Dispersión de Retornos entre Dos Monedas",
            status = "info", solidHeader = TRUE, width = 12,
            fluidRow(
              column(3,
                     selectInput("corr_x", "Eje X:", choices = CRYPTOS, selected = "BTC")
              ),
              column(3,
                     selectInput("corr_y", "Eje Y:", choices = CRYPTOS, selected = "ETH")
              ),
              column(6,
                     plotlyOutput("plot_scatter_corr", height = "350px", width = "100%")
              )
            )
          )
        )
      ), # fin correlacion
      
      # ----------------------------------------------------------------
      # TAB 5 - COMPARADOR
      # ----------------------------------------------------------------
      tabItem(
        tabName = "comparador",
        tags$h2("⚖️ Comparador de Rendimiento"),
        tags$p("Compara el rendimiento acumulado normalizado de múltiples criptomonedas en el mismo período.",
               style = "color:#7f8c8d; margin-bottom:20px;"),
        
        fluidRow(
          box(
            title = "⚙️ Configuración", status = "primary",
            solidHeader = TRUE, width = 3,
            checkboxGroupInput(
              "sel_cryptos_comp", "Selecciona monedas:",
              choices = CRYPTOS, selected = c("BTC", "ETH")
            ),
            tags$hr(style = "border-color:rgba(0,0,0,0.08);"),
            sliderInput(
              "sel_dias_comp", "Período (días):",
              min = 30, max = 1095, value = 365, step = 30
            ),
            radioButtons(
              "tipo_norm", "Normalización:",
              choices = c(
                "Base 100 (inicio = 100)" = "base100",
                "Retorno acumulado (%)"   = "pct"
              )
            )
          ),
          box(
            title = "📈 Rendimiento Acumulado Comparado",
            status = "success", solidHeader = TRUE, width = 9,
            plotlyOutput("plot_comparador", height = "400px", width = "100%")
          )
        ),
        
        fluidRow(
          box(
            title = "📋 Resumen Estadístico Comparativo",
            status = "info", solidHeader = TRUE, width = 12,
            DT::dataTableOutput("tabla_comparador")
          )
        )
      ), # fin comparador
      
      # ----------------------------------------------------------------
      # TAB 6 - ANÁLISIS EDA AVANZADO
      # ----------------------------------------------------------------
      tabItem(
        tabName = "analisis",
        tags$h2("🔬 Análisis Exploratorio Avanzado"),
        tags$p(
          "Series temporales, boxplots, descomposición STL, funciones ACF/PACF,",
          " pruebas de estacionariedad (ADF) y preparación para modelado ARIMA.",
          style = "color:#7f8c8d; margin-bottom:20px;"
        ),
        
        # Config panel
        fluidRow(
          box(
            title = "⚙️ Configuración del Análisis", status = "primary",
            solidHeader = TRUE, width = 12,
            fluidRow(
              column(3,
                     selectInput(
                       "analisis_crypto", "Criptomoneda:",
                       choices = CRYPTOS, selected = "BTC"
                     )
              ),
              column(3,
                     sliderInput(
                       "analisis_dias", "Días a analizar:",
                       min = 90, max = 1095, value = 365, step = 30
                     )
              ),
              column(3,
                     selectInput(
                       "analisis_variable", "Variable:",
                       choices = c(
                         "Precio Cierre (USD)"       = "close",
                         "Retorno Diario (%)"        = "retorno",
                         "Retorno Logarítmico (%)"   = "retorno_log",
                         "Volatilidad Diaria (%)"    = "volatilidad"
                       )
                     )
              ),
              column(3,
                     numericInput(
                       "arima_max_order",
                       "Orden máximo ARIMA (p,q):",
                       value = 5, min = 1, max = 10
                     )
              )
            )
          )
        ),
        
        # Boxplot general
        fluidRow(
          box(
            title = "🎨 Boxplot (Cajas y Bigotes)", status = "primary",
            solidHeader = TRUE, width = 12,
            tags$p(
              "El boxplot muestra la distribución: la caja es el rango intercuartil (IQR),",
              " la línea central es la mediana, los bigotes son los límites (1.5 × IQR) y los puntos son outliers.",
              style = "font-size:12px; color:#7f8c8d;"
            ),
            plotlyOutput("plot_analisis_boxplot", height = "400px", width = "100%")
          )
        ),
        
        # Serie + Boxplot mensual
        fluidRow(
          box(
            title = "📈 Serie Temporal", status = "success",
            solidHeader = TRUE, width = 6,
            plotlyOutput("plot_analisis_serie", height = "350px", width = "100%")
          ),
          box(
            title = "📊 Boxplot Mensual", status = "warning",
            solidHeader = TRUE, width = 6,
            plotlyOutput("plot_analisis_boxplot_mensual", height = "350px", width = "100%")
          )
        ),
        
        # ACF + PACF
        fluidRow(
          box(
            title = "📊 ACF — Función de Autocorrelación", status = "info",
            solidHeader = TRUE, width = 6,
            tags$p(
              "Mide la correlación entre la serie y sus valores rezagados.",
              " Ayuda a identificar el orden MA(q).",
              style = "font-size:12px; color:#7f8c8d;"
            ),
            plotlyOutput("plot_analisis_acf", height = "350px", width = "100%")
          ),
          box(
            title = "📊 PACF — Autocorrelación Parcial", status = "info",
            solidHeader = TRUE, width = 6,
            tags$p(
              "Mide la correlación parcial entre la serie y sus rezagos.",
              " Ayuda a identificar el orden AR(p).",
              style = "font-size:12px; color:#7f8c8d;"
            ),
            plotlyOutput("plot_analisis_pacf", height = "350px", width = "100%")
          )
        ),
        
        # Stats descriptivas + ADF (ANTES de STL)
        fluidRow(
          box(
            title = "📊 Estadísticas Descriptivas", status = "success",
            solidHeader = TRUE, width = 6,
            uiOutput("analisis_stats_html")
          ),
          box(
            title = "🔬 Prueba de Estacionariedad (ADF)", status = "warning",
            solidHeader = TRUE, width = 6,
            uiOutput("analisis_stationarity_html")
          )
        ),
        
        # STL Decomp (su propio fluidRow, después de Stats)
        fluidRow(
          box(
            title = "🔄 Descomposición STL de la Serie Temporal",
            status = "primary", solidHeader = TRUE, width = 12,
            tags$p(
              "Descompone la serie en Tendencia (T), Estacionalidad (S) y Residuo (R).",
              " Ecuación: Y(t) = T(t) + S(t) + R(t).",
              " Se requieren al menos 365 días para la descomposición.",
              style = "font-size:12px; color:#7f8c8d;"
            ),
            plotlyOutput("plot_analisis_decomposition", height = "500px", width = "100%")
          )
        ),
        
        # Tabla comparativa estacionariedad
        fluidRow(
          box(
            title = "📋 Comparativa de Estacionariedad entre Monedas",
            status = "info", solidHeader = TRUE, width = 12,
            tags$p(
              "La prueba ADF (Dickey-Fuller Aumentado) evalúa si una serie es estacionaria.",
              " Valor p < 0.05 indica estacionariedad (apta para modelado).",
              style = "font-size:12px; color:#7f8c8d;"
            ),
            DT::dataTableOutput("tabla_analisis_stationarity")
          )
        ),
        
        # ARIMA info
        fluidRow(
          box(
            title = "🤖 Modelado Predictivo con ARIMA", status = "danger",
            solidHeader = TRUE, width = 12,
            uiOutput("analisis_arima_info_html")
          )
        )
      ) # fin analisis
      
    ) # fin tabItems
  ) # fin dashboardBody
) # fin dashboardPage