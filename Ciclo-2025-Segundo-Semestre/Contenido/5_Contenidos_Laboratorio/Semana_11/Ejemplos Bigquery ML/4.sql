-- Crear modelo con división temporal (CUSTOM)
CREATE OR REPLACE MODEL `ML2.covid_cases_model`
OPTIONS(
  model_type='linear_reg',
  input_label_cols=['new_confirmed']
) AS
SELECT
  date,
  country_name,
  new_confirmed,
  new_deceased,
  population,
  mobility_retail_and_recreation,
  mobility_grocery_and_pharmacy,
  mobility_workplaces,
  -- Etiqueta personalizada para división temporal
  CASE 
    WHEN date < '2022-01-01' THEN 'TRAIN'
    ELSE 'EVAL'
  END AS data_split_col
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name = 'United States'
  AND new_confirmed IS NOT NULL
  AND date BETWEEN '2021-01-01' AND '2022-06-30';

-- Queremos predecir si el número de casos nuevos (new_confirmed) será alto o bajo, usando datos antes de 2022 para entrenar y 2022 en adelante para evaluar.
-- data_split_col: etiqueta cada fila como 'TRAIN' o 'EVAL' según la fecha. Entrena con datos de 2021 y evalúa con los de 2022 (simulando un escenario real de predicción futura).