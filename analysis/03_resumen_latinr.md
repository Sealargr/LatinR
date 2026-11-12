# Metodología reproducible en R para el estudio del clima en Barranquilla mediante la ciencia de datos

**Joseph Arias Viloria · Sebastian Ariza Grubert** — Universidad del Norte
Resumen escrito presentado a LatinR 2026 (trabajo #22). Versión en PDF: [`outputs/resumen.pdf`](../outputs/resumen.pdf).

**Palabras clave:** R, clima, Barranquilla, NOAA, temperatura aparente, confort térmico, cadenas de Markov.

## Abstract

Barranquilla mantiene temperaturas elevadas durante todo el año, pero la sensación térmica cambia entre meses debido a las variaciones de la humedad y el viento. Este trabajo desarrolla una metodología reproducible en R para procesar registros meteorológicos horarios de la ciudad entre 2023 y 2025 y construir un Índice de Confort Térmico (ICT) basado en la temperatura aparente de Steadman. R funcionó como eje computacional de la investigación: permitió importar y validar los archivos NOAA, limpiar y transformar los datos, convertir las observaciones a hora local, calcular la humedad relativa, caracterizar ciclos mensual y horario, construir el ICT y estimar modelos armónicos y cadenas de Markov. El flujo se integró en R Markdown para permitir recalcular resultados, tablas y figuras. El confort relativo fue mayor al comienzo del año, especialmente en febrero, y menor entre julio y septiembre, cuando disminuyó el viento y aumentaron la humedad y la temperatura aparente. Las épocas seca y húmeda presentaron dinámicas de confort diferentes.

## 1. Preparación y caracterización temporal

**Importación y validación.** Se utilizaron registros horarios de la estación Ernesto Cortissoz disponibles en la Integrated Surface Database de NOAA, desde el 1 de enero de 2023 hasta el 24 de agosto de 2025. En R, la función `cargar_noaa()` detecta diferencias de formato mediante `count.fields()`, corrige líneas delimitadas por comillas con `readLines()` y `gsub()`, y realiza la lectura con `read.csv()`. La función `validar_columnas()` comprueba la presencia de fecha, temperatura, punto de rocío y viento. Los archivos `DataYYYY.csv` se localizan, ordenan y unen automáticamente, conservando el año y el archivo de origen. El procedimiento reunió 33 683 registros y permite incorporar nuevos años agregando el archivo correspondiente.

**Limpieza y serie horaria.** Los campos compuestos de NOAA se transformaron en temperatura y punto de rocío en grados Celsius y viento en metros por segundo; los códigos de faltante se convirtieron en `NA`. Las fechas se interpretaron en UTC y se transformaron a la zona `America/Bogota`. Los reportes de una misma hora se agruparon y promediaron, produciendo 22 752 horas locales únicas. La humedad relativa se calculó mediante la ecuación de Magnus:

$$
HR = 100 \exp\left[\frac{17.625\,DEW}{243.04 + DEW} - \frac{17.625\,TMP}{243.04 + TMP}\right].
$$

El código conservó los días con al menos 18 horas válidas en temperatura, humedad y viento. De 961 días observados, 948 cumplieron simultáneamente este criterio, equivalente a una cobertura del 98,6 %.

**Caracterización mensual.** R permitió construir las series diarias y los resúmenes mensuales de temperatura media, temperatura máxima, humedad media y viento medio. La temperatura media mensual varió de 27,4 °C en febrero a 28,9 °C en julio, mientras que la máxima media pasó de 31,5 °C en febrero a 33,6 °C en septiembre. La humedad aumentó de 74,9 % en febrero a 86,7 % en noviembre. El mayor contraste correspondió al viento, con 17,1 km/h en febrero y 7,7 km/h en noviembre.

Las variables mensuales se normalizaron por separado entre 0 y 100 para comparar ciclos con unidades diferentes. Desde mayo aumentó la humedad y disminuyó el viento; entre agosto y noviembre la humedad permaneció alta y la ventilación se aproximó a su mínimo. Con base en este contraste se adoptaron dos periodos operativos: la época seca, de diciembre a abril, caracterizada por menor humedad relativa y mayor velocidad del viento, y la época húmeda, de mayo a noviembre, caracterizada por mayor humedad y menor ventilación. Estas denominaciones describen las condiciones relativas observadas y se utilizan para comparar la temperatura aparente, el ICT y sus transiciones.

La prueba de Shapiro–Wilk y las aproximaciones de Lilliefors y Anderson–Darling implementadas en R produjeron p < 0,001. Por ello se utilizaron medianas, rangos intercuartílicos y correlaciones de Spearman y Kendall. La asociación más intensa fue la relación inversa entre humedad y viento, con ρ = −0,811.

## 2. Temperatura aparente e Índice de Confort Térmico

**Temperatura aparente.** Mediante `prcomp()` y `factanal()`, R permitió evaluar la estructura conjunta de temperatura, humedad y viento. La primera componente explicó el 66,5 % de la varianza, pero sus cargas reflejaron la covariación estadística y no conservaron el sentido físico del confort. El KMO fue 0,46 en el total, 0,48 en la época seca y 0,58 en la húmeda, lo que indicó una adecuación factorial limitada. Se aplicó entonces la temperatura aparente de Steadman:

$$
e = \frac{HR}{100}\, 6.105 \exp\left(\frac{17.27\,TMP}{237.7 + TMP}\right), \qquad AT = TMP + 0.33\,e - 0.70\,WND - 4.
$$

El término $e$, asociado con la presión de vapor, aumenta la carga térmica, mientras el viento la reduce mediante enfriamiento convectivo. La temperatura aparente horaria presentó una media de 32,02 °C y una mediana de 31,93 °C. Su promedio mensual aumentó de 29,0 °C en febrero a 33,9 °C en septiembre, y el percentil 90 pasó de 33,2 a 38,4 °C. La mayor carga térmica se concentró entre las 11:00 y las 14:00. Al mediodía, la temperatura aparente alcanzó en promedio 34,3 °C en la época seca y 36,9 °C en la húmeda.

**Construcción del ICT.** R consolidó una serie final de 947 días, 413 de la época seca y 534 de la húmeda. En el 87,6 % de ellos, la temperatura aparente máxima ocurrió entre las 10:00 y las 14:00. El ICT invierte y normaliza esa máxima diaria:

$$
ICT_d = 100\, \frac{AT_{\text{máx}}^{(\text{máx})} - AT_{\text{máx},d}}{AT_{\text{máx}}^{(\text{máx})} - AT_{\text{máx}}^{(\text{mín})}}.
$$

Los valores altos representan mayor confort relativo. El ICT presentó una media de 44,33 y una mediana de 41,85. Se asoció negativamente con la temperatura máxima, ρ = −0,801, y la humedad media, ρ = −0,340, y positivamente con el viento, ρ = 0,440.

Febrero presentó la mayor mediana mensual del ICT, con 65,5, y septiembre la menor, con 27,0. Kruskal–Wallis identificó diferencias entre meses, con χ² = 397,92 y p < 0,001. El ICT medio fue 55,2 en la época seca y 35,9 en la húmeda. La comparación de Wilcoxon produjo p < 0,001, con d = 1,37, y una probabilidad de 0,84 de que un día seco elegido al azar presente mayor confort que uno húmedo.

**Ciclo anual armónico.** La evolución anual se modeló en R mediante términos seno y coseno:

$$
ICT_t = \beta_0 + \beta_1 \sin\left(\frac{2\pi t}{365.25}\right) + \beta_2 \cos\left(\frac{2\pi t}{365.25}\right) + \varepsilon_t.
$$

El modelo estimó una amplitud de 14,24 puntos, con máximo a comienzos de febrero y mínimo a comienzos de agosto, y explicó el 36,9 % de la variación diaria. Un segundo armónico elevó el R² a 39,4 % y ubicó el mínimo estimado en septiembre, permitiendo representar la asimetría del ciclo. La mejora fue moderada: el armónico anual conservó la estructura principal y el componente semestral recogió variaciones adicionales. La autocorrelación fue 0,68 a un día y 0,42 a los 30 días.

**Estados y cadenas de Markov.** Mediante `quantile()` y `cut()`, R dividió el ICT en tres estados globales:

$$
\text{Estado}(ICT_d) =
\begin{cases}
\text{Bajo}, & ICT_d \le 36{,}15,\\
\text{Medio}, & 36{,}15 < ICT_d \le 50{,}17,\\
\text{Alto}, & ICT_d > 50{,}17.
\end{cases}
$$

Las matrices se estimaron con funciones programadas en R que cuentan únicamente transiciones entre días consecutivos. En la cadena global, con 940 transiciones, los estados bajo y alto fueron más persistentes que el medio: $p_{BB} = 0{,}60$, $p_{MM} = 0{,}44$ y $p_{AA} = 0{,}68$. Su distribución estacionaria fue aproximadamente uniforme y cercana a las frecuencias marginales generadas por los terciles globales.

Las cadenas por época mostraron dinámicas opuestas. En la seca, la probabilidad estacionaria del confort alto fue 0,59 y su permanencia media 4,4 días. En la húmeda, la probabilidad estacionaria del confort bajo fue 0,52 y su permanencia media 2,9 días. Una prueba de razón de verosimilitud rechazó que ambas épocas compartieran la misma matriz, con G² = 107,8, seis grados de libertad y p < 0,001.

Los diagnósticos implementados en R evaluaron la homogeneidad entre épocas, el orden de dependencia, las rachas, la convergencia de $P^n$ y el desempeño predictivo fuera de muestra. El BIC favoreció una cadena de primer orden, aunque la época seca conservó evidencia de memoria adicional. La cadena resume la persistencia diaria, pero no toda la dependencia temporal ni las diferencias entre años.

La temperatura máxima, la humedad media y el viento medio explicaron conjuntamente el 84,4 % de la variabilidad de $AT_{\text{máx}}$. La descomposición LMG distribuyó ese R² entre temperatura máxima, con 68,6 %, viento, con 20,7 %, y humedad, con 10,7 %. El aporte del viento fue mayor en la época seca, en concordancia con las mayores velocidades registradas durante esos meses.

## Conclusiones y alcance

R constituyó el motor computacional de la investigación y permitió integrar en un flujo reproducible la limpieza, las series temporales, la temperatura aparente, el ICT, las figuras, los modelos y las cadenas de Markov. La incorporación de nuevos archivos actualiza automáticamente los resultados.

En Barranquilla, el mayor confort relativo se concentró al comienzo del año y el menor entre julio y septiembre. La humedad elevada y la menor ventilación intensificaron la carga térmica. Además, las épocas seca y húmeda presentaron dinámicas de confort diferentes.

El ICT representa confort relativo a la sombra para la estación Ernesto Cortissoz y el periodo estudiado, pues no se tiene en cuenta la radiación solar. La escala depende de los extremos observados, la máxima diaria caracteriza la franja de mayor calor y las cadenas resumen transiciones mediante probabilidades constantes dentro de cada época. El periodo permite describir el ciclo anual y la variabilidad entre años, pero no una tendencia climática de largo plazo. Una validación posterior puede incorporar radiación solar y percepción térmica local.
