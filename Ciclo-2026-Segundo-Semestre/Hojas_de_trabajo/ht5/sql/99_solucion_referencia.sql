-- Solucion de referencia para la HT5.

CREATE OR REPLACE VIEW `proyecto_demo.ht5_retencion.v_estudiantes_negocio` AS
SELECT
  estudiante_id,
  nombre,
  facultad,
  antiguedad_ciclos,
  promedio,
  creditos_aprobados
FROM `proyecto_demo.ht5_retencion.estudiantes`;

-- Consulta poco eficiente.
SELECT *
FROM `proyecto_demo.ht5_retencion.pagos`
WHERE atrasado = 1;

-- Consulta optimizada.
SELECT
  estudiante_id,
  fecha_pago,
  monto
FROM `proyecto_demo.ht5_retencion.pagos`
WHERE atrasado = 1
  AND fecha_pago BETWEEN '2026-02-01' AND '2026-03-31';

CREATE MATERIALIZED VIEW IF NOT EXISTS `proyecto_demo.ht5_retencion.mv_indicadores_facultad` AS
SELECT
  e.facultad,
  COUNT(DISTINCT e.estudiante_id) AS total_estudiantes,
  AVG(e.promedio) AS promedio_general,
  SUM(CASE WHEN p.atrasado = 1 THEN 1 ELSE 0 END) AS pagos_atrasados,
  AVG(a.sesiones_semana) AS promedio_sesiones,
  AVG(a.entregas_tardias) AS promedio_entregas_tardias
FROM `proyecto_demo.ht5_retencion.estudiantes` e
LEFT JOIN `proyecto_demo.ht5_retencion.pagos` p
  ON e.estudiante_id = p.estudiante_id
LEFT JOIN `proyecto_demo.ht5_retencion.actividad_virtual` a
  ON e.estudiante_id = a.estudiante_id
GROUP BY
  e.facultad;
