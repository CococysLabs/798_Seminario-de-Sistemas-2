-- Hoja de Trabajo 6
-- Solucion de referencia: clasificacion de propina alta con BigQuery ML.
--
-- Reemplaza TU_PROYECTO por tu ID real de proyecto.

CREATE OR REPLACE TABLE `TU_PROYECTO.proyecto2_taxi.ht6_features_clasificacion`
PARTITION BY pickup_date
CLUSTER BY split_col, payment_type, vendor_id
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
  IF(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) >= 0.20, 1, 0) AS is_high_tip,
  CASE
    WHEN pickup_date < DATE '2022-10-01' THEN 'TRAIN'
    WHEN pickup_date < DATE '2022-12-01' THEN 'EVAL'
    ELSE 'PREDICT'
  END AS split_col
FROM `TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
WHERE pickup_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31'
  AND trip_duration_minutes BETWEEN 1 AND 180
  AND fare_amount BETWEEN 1 AND 300
  AND tip_amount BETWEEN 0 AND 200;

SELECT
  split_col,
  is_high_tip,
  COUNT(*) AS total_viajes
FROM `TU_PROYECTO.proyecto2_taxi.ht6_features_clasificacion`
GROUP BY split_col, is_high_tip
ORDER BY split_col, is_high_tip;

CREATE OR REPLACE MODEL `TU_PROYECTO.proyecto2_taxi.ht6_modelo_propina_alta`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['is_high_tip'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  auto_class_weights = TRUE,
  max_iterations = 30
) AS
SELECT
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
  split_col = 'EVAL' AS is_eval
FROM `TU_PROYECTO.proyecto2_taxi.ht6_features_clasificacion`
WHERE split_col IN ('TRAIN', 'EVAL');

-- Metricas de clasificacion.
SELECT
  precision,
  recall,
  f1_score,
  accuracy,
  roc_auc
FROM ML.EVALUATE(
  MODEL `TU_PROYECTO.proyecto2_taxi.ht6_modelo_propina_alta`
);

-- Matriz de confusion.
SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `TU_PROYECTO.proyecto2_taxi.ht6_modelo_propina_alta`,
  (
    SELECT
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
      is_high_tip
    FROM `TU_PROYECTO.proyecto2_taxi.ht6_features_clasificacion`
    WHERE split_col = 'EVAL'
  ),
  STRUCT(0.50 AS threshold)
);

CREATE OR REPLACE TABLE `TU_PROYECTO.proyecto2_taxi.ht6_predicciones_propina_alta`
AS
SELECT
  pickup_date,
  pickup_location_id,
  dropoff_location_id,
  pickup_hour,
  predicted_is_high_tip,
  predicted_is_high_tip_probs
FROM ML.PREDICT(
  MODEL `TU_PROYECTO.proyecto2_taxi.ht6_modelo_propina_alta`,
  (
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
      pickup_month
    FROM `TU_PROYECTO.proyecto2_taxi.ht6_features_clasificacion`
    WHERE split_col = 'PREDICT'
  )
);

