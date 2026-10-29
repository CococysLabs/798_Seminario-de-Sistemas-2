-- Semana 11 - Ejemplo simple orientado al Proyecto 2.
-- Paso 3: evaluar modelo de clasificacion.
--
-- Reemplaza TU_PROYECTO por el ID real de tu proyecto de Google Cloud.

-- 1. Metricas generales del modelo.
SELECT *
FROM ML.EVALUATE(
  MODEL `TU_PROYECTO.semana11_taxi_demo.modelo_clasificacion_propina_alta_demo`
);

-- 2. Matriz de confusion con umbral 0.50.
-- Si la probabilidad de propina alta es >= 0.50, el modelo predice clase 1.
SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `TU_PROYECTO.semana11_taxi_demo.modelo_clasificacion_propina_alta_demo`,
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
    FROM `TU_PROYECTO.semana11_taxi_demo.ml_features_taxi_demo`
    WHERE split_col = 'EVAL'
  ),
  STRUCT(0.50 AS threshold)
);

-- 3. Curva ROC.
-- Permite observar el comportamiento del clasificador con distintos umbrales.
SELECT *
FROM ML.ROC_CURVE(
  MODEL `TU_PROYECTO.semana11_taxi_demo.modelo_clasificacion_propina_alta_demo`
)
ORDER BY threshold;

