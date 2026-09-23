CREATE OR REPLACE MODEL `ML2.income_model`
OPTIONS(
  model_type='logistic_reg',
  input_label_cols=['income_bracket']
) AS
SELECT
  age,
  education_num,
  hours_per_week,
  occupation,
  income_bracket
FROM
  `bigquery-public-data.ml_datasets.census_adult_income`;

--income_bracket es la variable objetivo (lo que queremos predecir).
-- Las demás columnas son variables de entrada (features).

SELECT * 
FROM ML.EVALUATE(MODEL `ML2.modelo_propinas`);
-- Cuando entrenas un modelo (por ejemplo, LOGISTIC_REG o LINEAR_REG), BigQuery ML automáticamente calcula varias métricas y las guarda.
