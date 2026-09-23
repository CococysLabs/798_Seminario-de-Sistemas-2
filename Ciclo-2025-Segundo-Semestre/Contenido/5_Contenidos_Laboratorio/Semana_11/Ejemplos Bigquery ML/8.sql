-- Generar predicciones con ML.PREDICT sobre el conjunto de prueba (o un holdout temporal) y guardar los resultados en una tabla/vista para el dashboard. • Para el tablero, contrastar valor real vs. predicho y añadir visualizaciones que expliquen el comportamiento por variables relevantes (p. ej., error por hora del día).


-- para predecir si un viaje tendrá propina alta (1) o baja (0).
CREATE OR REPLACE TABLE ML2.resultados_predicciones AS
SELECT
  *,
  predicted_tip_binaria AS propina_predicha,
  (SELECT prob FROM UNNEST(predicted_tip_binaria_probs) WHERE label = 1) AS probabilidad_alta
FROM ML.PREDICT(
  MODEL `ML2.modelo_propinas`,
  (
    SELECT
      passenger_count,
      trip_distance,
      fare_amount,
      EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
    WHERE EXTRACT(YEAR FROM pickup_datetime) = 2020
    LIMIT 10000
  )
);

--comparo

SELECT
  t.tip_amount,
  CASE WHEN t.tip_amount > 5 THEN 1 ELSE 0 END AS propina_real,
  p.predicted_tip_binaria AS propina_predicha,
  (SELECT prob FROM UNNEST(p.predicted_tip_binaria_probs) WHERE label = 1) AS probabilidad_alta,
  p.pickup_hour,
  ABS(CASE WHEN t.tip_amount > 5 THEN 1 ELSE 0 END - p.predicted_tip_binaria) AS error
FROM (
  SELECT
    passenger_count,
    trip_distance,
    fare_amount,
    EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
    tip_amount,
    total_amount
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
  WHERE EXTRACT(YEAR FROM pickup_datetime) = 2020
  LIMIT 10000
) t
JOIN ML2.resultados_predicciones p
USING(passenger_count, trip_distance, fare_amount, pickup_hour);






