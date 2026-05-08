library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(DT)
library(lubridate)
library(scales)
library(jsonlite)
library(httr)
library(zoo)
library(forecast)
library(tseries)

# -------------------------------------------------------------------
# CONFIGURACIÓN DE LA API
# -------------------------------------------------------------------
API_KEY    <- "ce6e922820dabbb917d5f6fd82b867726fbf320cf3f7414b33748c19e9514aae"
BASE_URL   <- "https://min-api.cryptocompare.com/data"

# -------------------------------------------------------------------
# LISTA DE CRIPTOMONEDAS (10 monedas)
# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
# PALETA DE COLORES PROFESIONAL
# -------------------------------------------------------------------
COLOR_PALETTE <- c(
  "#2E86AB", "#A23B72", "#F18F01", "#C73E1D", "#6A994E",
  "#BC4A6C", "#3D5A80", "#EE6C4D", "#98C1D9", "#293241"
)
names(COLOR_PALETTE) <- CRYPTOS

# -------------------------------------------------------------------
# FUNCIÓN: OBTENER DATOS HISTÓRICOS (CRYPTOCOMPARE)
# -------------------------------------------------------------------
get_historical_daily <- function(fsym, tsym = "USD", limit = 1905) {
  url <- paste0(BASE_URL, "/v2/histoday?fsym=", fsym, "&tsym=", tsym, 
                "&limit=", limit, "&api_key=", API_KEY)
  url <- URLencode(url)
  
  tryCatch({
    resp <- GET(url, timeout(30))
    if (http_error(resp)) return(NULL)
    
    data <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    if (is.null(data$Data$Data)) return(NULL)
    
    df <- as.data.frame(data$Data$Data)
    df <- df %>%
      mutate(
        fecha = as.Date(as.POSIXct(time, origin = "1970-01-01")),
        simbolo = fsym,
        open = as.numeric(open),
        high = as.numeric(high),
        low = as.numeric(low),
        close = as.numeric(close),
        volume = as.numeric(volumefrom),
        retorno = (close - lag(close)) / lag(close) * 100,
        retorno_log = log(close / lag(close)) * 100,
        volatilidad = abs(high - low) / open * 100
      ) %>%
      filter(!is.na(retorno))
    return(df)
  }, error = function(e) return(NULL))
}

# -------------------------------------------------------------------
# FUNCIÓN: OBTENER PRECIOS ACTUALES
# -------------------------------------------------------------------
get_price_overview <- function(fsyms, tsym = "USD") {
  fsyms_str <- paste(fsyms, collapse = ",")
  url <- paste0(BASE_URL, "/pricemultifull?fsyms=", fsyms_str, 
                "&tsyms=", tsym, "&api_key=", API_KEY)
  url <- URLencode(url)
  
  tryCatch({
    resp <- GET(url, timeout(30))
    if (http_error(resp)) return(NULL)
    
    data <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    if (is.null(data$RAW)) return(NULL)
    
    rows <- list()
    for (sym in fsyms) {
      if (!is.null(data$RAW[[sym]]) && !is.null(data$RAW[[sym]][[tsym]])) {
        d <- data$RAW[[sym]][[tsym]]
        rows[[sym]] <- data.frame(
          simbolo = sym,
          precio = d$PRICE,
          cambio_24h_pct = d$CHANGEPCT24HOUR,
          volumen_24h = d$VOLUME24HOURTO,
          cap_mercado = d$MKTCAP,
          stringsAsFactors = FALSE
        )
      }
    }
    if (length(rows) == 0) return(NULL)
    return(bind_rows(rows))
  }, error = function(e) return(NULL))
}

# -------------------------------------------------------------------
# FUNCIÓN: RESUMEN DE VALORES FALTANTES
# -------------------------------------------------------------------
missing_summary <- function(df) {
  df %>%
    summarise(across(everything(), ~ sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "Variable", values_to = "NAs") %>%
    mutate(Pct = round(NAs / nrow(df) * 100, 2)) %>%
    filter(NAs > 0)
}

# -------------------------------------------------------------------
# FUNCIÓN: MANEJO DE VALORES FALTANTES
# -------------------------------------------------------------------
handle_missing <- function(df, method = "interpolation") {
  if (method == "remove") {
    return(na.omit(df))
  } else if (method == "interpolation") {
    df <- df %>% arrange(fecha)
    for (col in c("close", "open", "high", "low", "volume", "retorno", "retorno_log", "volatilidad")) {
      if (col %in% names(df)) {
        df[[col]] <- na.approx(df[[col]], na.rm = FALSE)
        df[[col]] <- na.locf(df[[col]], na.rm = FALSE)
        df[[col]] <- na.locf(df[[col]], fromLast = TRUE, na.rm = FALSE)
      }
    }
    return(df)
  } else if (method == "mean") {
    for (col in c("close", "open", "high", "low", "volume", "retorno", "retorno_log", "volatilidad")) {
      if (col %in% names(df)) {
        df[[col]][is.na(df[[col]])] <- mean(df[[col]], na.rm = TRUE)
      }
    }
    return(df)
  }
  return(df)
}

# -------------------------------------------------------------------
# FUNCIÓN: BANDAS DE BOLLINGER
# -------------------------------------------------------------------
calculate_bollinger_bands <- function(prices, window = 20, sd_mult = 2) {
  sma <- rollmean(prices, window, fill = NA, align = "right")
  sd <- rollapply(prices, window, sd, fill = NA, align = "right")
  
  data.frame(
    sma = sma,
    upper = sma + (sd_mult * sd),
    lower = sma - (sd_mult * sd)
  )
}

# -------------------------------------------------------------------
# FUNCIÓN: DESCOMPOSICIÓN STL SEGURA (ADITIVA)
# -------------------------------------------------------------------
perform_stl_decomposition_safe <- function(serie, frecuencia = 7) {
  tryCatch({
    serie_clean <- as.numeric(na.omit(serie))
    
    if (length(serie_clean) < frecuencia * 2) {
      return(list(success = FALSE, error = "Datos insuficientes para descomposición STL (mínimo 2 períodos completos)"))
    }
    
    ts_serie <- ts(serie_clean, frequency = frecuencia)
    decomp <- stl(ts_serie, s.window = "periodic", robust = TRUE)
    
    n <- length(decomp$time.series[, "trend"])
    
    result <- data.frame(
      Observado = serie_clean[1:n],
      Tendencia = as.numeric(decomp$time.series[, "trend"]),
      Estacional = as.numeric(decomp$time.series[, "seasonal"]),
      Residuo = as.numeric(decomp$time.series[, "remainder"])
    )
    
    return(list(success = TRUE, data = result, n = n))
  }, error = function(e) {
    return(list(success = FALSE, error = paste("Error en STL:", e$message)))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: DESCOMPOSICIÓN CLÁSICA (ADITIVA O MULTIPLICATIVA)
# -------------------------------------------------------------------
perform_classical_decomposition <- function(serie, type = "additive", frecuencia = 7) {
  tryCatch({
    serie_clean <- as.numeric(na.omit(serie))
    
    if (length(serie_clean) < frecuencia * 2) {
      return(list(success = FALSE, error = "Datos insuficientes para descomposición clásica (mínimo 2 períodos completos)"))
    }
    
    # Para descomposición multiplicativa, los datos deben ser positivos
    if (type == "multiplicative" && any(serie_clean <= 0, na.rm = TRUE)) {
      # Si hay valores <= 0, agregar un pequeño desplazamiento
      min_val <- min(serie_clean[serie_clean > 0], na.rm = TRUE)
      if (is.finite(min_val)) {
        serie_clean <- serie_clean + min_val * 0.01
      } else {
        serie_clean <- serie_clean + 0.01
      }
    }
    
    ts_serie <- ts(serie_clean, frequency = frecuencia)
    decomp <- decompose(ts_serie, type = type)
    
    result <- data.frame(
      Observado = as.numeric(decomp$x),
      Tendencia = as.numeric(decomp$trend),
      Estacional = as.numeric(decomp$seasonal),
      Residuo = as.numeric(decomp$random)
    )
    
    return(list(success = TRUE, data = result, n = nrow(na.omit(result))))
  }, error = function(e) {
    return(list(success = FALSE, error = paste("Error en descomposición clásica:", e$message)))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: DESCOMPOSICIÓN UNIFICADA (ELIGE EL MÉTODO)
# -------------------------------------------------------------------
perform_decomposition_by_type <- function(serie, method = "stl", frecuencia = 7) {
  if (method == "stl") {
    return(perform_stl_decomposition_safe(serie, frecuencia))
  } else if (method == "additive") {
    return(perform_classical_decomposition(serie, type = "additive", frecuencia))
  } else if (method == "multiplicative") {
    return(perform_classical_decomposition(serie, type = "multiplicative", frecuencia))
  } else {
    return(list(success = FALSE, error = paste("Método no reconocido:", method)))
  }
}

# -------------------------------------------------------------------
# FUNCIÓN: PRUEBA DE ESTACIONARIEDAD ADF
# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
# FUNCIÓN: DETECCIÓN AUTOMÁTICA DE DIFERENCIACIÓN
# -------------------------------------------------------------------
detect_stationarity_and_differentiate <- function(serie, verbose = FALSE) {
  tryCatch({
    serie_clean <- as.numeric(na.omit(serie))
    
    if (length(serie_clean) < 20) {
      return(list(is_stationary = FALSE, d_value = 0, p_value = NA, 
                  statistic = NA, differenced_series = serie_clean,
                  conclusion = "Datos insuficientes para ADF"))
    }
    
    adf_result <- adf.test(serie_clean, alternative = "stationary")
    is_stationary <- adf_result$p.value < 0.05
    
    if (is_stationary) {
      d_value <- 0
      differenced <- serie_clean
    } else {
      d_value <- 1
      differenced <- diff(serie_clean, differences = 1)
    }
    
    return(list(
      is_stationary = is_stationary,
      d_value = d_value,
      p_value = adf_result$p.value,
      statistic = adf_result$statistic,
      differenced_series = differenced,
      conclusion = ifelse(is_stationary, "✓ Estacionaria", "✗ No estacionaria (diferenciada)")
    ))
  }, error = function(e) {
    return(list(is_stationary = FALSE, d_value = 1, p_value = NA, 
                statistic = NA, differenced_series = diff(as.numeric(na.omit(serie)), differences = 1),
                conclusion = "Error en ADF - d=1 por defecto"))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: MÉTRICAS DE ERROR PARA PREDICCIÓN
# -------------------------------------------------------------------
forecast_accuracy <- function(forecast, actual) {
  tryCatch({
    forecast <- as.numeric(na.omit(forecast))
    actual <- as.numeric(na.omit(actual))
    
    if (length(forecast) != length(actual) || length(forecast) < 2) {
      return(data.frame(MAPE = NA, MAE = NA, RMSE = NA, MSE = NA, R2 = NA, Corr = NA))
    }
    
    denominador <- pmax(abs(actual), 0.0001)
    mape <- mean(abs((actual - forecast) / denominador), na.rm = TRUE) * 100
    mape <- min(mape, 500)
    
    mae <- mean(abs(actual - forecast), na.rm = TRUE)
    rmse <- sqrt(mean((actual - forecast)^2, na.rm = TRUE))
    mse <- mean((actual - forecast)^2, na.rm = TRUE)
    
    ss_res <- sum((actual - forecast)^2, na.rm = TRUE)
    ss_tot <- sum((actual - mean(actual, na.rm = TRUE))^2, na.rm = TRUE)
    r2 <- ifelse(ss_tot > 0, 1 - (ss_res / ss_tot), NA)
    r2 <- max(r2, -10)
    
    corr <- tryCatch(cor(actual, forecast, use = "complete.obs"), error = function(e) NA)
    
    return(data.frame(
      MAPE = round(mape, 4),
      MAE = round(mae, 2),
      RMSE = round(rmse, 2),
      MSE = round(mse, 2),
      R2 = round(r2, 4),
      Corr = round(corr, 4)
    ))
  }, error = function(e) {
    return(data.frame(MAPE = NA, MAE = NA, RMSE = NA, MSE = NA, R2 = NA, Corr = NA))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: ROLLING FORECAST CON ARIMA
# -------------------------------------------------------------------
arima_rolling_forecast <- function(history, test, order, trace = FALSE) {
  tryCatch({
    history <- as.numeric(na.omit(history))
    test <- as.numeric(na.omit(test))
    
    if (length(history) < 10 || length(test) < 1) {
      return(rep(NA, length(test)))
    }
    
    predictions <- c()
    
    for (t in 1:length(test)) {
      model <- tryCatch(
        forecast::Arima(history, order = order, method = "ML"),
        error = function(e) NULL
      )
      
      if (is.null(model)) {
        pred <- if (t == 1) history[length(history)] else predictions[length(predictions)]
      } else {
        pred <- tryCatch(
          as.numeric(forecast::forecast(model, h = 1)$mean[1]),
          error = function(e) history[length(history)]
        )
      }
      
      if (is.na(pred) || length(pred) == 0) {
        pred <- history[length(history)]
      }
      
      predictions <- c(predictions, pred)
      history <- c(history, test[t])
    }
    
    return(predictions)
  }, error = function(e) {
    return(rep(NA, length(test)))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: FORECAST DIRECTO CON ARIMA
# -------------------------------------------------------------------
arima_direct_forecast <- function(train, horizon, order) {
  tryCatch({
    train <- as.numeric(na.omit(train))
    
    if (length(train) < 20 || horizon < 1) {
      return(rep(NA, horizon))
    }
    
    model <- forecast::Arima(train, order = order, method = "ML")
    
    pred <- tryCatch({
      fc <- forecast::forecast(model, h = horizon)
      as.numeric(fc$mean)
    }, error = function(e) {
      return(rep(NA, horizon))
    })
    
    if (length(pred) != horizon) {
      pred <- c(pred, rep(NA, horizon - length(pred)))
    }
    
    return(pred)
  }, error = function(e) {
    return(rep(NA, horizon))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: BÚSQUEDA DE MEJOR MODELO ARIMA SEGÚN CRITERIO
# -------------------------------------------------------------------
find_best_arima <- function(train, p_range = 0:3, d_range = 0:2, q_range = 0:3, 
                            criterion = "AIC", trace = FALSE, auto_d = TRUE) {
  tryCatch({
    train_clean <- as.numeric(na.omit(train))
    
    if (length(train_clean) < 30) {
      return(list(order = c(0, 1, 1), model = NULL, value = NA))
    }
    
    if (auto_d) {
      stationarity_check <- detect_stationarity_and_differentiate(train_clean, verbose = trace)
      d_range <- c(stationarity_check$d_value)
    }
    
    best_value <- Inf
    best_order <- c(0, d_range[1], 1)
    best_model <- NULL
    
    for (p in p_range) {
      for (d in d_range) {
        for (q in q_range) {
          if (p == 0 && d == 0 && q == 0) next
          
          tryCatch({
            model <- forecast::Arima(train_clean, order = c(p, d, q), method = "ML")
            
            crit_value <- switch(criterion,
                                 "AIC" = AIC(model),
                                 "BIC" = BIC(model),
                                 "HQIC" = {
                                   k <- p + d + q
                                   n <- length(train_clean)
                                   -2 * logLik(model) + 2 * k * log(log(n))
                                 },
                                 AIC(model))
            
            if (!is.na(crit_value) && crit_value < best_value) {
              best_value <- crit_value
              best_order <- c(p, d, q)
              best_model <- model
              if (trace) cat(sprintf("✓ ARIMA(%d,%d,%d) - %s: %.2f\n", p, d, q, criterion, crit_value))
            }
          }, error = function(e) {})
        }
      }
    }
    
    return(list(order = best_order, model = best_model, value = best_value))
  }, error = function(e) {
    return(list(order = c(0, 1, 1), model = NULL, value = NA))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: OBTENER MEJOR MODELO PARA PREDICCIÓN (CON AUTO d)
# -------------------------------------------------------------------
get_best_model_for_prediction <- function(train, criterion = "AIC", max_pq = 3) {
  tryCatch({
    train_clean <- as.numeric(na.omit(train))
    
    if (length(train_clean) < 30) {
      return(list(success = FALSE, error = "Datos insuficientes para modelado (mínimo 30 observaciones)"))
    }
    
    # Detectar estacionariedad y d óptimo
    stationarity_check <- detect_stationarity_and_differentiate(train_clean)
    d_optimo <- stationarity_check$d_value
    
    pq_rng <- 0:max_pq
    best_value <- Inf
    best_order <- c(1, d_optimo, 1)
    best_model <- NULL
    
    for (p in pq_rng) {
      for (q in pq_rng) {
        if (p == 0 && d_optimo == 0 && q == 0) next
        
        tryCatch({
          model <- Arima(train_clean, order = c(p, d_optimo, q), method = "ML")
          
          crit_value <- switch(criterion,
                               "AIC" = AIC(model),
                               "BIC" = BIC(model),
                               "HQIC" = {
                                 k <- p + d_optimo + q
                                 n <- length(train_clean)
                                 -2 * logLik(model) + 2 * k * log(log(n))
                               },
                               AIC(model))
          
          if (!is.na(crit_value) && crit_value < best_value) {
            best_value <- crit_value
            best_order <- c(p, d_optimo, q)
            best_model <- model
          }
        }, error = function(e) {})
      }
    }
    
    if (is.null(best_model)) {
      return(list(success = FALSE, error = "No se encontró ningún modelo válido"))
    }
    
    # Calcular métricas de error en entrenamiento
    fitted_vals <- as.numeric(fitted(best_model))
    resid_analysis <- analyze_residuals(residuals(best_model))
    
    return(list(
      success = TRUE,
      model = best_model,
      order = best_order,
      criterion_value = best_value,
      criterion_used = criterion,
      d_used = d_optimo,
      is_stationary = stationarity_check$is_stationary,
      fitted_values = fitted_vals,
      residuals_analysis = resid_analysis
    ))
  }, error = function(e) {
    return(list(success = FALSE, error = paste("Error en get_best_model:", e$message)))
  })
}

# -------------------------------------------------------------------
# FUNCIÓN: ANÁLISIS DE RESIDUOS
# -------------------------------------------------------------------
analyze_residuals <- function(residuals) {
  tryCatch({
    resid_clean <- as.numeric(na.omit(residuals))
    
    if (length(resid_clean) < 5) {
      return(list(
        normal_pval = NA,
        normal_conclusion = "⚠️ Datos insuficientes para tests",
        lb_pval = NA,
        lb_conclusion = "⚠️ Datos insuficientes para tests"
      ))
    }
    
    shapiro_test <- tryCatch({
      if (length(resid_clean) > 5000) {
        resid_sample <- sample(resid_clean, 5000)
        shapiro.test(resid_sample)
      } else {
        shapiro.test(resid_clean)
      }
    }, error = function(e) NULL)
    
    lb_test <- tryCatch({
      lag_value <- min(10, max(1, length(resid_clean) %/% 5))
      Box.test(resid_clean, lag = lag_value, type = "Ljung-Box")
    }, error = function(e) NULL)
    
    return(list(
      normal_pval = ifelse(is.null(shapiro_test), NA, shapiro_test$p.value),
      normal_conclusion = ifelse(!is.null(shapiro_test) && shapiro_test$p.value > 0.05,
                                 "✅ Los residuos parecen normales", 
                                 "⚠️ Los residuos NO siguen una distribución normal"),
      lb_pval = ifelse(is.null(lb_test), NA, lb_test$p.value),
      lb_conclusion = ifelse(!is.null(lb_test) && lb_test$p.value > 0.05,
                             "✅ Los residuos son independientes", 
                             "⚠️ Existe autocorrelación en los residuos")
    ))
  }, error = function(e) {
    return(list(
      normal_pval = NA,
      normal_conclusion = "❌ Error en análisis",
      lb_pval = NA,
      lb_conclusion = "❌ Error en análisis"
    ))
  })
}

# -------------------------------------------------------------------
# CARGA DE DATOS
# -------------------------------------------------------------------
cat("\n=== CARGANDO DATOS (10 monedas, 1905 días) ===\n")

hist_data <- NULL
for (crypto in CRYPTOS) {
  cat("Cargando", crypto, "...")
  data <- get_historical_daily(crypto, limit = 1905)
  if (!is.null(data) && nrow(data) > 0) {
    hist_data <- bind_rows(hist_data, data)
    cat(" OK (", nrow(data), " días)\n")
  } else {
    cat(" FALLÓ\n")
  }
  Sys.sleep(0.3)
}

# Datos de ejemplo si la API falla
if (is.null(hist_data) || nrow(hist_data) == 0) {
  cat("\n⚠️ API sin respuesta. Creando datos de ejemplo...\n")
  set.seed(123)
  fechas <- seq.Date(as.Date("2019-01-01"), as.Date("2024-04-10"), by = "day")
  
  for (sym in CRYPTOS) {
    precio_base <- switch(sym, 
                          "BTC" = 50000, "ETH" = 3000, "USDC" = 1, "SOL" = 100, 
                          "XRP" = 0.5, "TAO" = 300, "USDT" = 1, "DOGE" = 0.1, 
                          "USD1" = 1, "ZEC" = 30, 1000)
    
    trend <- seq(0, by = 0.0002, length.out = length(fechas)) * precio_base
    noise <- cumsum(rnorm(length(fechas), 0, precio_base * 0.015))
    close <- precio_base + trend + noise
    close <- pmax(close, precio_base * 0.1)
    
    df <- data.frame(
      fecha = fechas,
      simbolo = sym,
      close = close,
      open = c(close[1], close[-length(close)]),
      high = close + abs(rnorm(length(fechas), 0, close * 0.02)),
      low = close - abs(rnorm(length(fechas), 0, close * 0.02)),
      retorno = c(0, diff(close) / close[-length(close)] * 100),
      retorno_log = c(0, diff(log(close)) * 100),
      volatilidad = runif(length(fechas), 1, 6)
    )
    hist_data <- bind_rows(hist_data, df)
  }
  cat("✅ Datos de ejemplo creados\n")
}

# Precios actuales
prices_overview <- get_price_overview(CRYPTOS)
if (is.null(prices_overview)) {
  prices_overview <- data.frame(
    simbolo = names(CRYPTOS),
    precio = c(50000, 3000, 1, 100, 0.5, 300, 1, 0.1, 1, 30),
    cambio_24h_pct = runif(10, -5, 5),
    volumen_24h = runif(10, 1e8, 1e10),
    cap_mercado = c(1e12, 4e11, 5e10, 3e10, 1e10, 5e9, 8e10, 2e10, 4e9, 1e9)
  )
}

cat("\n✅ Datos cargados:", nrow(hist_data), "filas\n")
cat("📅 Período:", min(hist_data$fecha), "→", max(hist_data$fecha), "\n")
cat("🪙 Monedas:", paste(unique(hist_data$simbolo), collapse = ", "), "\n")