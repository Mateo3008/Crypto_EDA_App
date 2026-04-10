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
  "Bitcoin"  = "BTC",
  "Ethereum" = "ETH",
  "USD Coin" = "USDC",
  "Solana"   = "SOL",
  "XRP"      = "XRP",
  "Bittensor" = "TAO",
  "Tether"   = "USDT",
  "Dogecoin" = "DOGE",
  "USD1"     = "USD1",
  "Zcash"    = "ZEC"
)

# -------------------------------------------------------------------
# FUNCIÓN: OBTENER DATOS HISTÓRICOS
# -------------------------------------------------------------------
get_historical_daily <- function(fsym, tsym = "USD", limit = 840) {
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
# CARGA DE DATOS
# -------------------------------------------------------------------
cat("\n=== CARGANDO DATOS (10 monedas, 840 días) ===\n")

hist_data <- NULL
for (crypto in CRYPTOS) {
  cat("Cargando", crypto, "...")
  data <- get_historical_daily(crypto, limit = 840)
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
  fechas <- seq.Date(as.Date("2022-01-01"), as.Date("2024-04-10"), by = "day")
  
  for (sym in names(CRYPTOS)) {
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
cat("🪙 Monedas:", paste(unique(hist_data$simbolo), collapse=", "), "\n")