# Cómo contribuir

## Agregar un año nuevo

1. Descargue los registros horarios de la estación Ernesto Cortissoz desde la ISD de NOAA.
2. Guárdelos en `Data/` como `DataYYYY.csv` (por ejemplo `Data2026.csv`).
3. Vuelva a compilar `analysis/01_metodologia_completa.Rmd`. No hace falta cambiar la importación.

## Estilo del código

- Funciones reutilizables en `scripts/funciones.R`; los `.Rmd` las cargan con `source()`.
- Nombres en español y en `snake_case`.
- Rutas relativas a la raíz del proyecto (abra `LatinR.Rproj`).
- Las figuras generadas van en `figures/` y los documentos compilados en `outputs/`.

## No subir

- Credenciales, tokens ni archivos `.Renviron`.
- Archivos temporales (`.Rhistory`, `.RData`, cachés de knitr, `*.aux`, `*.log`).
- Los CSV de `Data/` sin revisar antes las condiciones indicadas en `Data/README.md`.
