# Instala los paquetes necesarios para reproducir el análisis.
paquetes <- c(
  "dplyr",
  "tidyr",
  "ggplot2",
  "rmarkdown",
  "knitr"
)

faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]

if (length(faltantes) > 0) {
  install.packages(faltantes)
}
