# Metodología reproducible en R para el estudio del clima en Barranquilla

**Joseph Arias Viloria · Sebastian Ariza Grubert**
Ciencia de Datos, Universidad del Norte · Trabajo presentado en **LatinR 2026**

## Descripción

Metodología reproducible en R para analizar el confort térmico de Barranquilla con datos
horarios de NOAA (2023-2025). Calcula la humedad relativa, la temperatura aparente de
Steadman y un Índice de Confort Térmico (ICT), caracteriza sus ciclos temporales y modela
las transiciones diarias con cadenas de Markov por época climática.

R es el eje de toda la metodología: desde la importación de NOAA hasta la generación
automática de tablas, figuras y documentos.

## Objetivo

- Procesar registros meteorológicos horarios.
- Integrar temperatura, humedad relativa y velocidad del viento.
- Calcular la temperatura aparente de Steadman.
- Construir un Índice de Confort Térmico (ICT).
- Caracterizar su variación temporal.
- Analizar la persistencia de los estados de confort entre días consecutivos con cadenas de Markov.

## Fuente de datos

Registros horarios de la estación **Ernesto Cortissoz** de la Integrated Surface Database
(ISD) de NOAA, años 2023, 2024 y 2025. Los CSV no se incluyen; ver
[`Data/README.md`](Data/README.md) para obtenerlos.

## Metodología

```
NOAA
  ↓
Importación y validación en R
  ↓
Limpieza y hora local (America/Bogota)
  ↓
Humedad relativa de Magnus
  ↓
Temperatura aparente de Steadman
  ↓
ICT diario
  ↓
Análisis temporal
  ↓
Cadenas de Markov por época
```

**Procesamiento.** Búsqueda automática de los archivos `DataYYYY.csv`, validación de
columnas, limpieza de temperatura, punto de rocío y viento, conversión de UTC a
`America/Bogota`, promedio de reportes dentro de una misma hora, humedad relativa con la
fórmula de Magnus y conservación de los días con al menos 18 horas válidas.

**Épocas climáticas.** Se delimitaron a partir del patrón mensual observado en R:
época seca (diciembre-abril) y época húmeda (mayo-noviembre). La humedad y el viento
muestran una relación inversa fuerte (Spearman ≈ −0,81).

**Temperatura aparente (Steadman, a la sombra).**

$$e = \frac{HR}{100}\, 6.105 \exp\left(\frac{17.27\,TMP}{237.7 + TMP}\right)$$

$$AT = TMP + 0.33\,e - 0.70\,WND - 4$$

**Índice de Confort Térmico.** Con la temperatura aparente máxima de cada día:

$$ICT_d = 100\,\frac{AT_{\max}^{(\max)} - AT_{\max,d}}{AT_{\max}^{(\max)} - AT_{\max}^{(\min)}}$$

Un ICT alto indica mayor confort relativo y uno bajo, mayor carga térmica. La escala es
relativa al periodo analizado; no es universal ni clínica.

**Cadenas de Markov.** El ICT se divide en tres estados (bajo, medio y alto) y solo se
cuentan transiciones entre días exactamente consecutivos, con una matriz por época.

## Principales resultados

- El mayor confort relativo se concentra al comienzo del año, sobre todo en febrero.
- Septiembre presenta el menor confort mensual; la recuperación empieza hacia noviembre y diciembre.
- La temperatura aparente diaria más alta ocurre aproximadamente entre las 11:00 y las 14:00.
- Entre épocas cambian más la humedad, el viento y la temperatura aparente que la temperatura del aire.
- Persistencia: en la época seca, alto → alto 77 % (alto → bajo 2 %); en la húmeda, bajo → bajo 65 % (bajo → alto 8 %).
  Los cambios entre extremos suelen pasar por el estado medio.
- Una prueba de homogeneidad indica que las matrices difieren entre épocas, lo que respalda
  usar una cadena por época (no es por sí sola una validación completa del supuesto de Markov).

## Estructura del repositorio

```
LatinR/
├── README.md
├── LICENSE
├── CITATION.cff
├── CONTRIBUTING.md
├── LatinR.Rproj
├── requirements.R
├── analysis/      # Documentos R Markdown y resumen en LaTeX
├── scripts/       # Funciones reutilizables (funciones.R) y etapas del flujo
├── outputs/       # HTML y PDF generados
├── figures/       # Figuras generadas
├── Data/          # CSV de NOAA (no versionados) e instrucciones
└── docs/          # Página publicada con GitHub Pages
```

## Requisitos

- R (≥ 4.2) y, opcionalmente, RStudio.
- Paquetes: `dplyr`, `tidyr`, `ggplot2`, `rmarkdown`, `knitr`.

## Reproducción

```r
# 1. Clonar el repositorio y abrir LatinR.Rproj
# 2. Instalar los paquetes
source("requirements.R")
# 3. Guardar Data2023.csv, Data2024.csv y Data2025.csv en Data/
# 4. Compilar el análisis
rmarkdown::render("analysis/01_metodologia_completa.Rmd", output_dir = "outputs")
```

## Autores

- Joseph Arias Viloria
- Sebastian Ariza Grubert

Estudiantes de Ciencia de Datos, Universidad del Norte.

## Licencia

Distribuido bajo la licencia incluida en [`LICENSE`](LICENSE).

## Cita

Si utiliza este trabajo, cítelo con la información de [`CITATION.cff`](CITATION.cff).
