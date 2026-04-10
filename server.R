# ============================================================
# SERVER.R - EDA de Criptomonedas (10 monedas)
# ============================================================

server <- function(input, output, session) {
  
  # ============================================================
  # CAMBIO DE TEMA (CLARO/OSCURO)
  # ============================================================
  
  tema_actual <- reactiveVal("claro")
  
  observeEvent(input$cambiar_tema, {
    if (tema_actual() == "claro") {
      tema_actual("oscuro")
      session$sendCustomMessage("cambiar_tema", list(tema = "oscuro"))
      updateActionButton(session, "cambiar_tema",
                         label = tagList(icon("sun"), " Modo Claro"))
    } else {
      tema_actual("claro")
      session$sendCustomMessage("cambiar_tema", list(tema = "claro"))
      updateActionButton(session, "cambiar_tema",
                         label = tagList(icon("moon"), " Modo Oscuro"))
    }
  })
  
  # ============================================================
  # FILTRADO DE DATOS
  # ============================================================
  
  datos_periodo <- function(ndays, simbolo = NULL) {
    cutoff <- Sys.Date() - ndays
    d <- hist_data %>% filter(fecha >= cutoff)
    if (!is.null(simbolo)) d <- d %>% filter(simbolo == !!simbolo)
    d
  }
  
  # ============================================================
  # FUNCIONES ESTADÍSTICAS LOCALES
  # ============================================================
  
  test_stationarity <- function(serie, nombre = "") {
    serie_clean <- na.omit(serie)
    if (length(serie_clean) < 10) {
      return(list(es_estacionaria = FALSE, p_valor = NA, 
                  estadistico = NA, conclusion = "Datos insuficientes"))
    }
    tryCatch({
      adf_test <- adf.test(serie_clean, alternative = "stationary")
      es_estacionaria <- adf_test$p.value < 0.05
      return(list(
        es_estacionaria = es_estacionaria,
        p_valor = adf_test$p.value,
        estadistico = adf_test$statistic,
        conclusion = ifelse(es_estacionaria, "✓ Estacionaria", "✗ No estacionaria")
      ))
    }, error = function(e) {
      return(list(es_estacionaria = FALSE, p_valor = NA, 
                  estadistico = NA, conclusion = paste("Error:", e$message)))
    })
  }
  
  # ============================================================
  # VALUE BOXES - INTRO
  # ============================================================
  
  output$vbox_monedas <- renderValueBox({
    valueBox(length(CRYPTOS), "Criptomonedas", icon = icon("coins"), color = "yellow")
  })
  
  output$vbox_registros <- renderValueBox({
    valueBox(nrow(hist_data), "Registros Históricos", icon = icon("database"), color = "blue")
  })
  
  output$vbox_periodo <- renderValueBox({
    rango <- paste(format(min(hist_data$fecha), "%d/%m/%y"), "—", format(max(hist_data$fecha), "%d/%m/%y"))
    valueBox(tags$p(rango, style = "font-size: 16px;"), "Período (840 días)", icon = icon("calendar"), color = "green")
  })
  
  output$vbox_missing <- renderValueBox({
    valueBox(sum(is.na(hist_data)), "Valores Faltantes", icon = icon("exclamation-triangle"), color = "red")
  })
  
  # ============================================================
  # TAB 1 - VISIÓN GENERAL
  # ============================================================
  
  output$tabla_overview <- DT::renderDataTable({
    prices_overview %>%
      mutate(
        precio = dollar(precio, accuracy = 0.01),
        cambio_24h_pct = paste0(round(cambio_24h_pct, 2), "%"),
        volumen_24h = dollar(volumen_24h, accuracy = 1, scale = 1e-6, suffix = "M"),
        cap_mercado = dollar(cap_mercado, accuracy = 1, scale = 1e-9, suffix = "B")
      ) %>%
      rename(Símbolo = simbolo, `Precio USD` = precio, `Cambio 24h` = cambio_24h_pct,
             `Volumen 24h` = volumen_24h, `Cap. Mercado` = cap_mercado)
  }, options = list(pageLength = 10, dom = "t"), rownames = FALSE)
  
  output$plot_market_cap <- renderPlotly({
    df <- prices_overview %>% mutate(simbolo = factor(simbolo, levels = simbolo[order(cap_mercado)]))
    p <- ggplot(df, aes(x = simbolo, y = cap_mercado/1e9, fill = simbolo,
                        text = paste0(simbolo, ": $", round(cap_mercado/1e9, 1), "B"))) +
      geom_col(show.legend = FALSE) + 
      labs(x = "", y = "Cap. Mercado (miles de millones USD)") +
      theme_minimal() + 
      coord_flip()
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_volume <- renderPlotly({
    df <- prices_overview %>% mutate(simbolo = factor(simbolo, levels = simbolo[order(volumen_24h)]))
    p <- ggplot(df, aes(x = simbolo, y = volumen_24h/1e6, fill = simbolo,
                        text = paste0(simbolo, ": $", round(volumen_24h/1e6, 0), "M"))) +
      geom_col(show.legend = FALSE) + 
      labs(x = "", y = "Volumen 24h (millones USD)") +
      theme_minimal() + 
      coord_flip()
    ggplotly(p, tooltip = "text")
  })
  
  # ============================================================
  # TAB 2 - PRECIOS
  # ============================================================
  
  output$plot_boxplot_precios <- renderPlotly({
    req(input$sel_dias)
    cutoff <- Sys.Date() - input$sel_dias
    df <- hist_data %>% filter(fecha >= cutoff)
    
    p <- ggplot(df, aes(x = simbolo, y = close, fill = simbolo)) +
      geom_boxplot(alpha = 0.7, outlier.color = "#e74c3c", outlier.size = 2) +
      stat_summary(fun = "mean", geom = "point", shape = 18, size = 4, color = "white") +
      labs(title = paste("Boxplot de Precios - Últimos", input$sel_dias, "días"),
           x = "", y = "Precio (USD)") +
      scale_y_log10(labels = scales::dollar) +
      theme_minimal() +
      theme(legend.position = "none",
            plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p) %>% layout(showlegend = FALSE)
  })
  
  datos_precio <- reactive({
    req(input$sel_crypto_precio, input$sel_dias)
    datos_periodo(input$sel_dias, input$sel_crypto_precio) %>% arrange(fecha)
  })
  
  output$plot_precio_serie <- renderPlotly({
    df <- datos_precio()
    p <- ggplot(df, aes(x = fecha, y = close)) + 
      geom_line(color = "#e94560", linewidth = 0.8) +
      labs(title = paste(input$sel_crypto_precio, "- Precio de Cierre"), 
           x = "", y = "Precio (USD)") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$plot_candlestick <- renderPlotly({
    df <- datos_precio() %>% tail(60)
    plot_ly(df, x = ~fecha, type = "candlestick", 
            open = ~open, close = ~close, high = ~high, low = ~low,
            increasing = list(line = list(color = "#2ecc71")), 
            decreasing = list(line = list(color = "#e74c3c"))) %>%
      layout(title = paste("Candlestick -", input$sel_crypto_precio), 
             xaxis = list(title = ""), yaxis = list(title = "Precio (USD)"))
  })
  
  # ============================================================
  # TAB 3 - RETORNOS & RIESGO
  # ============================================================
  
  output$plot_boxplot_retornos <- renderPlotly({
    req(input$sel_dias_ret)
    cutoff <- Sys.Date() - input$sel_dias_ret
    df <- hist_data %>% filter(fecha >= cutoff)
    
    p <- ggplot(df, aes(x = simbolo, y = retorno, fill = simbolo)) +
      geom_boxplot(alpha = 0.7, outlier.color = "#e74c3c", outlier.size = 1.5) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      stat_summary(fun = "mean", geom = "point", shape = 18, size = 3, color = "white") +
      labs(title = paste("Boxplot de Retornos - Últimos", input$sel_dias_ret, "días"),
           x = "", y = "Retorno (%)") +
      theme_minimal() +
      theme(legend.position = "none",
            plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p) %>% layout(showlegend = FALSE)
  })
  
  datos_ret <- reactive({
    req(input$sel_crypto_ret, input$sel_dias_ret)
    datos_periodo(input$sel_dias_ret, input$sel_crypto_ret) %>%
      arrange(fecha) %>% 
      mutate(mes = floor_date(fecha, "month"))
  })
  
  output$plot_retornos <- renderPlotly({
    df <- datos_ret()
    tipo <- input$tipo_grafico_ret
    
    if (tipo == "hist") {
      p <- ggplot(df, aes(x = retorno)) + 
        geom_histogram(aes(fill = after_stat(x) > 0), bins = 50, alpha = 0.8) +
        scale_fill_manual(values = c(`TRUE` = "#2ecc71", `FALSE` = "#e74c3c")) +
        geom_vline(xintercept = 0, linetype = "dashed") +
        labs(title = "Distribución de Retornos", x = "Retorno (%)", y = "Frecuencia") +
        theme_minimal() + 
        theme(legend.position = "none")
    } else if (tipo == "serie") {
      p <- ggplot(df, aes(x = fecha, y = retorno, fill = retorno > 0)) + 
        geom_col(show.legend = FALSE) +
        scale_fill_manual(values = c(`TRUE` = "#2ecc71", `FALSE` = "#e74c3c")) +
        labs(title = "Retornos en el Tiempo", x = "", y = "Retorno (%)") + 
        theme_minimal()
    } else if (tipo == "boxplot") {
      df$mes_label <- format(df$mes, "%b %Y")
      p <- ggplot(df, aes(x = reorder(mes_label, mes), y = retorno)) + 
        geom_boxplot(fill = "#3498db", alpha = 0.7) +
        labs(title = "Boxplot por Mes", x = "", y = "Retorno (%)") + 
        theme_minimal() + 
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    } else {
      df$vol30 <- zoo::rollapply(df$retorno, 30, sd, fill = NA, align = "right")
      p <- ggplot(df, aes(x = fecha, y = vol30)) + 
        geom_line(color = "#e94560", linewidth = 0.8) + 
        geom_area(alpha = 0.2, fill = "#e94560") +
        labs(title = "Volatilidad Rodante 30 días", x = "", y = "Volatilidad (%)") + 
        theme_minimal()
    }
    ggplotly(p)
  })
  
  output$tabla_riesgo <- DT::renderDataTable({
    cutoff <- Sys.Date() - input$sel_dias_ret
    hist_data %>% 
      filter(fecha >= cutoff) %>% 
      group_by(simbolo) %>%
      summarise(
        `Retorno Medio (%)` = round(mean(retorno, na.rm = TRUE), 3),
        `Desv. Estándar (%)` = round(sd(retorno, na.rm = TRUE), 3),
        `VaR 95% (%)` = round(quantile(retorno, 0.05, na.rm = TRUE), 3),
        `% Días Positivos` = round(sum(retorno > 0, na.rm = TRUE) / n() * 100, 1)
      ) %>% 
      rename(Símbolo = simbolo)
  }, options = list(pageLength = 10, dom = "t"), rownames = FALSE)
  
  # ============================================================
  # TAB 4 - CORRELACIONES
  # ============================================================
  
  datos_corr <- reactive({
    req(input$sel_dias_corr, input$sel_cryptos_corr)
    cutoff <- Sys.Date() - input$sel_dias_corr
    hist_data %>% 
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_corr) %>%
      select(fecha, simbolo, retorno) %>% 
      pivot_wider(names_from = simbolo, values_from = retorno) %>% 
      select(-fecha)
  })
  
  output$plot_heatmap_corr <- renderPlotly({
    df_wide <- datos_corr()
    req(ncol(df_wide) >= 2)
    corr_mat <- cor(df_wide, use = "complete.obs", method = tolower(input$metodo_corr))
    df_long <- as.data.frame(as.table(corr_mat)) %>% 
      rename(Var1 = Var1, Var2 = Var2, Corr = Freq)
    
    p <- ggplot(df_long, aes(x = Var1, y = Var2, fill = Corr, 
                             text = paste0(Var1, " vs ", Var2, ": ", round(Corr, 3)))) +
      geom_tile(color = "white") + 
      geom_text(aes(label = round(Corr, 2)), size = 3) +
      scale_fill_gradient2(low = "#3498db", mid = "#f4f6f9", high = "#e74c3c", 
                           midpoint = 0, limits = c(-1, 1)) +
      labs(title = paste("Correlación de Retornos -", input$metodo_corr)) + 
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_scatter_corr <- renderPlotly({
    req(input$corr_x, input$corr_y, input$corr_x != input$corr_y)
    cutoff <- Sys.Date() - input$sel_dias_corr
    df <- hist_data %>% 
      filter(fecha >= cutoff, simbolo %in% c(input$corr_x, input$corr_y)) %>%
      select(fecha, simbolo, retorno) %>% 
      pivot_wider(names_from = simbolo, values_from = retorno) %>% 
      drop_na()
    
    p <- ggplot(df, aes(x = .data[[input$corr_x]], y = .data[[input$corr_y]])) +
      geom_point(alpha = 0.5, color = "#627EEA") + 
      geom_smooth(method = "lm", se = TRUE, color = "#e94560") +
      labs(title = paste("Dispersión:", input$corr_x, "vs", input$corr_y),
           x = paste("Retorno", input$corr_x, "(%)"), 
           y = paste("Retorno", input$corr_y, "(%)")) + 
      theme_minimal()
    ggplotly(p)
  })
  
  # ============================================================
  # TAB 5 - COMPARADOR
  # ============================================================
  
  datos_comp <- reactive({
    req(input$sel_cryptos_comp, input$sel_dias_comp)
    cutoff <- Sys.Date() - input$sel_dias_comp
    hist_data %>% 
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_comp) %>% 
      arrange(fecha) %>%
      group_by(simbolo) %>% 
      mutate(
        precio_ini = first(close), 
        rendim_base100 = close / precio_ini * 100,
        rendim_pct = (close - precio_ini) / precio_ini * 100
      ) %>% 
      ungroup()
  })
  
  output$plot_comparador <- renderPlotly({
    df <- datos_comp()
    yvar <- if (input$tipo_norm == "base100") "rendim_base100" else "rendim_pct"
    ylab <- if (input$tipo_norm == "base100") "Rendimiento (base 100)" else "Rendimiento acumulado (%)"
    
    p <- ggplot(df, aes(x = fecha, y = .data[[yvar]], color = simbolo)) + 
      geom_line(linewidth = 0.9) +
      labs(title = paste("Rendimiento Comparado - últimos", input$sel_dias_comp, "días"), 
           x = "", y = ylab, color = "Cripto") +
      theme_minimal()
    
    if (input$tipo_norm == "base100") p <- p + geom_hline(yintercept = 100, linetype = "dashed", color = "grey50")
    if (input$tipo_norm == "pct") p <- p + geom_hline(yintercept = 0, linetype = "dashed", color = "grey50")
    
    ggplotly(p)
  })
  
  output$tabla_comparador <- DT::renderDataTable({
    req(input$sel_cryptos_comp)
    cutoff <- Sys.Date() - input$sel_dias_comp
    hist_data %>% 
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_comp) %>% 
      group_by(simbolo) %>%
      summarise(
        `Precio Inicial` = round(first(close), 2), 
        `Precio Final` = round(last(close), 2),
        `Rendimiento %` = round((last(close) - first(close)) / first(close) * 100, 2),
        `Volatilidad %` = round(sd(retorno, na.rm = TRUE), 3)
      ) %>%
      rename(Símbolo = simbolo) %>% 
      arrange(desc(`Rendimiento %`))
  }, options = list(pageLength = 10, dom = "t"), rownames = FALSE)
  
  # ============================================================
  # TAB 6 - ANÁLISIS (EDA Avanzado)
  # ============================================================
  
  datos_analisis <- reactive({
    req(input$analisis_crypto, input$analisis_dias)
    df <- datos_periodo(input$analisis_dias, input$analisis_crypto) %>% arrange(fecha)
    var_name <- input$analisis_variable
    df$valor <- switch(var_name,
                       "close" = df$close,
                       "retorno" = df$retorno,
                       "retorno_log" = df$retorno_log,
                       "volatilidad" = df$volatilidad,
                       df$close)
    df
  })
  
  # BOXPLOT
  output$plot_analisis_boxplot <- renderPlotly({
    req(datos_analisis())
    df <- datos_analisis()
    var_names <- c("close" = "Precio", "retorno" = "Retorno", 
                   "retorno_log" = "Retorno Log", "volatilidad" = "Volatilidad")
    unidad <- ifelse(input$analisis_variable == "close", "USD", "%")
    
    p <- ggplot(df, aes(x = input$analisis_crypto, y = valor)) + 
      geom_boxplot(fill = "#3498db", alpha = 0.7, outlier.color = "#e74c3c", outlier.size = 2) +
      labs(title = paste("Boxplot de", var_names[input$analisis_variable], "-", input$analisis_crypto), 
           y = paste(var_names[input$analisis_variable], unidad), x = "") + 
      theme_minimal()
    
    ggplotly(p)
  })
  
  # SERIE TEMPORAL
  output$plot_analisis_serie <- renderPlotly({
    req(datos_analisis())
    df <- datos_analisis()
    var_names <- c("close" = "Precio", "retorno" = "Retorno", 
                   "retorno_log" = "Retorno Log", "volatilidad" = "Volatilidad")
    unidad <- ifelse(input$analisis_variable == "close", "USD", "%")
    
    p <- ggplot(df, aes(x = fecha, y = valor)) + 
      geom_line(color = "#e94560", linewidth = 0.8) + 
      geom_area(alpha = 0.3, fill = "#e94560") +
      labs(title = paste("Serie Temporal -", var_names[input$analisis_variable]), 
           x = "", y = paste(var_names[input$analisis_variable], unidad)) + 
      theme_minimal()
    
    ggplotly(p)
  })
  
  # BOXPLOT MENSUAL
  output$plot_analisis_boxplot_mensual <- renderPlotly({
    req(datos_analisis())
    df <- datos_analisis() %>%
      mutate(mes = floor_date(fecha, "month"),
             mes_label = format(mes, "%b %Y"))
    
    var_names <- c("close" = "Precio", "retorno" = "Retorno", 
                   "retorno_log" = "Retorno Log", "volatilidad" = "Volatilidad")
    unidad <- ifelse(input$analisis_variable == "close", "USD", "%")
    
    p <- ggplot(df, aes(x = reorder(mes_label, mes), y = valor)) + 
      geom_boxplot(fill = "#2ecc71", alpha = 0.7, outlier.color = "#e74c3c") +
      labs(title = paste("Boxplot Mensual -", var_names[input$analisis_variable]), 
           x = "Mes", y = paste(var_names[input$analisis_variable], unidad)) + 
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  # ACF
  output$plot_analisis_acf <- renderPlotly({
    req(datos_analisis())
    serie <- na.omit(datos_analisis()$valor)
    if (length(serie) < 10) return(NULL)
    
    acf_result <- acf(serie, plot = FALSE, lag.max = min(50, length(serie)/3))
    df_acf <- data.frame(Lag = acf_result$lag, ACF = acf_result$acf)
    ci <- qnorm((1 + 0.95)/2) / sqrt(length(serie))
    
    p <- ggplot(df_acf, aes(x = Lag, y = ACF)) + 
      geom_bar(stat = "identity", fill = "#3498db", alpha = 0.7) +
      geom_hline(yintercept = c(ci, -ci), linetype = "dashed", color = "red") +
      labs(title = "Función de Autocorrelación (ACF)", 
           subtitle = "ρ(k) = Cov(Y_t, Y_{t-k}) / Var(Y_t)",
           x = "Rezago (días)", y = "Autocorrelación") + 
      theme_minimal()
    ggplotly(p)
  })
  
  # PACF
  output$plot_analisis_pacf <- renderPlotly({
    req(datos_analisis())
    serie <- na.omit(datos_analisis()$valor)
    if (length(serie) < 10) return(NULL)
    
    pacf_result <- pacf(serie, plot = FALSE, lag.max = min(50, length(serie)/3))
    df_pacf <- data.frame(Lag = pacf_result$lag, PACF = pacf_result$acf)
    ci <- qnorm((1 + 0.95)/2) / sqrt(length(serie))
    
    p <- ggplot(df_pacf, aes(x = Lag, y = PACF)) + 
      geom_bar(stat = "identity", fill = "#e74c3c", alpha = 0.7) +
      geom_hline(yintercept = c(ci, -ci), linetype = "dashed", color = "blue") +
      labs(title = "Función de Autocorrelación Parcial (PACF)", 
           subtitle = "φ_{kk} = correlación parcial entre Y_t y Y_{t-k}",
           x = "Rezago (días)", y = "Autocorrelación Parcial") + 
      theme_minimal()
    ggplotly(p)
  })
  
  # DESCOMPOSICIÓN STL
  output$plot_analisis_decomposition <- renderPlotly({
    req(datos_analisis())
    serie <- na.omit(datos_analisis()$valor)
    
    if (length(serie) < 365) {
      p <- ggplot() + 
        annotate("text", x = 0.5, y = 0.5, 
                 label = paste("⚠️ Se necesitan al menos 365 días.\nActualmente hay", length(serie), "días."), 
                 size = 5, color = "red") + 
        theme_void()
      return(ggplotly(p))
    }
    
    tryCatch({
      ts_serie <- ts(serie, frequency = 7, start = c(1, 1))
      decomp <- stl(ts_serie, s.window = "periodic", robust = TRUE)
      
      df_decomp <- data.frame(
        fecha = datos_analisis()$fecha[1:length(decomp$time.series[, "trend"])],
        Observado = serie[1:length(decomp$time.series[, "trend"])],
        Tendencia = as.numeric(decomp$time.series[, "trend"]),
        Estacional = as.numeric(decomp$time.series[, "seasonal"]),
        Residuo = as.numeric(decomp$time.series[, "remainder"])
      ) %>% pivot_longer(cols = -fecha, names_to = "Componente", values_to = "valor")
      
      p <- ggplot(df_decomp, aes(x = fecha, y = valor, color = Componente)) + 
        geom_line(linewidth = 0.7) +
        facet_wrap(~Componente, scales = "free_y", ncol = 1) +
        scale_color_manual(values = c("Observado" = "#2c3e50", "Tendencia" = "#e74c3c", 
                                      "Estacional" = "#3498db", "Residuo" = "#2ecc71")) +
        labs(title = "Descomposición STL de la Serie Temporal", 
             subtitle = "Ecuación: Y(t) = T(t) + S(t) + R(t) | T = Tendencia, S = Estacionalidad, R = Residuo",
             x = "", y = "") + 
        theme_minimal() + 
        theme(legend.position = "none")
      
      ggplotly(p) %>% layout(height = 600)
    }, error = function(e) {
      p <- ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = paste("Error:", e$message), size = 4) + 
        theme_void()
      ggplotly(p)
    })
  })
  
  # ESTADÍSTICAS DESCRIPTIVAS
  output$analisis_stats_html <- renderUI({
    req(datos_analisis())
    serie <- na.omit(datos_analisis()$valor)
    
    media <- round(mean(serie), 2)
    mediana <- round(median(serie), 2)
    desviacion <- round(sd(serie), 2)
    minimo <- round(min(serie), 2)
    maximo <- round(max(serie), 2)
    q1 <- round(quantile(serie, 0.25), 2)
    q3 <- round(quantile(serie, 0.75), 2)
    n <- length(serie)
    
    var_names <- c("close" = "Precio Cierre", "retorno" = "Retorno Diario", 
                   "retorno_log" = "Retorno Logarítmico", "volatilidad" = "Volatilidad")
    unidad <- ifelse(input$analisis_variable == "close", "USD", "%")
    
    div(style = "background: #f8f9fa; padding: 20px; border-radius: 10px;",
        h4(icon("chart-line"), "Estadísticas Descriptivas", style = "color: #2c3e50; margin-bottom: 20px;"),
        
        div(style = "background: #e8e8e8; padding: 10px; border-radius: 8px; margin-bottom: 20px;",
            p(style = "font-family: monospace; font-size: 12px; margin: 0;",
              "📐 Media: μ = (1/n) Σ xᵢ | Desv. Estándar: σ = √[(1/n) Σ (xᵢ - μ)²]"
            )
        ),
        
        fluidRow(
          column(6, div(style = "background: white; padding: 15px; border-radius: 8px; margin-bottom: 10px;",
                        p(style = "color: #7f8c8d; margin: 0;", "📊 Media (μ)"),
                        h3(style = "color: #e94560; margin: 5px 0;", paste(media, unidad))
          )),
          column(6, div(style = "background: white; padding: 15px; border-radius: 8px; margin-bottom: 10px;",
                        p(style = "color: #7f8c8d; margin: 0;", "📊 Mediana"),
                        h3(style = "color: #3498db; margin: 5px 0;", paste(mediana, unidad))
          ))
        ),
        fluidRow(
          column(6, div(style = "background: white; padding: 15px; border-radius: 8px; margin-bottom: 10px;",
                        p(style = "color: #7f8c8d; margin: 0;", "📊 Desviación Estándar (σ)"),
                        h3(style = "color: #2ecc71; margin: 5px 0;", paste(desviacion, unidad))
          )),
          column(6, div(style = "background: white; padding: 15px; border-radius: 8px; margin-bottom: 10px;",
                        p(style = "color: #7f8c8d; margin: 0;", "📊 Rango Intercuartil (IQR)"),
                        h3(style = "color: #9b59b6; margin: 5px 0;", paste(q3 - q1, unidad))
          ))
        ),
        fluidRow(
          column(12, div(style = "background: white; padding: 15px; border-radius: 8px;",
                         p(style = "color: #7f8c8d; margin: 0;", "📊 Rango"),
                         h3(style = "color: #f39c12; margin: 5px 0;", paste(minimo, "-", maximo, unidad)),
                         p(style = "color: #95a5a6; margin: 0; font-size: 11px;", paste("Número de observaciones:", n))
          ))
        )
    )
  })
  
  # PRUEBA ADF
  output$analisis_stationarity_html <- renderUI({
    req(datos_analisis())
    serie <- na.omit(datos_analisis()$valor)
    
    tryCatch({
      adf_test <- adf.test(serie, alternative = "stationary")
      es_estacionaria <- adf_test$p.value < 0.05
      color <- ifelse(es_estacionaria, "#2ecc71", "#e74c3c")
      icono <- ifelse(es_estacionaria, "check-circle", "exclamation-triangle")
      texto <- ifelse(es_estacionaria, "✓ La serie ES estacionaria", "✗ La serie NO es estacionaria")
      
      div(style = "background: #f8f9fa; padding: 20px; border-radius: 10px;",
          h4(icon("flask"), "Prueba de Dickey-Fuller Aumentado (ADF)", style = "color: #2c3e50;"),
          
          div(style = "background: #e8e8e8; padding: 10px; border-radius: 8px; margin-bottom: 20px;",
              p(style = "font-family: monospace; font-size: 12px; margin: 0;",
                "📐 Ecuación: Δyₜ = α + βt + γyₜ₋₁ + δ₁Δyₜ₋₁ + ... + εₜ"
              ),
              p(style = "font-family: monospace; font-size: 11px; margin: 5px 0 0 0; color: #555;",
                "H₀: γ = 0 (raíz unitaria, NO estacionaria) | H₁: γ < 0 (estacionaria)"
              )
          ),
          
          fluidRow(
            column(6, div(style = "background: white; padding: 15px; border-radius: 8px;",
                          p(style = "color: #7f8c8d; margin: 0;", "📊 Estadístico ADF"),
                          h4(style = paste("color:", color), round(adf_test$statistic, 4))
            )),
            column(6, div(style = "background: white; padding: 15px; border-radius: 8px;",
                          p(style = "color: #7f8c8d; margin: 0;", "📊 Valor p"),
                          h4(style = paste("color:", color), round(adf_test$p.value, 6))
            ))
          ),
          br(),
          div(style = paste("background:", color, "20; padding: 12px; border-radius: 8px; border-left: 4px solid", color),
              h5(icon(icono), texto, style = paste("color:", color)),
              p(style = "color: #555; font-size: 13px;",
                ifelse(es_estacionaria, 
                       "✅ La serie rechaza H₀ (p < 0.05). No tiene raíz unitaria. Es apta para modelado.",
                       "⚠️ La serie NO rechaza H₀ (p ≥ 0.05). Tiene raíz unitaria. Se recomienda diferenciación (d=1).")
              )
          )
      )
    }, error = function(e) {
      div(style = "background: #f8f9fa; padding: 20px; border-radius: 10px;",
          h4(icon("flask"), "Prueba ADF", style = "color: #2c3e50;"),
          div(style = "background: #fff3cd; padding: 15px; border-radius: 8px;",
              p("⚠️ No se pudo realizar la prueba. Datos insuficientes.")
          )
      )
    })
  })
  
  # TABLA DE ESTACIONARIEDAD
  output$tabla_analisis_stationarity <- DT::renderDataTable({
    req(input$analisis_dias)
    cutoff <- Sys.Date() - input$analisis_dias
    var_name <- input$analisis_variable
    var_col <- switch(var_name, 
                      "close" = "close", 
                      "retorno" = "retorno", 
                      "retorno_log" = "retorno_log", 
                      "volatilidad" = "volatilidad", 
                      "close")
    
    resultados <- lapply(unique(hist_data$simbolo), function(crypto) {
      df_crypto <- hist_data %>% filter(simbolo == crypto, fecha >= cutoff)
      if (nrow(df_crypto) < 10) {
        return(data.frame(Criptomoneda = crypto, `¿Estacionaria?` = "⚠️ Insuficientes", `Valor p` = NA, Recomendación = NA))
      }
      serie <- na.omit(df_crypto[[var_col]])
      if (length(serie) < 10) {
        return(data.frame(Criptomoneda = crypto, `¿Estacionaria?` = "⚠️ Insuficientes", `Valor p` = NA, Recomendación = NA))
      }
      
      tryCatch({
        adf_test <- adf.test(serie, alternative = "stationary")
        es_estacionaria <- adf_test$p.value < 0.05
        data.frame(
          Criptomoneda = crypto,
          `¿Estacionaria?` = ifelse(es_estacionaria, "✅ Sí", "❌ No"),
          `Valor p` = round(adf_test$p.value, 6),
          Recomendación = ifelse(es_estacionaria, "Apta para modelado", "Requiere diferenciación (d=1)")
        )
      }, error = function(e) {
        data.frame(Criptomoneda = crypto, `¿Estacionaria?` = "⚠️ Error", `Valor p` = NA, Recomendación = "No se pudo calcular")
      })
    }) %>% bind_rows()
    
    DT::datatable(resultados, options = list(pageLength = 10, dom = "t"), rownames = FALSE)
  })
  
  # INFORMACIÓN ARIMA
  output$analisis_arima_info_html <- renderUI({
    div(style = "background: #f8f9fa; padding: 20px; border-radius: 10px;",
        h4(icon("chart-line"), "Modelado Predictivo con ARIMA", style = "color: #2c3e50;"),
        
        div(style = "background: #e8e8e8; padding: 10px; border-radius: 8px; margin-bottom: 20px;",
            p(style = "font-family: monospace; font-size: 12px; margin: 0; font-weight: bold;",
              "📐 Ecuación del modelo ARIMA(p,d,q):"
            ),
            p(style = "font-family: monospace; font-size: 13px; margin: 10px 0; text-align: center;",
              "φ(B)(1-B)ᵈ yₜ = θ(B) εₜ"
            ),
            p(style = "font-family: monospace; font-size: 11px; margin: 5px 0 0 0; color: #555;",
              "donde: φ(B) = 1 - φ₁B - φ₂B² - ... - φₚBᵖ (parte AR)")
        ),
        
        p("ARIMA es un modelo estadístico para predicción de series temporales:"),
        tags$ul(
          tags$li(tags$strong("AR (p)"), ": Orden autoregresivo - yₜ = φ₁yₜ₋₁ + ... + φₚyₜ₋ₚ + εₜ"),
          tags$li(tags$strong("I (d)"), ": Diferenciación - (1-B)ᵈ yₜ para hacer la serie estacionaria"),
          tags$li(tags$strong("MA (q)"), ": Media móvil - yₜ = εₜ + θ₁εₜ₋₁ + ... + θ_qεₜ₋q")
        ),
        hr(),
        h5(icon("bullseye"), "🎯 Objetivo del Proyecto", style = "color: #e94560;"),
        p("El objetivo final es desarrollar un modelo predictivo robusto que permita estimar los precios futuros de criptomonedas utilizando ARIMA y técnicas avanzadas de series temporales."),
        hr(),
        p(style = "color: #7f8c8d; font-size: 12px; font-style: italic;",
          "📌 Los modelos ARIMA completos se implementarán en la siguiente fase del proyecto.")
    )
  })
  
}