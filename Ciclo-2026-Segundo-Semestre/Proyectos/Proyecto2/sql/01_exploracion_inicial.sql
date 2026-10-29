-- Exploracion inicial del dataset publico.
-- Ajustado al esquema real del dataset en BigQuery.

-- Ver esquema de la tabla publica.
SELECT
  column_name,
  data_type,
  is_nullable,
  ordinal_position
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'tlc_yellow_trips_2022'
ORDER BY ordinal_position;

SELECT
  COUNT(*) AS total_rows,
  MIN(pickup_datetime) AS min_pickup_datetime,
  MAX(pickup_datetime) AS max_pickup_datetime,
  MIN(dropoff_datetime) AS min_dropoff_datetime,
  MAX(dropoff_datetime) AS max_dropoff_datetime,
  MIN(trip_distance) AS min_trip_distance,
  MAX(trip_distance) AS max_trip_distance
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

SELECT
  EXTRACT(MONTH FROM pickup_datetime) AS pickup_month,
  COUNT(*) AS trips,
  ROUND(AVG(total_amount), 2) AS avg_total_amount,
  ROUND(AVG(trip_distance), 2) AS avg_trip_distance
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_month
ORDER BY pickup_month;

SELECT
  payment_type,
  COUNT(*) AS trips,
  ROUND(AVG(tip_amount), 2) AS avg_tip_amount,
  ROUND(AVG(fare_amount), 2) AS avg_fare_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY payment_type
ORDER BY trips DESC;

SELECT
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  COUNT(*) AS trips,
  ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
  ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_hour
ORDER BY pickup_hour;

SELECT
  pickup_location_id,
  dropoff_location_id,
  COUNT(*) AS trips,
  ROUND(SUM(total_amount), 2) AS total_revenue
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_location_id, dropoff_location_id
ORDER BY trips DESC
LIMIT 20;
