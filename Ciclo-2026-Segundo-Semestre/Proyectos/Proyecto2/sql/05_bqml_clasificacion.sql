-- Modelo de clasificacion listo para ejecutar directamente.

CREATE OR REPLACE MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_clasificacion_propina_alta`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['is_high_tip'],
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
  is_high_tip
FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
WHERE split_col = 'TRAIN';

SELECT *
FROM ML.EVALUATE(MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_clasificacion_propina_alta`);

SELECT *
FROM ML.ROC_CURVE(MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_clasificacion_propina_alta`);

SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_clasificacion_propina_alta`,
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
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'EVAL'
  ),
  STRUCT(0.50 AS threshold)
);

CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.pred_clasificacion_propina_alta`
AS
SELECT
  pickup_date,
  pickup_location_id,
  dropoff_location_id,
  pickup_hour,
  predicted_is_high_tip,
  predicted_is_high_tip_probs
FROM ML.PREDICT(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_clasificacion_propina_alta`,
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
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'PREDICT'
  )
);
