-- Script listo para ejecutar con variables parametrizadas.
DECLARE source_start_date DATE DEFAULT DATE '${SOURCE_START_DATE}';
DECLARE source_end_date DATE DEFAULT DATE '${SOURCE_END_DATE}';

CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
PARTITION BY pickup_date
CLUSTER BY vendor_id, pickup_location_id, dropoff_location_id, payment_type
AS
WITH source_data AS (
  SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    DATE(pickup_datetime) AS pickup_date,
    passenger_count,
    trip_distance,
    rate_code,
    store_and_fwd_flag,
    pickup_location_id,
    dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    imp_surcharge,
    airport_fee,
    total_amount
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE DATE(pickup_datetime) BETWEEN source_start_date AND source_end_date
)
SELECT
  vendor_id,
  pickup_datetime,
  dropoff_datetime,
  pickup_date,
  passenger_count,
  trip_distance,
  rate_code,
  store_and_fwd_flag,
  pickup_location_id,
  dropoff_location_id,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  imp_surcharge,
  airport_fee,
  total_amount,
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) AS trip_duration_minutes,
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_day_of_week,
  EXTRACT(MONTH FROM pickup_datetime) AS pickup_month,
  SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) AS tip_pct,
  IF(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) >= 0.20, 1, 0) AS is_high_tip
FROM source_data
WHERE pickup_datetime IS NOT NULL
  AND dropoff_datetime IS NOT NULL
  AND dropoff_datetime >= pickup_datetime
  AND passenger_count BETWEEN 1 AND 6
  AND trip_distance > 0
  AND trip_distance <= 100
  AND fare_amount > 0
  AND fare_amount <= 500
  AND tip_amount >= 0
  AND total_amount > 0
  AND total_amount <= 1000;
