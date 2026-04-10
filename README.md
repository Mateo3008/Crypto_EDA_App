# Crypto EDA Dashboard

**Análisis Exploratorio de Criptomonedas con R/Shiny**  
Mateo Barrios · Rafael Romero — Proyecto Académico 2026

---

## ¿Qué hace este proyecto?

Dashboard interactivo que consume datos en tiempo real de la API de [CryptoCompare](https://min-api.cryptocompare.com/) para analizar el comportamiento histórico de 10 criptomonedas. El análisis está orientado hacia la construcción futura de un modelo predictivo de precios basado en ARIMA.

**Monedas analizadas:** BTC · ETH · USDC · SOL · XRP · TAO · USDT · DOGE · USD1 · ZEC

---

## Módulos del dashboard

| Pestaña | Contenido |
|---|---|
| **Introducción** | Contexto del proyecto, objetivo, integrantes |
| **Visión General** | Precios actuales, capitalización de mercado, volumen 24h |
| **Precios** | Serie temporal, medias móviles, Bandas de Bollinger, candlestick |
| **Retornos & Riesgo** | Distribución de retornos, VaR 95%, CVaR, Sharpe, drawdown |
| **Correlaciones** | Heatmap de correlación, scatter entre pares, análisis de diversificación |
| **Comparador** | Rendimiento acumulado normalizado en base 100 |
| **Análisis (EDA → Modelo)** | Box plot, descomposición STL, ACF/PACF, test ADF, contextualización ARIMA |

---

## Requisitos

- R >= 4.2.0
- RStudio (recomendado) o R desde terminal

---

## Opción 1 — Correr en local

### 1. Clonar el repositorio o descargar archivo .zip del siguiente enlace

https://github.com/Mateo3008/Crypto_EDA_App/tree/main

### 2. Abrir en RStudio

Abre cualquiera de los tres archivos (`global.R`, `ui.R` o `server.R`) desde RStudio. Los tres deben estar en la misma carpeta.

### 3. Instalar dependencias

Ejecuta esto una sola vez en la consola de R:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "tidyverse",
  "plotly",
  "DT",
  "lubridate",
  "scales",
  "jsonlite",
  "httr",
  "zoo",
  "forecast",
  "tseries"
))
```

### 4. Correr la app

```r
shiny::runApp(".")
```

O desde RStudio con el botón **Run App** que aparece en la esquina superior derecha al abrir cualquiera de los archivos.

---

## Opción 2 — Despliegue en shinyapps.io ⭐ recomendado

Esta opción publica la app en un link público. Cualquier persona puede abrirla en el navegador **sin instalar R ni ninguna librería**.

### 1. Crear cuenta gratuita

Ir a [https://www.shinyapps.io/](https://www.shinyapps.io/) y registrarse. El plan gratuito incluye hasta 5 apps activas y 25 horas de uso mensual — más que suficiente para un proyecto académico.

### 2. tener descargado el repositorio y descomprimido

https://github.com/Mateo3008/Crypto_EDA_App/tree/main

### 3. Instalar dependencias y rsconnect

```r
install.packages(c(
  "shiny", "shinydashboard", "tidyverse", "plotly",
  "DT", "lubridate", "scales", "jsonlite", "httr",
  "zoo", "forecast", "tseries", "rsconnect"
))
```

### 4. Conectar tu cuenta de shinyapps.io

En el sitio de shinyapps.io ve a **Account → Tokens → Show** y copia el comando que aparece. Se ve así:

```r
rsconnect::setAccountInfo(
  name   = "tu-usuario",
  token  = "TU_TOKEN",
  secret = "TU_SECRET"
)
```

Pégalo en la consola de RStudio y ejecútalo.

### 5. Publicar la app

Con la carpeta del proyecto abierta en RStudio, ejecuta:

```r
rsconnect::deployApp(".")
```

RStudio sube todos los archivos automáticamente. Al terminar abre el link en el navegador. Queda algo así:

https://mateobarrios.shinyapps.io/Crypto_EDA_App/

Ese link se puede compartir con el profesor o cualquier persona directamente.

---

## Estructura del proyecto

```
Crypto_EDA_App/
├── global.R      # Librerías, configuración API, carga de datos
├── ui.R          # Interfaz de usuario (shinydashboard)
├── server.R      # Lógica reactiva y gráficos
└── www/
    └── crypto.svg  # Logo de la aplicación
```

---

## Fuente de datos

La app usa la **CryptoCompare API** para obtener:

- Datos OHLCV diarios (~840 días de historial por moneda)
- Precio spot, capitalización y volumen en tiempo real

Si la API no responde al iniciar, la app genera automáticamente datos de ejemplo para que el dashboard siga funcionando sin interrupciones.

**Endpoint historial:**
```
GET https://min-api.cryptocompare.com/data/v2/histoday
    ?fsym={SYMBOL}&tsym=USD&limit=840&api_key={KEY}
```

**Endpoint precios actuales:**
```
GET https://min-api.cryptocompare.com/data/pricemultifull
    ?fsyms={SYMBOLS}&tsyms=USD&api_key={KEY}
```

---

## Análisis incluidos

### Estadísticos descriptivos
- Media, mediana, desviación estándar, asimetría, curtosis
- VaR 95% y CVaR (Expected Shortfall)
- Sharpe ratio anualizado y volatilidad anualizada

### Series de tiempo (EDA orientado al modelo)
- Descomposición STL (tendencia + estacionalidad + residuo)
- Funciones ACF y PACF con bandas de confianza al 95%
- Test Augmented Dickey-Fuller (ADF) de estacionariedad
- Box plot interactivo de precio de cierre por mes
- Contextualización teórica del modelo ARIMA(p,d,q)

### Próxima fase
Los modelos ARIMA completos con validación train/test, evaluación de error (MAE, RMSE) y forecast formal se implementarán en la siguiente entrega del proyecto.

---

## Dependencias principales

| Librería | Uso |
|---|---|
| `shiny` + `shinydashboard` | Framework de la app |
| `tidyverse` | Manipulación y transformación de datos |
| `plotly` | Gráficos interactivos |
| `DT` | Tablas interactivas |
| `httr` + `jsonlite` | Conexión a la API REST |
| `zoo` | Medias móviles y ventanas rodantes |
| `forecast` | `auto.arima()`, ACF, PACF |
| `tseries` | Test ADF de estacionariedad |
| `rsconnect` | Despliegue en shinyapps.io |

---

## Equipo

Mateo Barrios Royet-
Rafael Romero

---

*Fuente de datos: [CryptoCompare API](https://min-api.cryptocompare.com/) · Framework: [R Shiny](https://shiny.posit.co/) · Despliegue: [shinyapps.io](https://www.shinyapps.io/)*
