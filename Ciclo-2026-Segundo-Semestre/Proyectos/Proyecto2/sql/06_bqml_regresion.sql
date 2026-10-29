-- Modelos de regresion listos para ejecutar directamente.
-- Se entrenan 2 modelos distintos y luego se comparan con MAE, MSE, RMSE y R2.

-- Modelo 1: regresion lineal.
CREATE OR REPLACE MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_lineal`
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['tip_amount'],
  l2_reg = 1.0
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
  tip_amount
FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
WHERE split_col = 'TRAIN';

-- Modelo 2: arboles potenciados.
CREATE OR REPLACE MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_boosted`
OPTIONS (
  model_type = 'BOOSTED_TREE_REGRESSOR',
  input_label_cols = ['tip_amount'],
  max_iterations = 25,
  subsample = 0.8,
  learn_rate = 0.1,
  max_tree_depth = 6
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
  tip_amount
FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
WHERE split_col = 'TRAIN';

-- Evaluacion individual del modelo lineal.
SELECT *
FROM ML.EVALUATE(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_lineal`,
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
      tip_amount
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'EVAL'
  )
);

-- Evaluacion individual del modelo boosted tree.
SELECT *
FROM ML.EVALUATE(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_boosted`,
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
      tip_amount
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'EVAL'
  )
);

-- Importancia de variables para el modelo boosted tree.
SELECT *
FROM ML.FEATURE_IMPORTANCE(MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_boosted`)
ORDER BY importance_gain DESC;

-- Comparacion consolidada de metricas.
CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.comparacion_modelos_regresion`
AS
WITH linear_eval AS (
  SELECT
    'LINEAR_REG' AS model_name,
    mean_absolute_error AS mae,
    mean_squared_error AS mse,
    SQRT(mean_squared_error) AS rmse,
    r2_score AS r2
  FROM ML.EVALUATE(
    MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_lineal`,
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
        tip_amount
      FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
      WHERE split_col = 'EVAL'
    )
  )
),
boosted_eval AS (
  SELECT
    'BOOSTED_TREE_REGRESSOR' AS model_name,
    mean_absolute_error AS mae,
    mean_squared_error AS mse,
    SQRT(mean_squared_error) AS rmse,
    r2_score AS r2
  FROM ML.EVALUATE(
    MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_boosted`,
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
        tip_amount
      FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
      WHERE split_col = 'EVAL'
    )
  )
)
SELECT *
FROM linear_eval
UNION ALL
SELECT *
FROM boosted_eval;

SELECT *
FROM `${PROJECT_ID}.${DATASET_ID}.comparacion_modelos_regresion`
ORDER BY rmse ASC;

-- Predicciones del modelo lineal sobre datos nuevos.
CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.pred_regresion_propina_lineal`
AS
SELECT
  pickup_date,
  pickup_location_id,
  dropoff_location_id,
  pickup_hour,
  tip_amount AS actual_tip_amount,
  predicted_tip_amount
FROM ML.PREDICT(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_lineal`,
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
      pickup_month,
      tip_amount
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'PREDICT'
  )
);

-- Predicciones del modelo boosted tree sobre datos nuevos.
CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.pred_regresion_propina_boosted`
AS
SELECT
  pickup_date,
  pickup_location_id,
  dropoff_location_id,
  pickup_hour,
  tip_amount AS actual_tip_amount,
  predicted_tip_amount
FROM ML.PREDICT(
  MODEL `${PROJECT_ID}.${DATASET_ID}.modelo_regresion_propina_boosted`,
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
      pickup_month,
      tip_amount
    FROM `${PROJECT_ID}.${DATASET_ID}.ml_features_taxi_2022`
    WHERE split_col = 'PREDICT'
  )
);

-- Tabla final de prediccion principal.
-- Se deja apuntando al modelo boosted tree para no romper los objetos posteriores del dashboard.
CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.pred_regresion_propina`
AS
SELECT *
FROM `${PROJECT_ID}.${DATASET_ID}.pred_regresion_propina_boosted`;
