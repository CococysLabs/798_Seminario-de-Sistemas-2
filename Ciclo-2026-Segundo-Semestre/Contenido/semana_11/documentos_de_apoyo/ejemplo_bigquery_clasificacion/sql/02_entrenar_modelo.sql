-- Semana 11 - Ejemplo simple orientado al Proyecto 2.
-- Paso 2: entrenar modelo de clasificacion de propina alta.
--
-- Reemplaza TU_PROYECTO por el ID real de tu proyecto de Google Cloud.

CREATE OR REPLACE MODEL `TU_PROYECTO.semana11_taxi_demo.modelo_clasificacion_propina_alta_demo`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['is_high_tip'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  auto_class_weights = TRUE,
  max_iterations = 20
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
FROM `TU_PROYECTO.semana11_taxi_demo.ml_features_taxi_demo`
WHERE split_col IN ('TRAIN', 'EVAL');

