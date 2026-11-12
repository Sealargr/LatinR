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

## ---- funciones-patrones-mensuales-normalizados ----
normalizar_0_100 <- function(x) {
  resultado <- rep(
    NA_real_,
    length(x)
  )

  validos <- is.finite(x)

  if (!any(validos)) {
    return(resultado)
  }

  minimo <- min(
    x[validos],
    na.rm = TRUE
  )

  maximo <- max(
    x[validos],
    na.rm = TRUE
  )

  if (isTRUE(all.equal(minimo, maximo))) {
    resultado[validos] <- 0
  } else {
    resultado[validos] <- 100 *
      (x[validos] - minimo) /
      (maximo - minimo)

    resultado[validos] <- pmin(
      100,
      pmax(
        0,
        resultado[validos]
      )
    )
  }

  round(
    resultado,
    digits = 10
  )
}

## ---- funciones-pruebas-normalidad ----
lilliefors <- function(x) {
  x <- sort(x[!is.na(x)]); n <- length(x)
  p <- pnorm((x - mean(x)) / sd(x))
  K <- max(max(seq_len(n) / n - p), max(p - (seq_len(n) - 1) / n))
  if (n <= 100) { Kd <- K; nd <- n } else { Kd <- K * ((n / 100)^0.49); nd <- 100 }
  pv <- exp(-7.01256 * Kd^2 * (nd + 2.78019) + 2.99587 * Kd * sqrt(nd + 2.78019) -
              0.122119 + 0.974598 / sqrt(nd) + 1.67997 / nd)
  if (pv > 0.1) {
    KK <- (sqrt(n) - 0.01 + 0.85 / sqrt(n)) * K
    pv <- if (KK <= 0.302) 1
    else if (KK <= 0.5) 2.76773 - 19.828315 * KK + 80.709644 * KK^2 - 138.55152 * KK^3 + 81.218052 * KK^4
    else if (KK <= 0.9) -4.901232 + 40.662806 * KK - 97.490286 * KK^2 + 94.029866 * KK^3 - 32.355711 * KK^4
    else if (KK <= 1.31) 6.198765 - 19.558097 * KK + 23.186922 * KK^2 - 12.234627 * KK^3 + 2.423045 * KK^4
    else 0
  }
  c(estadistico = K, p = pv)
}

anderson_darling <- function(x) {
  x <- sort(x[!is.na(x)]); n <- length(x)
  z <- (x - mean(x)) / sd(x)
  h <- (2 * seq_len(n) - 1) * (pnorm(z, log.p = TRUE) + rev(pnorm(-z, log.p = TRUE)))
  A <- -n - mean(h)
  AA <- (1 + 0.75 / n + 2.25 / n^2) * A
  pv <- if (AA < 0.2) 1 - exp(-13.436 + 101.14 * AA - 223.73 * AA^2)
  else if (AA < 0.34) 1 - exp(-8.318 + 42.796 * AA - 59.938 * AA^2)
  else if (AA < 0.6) exp(0.9177 - 4.279 * AA - 1.38 * AA^2)
  else if (AA < 10) exp(1.2937 - 5.709 * AA + 0.0186 * AA^2)
  else 3.7e-24
  c(estadistico = A, p = pv)
}

## ---- funciones-kmo-bartlett-tucker ----
kmo <- function(X) {
  R <- cor(X)
  A <- -cov2cor(solve(R))  # correlaciones parciales
  diag(R) <- 0; diag(A) <- 0
  sum(R^2) / (sum(R^2) + sum(A^2))
}
bartlett_esfericidad <- function(X) {
  n <- nrow(X); p <- ncol(X)
  estadistico <- -(n - 1 - (2 * p + 5) / 6) * log(det(cor(X)))
  gl <- p * (p - 1) / 2
  c(chi2 = estadistico, gl = gl, p = pchisq(estadistico, gl, lower.tail = FALSE))
}

## ---- funcion-cadena-markov-global ----
cadena_markov_global <- function(base, estado) {
  x <- base[!is.na(base[[estado]]) & !is.na(base$Fecha), c("Fecha", estado)]
  x <- x[order(x$Fecha), ]
  niveles <- levels(base[[estado]])
  consecutivo <- diff(as.numeric(x$Fecha)) == 1
  desde <- factor(x[[estado]][-nrow(x)][consecutivo], levels = niveles)
  hacia <- factor(x[[estado]][-1][consecutivo], levels = niveles)
  conteos <- table(Desde = desde, Hacia = hacia)
  sumas <- rowSums(conteos)
  P <- matrix(NA_real_, nrow(conteos), ncol(conteos), dimnames = dimnames(conteos))
  estimables <- sumas > 0
  P[estimables, ] <- sweep(conteos[estimables, , drop = FALSE],
                            1, sumas[estimables], "/")
  estacionaria <- setNames(rep(NA_real_, length(niveles)), niveles)
  if (all(estimables) && all(is.finite(P))) {
    vec <- eigen(t(P))
    indice <- which.min(abs(vec$values - 1))
    pi_est <- Re(vec$vectors[, indice])
    if (sum(pi_est) < 0) pi_est <- -pi_est
    if (sum(pi_est) > 0) estacionaria <- setNames(pi_est / sum(pi_est), niveles)
  }
  diagonal <- diag(P)
  permanencia <- setNames(rep(NA_real_, length(niveles)), niveles)
  permanencia[is.finite(diagonal) & diagonal < 1] <-
    1 / (1 - diagonal[is.finite(diagonal) & diagonal < 1])
  permanencia[is.finite(diagonal) & diagonal == 1] <- Inf
  list(transiciones = sum(conteos), conteos = conteos, P = P,
       estacionaria = estacionaria, permanencia_dias = permanencia)
}

## ---- funciones-homogeneidad ----
prueba_homogeneidad <- function(lista_conteos) {
  total <- Reduce(`+`, lista_conteos)
  P_comun <- sweep(total, 1, rowSums(total), "/")
  G2 <- 0
  for (n in lista_conteos) {
    P_e <- sweep(n, 1, pmax(rowSums(n), 1), "/")
    positivos <- n > 0
    G2 <- G2 + 2 * sum(n[positivos] * log(P_e[positivos] / P_comun[positivos]))
  }
  S <- nrow(total)
  gl <- (length(lista_conteos) - 1) * S * (S - 1)
  c(G2 = G2, gl = gl, p = pchisq(G2, gl, lower.tail = FALSE))
}

## ---- funciones-orden-markov ----
ternas_estado <- function(base, estado = "ICT_estado") {
  x <- base[order(base$Fecha), c("Fecha", estado)]
  n <- nrow(x)
  ok <- diff(as.numeric(x$Fecha))[-1] == 1 & diff(as.numeric(x$Fecha))[-(n - 1)] == 1
  data.frame(Ayer = x[[estado]][1:(n - 2)][ok],
             Hoy = x[[estado]][2:(n - 1)][ok],
             Manana = x[[estado]][3:n][ok])
}
prueba_orden <- function(base) {
  tr <- ternas_estado(base)
  n3 <- table(tr$Ayer, tr$Hoy, tr$Manana)          # n_{ijk}
  n_ij <- apply(n3, c(1, 2), sum)                  # n_{ij.}
  n_jk <- apply(n3, c(2, 3), sum)                  # n_{.jk}
  n_j <- apply(n3, 2, sum)                         # n_{.j.}
  n_k <- apply(n3, 3, sum)                         # n_{..k}
  N <- sum(n3); S <- dim(n3)[1]
  # Orden 1 frente a orden 2
  G2_12 <- 0
  for (i in 1:S) for (j in 1:S) for (k in 1:S) {
    if (n3[i, j, k] > 0) {
      G2_12 <- G2_12 + 2 * n3[i, j, k] *
        log((n3[i, j, k] / n_ij[i, j]) / (n_jk[j, k] / n_j[j]))
    }
  }
  # Orden 0 frente a orden 1 (independencia entre hoy y mañana)
  G2_01 <- 0
  for (j in 1:S) for (k in 1:S) {
    if (n_jk[j, k] > 0) {
      G2_01 <- G2_01 + 2 * n_jk[j, k] * log((n_jk[j, k] / n_j[j]) / (n_k[k] / N))
    }
  }
  gl_12 <- S * (S - 1)^2; gl_01 <- (S - 1)^2
  # BIC de cada orden (menor es mejor)
  logL0 <- sum(n_k[n_k > 0] * log(n_k[n_k > 0] / N))
  logL1 <- logL0 + G2_01 / 2
  logL2 <- logL1 + G2_12 / 2
  bic <- -2 * c(logL0, logL1, logL2) + log(N) * c(S - 1, S * (S - 1), S^2 * (S - 1))
  data.frame(Ternas = N,
             G2_orden0_vs_1 = round(G2_01, 1), gl_01 = gl_01,
             p_orden0_vs_1 = fmt_p(pchisq(G2_01, gl_01, lower.tail = FALSE)),
             G2_orden1_vs_2 = round(G2_12, 1), gl_12 = gl_12,
             p_orden1_vs_2 = fmt_p(pchisq(G2_12, gl_12, lower.tail = FALSE)),
             p_num_12 = pchisq(G2_12, gl_12, lower.tail = FALSE),
             BIC_orden0 = round(bic[1], 1), BIC_orden1 = round(bic[2], 1),
             BIC_orden2 = round(bic[3], 1),
             Orden_BIC = which.min(bic) - 1)
}

## ---- funciones-rachas ----
rachas_observadas <- function(base, estado = "ICT_estado") {
  x <- base[order(base$Fecha), ]
  corte <- c(TRUE, diff(as.numeric(x$Fecha)) != 1 |
               x[[estado]][-1] != x[[estado]][-nrow(x)])
  grupo <- cumsum(corte)
  data.frame(Estado = x[[estado]][corte], Duracion = as.integer(table(grupo)))
}

## ---- funciones-convergencia-pn ----
potencias <- function(P, n_max = 15) {
  Pn <- diag(nrow(P)); salida <- list()
  for (n in 1:n_max) { Pn <- Pn %*% P; salida[[n]] <- Pn }
  salida
}

## ---- funciones-descomposicion-lmg ----
r2_modelo <- function(variables, base, respuesta = "AT_max") {
  if (length(variables) == 0) return(0)
  summary(lm(reformulate(variables, response = respuesta), data = base))$r.squared
}

lmg <- function(base, variables) {
  p <- length(variables)
  aporte <- setNames(numeric(p), variables)
  for (variable in variables) {
    otras <- setdiff(variables, variable)
    for (tam in 0:length(otras)) {
      subconjuntos <- if (tam == 0) list(character(0)) else
        combn(otras, tam, simplify = FALSE)
      peso <- factorial(tam) * factorial(p - tam - 1) / factorial(p)
      for (conjunto in subconjuntos) {
        aporte[variable] <- aporte[variable] + peso *
          (r2_modelo(c(conjunto, variable), base) - r2_modelo(conjunto, base))
      }
    }
  }
  aporte
}
