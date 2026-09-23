--Como evitar el data leakage?
--Evitar que el modelo “vea” datos del futuro o de la variable objetivo durante el entrenamiento.
--Esto puede ocurrir si, por ejemplo, calculas promedios o transformaciones usando todas las filas (incluyendo las del test) antes de dividir el dataset.

CREATE OR REPLACE MODEL `ML2.income_model`
OPTIONS(
  model_type='logistic_reg',
  input_label_cols=['income_bracket'],
  data_split_method='RANDOM',
  data_split_eval_fraction=0.2 --Dividir el dataset primero, y luego calcular el promedio solo con los datos de entrenamiento.
) AS
SELECT
  age,
  education_num,
  hours_per_week,
  occupation,
  income_bracket
FROM
  `bigquery-public-data.ml_datasets.census_adult_income`;

/*
En todo modelo de Machine Learning, los datos se dividen en dos partes:

Training set (entrenamiento): para que el modelo aprenda patrones.
Evaluation set (validación o prueba): para medir si el modelo predice correctamente con datos nuevos.

| Cantidad de filas        | Qué hace BigQuery ML                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| < 500 filas              | Usa **todas las filas** para entrenar (no se crea conjunto de evaluación porque hay pocos datos).                              |
| Entre 500 y 50,000 filas | Usa el **80% de los datos para entrenamiento** y el **20% para evaluación**, dividiendo **de forma aleatoria (RANDOM split)**. |
| > 50,000 filas           | Usa todos los datos para entrenar, pero **solo 10,000 filas aleatorias** para evaluación.                                      |

*/

CREATE OR REPLACE MODEL my_dataset.customer_churn_model
OPTIONS(
  model_type='logistic_reg',
  
) AS
SELECT * FROM ML2.customer_data;


/*
Si tienes 30,000 registros → 24,000 se usan para entrenar y 6,000 para evaluar.
Si tienes 200,000 registros → se entrenará con 190,000 y evaluará con 10,000.
*/