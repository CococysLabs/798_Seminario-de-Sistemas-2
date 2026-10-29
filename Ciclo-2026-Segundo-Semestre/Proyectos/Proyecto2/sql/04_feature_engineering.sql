-- Feature engineering listo para ejecutar directamente.

CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
PARTITION BY pickup_date
CLUSTER BY split_col, payment_type, pickup_location_id, dropoff_location_id
AS
SELECT
  pickup_date,
  vendor_id,
  passenger_count,
  trip_distance,
  rate_code,
  store_and_fwd_flag,
  pickup_location_id,
  dropoff_location_id,
  payment_type,
  fare_amount,
  trip_duration_minutes,
  pickup_hour,
  pickup_day_of_week,
  pickup_month,
  is_high_tip,
  tip_amount,
  CASE
    WHEN pickup_date < '2022-10-01' THEN 'TRAIN'
    WHEN pickup_date < '2022-12-01' THEN 'EVAL'
    ELSE 'PREDICT'
  END AS split_col
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
WHERE trip_duration_minutes BETWEEN 1 AND 180
  AND tip_amount BETWEEN 0 AND 200
  AND fare_amount BETWEEN 1 AND 300;

SELECT
  split_col,
  COUNT(*) AS rows_in_split
FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
GROUP BY split_col
ORDER BY split_col;
