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
(ISD) de NOAA, del 1 de enero de 2023 al 24 de agosto de 2025. Los CSV están en
[`Data/`](Data/); ver [`Data/README.md`](Data/README.md).

## Documentos

| Documento | Contenido |
| --- | --- |
| [Resumen escrito](analysis/03_resumen_latinr.md) | La metodología y los resultados en palabras (trabajo #22 de LatinR 2026) |
| [Metodología completa](analysis/01_metodologia_completa.Rmd) | Todo el análisis reproducible, con código, pruebas y diagnósticos |
| [Presentación](analysis/02_presentacion_latinr.Rmd) | Versión resumida con lo que se muestra en LatinR |

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
├── analysis/
│   ├── 01_metodologia_completa.Rmd   # Metodología completa
│   ├── 02_presentacion_latinr.Rmd    # Versión resumida para la presentación
│   └── 03_resumen_latinr.md          # Resumen escrito (trabajo #22)
├── scripts/       # funciones.R: funciones reutilizables que carga el .Rmd
├── outputs/       # HTML y PDF generados (resumen.pdf)
├── figures/       # Figuras generadas
├── Data/          # CSV de NOAA (2023-2025) y su descripción
└── docs/          # Página publicada con GitHub Pages
```

## Organización del código

El análisis completo está en [`analysis/01_metodologia_completa.Rmd`](analysis/01_metodologia_completa.Rmd).
Las funciones reutilizables (formato, carga y limpieza de NOAA, pruebas de normalidad,
KMO y Bartlett, cadenas de Markov, homogeneidad, orden, rachas y LMG) viven en
[`scripts/funciones.R`](scripts/funciones.R). El documento las carga con `source()` y las
muestra en la sección donde se explican mediante `knitr::read_chunk()`, así que el HTML
conserva todo el código sin duplicarlo. El `.Rmd` localiza la raíz del proyecto
(la carpeta con `LatinR.Rproj`), por lo que puede compilarse con el botón *Knit* o con
`rmarkdown::render()`.

## Requisitos

- R (≥ 4.2) y, opcionalmente, RStudio.
- Paquetes: `dplyr`, `tidyr`, `ggplot2`, `scales`, `rmarkdown`, `knitr`.

## Reproducción

```r
# 1. Clonar el repositorio y abrir LatinR.Rproj
# 2. Instalar los paquetes
source("requirements.R")
# 3. Compilar la metodología completa y la presentación
rmarkdown::render("analysis/01_metodologia_completa.Rmd", output_dir = "outputs")
rmarkdown::render("analysis/02_presentacion_latinr.Rmd", output_dir = "outputs")
```

## Autores

- Joseph Arias Viloria
- Sebastian Ariza Grubert

Estudiantes de Ciencia de Datos, Universidad del Norte.

## Licencia

Distribuido bajo la licencia incluida en [`LICENSE`](LICENSE).

## Cita

Si utiliza este trabajo, cítelo con la información de [`CITATION.cff`](CITATION.cff).
