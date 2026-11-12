# Datos

Los datos no se incluyen en el repositorio. Son registros horarios de la estación
**Ernesto Cortissoz** (Barranquilla), descargados de la
[Integrated Surface Database (ISD)](https://www.ncei.noaa.gov/products/land-based-station/integrated-surface-database)
de NOAA.

## Archivos esperados

Guarde un archivo por año en esta carpeta con el nombre `DataYYYY.csv`:

```
Data/
├── Data2023.csv
├── Data2024.csv
└── Data2025.csv
```

La importación busca automáticamente todos los archivos que siguen esta convención,
así que para agregar un año (por ejemplo `Data2026.csv`) basta con guardarlo aquí.

## Columnas requeridas

El análisis valida que cada archivo tenga las columnas de fecha y hora (UTC),
temperatura del aire (`TMP`), punto de rocío (`DEW`) y viento (`WND`) en el
formato de la ISD.

## Antes de subir los datos

Si deciden publicar los CSV, verifiquen primero:

- la licencia y las condiciones de redistribución de NOAA;
- el tamaño de los archivos;
- que no contengan información privada;
- que cada archivo corresponda realmente al año indicado.
