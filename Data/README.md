# Datos

Registros horarios de la estación **Ernesto Cortissoz** (Barranquilla, estación
80028099999), descargados de la
[Integrated Surface Database (ISD)](https://www.ncei.noaa.gov/products/land-based-station/integrated-surface-database)
de NOAA. Cubren del 1 de enero de 2023 al 24 de agosto de 2025.

| Archivo | Registros | Año de las fechas |
| --- | ---: | --- |
| `Data2023.csv` | 12 963 | 2024 |
| `Data2024.csv` | 11 502 | 2023 |
| `Data2025.csv` | 9 218 | 2025 |

> **Nota:** los nombres de `Data2023.csv` y `Data2024.csv` están intercambiados respecto
> al año de sus fechas. El análisis toma el año de la fecha de cada registro y no del nombre
> del archivo, así que los resultados no cambian; el documento metodológico lo detecta y lo
> informa en la sección 1.4.

## Convención de nombres

La importación busca automáticamente todos los archivos `DataYYYY.csv` de esta carpeta.
Para agregar un año (por ejemplo `Data2026.csv`), basta con guardarlo aquí y volver a
compilar el documento.

## Columnas requeridas

Cada archivo debe tener `DATE` (UTC), `TMP` (temperatura del aire), `DEW` (punto de rocío)
y `WND` (viento) en el formato de la ISD. También se conservan, si existen, `REPORT_TYPE`,
`LATITUDE`, `LONGITUDE`, `ELEVATION` y `NAME`.

## Licencia de los datos

Los datos de la ISD son de NOAA (National Centers for Environmental Information) y se
redistribuyen sin modificaciones. Si los usa, cite a NOAA NCEI como fuente.
