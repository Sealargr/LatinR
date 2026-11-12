# Funciones reutilizables de la metodología de confort térmico de Barranquilla.
#
# El documento analysis/01_metodologia_completa.Rmd carga este archivo con
# source() y muestra cada sección con knitr::read_chunk(): las líneas
# "## ---- etiqueta ----" marcan el chunk del Rmd donde se presenta cada función.
# También puede cargarse solo, para probar las funciones:
#   source("scripts/funciones.R", encoding = "UTF-8")

## ---- utilidades ----
fmt_p <- function(x) {
  ifelse(is.na(x), NA_character_,
         ifelse(x < 0.001, "<0,001", sub("\\.", ",", sprintf("%.3f", x))))
}

meses_es <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
              "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")

# fmt(): número con coma decimal y punto de miles, para usar en el texto.
fmt <- function(x, d = 1) {
  formatC(as.numeric(x), format = "f", digits = d,
          big.mark = ".", decimal.mark = ",")
}
# fmt_pt(): valor p ya redactado ("< 0,001" o "= 0,023").
fmt_pt <- function(p) ifelse(p < 0.001, "< 0,001", paste("=", fmt_p(p)))
meses_completos <- c("enero", "febrero", "marzo", "abril", "mayo", "junio",
                     "julio", "agosto", "septiembre", "octubre",
                     "noviembre", "diciembre")
# Época seca: diciembre a abril; época húmeda: mayo a noviembre.
meses_secos <- c(12, 1, 2, 3, 4)
asignar_epoca <- function(numero_mes) {
  factor(ifelse(numero_mes %in% meses_secos, "Seca", "Humeda"),
         levels = c("Seca", "Humeda"))
}
colores_epoca <- c(Seca = "#E6550D", Humeda = "#3182BD")
colores_estado <- c(Bajo = "firebrick", Medio = "khaki", Alto = "seagreen")
# Mes (en palabras) y valor donde una columna de una tabla mensual es extrema.
mes_ext <- function(tabla, columna, f = which.max) {
  meses_completos[match(as.character(tabla$Mes[f(tabla[[columna]])]), meses_es)]
}
val_ext <- function(tabla, columna, f = which.max) {
  tabla[[columna]][f(tabla[[columna]])]
}
val_mes <- function(tabla, columna, mes) {
  tabla[[columna]][as.character(tabla$Mes) == mes]
}

## ---- definir-funciones-carga-noaa ----
cargar_noaa <- function(path) {
  if (!file.exists(path)) stop("No se encontró el archivo: ", path)
  n_campos <- count.fields(path, sep = ",", quote = "\"")[1]

  if (n_campos <= 2) {
    lineas <- readLines(path, warn = FALSE, encoding = "UTF-8")
    lineas <- gsub('^"|"$', "", lineas)
    lineas <- gsub('""', '"', lineas, fixed = TRUE)
    conexion <- textConnection(lineas)
    on.exit(close(conexion), add = TRUE)
    df <- read.csv(conexion, stringsAsFactors = FALSE,
                   quote = "\"", check.names = FALSE)
  } else {
    df <- read.csv(path, stringsAsFactors = FALSE,
                   quote = "\"", check.names = FALSE)
  }

  names(df) <- trimws(toupper(names(df)))
  df
}

columnas_requeridas <- c("DATE", "TMP", "DEW", "WND")

validar_columnas <- function(df, nombre_archivo) {
  faltantes <- setdiff(columnas_requeridas, names(df))
  if (length(faltantes) > 0) {
    stop("Faltan columnas en ", nombre_archivo, ": ",
         paste(faltantes, collapse = ", "))
  }
  invisible(TRUE)
}

## ---- definir-funciones-limpieza ----
limpiar_temperatura <- function(x) {
  valor <- suppressWarnings(as.numeric(sub(",.*", "", trimws(as.character(x)))))
  valor[valor %in% c(9999, 99999)] <- NA_real_
  valor <- valor / 10
  valor[valor < -80 | valor > 60] <- NA_real_
  valor
}

limpiar_viento <- function(x) {
  partes <- strsplit(as.character(x), ",", fixed = TRUE)
  valor <- vapply(partes,
                  function(z) if (length(z) >= 4) z[4] else NA_character_,
                  character(1))
  valor <- suppressWarnings(as.numeric(valor))
  valor[valor == 9999] <- NA_real_
  valor <- valor / 10
  valor[valor < 0 | valor > 100] <- NA_real_
  valor
}
