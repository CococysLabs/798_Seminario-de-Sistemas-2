-- Semana 11 - Ejemplo simple orientado al Proyecto 2.
-- Paso 4: aplicar el modelo sobre viajes nuevos.
--
-- Reemplaza TU_PROYECTO por el ID real de tu proyecto de Google Cloud.

CREATE OR REPLACE TABLE `TU_PROYECTO.semana11_taxi_demo.pred_clasificacion_propina_alta_demo` AS
SELECT
  trip_id,
  pickup_date,
  pickup_location_id,
  dropoff_location_id,
  pickup_hour,
  fare_amount,
  tip_amount AS actual_tip_amount_demo,
  is_high_tip AS actual_is_high_tip_demo,
  predicted_is_high_tip,
  predicted_is_high_tip_probs
FROM ML.PREDICT(
  MODEL `TU_PROYECTO.semana11_taxi_demo.modelo_clasificacion_propina_alta_demo`,
  (
    SELECT
      trip_id,
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
      tip_amount,
      is_high_tip,
      trip_duration_minutes,
      pickup_hour,
      pickup_day_of_week,
      pickup_month
    FROM `TU_PROYECTO.semana11_taxi_demo.ml_features_taxi_demo`
    WHERE split_col = 'PREDICT'
  ),
  STRUCT(0.50 AS threshold)
);

SELECT *
FROM `TU_PROYECTO.semana11_taxi_demo.pred_clasificacion_propina_alta_demo`
ORDER BY trip_id;
