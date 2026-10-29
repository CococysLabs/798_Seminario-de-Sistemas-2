# Dashboard de Looker Studio para Proyecto 2

Este documento deja el tablero definido para que cumplas los requerimientos visuales del Proyecto 2 usando las vistas y tablas finales generadas en BigQuery.

## 1. Fuente de datos

Conecta Looker Studio a BigQuery y agrega estas 4 fuentes:

- `${PROJECT_ID}.${DATASET_ID}.vw_daily_kpis`
- `${PROJECT_ID}.${DATASET_ID}.vw_hourly_patterns`
- `${PROJECT_ID}.${DATASET_ID}.vw_prediction_summary`
- `${PROJECT_ID}.${DATASET_ID}.dashboard_model_comparison`

Si el conector te pide credenciales, usa:

- proyecto: `${PROJECT_ID}`
- dataset: `${DATASET_ID}`
- ubicacion: `${BQ_LOCATION}`

## 2. Estructura recomendada del tablero

### Pagina 1. Resumen ejecutivo

Agrega estas tarjetas KPI usando `vw_daily_kpis`:

- `SUM(trips)` como total de viajes
- `SUM(total_revenue)` como ingreso total
- `AVG(avg_ticket)` como ticket promedio
- `AVG(avg_tip_amount)` como propina promedio

Agrega estos graficos:

- serie temporal: dimension `pickup_date`, metricas `trips` y `total_revenue`
- barras: dimension `pickup_date`, metrica `avg_ticket`

Filtros recomendados:

- control de rango de fechas sobre `pickup_date`

### Pagina 2. Patrones operativos

Usa `vw_hourly_patterns`.

Agrega estos graficos:

- heatmap o tabla dinamica: filas `pickup_hour`, columnas `pickup_day_of_week`, metrica `trips`
- barras horizontales: dimension `pickup_hour`, metrica `avg_total_amount`
- barras horizontales: dimension `pickup_hour`, metrica `avg_tip_pct`

Campo calculado sugerido para etiquetar el dia:

```text
CASE
  WHEN pickup_day_of_week = 1 THEN "Domingo"
  WHEN pickup_day_of_week = 2 THEN "Lunes"
  WHEN pickup_day_of_week = 3 THEN "Martes"
  WHEN pickup_day_of_week = 4 THEN "Miercoles"
  WHEN pickup_day_of_week = 5 THEN "Jueves"
  WHEN pickup_day_of_week = 6 THEN "Viernes"
  WHEN pickup_day_of_week = 7 THEN "Sabado"
END
```

### Pagina 3. Modelos predictivos

Usa `vw_prediction_summary` y `dashboard_model_comparison`.

Agrega estos graficos:

- serie temporal: dimension `pickup_date`, metricas `avg_actual_tip_amount` y `avg_predicted_tip_amount`
- dispersion: dimension `actual_tip_amount`, metrica `predicted_tip_amount`
- barras: dimension `pickup_hour`, metrica `avg_high_tip_probability`
- tabla: dimensiones `pickup_location_id`, `dropoff_location_id`, metricas `actual_tip_amount`, `predicted_tip_amount`, `predicted_high_tip_probability`

## 3. Visualizaciones minimas para la rubrica

Si quieres cubrir el minimo con claridad, incluye al menos estas 5:

1. Line chart de viajes e ingreso por fecha.
2. Heatmap de viajes por hora y dia.
3. Grafico de barras de propina promedio o porcentaje de propina por hora.
4. Comparacion entre propina real y propina predicha.
5. Promedio de probabilidad de propina alta por hora.

## 4. Configuracion recomendada

- activa filtros por fecha a nivel de pagina
- usa formato moneda USD para `total_revenue`, `avg_ticket`, `avg_tip_amount`, `actual_tip_amount` y `predicted_tip_amount`
- usa formato porcentaje para `avg_tip_pct`, `avg_high_tip_probability` y `avg_predicted_high_tip_flag`
- ordena `pickup_hour` ascendente
- si el scatter plot queda muy pesado, agrega un filtro por rango de fechas o limita a un subconjunto de horas

## 5. Evidencias que debes guardar

Guarda capturas en `evidencias/` de:

- conexion de Looker Studio a BigQuery
- pagina de resumen ejecutivo
- pagina de patrones operativos
- pagina de modelos predictivos
- tablero completo con filtros visibles

## 6. Enlace final

Cuando el dashboard quede listo, agrega en el README principal o en tu entrega:

- enlace de Looker Studio
- breve descripcion de cada pagina
- 3 a 5 hallazgos obtenidos del tablero
