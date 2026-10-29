-- Consultas analiticas listas para copiar y pegar en BigQuery.
-- Este archivo usa directamente el proyecto y dataset definidos para el Proyecto 2.

-- Consulta base sin optimizacion.
SELECT
  DATE(pickup_datetime) AS pickup_date,
  COUNT(*) AS trips,
  ROUND(SUM(total_amount), 2) AS revenue
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) BETWEEN '2022-07-01' AND '2022-09-30'
GROUP BY pickup_date
ORDER BY pickup_date;

-- Consulta equivalente sobre tabla optimizada.
SELECT
  pickup_date,
  COUNT(*) AS trips,
  ROUND(SUM(total_amount), 2) AS revenue
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
WHERE pickup_date BETWEEN '2022-07-01' AND '2022-09-30'
GROUP BY pickup_date
ORDER BY pickup_date;

-- Franja horaria con mayor demanda.
SELECT
  pickup_hour,
  COUNT(*) AS trips,
  ROUND(AVG(total_amount), 2) AS avg_total_amount,
  ROUND(AVG(tip_pct), 4) AS avg_tip_pct
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
GROUP BY pickup_hour
ORDER BY trips DESC;

-- Top rutas por ingreso.
SELECT
  pickup_location_id,
  dropoff_location_id,
  COUNT(*) AS trips,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
GROUP BY pickup_location_id, dropoff_location_id
ORDER BY total_revenue DESC
LIMIT 25;

-- Comportamiento semanal.
SELECT
  pickup_day_of_week,
  COUNT(*) AS trips,
  ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
  ROUND(AVG(tip_amount), 2) AS avg_tip_amount
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
GROUP BY pickup_day_of_week
ORDER BY pickup_day_of_week;
