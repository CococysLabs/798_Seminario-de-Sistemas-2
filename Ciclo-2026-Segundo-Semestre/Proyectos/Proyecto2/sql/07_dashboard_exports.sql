-- Objetos finales para dashboard listos para ejecutar directamente.

CREATE OR REPLACE VIEW `${PROJECT_ID}.${DATASET_ID}.vw_daily_kpis`
AS
SELECT
  pickup_date,
  COUNT(*) AS trips,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(AVG(total_amount), 2) AS avg_ticket,
  ROUND(AVG(tip_amount), 2) AS avg_tip_amount,
  ROUND(AVG(trip_distance), 2) AS avg_trip_distance
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
GROUP BY pickup_date;

CREATE OR REPLACE VIEW `${PROJECT_ID}.${DATASET_ID}.vw_hourly_patterns`
AS
SELECT
  pickup_hour,
  pickup_day_of_week,
  COUNT(*) AS trips,
  ROUND(AVG(total_amount), 2) AS avg_total_amount,
  ROUND(AVG(tip_pct), 4) AS avg_tip_pct
FROM `${PROJECT_ID}.${DATASET_ID}.taxi_trips_2022_optimized`
GROUP BY pickup_hour, pickup_day_of_week;

CREATE OR REPLACE TABLE `${PROJECT_ID}.${DATASET_ID}.dashboard_model_comparison`
AS
SELECT
  r.pickup_date,
  r.pickup_location_id,
  r.dropoff_location_id,
  r.pickup_hour,
  r.actual_tip_amount,
  r.predicted_tip_amount,
  c.predicted_is_high_tip,
  (
    SELECT p.prob
    FROM UNNEST(c.predicted_is_high_tip_probs) AS p
    WHERE p.label = 1
  ) AS predicted_high_tip_probability
FROM `${PROJECT_ID}.${DATASET_ID}.pred_regresion_propina` r
LEFT JOIN `${PROJECT_ID}.${DATASET_ID}.pred_clasificacion_propina_alta` c
  USING (pickup_date, pickup_location_id, dropoff_location_id, pickup_hour);

CREATE OR REPLACE VIEW `${PROJECT_ID}.${DATASET_ID}.vw_prediction_summary`
AS
SELECT
  pickup_date,
  pickup_hour,
  COUNT(*) AS predictions,
  ROUND(AVG(actual_tip_amount), 2) AS avg_actual_tip_amount,
  ROUND(AVG(predicted_tip_amount), 2) AS avg_predicted_tip_amount,
  ROUND(AVG(predicted_high_tip_probability), 4) AS avg_high_tip_probability,
  ROUND(AVG(CAST(predicted_is_high_tip AS INT64)), 4) AS avg_predicted_high_tip_flag
FROM `${PROJECT_ID}.${DATASET_ID}.dashboard_model_comparison`
GROUP BY pickup_date, pickup_hour;
