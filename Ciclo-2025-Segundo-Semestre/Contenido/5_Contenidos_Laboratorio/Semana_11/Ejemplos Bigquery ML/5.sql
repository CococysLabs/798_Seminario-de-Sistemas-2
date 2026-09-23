-- Ingeniería de características (features) • Justificar las variables elegidas y, cuando aplique, crear features derivadas (p. ej., hora del día, día de la semana, binning de distancia, interacciones sencillas). • Tratar valores atípicos y nulos de forma consistente; explicar decisiones (recorte, imputación, exclusión).


-- Justificar variables
--pickup_datetime: útil para derivar hora y día de la semana.
--pickup_location_id:  influye en el tráfico o tipo de zona.
--passenger_count: podría afectar la distancia promedio.

-- features derivadas
SELECT
  trip_distance,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  CASE WHEN trip_distance > 10 THEN 'long' ELSE 'short' END AS distance_bin
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`;


-- Tratar valores 
SELECT
  IFNULL(passenger_count, 1) AS passenger_count,  -- Imputar nulos con 1
  IF(trip_distance > 10000, 10000, trip_distance) AS Distancia_maxima  -- Recortar las distancias ridiculamente grandes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
;
-- Siempre documentar el motivo esos cambios (ej. "Se recortaron tarifas mayores a $200 porque representan <0.1% de los viajes y distorsionan el promedio").
