-- Documentar hiperparámetros
-- Cuando creamos un modelo en BigQuery ML, puedes configurar hiperparámetros que controlan cómo aprende el modelo.
-- Calcula la probabilidad de que un viaje reciba una propina mayor a 5 dólares, usando los datos del viaje.

CREATE OR REPLACE MODEL `ML2.modelo_propinas2`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['tip_binaria'],
  data_split_method = 'AUTO_SPLIT',
  l1_reg = 0.2,
  l2_reg = 0.01,
  max_iterations = 10,
  ls_init_learn_rate = 0.2
) AS
SELECT
  IF(tip_amount > 5, 1, 0) AS tip_binaria,
  fare_amount,
  trip_distance,
  passenger_count,
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
WHERE fare_amount > 0
limit 1000;


-- consultamos las métricas 
SELECT *
FROM ML.TRAINING_INFO(MODEL `ML2.modelo_propinas2`);

/*
EJEMPLO DE LA DOCU QUE QUIERO :)

Modelo: modelo_propinas
Tipo: Regresión logística
Variables: fare_amount, trip_distance, passenger_count, pickup_hour
Objetivo: tip_binaria (1 si propina > $5)
Data split: AUTO (80/20 aleatorio)
Regularización: L1 = 0.1, L2 = 0.01
Iteraciones: 50
Métrica usada: Log Loss, Accuracy
Evidencia: Resultados de ML.TRAINING_INFO y ML.EVALUATE
*/