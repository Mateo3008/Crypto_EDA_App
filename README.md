# Crypto EDA Dashboard

**Análisis Exploratorio de Criptomonedas con R / Shiny**  
Mateo Barrios · Rafael Romero — Proyecto Académico 2026

---

## ¿Qué hace este proyecto?

Dashboard interactivo que consume datos en tiempo real de la API de [CryptoCompare](https://min-api.cryptocompare.com/) para analizar el comportamiento histórico de 10 criptomonedas. El análisis está orientado hacia la construcción futura de un modelo predictivo de precios basado en ARIMA.

El diseño sigue un estilo fintech profesional inspirado en Bloomberg Terminal y TradingView: glassmorphism, tema claro/oscuro, animaciones de trazado progresivo en los gráficos y un overlay de carga con mensajes contextuales.

**Monedas analizadas:** BTC · ETH · USDC · SOL · XRP · TAO · USDT · DOGE · USD1 · ZEC

---

## Módulos del dashboard

| Pestaña | Contenido |
|---|---|
| **Introducción** | Hero banner, value boxes, tarjetas de monedas, objetivo del proyecto, ecuaciones LaTeX, equipo |
| **Visión General** | Precios actuales en tiempo real, capitalización de mercado, volumen 24h |
| **Precios** | Boxplot de precios, serie temporal, candlestick (últimos 60 días), **Bandas de Bollinger** |
| **Retornos & Riesgo** | Boxplot de retornos, histograma, serie temporal, volatilidad rodante 30d, VaR 95% |
| **Correlaciones** | Heatmap de correlación (Pearson / Spearman), scatter entre pares seleccionables |
| **Comparador** | Rendimiento acumulado normalizado en base 100 o porcentaje, tabla comparativa |
| **Análisis (EDA → Modelo)** | Boxplot, serie temporal, boxplot mensual, ACF, PACF, estadísticas descriptivas, test ADF, tabla comparativa de estacionariedad, contextualización ARIMA |

---

## Funcionalidades destacadas

### Bandas de Bollinger
Indicador técnico de volatilidad incluido en la pestaña **Precios**. Permite configurar:
- **Criptomoneda** a analizar
- **Período de la SMA** (5 a 60 días)
- **Desviaciones estándar k** (1 a 3)

Incluye dos gráficos: el canal de bandas sobre el precio de cierre, y el **ancho de banda relativo** como medida de volatilidad histórica.

```
BB± = SMAₙ ± k · σₙ
%Bandwidth = (BB₊ − BB₋) / SMAₙ × 100
```

### Tema claro / oscuro
Botón en el sidebar con persistencia en `localStorage`. Se recuerda entre sesiones.

### Animaciones de trazado progresivo
Los gráficos de línea se dibujan de izquierda a derecha al cargarse. Las barras crecen desde cero. La animación se repite automáticamente cada vez que se cambia un slider o selector.

### Overlay de carga contextual
Al cambiar parámetros pesados aparece un loader semitransparente con mensajes rotativos: *"Consultando API…"*, *"Calculando Bollinger…"*, *"Renderizando gráfico…"*, etc.

### Fondo de partículas interactivo
Implementado con `particles.js`. Las partículas reaccionan al cursor (modo `grab`) y tienen un ligero efecto parallax con el movimiento del mouse.

---

## Requisitos

- R >= 4.2.0
- RStudio (recomendado) o R desde terminal

---

## Opción 1 — Correr en local

### 1. Clonar el repositorio o descargar el .zip

```
https://github.com/Mateo3008/Crypto_EDA_App
```

### 2. Abrir en RStudio

Abre cualquiera de los tres archivos (`global.R`, `ui.R` o `server.R`). Los tres deben estar en la misma carpeta junto con la carpeta `www/`.

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

Ir a [https://www.shinyapps.io/](https://www.shinyapps.io/) y registrarse. El plan gratuito incluye hasta 5 apps activas y 25 horas de uso mensual.

### 2. Tener el repositorio descargado y descomprimido

```
https://github.com/Mateo3008/Crypto_EDA_App
```

### 3. Instalar dependencias y rsconnect

```r
install.packages(c(
  "shiny", "shinydashboard", "tidyverse", "plotly",
  "DT", "lubridate", "scales", "jsonlite", "httr",
  "zoo", "forecast", "tseries", "rsconnect"
))
```

### 4. Conectar tu cuenta de shinyapps.io

En el sitio ve a **Account → Tokens → Show** y copia el comando que aparece:

```r
rsconnect::setAccountInfo(
  name   = "tu-usuario",
  token  = "TU_TOKEN",
  secret = "TU_SECRET"
)
```

Pégalo en la consola de RStudio y ejecútalo.

### 5. Publicar la app

```r
rsconnect::deployApp(".")
```

RStudio sube todos los archivos automáticamente. Al terminar abre el link en el navegador:

```
https://tu-usuario.shinyapps.io/Crypto_EDA_App/
```

---

## Estructura del proyecto

```
Crypto_EDA_App/
├── global.R        # Librerías, configuración API, carga de datos
├── ui.R            # Interfaz de usuario (shinydashboard)
├── server.R        # Lógica reactiva y gráficos
├── README.md       # Este archivo
└── www/
    └── crypto.svg  # Logo de la aplicación
```

---

## Fuente de datos

La app usa la **CryptoCompare API** para obtener:

- Datos OHLCV diarios (~1905 días de historial por moneda)
- Precio spot, capitalización de mercado y volumen en tiempo real

Si la API no responde al iniciar, la app genera automáticamente datos de ejemplo con tendencia y ruido aleatorio para que el dashboard siga funcionando sin interrupciones.

**Endpoint historial:**
```
GET https://min-api.cryptocompare.com/data/v2/histoday
    ?fsym={SYMBOL}&tsym=USD&limit=1905&api_key={KEY}
```

**Endpoint precios actuales:**
```
GET https://min-api.cryptocompare.com/data/pricemultifull
    ?fsyms={SYMBOLS}&tsyms=USD&api_key={KEY}
```

---

## Análisis incluidos

### Estadísticos descriptivos
- Media, mediana, desviación estándar
- Rango, Q1, Q3, IQR
- VaR 95% (Value at Risk)

### Indicadores técnicos
- **Bandas de Bollinger** — canal de volatilidad con SMA configurable y k desviaciones estándar ajustables
- **Volatilidad rodante** — ventana de 30 días sobre retornos diarios
- **Candlestick** — OHLCV de los últimos 60 días por moneda

### Series de tiempo (EDA orientado al modelo)
- Descomposición STL (tendencia + estacionalidad + residuo) — requiere mínimo 365 días
- Funciones ACF y PACF con bandas de confianza al 95%
- Test Augmented Dickey-Fuller (ADF) de estacionariedad, individual y comparativo entre monedas
- Boxplot mensual de la variable seleccionada
- Contextualización teórica del modelo ARIMA(p,d,q)

### Ecuaciones principales

| Concepto | Fórmula |
|---|---|
| Retorno simple | `rₜ = (Pₜ − Pₜ₋₁) / Pₜ₋₁ × 100` |
| Retorno logarítmico | `rₜˡᵒᵍ = ln(Pₜ / Pₜ₋₁) × 100` |
| Descomposición STL | `Y(t) = T(t) + S(t) + R(t)` |
| Modelo ARIMA(p,d,q) | `φ(B)(1−B)ᵈ yₜ = θ(B) εₜ` |
| Banda de Bollinger | `BB± = SMAₙ ± k · σₙ` |
| Ancho de banda | `%Bw = (BB₊ − BB₋) / SMAₙ × 100` |

### Próxima fase
Los modelos ARIMA completos con validación train/test, evaluación de error (MAE, RMSE) y forecast formal se implementarán en la siguiente entrega del proyecto.

---

## Dependencias principales

| Librería | Uso |
|---|---|
| `shiny` + `shinydashboard` | Framework de la app |
| `tidyverse` | Manipulación y transformación de datos |
| `plotly` | Gráficos interactivos con animaciones |
| `DT` | Tablas interactivas |
| `httr` + `jsonlite` | Conexión a la API REST de CryptoCompare |
| `zoo` | Medias móviles, ventanas rodantes, Bollinger |
| `forecast` | `auto.arima()`, ACF, PACF |
| `tseries` | Test ADF de estacionariedad |
| `lubridate` | Manipulación de fechas |
| `scales` | Formato de ejes y etiquetas |
| `rsconnect` | Despliegue en shinyapps.io |

---

## Diseño visual

El dashboard usa un sistema de diseño inspirado en Bloomberg Terminal y TradingView:

- **Glassmorphism** — cajas semitransparentes con `backdrop-filter: blur` sobre fondo dinámico
- **Tema claro / oscuro** — conmutable con persistencia en `localStorage`
- **Tipografía Inter** — fuente usada por Figma, Linear, Vercel
- **Animaciones de trazado** — líneas se dibujan progresivamente; barras crecen desde cero
- **Partículas interactivas** — fondo animado con `particles.js`, reacción al cursor y parallax con el mouse
- **Overlay de carga** — spinner con mensajes contextuales al cambiar parámetros
- **LED indicator** — punto parpadeante verde en cada título de caja
- **Scrollbar personalizada** — gradiente naranja → azul

---

## Equipo

**Mateo Barrios** — Ciencia de Datos  
GitHub: [Mateo3008](https://github.com/Mateo3008/Crypto_EDA_App)

**Rafael Romero** — Ciencia de Datos  
GitHub: [rafaelromero06](https://github.com/rafaelromero06)

---

*Fuente de datos: [CryptoCompare API](https://min-api.cryptocompare.com/) · Framework: [R Shiny](https://shiny.posit.co/) · Despliegue: [shinyapps.io](https://www.shinyapps.io/)*