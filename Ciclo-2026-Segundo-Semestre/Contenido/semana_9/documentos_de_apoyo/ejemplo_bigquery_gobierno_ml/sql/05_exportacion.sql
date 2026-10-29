-- Exportacion de datos agregados.
EXPORT DATA OPTIONS (
  uri = 'gs://semana9-novashop-project-9f4fe3c2-3919-4941-805/semana9/exportes/ventas_region_*.csv',
  format = 'CSV',
  overwrite = true,
  header = true
) AS
SELECT *
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.v_ventas_agregadas_region`;

-- Exportacion del modelo.
EXPORT MODEL `project-9f4fe3c2-3919-4941-805.semana9_novashop.modelo_churn`
OPTIONS (
  uri = 'gs://semana9-novashop-project-9f4fe3c2-3919-4941-805/semana9/modelo_churn/'
);
