# ============================================================
# SERVER.R - EDA de Criptomonedas | Crypto Dashboard
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
  # FUNCIONES AUXILIARES
  # ============================================================
  
  datos_periodo <- function(ndays, simbolo = NULL) {
    last_date <- max(hist_data$fecha, na.rm = TRUE)
    cutoff <- last_date - ndays
    d <- hist_data %>% filter(fecha >= cutoff)
    if (!is.null(simbolo)) d <- d %>% filter(simbolo == !!simbolo)
    d
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
    valueBox(tags$p(rango, style = "font-size: 14px;"), "Periodo (1905 dias)", icon = icon("calendar"), color = "green")
  })
  
  output$vbox_missing <- renderValueBox({
    valueBox(sum(is.na(hist_data)), "Valores Faltantes", icon = icon("exclamation-triangle"), color = "red")
  })
  
  # ============================================================
  # VALORES FALTANTES
  # ============================================================
  
  output$tabla_missing <- renderDT({
    df <- hist_data %>% filter(simbolo == input$miss_crypto)
    ms <- missing_summary(df)
    if (nrow(ms) == 0) ms <- data.frame(Variable = "(sin NAs)", NAs = 0, Pct = 0)
    datatable(ms, rownames = FALSE, options = list(dom = "t", pageLength = 15))
  })
  
  datos_imputados <- reactiveVal(NULL)
  
  observeEvent(input$btn_impute, {
    df <- hist_data %>% filter(simbolo == input$miss_crypto)
    df_imp <- handle_missing(df, method = input$miss_method)
    datos_imputados(df_imp)
    showNotification("Imputacion aplicada.", type = "message", duration = 4)
  })
  
  output$plot_missing_compare <- renderPlotly({
    df_orig <- hist_data %>% filter(simbolo == input$miss_crypto) %>% arrange(fecha)
    df_imp <- datos_imputados()
    
    p <- ggplot(df_orig, aes(x = fecha, y = close)) +
      geom_line(color = "#bdc3c7", linewidth = 0.7, na.rm = TRUE) +
      labs(x = NULL, y = "Precio cierre (USD)", title = paste(input$miss_crypto, "— Original (gris) vs Imputado (rojo)")) +
      theme_minimal()
    
    if (!is.null(df_imp)) {
      p <- p + geom_line(data = df_imp, aes(x = fecha, y = close), color = "#e74c3c", linewidth = 0.8)
    }
    ggplotly(p)
  })
  
  output$plot_missing_heatmap <- renderPlotly({
    cols <- c("close", "retorno", "retorno_log", "volatilidad")
    df_heat <- hist_data %>%
      group_by(simbolo) %>%
      summarise(across(all_of(intersect(cols, names(hist_data))),
                       ~ sum(is.na(.)) / n() * 100, .names = "{.col}")) %>%
      pivot_longer(-simbolo, names_to = "Variable", values_to = "pct_na")
    
    p <- ggplot(df_heat, aes(x = Variable, y = simbolo, fill = pct_na,
                             text = paste0(simbolo, " · ", Variable, ": ", round(pct_na, 2), "%"))) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "white", high = "#e74c3c", name = "% NA") +
      labs(x = NULL, y = NULL, title = "% de valores faltantes por moneda y variable") +
      theme_minimal()
    ggplotly(p, tooltip = "text")
  })
  
  # ============================================================
  # VISION GENERAL
  # ============================================================
  
  output$tabla_overview <- renderDT({
    prices_overview %>%
      mutate(
        precio = dollar(precio, accuracy = 0.01),
        cambio_24h_pct = paste0(round(cambio_24h_pct, 2), "%"),
        volumen_24h = dollar(volumen_24h, accuracy = 1, scale = 1e-6, suffix = "M"),
        cap_mercado = dollar(cap_mercado, accuracy = 1, scale = 1e-9, suffix = "B")
      ) %>%
      rename(Symbol = simbolo, `Precio USD` = precio, `Cambio 24h` = cambio_24h_pct,
             `Volumen 24h` = volumen_24h, `Cap. Mercado` = cap_mercado) %>%
      datatable(rownames = FALSE, options = list(pageLength = 10, dom = "t"))
  })
  
  output$plot_market_cap <- renderPlotly({
    df <- prices_overview %>% mutate(simbolo = reorder(simbolo, cap_mercado))
    p <- ggplot(df, aes(x = simbolo, y = cap_mercado / 1e9, fill = simbolo,
                        text = paste0(simbolo, ": $", round(cap_mercado / 1e9, 1), "B"))) +
      geom_col(show.legend = FALSE) + coord_flip() + theme_minimal() +
      labs(x = NULL, y = "Cap. Mercado (miles de millones USD)")
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_volume <- renderPlotly({
    df <- prices_overview %>% mutate(simbolo = reorder(simbolo, volumen_24h))
    p <- ggplot(df, aes(x = simbolo, y = volumen_24h / 1e6, fill = simbolo,
                        text = paste0(simbolo, ": $", round(volumen_24h / 1e6, 0), "M"))) +
      geom_col(show.legend = FALSE) + coord_flip() + theme_minimal() +
      labs(x = NULL, y = "Volumen 24h (millones USD)")
    ggplotly(p, tooltip = "text")
  })
  
  # ============================================================
  # PRECIOS
  # ============================================================
  
  output$plot_boxplot_precios <- renderPlotly({
    df <- datos_periodo(input$sel_dias)
    p <- ggplot(df, aes(x = simbolo, y = close, fill = simbolo)) +
      geom_boxplot(alpha = 0.7, outlier.color = "#e74c3c", outlier.size = 2) +
      stat_summary(fun = "mean", geom = "point", shape = 18, size = 4, color = "white") +
      scale_y_log10(labels = dollar) + coord_flip() + theme_minimal() +
      labs(x = NULL, y = "Precio USD (escala log)") + theme(legend.position = "none")
    ggplotly(p)
  })
  
  datos_precio_sel <- reactive({
    req(input$sel_crypto_precio, input$sel_dias)
    datos_periodo(input$sel_dias, input$sel_crypto_precio) %>% arrange(fecha)
  })
  
  output$plot_precio_serie <- renderPlotly({
    df <- datos_precio_sel()
    p <- ggplot(df, aes(x = fecha, y = close)) +
      geom_line(color = "#e94560", linewidth = 0.8) +
      labs(x = NULL, y = "Precio (USD)") + theme_minimal()
    ggplotly(p)
  })
  
  output$plot_candlestick <- renderPlotly({
    df <- datos_precio_sel() %>% tail(60)
    plot_ly(df, x = ~fecha, type = "candlestick",
            open = ~open, close = ~close, high = ~high, low = ~low,
            increasing = list(line = list(color = "#2ecc71")),
            decreasing = list(line = list(color = "#e74c3c"))) %>%
      layout(xaxis = list(title = ""), yaxis = list(title = "Precio (USD)"))
  })
  
  # Bandas de Bollinger
  datos_bollinger <- reactive({
    req(input$bb_crypto, input$bb_period, input$bb_sd)
    df <- datos_periodo(1095, input$bb_crypto) %>% arrange(fecha)
    
    if (nrow(df) < input$bb_period) return(NULL)
    
    bb <- calculate_bollinger_bands(df$close, window = input$bb_period, sd_mult = input$bb_sd)
    df <- cbind(df, bb)
    df %>% drop_na(sma, upper, lower)
  })
  
  output$plot_bollinger_bands <- renderPlotly({
    df <- datos_bollinger()
    req(df)
    
    p <- ggplot(df, aes(x = fecha)) +
      geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#3498db", alpha = 0.2) +
      geom_line(aes(y = close, color = "Precio"), linewidth = 0.8) +
      geom_line(aes(y = sma, color = "SMA"), linetype = "dashed", linewidth = 0.6) +
      geom_line(aes(y = upper, color = "Banda Superior"), linetype = "dotted", linewidth = 0.6) +
      geom_line(aes(y = lower, color = "Banda Inferior"), linetype = "dotted", linewidth = 0.6) +
      scale_color_manual(values = c("Precio" = "#e94560", "SMA" = "#F7931A",
                                    "Banda Superior" = "#2ecc71", "Banda Inferior" = "#2ecc71")) +
      labs(x = NULL, y = "Precio (USD)", title = paste("Bandas de Bollinger -", input$bb_crypto)) +
      theme_minimal() + theme(legend.position = "bottom")
    ggplotly(p)
  })
  
  # ============================================================
  # RETORNOS & RIESGO
  # ============================================================
  
  output$plot_boxplot_retornos <- renderPlotly({
    df <- datos_periodo(input$sel_dias_ret)
    p <- ggplot(df, aes(x = simbolo, y = retorno, fill = simbolo)) +
      geom_boxplot(alpha = 0.7, outlier.color = "#e74c3c") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      coord_flip() + theme_minimal() + labs(x = NULL, y = "Retorno (%)") +
      theme(legend.position = "none")
    ggplotly(p)
  })
  
  datos_ret_sel <- reactive({
    req(input$sel_crypto_ret, input$sel_dias_ret)
    datos_periodo(input$sel_dias_ret, input$sel_crypto_ret) %>%
      arrange(fecha) %>% mutate(mes = floor_date(fecha, "month"))
  })
  
  output$plot_retornos <- renderPlotly({
    df <- datos_ret_sel()
    tipo <- input$tipo_grafico_ret
    
    if (tipo == "hist") {
      p <- ggplot(df, aes(x = retorno, fill = after_stat(x) > 0)) +
        geom_histogram(bins = 50, alpha = 0.8) +
        scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c")) +
        geom_vline(xintercept = 0, linetype = "dashed") + theme_minimal() +
        labs(x = "Retorno (%)", y = "Frecuencia") + theme(legend.position = "none")
    } else if (tipo == "serie") {
      p <- ggplot(df, aes(x = fecha, y = retorno, fill = retorno > 0)) +
        geom_col(show.legend = FALSE) +
        scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c")) +
        theme_minimal() + labs(x = NULL, y = "Retorno (%)")
    } else if (tipo == "boxplot") {
      df$ml <- format(df$mes, "%b %Y")
      p <- ggplot(df, aes(x = reorder(ml, mes), y = retorno)) +
        geom_boxplot(fill = "#3498db", alpha = 0.7) + theme_minimal() +
        labs(x = NULL, y = "Retorno (%)") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
    } else {
      df$v30 <- zoo::rollapply(df$retorno, 30, sd, fill = NA, align = "right")
      p <- ggplot(df, aes(x = fecha, y = v30)) +
        geom_line(color = "#e94560", linewidth = 0.8) +
        geom_area(alpha = 0.2, fill = "#e94560") + theme_minimal() +
        labs(x = NULL, y = "Volatilidad (%)")
    }
    ggplotly(p)
  })
  
  output$tabla_riesgo <- renderDT({
    df <- datos_periodo(input$sel_dias_ret) %>%
      group_by(simbolo) %>%
      summarise(
        `Ret. Medio(%)` = round(mean(retorno, na.rm = TRUE), 3),
        `Desv. Est.(%)` = round(sd(retorno, na.rm = TRUE), 3),
        `VaR 95%(%)` = round(quantile(retorno, 0.05, na.rm = TRUE), 3),
        `Dias pos. (%)` = round(sum(retorno > 0, na.rm = TRUE) / n() * 100, 1)
      ) %>%
      rename(Symbol = simbolo)
    datatable(df, rownames = FALSE, options = list(dom = "t", pageLength = 10))
  })
  
  # ============================================================
  # CORRELACIONES
  # ============================================================
  
  datos_corr_wide <- reactive({
    req(input$sel_dias_corr, input$sel_cryptos_corr)
    cutoff <- max(hist_data$fecha) - input$sel_dias_corr
    hist_data %>%
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_corr) %>%
      select(fecha, simbolo, retorno) %>%
      pivot_wider(names_from = simbolo, values_from = retorno) %>%
      select(-fecha)
  })
  
  output$plot_heatmap_corr <- renderPlotly({
    df <- datos_corr_wide()
    req(ncol(df) >= 2)
    mat <- cor(df, use = "complete.obs", method = tolower(input$metodo_corr))
    df_long <- as.data.frame(as.table(mat)) %>% rename(Var1 = Var1, Var2 = Var2, Corr = Freq)
    
    p <- ggplot(df_long, aes(x = Var1, y = Var2, fill = Corr,
                             text = paste0(Var1, " vs ", Var2, ": ", round(Corr, 3)))) +
      geom_tile(color = "white") + geom_text(aes(label = round(Corr, 2)), size = 3) +
      scale_fill_gradient2(low = "#3498db", mid = "white", high = "#e74c3c", midpoint = 0, limits = c(-1, 1)) +
      theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = NULL, y = NULL)
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_scatter_corr <- renderPlotly({
    req(input$corr_x, input$corr_y, input$corr_x != input$corr_y)
    cutoff <- max(hist_data$fecha) - input$sel_dias_corr
    df <- hist_data %>%
      filter(fecha >= cutoff, simbolo %in% c(input$corr_x, input$corr_y)) %>%
      select(fecha, simbolo, retorno) %>%
      pivot_wider(names_from = simbolo, values_from = retorno) %>% drop_na()
    
    p <- ggplot(df, aes(x = .data[[input$corr_x]], y = .data[[input$corr_y]])) +
      geom_point(alpha = 0.5, color = "#627EEA") +
      geom_smooth(method = "lm", se = TRUE, color = "#e94560") +
      theme_minimal() +
      labs(x = paste("Retorno", input$corr_x, "(%)"), y = paste("Retorno", input$corr_y, "(%)"))
    ggplotly(p)
  })
  
  # ============================================================
  # COMPARADOR
  # ============================================================
  
  datos_comp_r <- reactive({
    req(input$sel_cryptos_comp, input$sel_dias_comp)
    cutoff <- max(hist_data$fecha) - input$sel_dias_comp
    hist_data %>%
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_comp) %>%
      arrange(fecha) %>% group_by(simbolo) %>%
      mutate(ini = first(close), norm = close / ini * 100, pct = (close - ini) / ini * 100) %>% ungroup()
  })
  
  output$plot_comparador <- renderPlotly({
    df <- datos_comp_r()
    yv <- if (input$tipo_norm == "base100") "norm" else "pct"
    yl <- if (input$tipo_norm == "base100") "Rendimiento (base 100)" else "Rendimiento acumulado (%)"
    
    p <- ggplot(df, aes(x = fecha, y = .data[[yv]], color = simbolo)) +
      geom_line(linewidth = 0.9) + theme_minimal() +
      labs(x = NULL, y = yl, color = "Moneda")
    
    if (input$tipo_norm == "base100") p <- p + geom_hline(yintercept = 100, linetype = "dashed", color = "grey50")
    ggplotly(p)
  })
  
  output$tabla_comparador <- renderDT({
    req(input$sel_cryptos_comp)
    cutoff <- max(hist_data$fecha) - input$sel_dias_comp
    df <- hist_data %>%
      filter(fecha >= cutoff, simbolo %in% input$sel_cryptos_comp) %>%
      group_by(simbolo) %>%
      summarise(
        `P. Inicial` = round(first(close), 2),
        `P. Final` = round(last(close), 2),
        `Rend. %` = round((last(close) - first(close)) / first(close) * 100, 2),
        `Vol. %` = round(sd(retorno, na.rm = TRUE), 3)
      ) %>%
      rename(Symbol = simbolo) %>% arrange(desc(`Rend. %`))
    datatable(df, rownames = FALSE, options = list(dom = "t", pageLength = 10))
  })
  
  # ============================================================
  # ANALISIS EDA AVANZADO
  # ============================================================
  
  datos_analisis_r <- reactive({
    req(input$analisis_crypto, input$analisis_dias)
    df <- datos_periodo(input$analisis_dias, input$analisis_crypto) %>% arrange(fecha)
    df$valor <- df[[input$analisis_variable]]
    df
  })
  
  output$plot_analisis_boxplot <- renderPlotly({
    df <- datos_analisis_r()
    p <- ggplot(df, aes(x = input$analisis_crypto, y = valor)) +
      geom_boxplot(fill = "#3498db", alpha = 0.7, outlier.color = "#e74c3c") +
      theme_minimal() + labs(x = NULL, y = input$analisis_variable)
    ggplotly(p)
  })
  
  output$plot_analisis_serie <- renderPlotly({
    df <- datos_analisis_r()
    p <- ggplot(df, aes(x = fecha, y = valor)) +
      geom_line(color = "#e94560", linewidth = 0.8) +
      geom_area(alpha = 0.2, fill = "#e94560") + theme_minimal() +
      labs(x = NULL, y = input$analisis_variable)
    ggplotly(p)
  })
  
  output$plot_analisis_boxplot_mensual <- renderPlotly({
    df <- datos_analisis_r() %>% mutate(ml = format(floor_date(fecha, "month"), "%b %Y"))
    p <- ggplot(df, aes(x = reorder(ml, fecha), y = valor)) +
      geom_boxplot(fill = "#2ecc71", alpha = 0.7, outlier.color = "#e74c3c") +
      theme_minimal() + labs(x = NULL, y = input$analisis_variable) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    ggplotly(p)
  })
  
  output$plot_analisis_acf <- renderPlotly({
    serie <- na.omit(datos_analisis_r()$valor)
    if (length(serie) < 10) return(NULL)
    
    acf_r <- acf(serie, plot = FALSE, lag.max = min(50, floor(length(serie) / 3)))
    ci <- qnorm(0.975) / sqrt(length(serie))
    df_a <- data.frame(Lag = as.numeric(acf_r$lag), ACF = as.numeric(acf_r$acf))
    
    p <- ggplot(df_a, aes(x = Lag, y = ACF)) +
      geom_bar(stat = "identity", fill = "#3498db", alpha = 0.7) +
      geom_hline(yintercept = c(ci, -ci), linetype = "dashed", color = "red") +
      theme_minimal() + labs(x = "Rezago", y = "ACF")
    ggplotly(p)
  })
  
  output$plot_analisis_pacf <- renderPlotly({
    serie <- na.omit(datos_analisis_r()$valor)
    if (length(serie) < 10) return(NULL)
    
    pacf_r <- pacf(serie, plot = FALSE, lag.max = min(50, floor(length(serie) / 3)))
    ci <- qnorm(0.975) / sqrt(length(serie))
    df_p <- data.frame(Lag = as.numeric(pacf_r$lag), PACF = as.numeric(pacf_r$acf))
    
    p <- ggplot(df_p, aes(x = Lag, y = PACF)) +
      geom_bar(stat = "identity", fill = "#e74c3c", alpha = 0.7) +
      geom_hline(yintercept = c(ci, -ci), linetype = "dashed", color = "blue") +
      theme_minimal() + labs(x = "Rezago", y = "PACF")
    ggplotly(p)
  })
  
  output$analisis_stats_html <- renderUI({
    serie <- na.omit(datos_analisis_r()$valor)
    tags$div(
      tags$p(tags$strong("n = "), length(serie)),
      tags$p(tags$strong("Media = "), round(mean(serie), 4)),
      tags$p(tags$strong("Mediana = "), round(median(serie), 4)),
      tags$p(tags$strong("Desv. estandar = "), round(sd(serie), 4)),
      tags$p(tags$strong("IQR = "), round(IQR(serie), 4)),
      tags$p(tags$strong("Min = "), round(min(serie), 4)),
      tags$p(tags$strong("Max = "), round(max(serie), 4))
    )
  })
  
  output$analisis_stationarity_html <- renderUI({
    serie <- na.omit(datos_analisis_r()$valor)
    if (length(serie) < 10) return(tags$p("Datos insuficientes."))
    
    test_result <- test_stationarity(serie)
    col <- if (test_result$es_estacionaria) "#2ecc71" else "#e74c3c"
    
    tags$div(
      h5("Prueba de Dickey-Fuller Aumentada (ADF)", style = "margin-top: 0;"),
      tags$hr(),
      p(tags$strong("Estadistico ADF:"), round(test_result$estadistico, 4)),
      p(tags$strong("Valor p:"), round(test_result$p_valor, 6)),
      p(tags$strong("Conclusion:"), test_result$conclusion),
      tags$div(style = paste0("background:", col, "20; border-left: 4px solid ", col, "; padding: 10px; border-radius: 6px; margin-top: 10px;"),
               p(style = "margin: 0;", if(test_result$es_estacionaria) 
                 "La serie es estacionaria. Se puede modelar con d=0."
                 else "La serie NO es estacionaria. Se aplicara diferenciacion d=1 para modelar.")
      )
    )
  })
  
  # DESCOMPOSICION UNIFICADA
  output$plot_analisis_decomposition <- renderPlotly({
    df <- datos_analisis_r()
    serie <- na.omit(df$valor)
    
    if (length(serie) < 100) {
      return(ggplotly(ggplot() +
                        annotate("text", x = 0.5, y = 0.5, label = "Se necesitan al menos 100 datos.", size = 5) +
                        theme_void()))
    }
    
    tipo_descomp <- input$tipo_descomp
    result <- perform_decomposition_by_type(serie, method = tipo_descomp, frecuencia = 7)
    
    if (!result$success) {
      return(ggplotly(ggplot() +
                        annotate("text", x = 0.5, y = 0.5, label = result$error, size = 4, color = "red") +
                        theme_void()))
    }
    
    comp_long <- result$data %>%
      mutate(idx = row_number()) %>%
      pivot_longer(-idx, names_to = "Componente", values_to = "valor")
    
    p <- ggplot(comp_long, aes(x = idx, y = valor, color = Componente)) +
      geom_line(linewidth = 0.7, na.rm = TRUE) +
      facet_wrap(~Componente, scales = "free_y", ncol = 1) +
      scale_color_manual(values = c(
        "Observado" = "#2c3e50", "Tendencia" = "#e74c3c",
        "Estacional" = "#3498db", "Residuo" = "#2ecc71"
      )) +
      theme_minimal() + labs(x = "Indice temporal", y = NULL) +
      theme(legend.position = "none", strip.text = element_text(face = "bold", size = 11))
    
    ggplotly(p) %>% layout(height = 550)
  })
  
  output$tabla_analisis_stationarity <- renderDT({
    req(input$analisis_dias, input$analisis_variable)
    cutoff <- max(hist_data$fecha) - input$analisis_dias
    vc <- input$analisis_variable
    
    res <- lapply(unique(hist_data$simbolo), function(cr) {
      s <- na.omit(hist_data[hist_data$simbolo == cr & hist_data$fecha >= cutoff, vc][[1]])
      if (length(s) < 10) return(data.frame(Moneda = cr, Estacionaria = "insuf.", `p-valor` = NA, `d recomendado` = "--"))
      
      test_result <- test_stationarity(s)
      d_rec <- if (test_result$es_estacionaria) 0 else 1
      
      data.frame(
        Moneda = cr,
        Estacionaria = if (test_result$es_estacionaria) "Si" else "No",
        `p-valor` = round(test_result$p_valor, 6),
        `d recomendado` = d_rec
      )
    })
    
    datatable(bind_rows(res), rownames = FALSE, options = list(dom = "t", pageLength = 12))
  })
  
  # ============================================================
  # MODELO ARIMA (Pestana principal)
  # ============================================================
  
  arima_results <- reactiveValues(
    best_model = NULL, best_order = NULL, best_criterion = NULL,
    train = NULL, test = NULL, train_dates = NULL, test_dates = NULL,
    forecast_rolling = NULL, forecast_directo = NULL,
    all_orders = NULL, residuals = NULL, metrics_rolling = NULL, metrics_directo = NULL
  )
  
  observeEvent(input$btn_arima, {
    req(input$arima_crypto, input$arima_variable, input$arima_train_dias)
    
    withProgress(message = "Ajustando modelos ARIMA...", value = 0, {
      
      vc <- input$arima_variable
      df <- hist_data %>%
        filter(simbolo == input$arima_crypto) %>%
        arrange(fecha) %>%
        handle_missing(method = "interpolation")
      
      serie <- na.omit(df[[vc]])
      fechas <- df$fecha[!is.na(df[[vc]])]
      n <- length(serie)
      n_train <- min(input$arima_train_dias, n - input$arima_horizonte - 5)
      n_test <- input$arima_horizonte
      
      if (n_train < 30) {
        showNotification("Necesitas al menos 30 dias de entrenamiento.", type = "error")
        return()
      }
      
      train <- serie[1:n_train]
      test <- serie[(n_train + 1):(n_train + n_test)]
      train_dates <- fechas[1:n_train]
      test_dates <- fechas[(n_train + 1):(n_train + n_test)]
      
      # Detectar d optimo automaticamente
      stationarity_result <- detect_stationarity_and_differentiate(train)
      d_optimo <- stationarity_result$d_value
      
      setProgress(0.1, detail = paste("d optimo detectado:", d_optimo))
      
      # Busqueda de mejores ordenes
      criterio <- input$arima_criterio
      max_pq <- input$arima_max_pq
      pq_rng <- 0:max_pq
      
      best_val <- Inf
      best_order <- c(1, d_optimo, 0)
      best_mdl <- NULL
      all_rows <- list()
      
      total_iter <- length(pq_rng)^2
      iter <- 0
      
      for (p in pq_rng) {
        for (q in pq_rng) {
          iter <- iter + 1
          if (p == 0 && d_optimo == 0 && q == 0) next
          
          tryCatch({
            mdl <- Arima(train, order = c(p, d_optimo, q), method = "ML", optim.control = list(maxit = 200))
            
            val <- switch(criterio,
                          "AIC" = mdl$aic,
                          "BIC" = BIC(mdl),
                          "HQIC" = {
                            k <- length(mdl$coef) + 1
                            n2 <- length(mdl$residuals)
                            2 * k * log(log(n2)) - 2 * mdl$loglik
                          },
                          mdl$aic
            )
            
            all_rows[[length(all_rows) + 1]] <- data.frame(
              p = p, d = d_optimo, q = q,
              AIC = round(mdl$aic, 3),
              BIC = round(BIC(mdl), 3),
              LogLik = round(mdl$loglik, 3)
            )
            
            if (val < best_val) {
              best_val <- val
              best_order <- c(p, d_optimo, q)
              best_mdl <- mdl
            }
          }, error = function(e) NULL)
          
          setProgress(0.1 + 0.3 * (iter / total_iter), detail = paste("Probando p=", p, "q=", q))
        }
      }
      
      if (is.null(best_mdl)) {
        showNotification("No se pudo ajustar ningun modelo.", type = "error")
        return()
      }
      
      setProgress(0.5, detail = "Generando pronostico rolling...")
      
      # Rolling forecast
      history <- as.list(train)
      yhat_rolling <- numeric(n_test)
      
      for (t in seq_len(n_test)) {
        tryCatch({
          m <- Arima(unlist(history), order = best_order, method = "ML", optim.control = list(maxit = 100))
          yhat_rolling[t] <- as.numeric(forecast(m, h = 1)$mean[1])
          history <- c(history, list(test[t]))
        }, error = function(e) {
          yhat_rolling[t] <- if (t > 1) yhat_rolling[t - 1] else tail(train, 1)
          history <<- c(history, list(test[t]))
        })
        setProgress(0.5 + 0.3 * (t / n_test), detail = paste("Rolling paso", t, "de", n_test))
      }
      
      setProgress(0.85, detail = "Generando pronostico directo...")
      
      # Direct forecast
      yhat_directo <- tryCatch(
        as.numeric(forecast(best_mdl, h = n_test)$mean),
        error = function(e) rep(tail(train, 1), n_test)
      )
      
      setProgress(0.95, detail = "Calculando metricas...")
      
      # Calcular metricas
      metrics_rolling <- forecast_accuracy(yhat_rolling, test)
      metrics_directo <- forecast_accuracy(yhat_directo, test)
      
      setProgress(1, detail = "Listo!")
      
      arima_results$best_model <- best_mdl
      arima_results$best_order <- best_order
      arima_results$best_criterion <- best_val
      arima_results$train <- train
      arima_results$test <- test
      arima_results$train_dates <- train_dates
      arima_results$test_dates <- test_dates
      arima_results$forecast_rolling <- yhat_rolling
      arima_results$forecast_directo <- yhat_directo
      arima_results$all_orders <- bind_rows(all_rows) %>% arrange(AIC)
      arima_results$residuals <- residuals(best_mdl)
      arima_results$metrics_rolling <- metrics_rolling
      arima_results$metrics_directo <- metrics_directo
      
      showNotification(
        paste("Mejor modelo: ARIMA(", best_order[1], ",", best_order[2], ",", best_order[3],
              ") | ", criterio, " = ", round(best_val, 3)),
        type = "message", duration = 6
      )
    })
  })
  
  output$arima_best_model_ui <- renderUI({
    bo <- arima_results$best_order
    if (is.null(bo)) return(tags$p("Presiona 'Ajustar Modelo' para comenzar.", style = "color:#7f8c8d;"))
    
    tags$div(
      tags$h3(paste0("ARIMA(", bo[1], ", ", bo[2], ", ", bo[3], ")"), style = "color:#2c3e50;font-weight:900; text-align: center;"),
      fluidRow(
        column(4, tags$div(class = "def-box", tags$strong("p (AR):"), tags$br(), tags$span(bo[1], style = "font-size: 24px; font-weight: bold;"))),
        column(4, tags$div(class = "obs-box", tags$strong("d (I):"), tags$br(), tags$span(bo[2], style = "font-size: 24px; font-weight: bold;"))),
        column(4, tags$div(class = "warn-box", tags$strong("q (MA):"), tags$br(), tags$span(bo[3], style = "font-size: 24px; font-weight: bold;")))
      ),
      tags$p(style = "color:#7f8c8d;font-size:12px;margin-top:8px; text-align: center;",
             paste0("Criterio: ", input$arima_criterio, " = ", round(arima_results$best_criterion, 3)))
    )
  })
  
  output$tabla_arima_criterios <- renderDT({
    req(arima_results$all_orders)
    datatable(arima_results$all_orders %>% head(15), rownames = FALSE,
              options = list(dom = "t", pageLength = 15, scrollX = TRUE))
  })
  
  output$plot_arima_fit <- renderPlotly({
    req(arima_results$best_model, arima_results$train)
    fitted_vals <- fitted(arima_results$best_model)
    df <- data.frame(fecha = arima_results$train_dates,
                     Real = arima_results$train,
                     Ajustado = as.numeric(fitted_vals))
    
    p <- ggplot(df, aes(x = fecha)) +
      geom_line(aes(y = Real, color = "Real"), linewidth = 0.8) +
      geom_line(aes(y = Ajustado, color = "Ajustado"), linewidth = 0.8, linetype = "dashed") +
      scale_color_manual(values = c("Real" = "#2c3e50", "Ajustado" = "#e74c3c")) +
      theme_minimal() + labs(x = NULL, y = input$arima_variable, color = NULL) +
      ggtitle("Ajuste del Modelo ARIMA en Entrenamiento")
    ggplotly(p)
  })
  
  output$plot_arima_forecast <- renderPlotly({
    req(arima_results$test, arima_results$forecast_rolling)
    tipo <- input$arima_tipo
    yhat <- if (tipo == "rolling") arima_results$forecast_rolling else arima_results$forecast_directo
    td <- arima_results$test_dates
    
    n_ctx <- min(60, length(arima_results$train))
    df_train <- data.frame(
      fecha = tail(arima_results$train_dates, n_ctx),
      valor = tail(arima_results$train, n_ctx),
      tipo = "Entrenamiento"
    )
    df_test <- data.frame(fecha = td, valor = arima_results$test, tipo = "Real (test)")
    df_pred <- data.frame(fecha = td, valor = yhat,
                          tipo = if (tipo == "rolling") "Rolling forecast" else "Directo forecast")
    
    df_all <- bind_rows(df_train, df_test, df_pred)
    
    p <- ggplot(df_all, aes(x = fecha, y = valor, color = tipo)) +
      geom_line(linewidth = 0.9) +
      scale_color_manual(values = c("Entrenamiento" = "#2ecc71", "Real (test)" = "#3498db",
                                    "Rolling forecast" = "#e74c3c", "Directo forecast" = "#9b59b6")) +
      theme_minimal() + labs(x = NULL, y = input$arima_variable, color = NULL) +
      ggtitle("Pronostico vs Valores Reales")
    ggplotly(p) %>% layout(hovermode = "x unified")
  })
  
  output$tabla_arima_error <- renderDT({
    req(arima_results$metrics_rolling, arima_results$metrics_directo)
    
    df <- data.frame(
      Metrica = c("MAPE (%)", "MAE", "RMSE", "MSE", "R2", "Correlacion"),
      Rolling = c(
        arima_results$metrics_rolling$MAPE,
        arima_results$metrics_rolling$MAE,
        arima_results$metrics_rolling$RMSE,
        arima_results$metrics_rolling$MSE,
        arima_results$metrics_rolling$R2,
        arima_results$metrics_rolling$Corr
      ),
      Directo = c(
        arima_results$metrics_directo$MAPE,
        arima_results$metrics_directo$MAE,
        arima_results$metrics_directo$RMSE,
        arima_results$metrics_directo$MSE,
        arima_results$metrics_directo$R2,
        arima_results$metrics_directo$Corr
      )
    )
    
    datatable(df, rownames = FALSE, options = list(dom = "t", pageLength = 6))
  })
  
  output$plot_arima_resid_acf <- renderPlotly({
    req(arima_results$residuals)
    resid <- na.omit(as.numeric(arima_results$residuals))
    acf_r <- acf(resid, plot = FALSE, lag.max = min(40, floor(length(resid) / 3)))
    ci <- qnorm(0.975) / sqrt(length(resid))
    df_a <- data.frame(Lag = as.numeric(acf_r$lag), ACF = as.numeric(acf_r$acf))
    
    p <- ggplot(df_a, aes(x = Lag, y = ACF)) +
      geom_bar(stat = "identity", fill = "#9b59b6", alpha = 0.8) +
      geom_hline(yintercept = c(ci, -ci), linetype = "dashed", color = "red") +
      theme_minimal() + labs(title = "ACF de Residuales", x = "Rezago", y = "ACF")
    ggplotly(p)
  })
  
  output$plot_arima_resid_hist <- renderPlotly({
    req(arima_results$residuals)
    resid <- na.omit(as.numeric(arima_results$residuals))
    df_r <- data.frame(r = resid)
    
    p <- ggplot(df_r, aes(x = r)) +
      geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "#9b59b6", alpha = 0.7) +
      stat_function(fun = dnorm, args = list(mean = mean(resid), sd = sd(resid)),
                    color = "#e74c3c", linewidth = 1) +
      geom_vline(xintercept = 0, linetype = "dashed") +
      theme_minimal() + labs(title = "Distribucion de Residuales", x = "Residual", y = "Densidad")
    ggplotly(p)
  })
  
  # Comparacion de horizontes
  horizonte_results <- reactiveVal(NULL)
  
  observeEvent(input$btn_all_horizons, {
    req(arima_results$best_order, arima_results$train)
    
    withProgress(message = "Calculando horizontes 7/14/21/28 dias...", {
      rows <- list()
      horizons <- c(7, 14, 21, 28)
      
      for (h_idx in seq_along(horizons)) {
        h <- horizons[h_idx]
        train_s <- arima_results$train
        n_test_h <- min(h, length(arima_results$test))
        if (n_test_h < 1) next
        
        test_h <- arima_results$test[1:n_test_h]
        
        # Rolling forecast
        history <- as.list(train_s)
        yhat_h <- numeric(n_test_h)
        
        for (t in seq_len(n_test_h)) {
          tryCatch({
            m <- Arima(unlist(history), order = arima_results$best_order,
                       method = "ML", optim.control = list(maxit = 50))
            yhat_h[t] <- as.numeric(forecast(m, h = 1)$mean[1])
            history <- c(history, list(test_h[t]))
          }, error = function(e) {
            yhat_h[t] <- if (t > 1) yhat_h[t - 1] else tail(train_s, 1)
            history <<- c(history, list(test_h[t]))
          })
        }
        
        metrics <- forecast_accuracy(yhat_h, test_h)
        
        rows[[h_idx]] <- data.frame(
          Horizonte = paste(h, "dias"),
          MAPE = round(metrics$MAPE, 2),
          RMSE = round(metrics$RMSE, 2),
          MAE = round(metrics$MAE, 2),
          R2 = round(metrics$R2, 4)
        )
        
        setProgress(h_idx / length(horizons))
      }
      
      horizonte_results(bind_rows(rows))
      showNotification("Comparacion de horizontes completada.", type = "message", duration = 4)
    })
  })
  
  output$tabla_comparacion_horizontes <- renderDT({
    req(horizonte_results())
    datatable(horizonte_results(), rownames = FALSE, options = list(dom = "t", pageLength = 10))
  })
  
  output$plot_comparacion_horizontes <- renderPlotly({
    req(horizonte_results())
    df <- horizonte_results() %>%
      pivot_longer(-Horizonte, names_to = "Metrica", values_to = "Valor")
    
    p <- ggplot(df, aes(x = Horizonte, y = Valor, fill = Metrica)) +
      geom_col(position = "dodge", alpha = 0.85) +
      scale_fill_manual(values = c("MAPE" = "#e74c3c", "RMSE" = "#3498db", "MAE" = "#2ecc71", "R2" = "#9b59b6")) +
      theme_minimal() + labs(x = NULL, y = "Valor") +
      theme(axis.text.x = element_text(angle = 30, hjust = 1))
    ggplotly(p)
  })
  
  # ============================================================
  # PREDICCION OPTIMA (MEJOR MODELO) - VERSION CORREGIDA
  # ============================================================
  
  optimal_model_results <- reactiveVal(NULL)
  
  observeEvent(input$btn_optimal_prediction, {
    req(input$optimal_crypto, input$optimal_criterion, input$optimal_horizon)
    
    withProgress(message = "Buscando el mejor modelo ARIMA...", value = 0, {
      
      # Obtener datos
      df <- hist_data %>%
        filter(simbolo == input$optimal_crypto) %>%
        arrange(fecha) %>%
        handle_missing(method = "interpolation")
      
      serie <- na.omit(df$close)
      fechas <- df$fecha[!is.na(df$close)]
      n <- length(serie)
      
      # Usar 80% de los datos para entrenamiento
      n_train <- floor(n * 0.8)
      train <- serie[1:n_train]
      train_dates <- fechas[1:n_train]
      test <- serie[(n_train + 1):n]
      test_dates <- fechas[(n_train + 1):n]
      
      setProgress(0.3, detail = "Evaluando modelos ARIMA...")
      
      # Encontrar el mejor modelo segun el criterio seleccionado
      best_result <- get_best_model_for_prediction(
        train, 
        criterion = input$optimal_criterion,
        max_pq = input$optimal_max_pq
      )
      
      if (!best_result$success) {
        showNotification(best_result$error, type = "error")
        return()
      }
      
      setProgress(0.6, detail = paste("Modelo encontrado: ARIMA(", 
                                      best_result$order[1], ",", best_result$order[2], ",", 
                                      best_result$order[3], ")"))
      
      # Generar prediccion
      horizon <- input$optimal_horizon
      forecast_result <- forecast(best_result$model, h = horizon)
      
      # ============================================================
      # CLAVE: Usar la fecha REAL mas reciente de TODOS los datos
      # ============================================================
      last_historical_date <- max(fechas, na.rm = TRUE)
      future_dates <- seq(last_historical_date + 1, by = "day", length.out = horizon)
      
      # Dataframe de predicciones
      forecast_df <- data.frame(
        Fecha = future_dates,
        Prediccion = round(as.numeric(forecast_result$mean), 2),
        Lower_80 = round(as.numeric(forecast_result$lower[, 1]), 2),
        Upper_80 = round(as.numeric(forecast_result$upper[, 1]), 2),
        Lower_95 = round(as.numeric(forecast_result$lower[, 2]), 2),
        Upper_95 = round(as.numeric(forecast_result$upper[, 2]), 2)
      )
      
      # Evaluar el modelo en test
      n_test_available <- length(test)
      if (n_test_available >= 7) {
        n_test_actual <- min(horizon, n_test_available)
        test_subset <- test[1:n_test_actual]
        yhat_test <- arima_rolling_forecast(train, test_subset, best_result$order)
        test_metrics <- forecast_accuracy(yhat_test, test_subset)
      } else {
        test_metrics <- data.frame(MAPE = NA, MAE = NA, RMSE = NA, MSE = NA, R2 = NA, Corr = NA)
      }
      
      # Guardar resultados
      optimal_model_results(list(
        success = TRUE,
        model = best_result$model,
        order = best_result$order,
        criterion = input$optimal_criterion,
        criterion_value = best_result$criterion_value,
        d_used = best_result$d_used,
        is_stationary = best_result$is_stationary,
        forecast_df = forecast_df,
        test_metrics = test_metrics,
        last_price = round(tail(train, 1), 2),
        first_pred = forecast_df$Prediccion[1],
        first_pred_date = forecast_df$Fecha[1],
        train_dates = train_dates,
        train = train,
        test = test,
        test_dates = test_dates,
        residuals_analysis = best_result$residuals_analysis,
        last_historical_date = last_historical_date
      ))
      
      setProgress(1, detail = "Listo!")
      
      showNotification(
        paste("Mejor modelo: ARIMA(", best_result$order[1], ",", best_result$order[2], ",", 
              best_result$order[3], ") | ", input$optimal_criterion, " = ", round(best_result$criterion_value, 3)),
        type = "message", duration = 6
      )
    })
  })
  
  # Informacion del modelo seleccionado
  output$optimal_model_info <- renderUI({
    res <- optimal_model_results()
    if (is.null(res) || !res$success) {
      return(tags$div(
        class = "pred-box",
        h4("No hay modelo cargado"),
        p("Presiona 'Buscar Mejor Modelo' para comenzar.", style = "color: #7f8c8d;")
      ))
    }
    
    color_d <- ifelse(res$d_used == 0, "#2ecc71", "#e74c3c")
    
    tags$div(
      h3(paste0("ARIMA(", res$order[1], ",", res$order[2], ",", res$order[3], ")"),
         style = "color: #27ae60; text-align: center; margin-top: 0;"),
      hr(),
      p(tags$strong("Criterio:"), res$criterion),
      p(tags$strong("Valor:"), round(res$criterion_value, 3)),
      p(tags$strong("Diferenciacion (d):"), res$d_used,
        style = paste0("color: ", color_d, "; font-weight: bold;")),
      p(tags$strong("Estacionariedad:"), 
        if(res$is_stationary) "Si (d=0)" else "No (se aplico d=1)"),
      hr(),
      p(tags$strong("Test Normalidad:"), 
        if(!is.na(res$residuals_analysis$normal_pval) && res$residuals_analysis$normal_pval > 0.05) 
          "Aceptable" else "Cuestionable"),
      p(tags$strong("Test Independencia:"), 
        if(!is.na(res$residuals_analysis$lb_pval) && res$residuals_analysis$lb_pval > 0.05) 
          "Aceptable" else "Cuestionable")
    )
  })
  
  # Tarjeta de prediccion para MAÑANA (corregida)
  output$prediction_tomorrow_box <- renderValueBox({
    res <- optimal_model_results()
    
    if (is.null(res) || !res$success) {
      valueBox(
        value = "---",
        subtitle = "Prediccion para (selecciona datos primero)",
        icon = icon("calendar-day"),
        color = "blue"
      )
    } else {
      last_price <- res$last_price
      first_pred <- res$first_pred
      change_pct <- round((first_pred - last_price) / last_price * 100, 2)
      change_abs <- round(first_pred - last_price, 2)
      
      if (change_pct >= 0) {
        change_text <- paste0("▲ +", abs(change_pct), "% (", change_abs, " USD)")
        change_color <- "green"
        arrow_icon <- icon("arrow-up")
      } else {
        change_text <- paste0("▼ ", abs(change_pct), "% (", change_abs, " USD)")
        change_color <- "red"
        arrow_icon <- icon("arrow-down")
      }
      
      pred_date <- format(res$first_pred_date, "%d/%m/%Y")
      
      valueBox(
        value = tags$div(
          style = "text-align: center;",
          tags$span(paste0("$", format(first_pred, big.mark = ",")), 
                    style = "font-size: 28px; font-weight: bold; display: block;"),
          tags$span(arrow_icon, change_text, 
                    style = paste0("color: ", change_color, "; font-size: 14px; margin-top: 5px;"))
        ),
        subtitle = paste("Prediccion para", pred_date, "(", input$optimal_crypto, ")"),
        icon = icon("calendar-day"),
        color = if (change_pct >= 0) "green" else "red"
      )
    }
  })
  
  # ============================================================
  # GRAFICO DE PREDICCION OPTIMA - CON ENTRENAMIENTO + TEST + PREDICCION
  # ============================================================
  output$plot_optimal_forecast <- renderPlotly({
    res <- optimal_model_results()
    
    if (is.null(res) || !res$success) {
      p <- ggplot() + 
        annotate("text", x = 0.5, y = 0.5, 
                 label = "Selecciona una criptomoneda y presiona 'Buscar Mejor Modelo'", 
                 size = 5, color = "#7f8c8d") + 
        theme_void()
      return(ggplotly(p))
    }
    
    # ============================================================
    # DATOS DE ENTRENAMIENTO (ultimos 200 dias para contexto)
    # ============================================================
    n_train_hist <- min(200, length(res$train))
    df_train <- data.frame(
      Fecha = tail(res$train_dates, n_train_hist),
      Precio = tail(res$train, n_train_hist),
      Tipo = "Entrenamiento"
    )
    
    # ============================================================
    # DATOS DE TEST (estos son los que faltaban!!!)
    # ============================================================
    df_test <- data.frame(
      Fecha = res$test_dates,
      Precio = res$test,
      Tipo = "Test (Real)"
    )
    
    # ============================================================
    # DATOS DE PREDICCION
    # ============================================================
    df_pred <- data.frame(
      Fecha = res$forecast_df$Fecha,
      Precio = res$forecast_df$Prediccion,
      Tipo = "Prediccion"
    )
    
    # ============================================================
    # UNIR TODOS LOS DATAFRAMES (Entrenamiento + Test + Prediccion)
    # ============================================================
    df_all <- bind_rows(df_train, df_test, df_pred)
    
    # DIAGNOSTICO EN CONSOLA
    cat("\n=== DIAGNOSTICO GRAFICO PREDICCION ===\n")
    cat("Entrenamiento:", format(min(df_train$Fecha, na.rm=TRUE), "%Y-%m-%d"), "→", format(max(df_train$Fecha, na.rm=TRUE), "%Y-%m-%d"), "\n")
    cat("Test:", format(min(df_test$Fecha, na.rm=TRUE), "%Y-%m-%d"), "→", format(max(df_test$Fecha, na.rm=TRUE), "%Y-%m-%d"), "\n")
    cat("Prediccion:", format(min(df_pred$Fecha, na.rm=TRUE), "%Y-%m-%d"), "→", format(max(df_pred$Fecha, na.rm=TRUE), "%Y-%m-%d"), "\n")
    cat("========================================\n")
    
    # ============================================================
    # GRAFICO
    # ============================================================
    p <- ggplot() +
      # Linea de entrenamiento
      geom_line(data = df_train, aes(x = Fecha, y = Precio, color = "Entrenamiento"), linewidth = 0.9) +
      # Linea de test (datos reales que el modelo no vio durante entrenamiento)
      geom_line(data = df_test, aes(x = Fecha, y = Precio, color = "Test (Real)"), linewidth = 0.9) +
      # Linea de prediccion
      geom_line(data = df_pred, aes(x = Fecha, y = Precio, color = "Prediccion"), linewidth = 1.2) +
      # Intervalos de confianza
      geom_ribbon(data = res$forecast_df, aes(x = Fecha, ymin = Lower_95, ymax = Upper_95),
                  fill = "#3498db", alpha = 0.2) +
      geom_ribbon(data = res$forecast_df, aes(x = Fecha, ymin = Lower_80, ymax = Upper_80),
                  fill = "#3498db", alpha = 0.3) +
      scale_color_manual(
        name = "",
        values = c("Entrenamiento" = "#2c3e50", 
                   "Test (Real)" = "#3498db", 
                   "Prediccion" = "#e74c3c")
      ) +
      labs(title = paste("Prediccion Optima -", input$optimal_crypto),
           subtitle = paste("Modelo ARIMA(", res$order[1], ",", res$order[2], ",", res$order[3], 
                            ") | Criterio:", res$criterion,
                            " | Ultimo dato real:", format(res$last_historical_date, "%Y-%m-%d")),
           x = "", y = "Precio (USD)") +
      theme_minimal() +
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = c("x", "y", "color")) %>% 
      layout(hovermode = "x unified",
             xaxis = list(title = "Fecha"),
             yaxis = list(title = "Precio (USD)"))
  })
  
  # Tabla de metricas del modelo optimo
  output$optimal_metrics_table <- renderDT({
    res <- optimal_model_results()
    if (is.null(res) || !res$success) {
      return(datatable(data.frame(Mensaje = "No hay modelo cargado"), options = list(dom = "t")))
    }
    
    df <- data.frame(
      Metrica = c("MAPE (%)", "MAE (USD)", "RMSE (USD)", "MSE", "R2", "Correlacion"),
      Valor = c(
        ifelse(is.na(res$test_metrics$MAPE), "N/A", round(res$test_metrics$MAPE, 2)),
        ifelse(is.na(res$test_metrics$MAE), "N/A", round(res$test_metrics$MAE, 2)),
        ifelse(is.na(res$test_metrics$RMSE), "N/A", round(res$test_metrics$RMSE, 2)),
        ifelse(is.na(res$test_metrics$MSE), "N/A", round(res$test_metrics$MSE, 2)),
        ifelse(is.na(res$test_metrics$R2), "N/A", round(res$test_metrics$R2, 4)),
        ifelse(is.na(res$test_metrics$Corr), "N/A", round(res$test_metrics$Corr, 4))
      )
    )
    
    datatable(df, rownames = FALSE, options = list(dom = "t", pageLength = 6))
  })
  
  # Tabla de predicciones detalladas
  output$optimal_forecast_table <- renderDT({
    res <- optimal_model_results()
    if (is.null(res) || !res$success) {
      return(datatable(data.frame(Mensaje = "No hay modelo cargado"), options = list(dom = "t")))
    }
    
    df <- res$forecast_df %>%
      mutate(
        Fecha = format(Fecha, "%Y-%m-%d"),
        Prediccion = paste0("$", format(Prediccion, big.mark = ",")),
        `Intervalo 80%` = paste0("$", format(Lower_80, big.mark = ","), " - $", format(Upper_80, big.mark = ",")),
        `Intervalo 95%` = paste0("$", format(Lower_95, big.mark = ","), " - $", format(Upper_95, big.mark = ","))
      ) %>%
      select(Fecha, Prediccion, `Intervalo 80%`, `Intervalo 95%`)
    
    datatable(df, rownames = FALSE, 
              options = list(pageLength = 10, scrollX = TRUE),
              class = "display nowrap")
  })
  
}