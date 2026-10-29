-- 1) Tabla analitica para entrenamiento.
CREATE OR REPLACE TABLE `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes_entrenamiento` AS
SELECT
  c.cliente_id,
  c.antiguedad_meses,
  c.consumo_promedio,
  c.sesiones_mes,
  COUNTIF(s.tipo_ticket = 'reclamo') AS incidencias_soporte,
  IFNULL(SUM(v.monto), 0) AS monto_total_compras,
  c.abandono
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes` c
LEFT JOIN `project-9f4fe3c2-3919-4941-805.semana9_novashop.soporte` s
  ON c.cliente_id = s.cliente_id
LEFT JOIN `project-9f4fe3c2-3919-4941-805.semana9_novashop.ventas` v
  ON c.cliente_id = v.cliente_id
GROUP BY
  c.cliente_id,
  c.antiguedad_meses,
  c.consumo_promedio,
  c.sesiones_mes,
  c.abandono;

-- 2) Crear modelo.
CREATE OR REPLACE MODEL `project-9f4fe3c2-3919-4941-805.semana9_novashop.modelo_churn`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['abandono']
) AS
SELECT
  antiguedad_meses,
  consumo_promedio,
  sesiones_mes,
  incidencias_soporte,
  monto_total_compras,
  abandono
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes_entrenamiento`;

-- 3) Evaluar.
SELECT *
FROM ML.EVALUATE(MODEL `project-9f4fe3c2-3919-4941-805.semana9_novashop.modelo_churn`);

-- 4) Prediccion.
SELECT
  *
FROM ML.PREDICT(
  MODEL `project-9f4fe3c2-3919-4941-805.semana9_novashop.modelo_churn`,
  (
    SELECT
      antiguedad_meses,
      consumo_promedio,
      sesiones_mes,
      incidencias_soporte,
      monto_total_compras
    FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes_entrenamiento`
  )
);
