-- 1) Consulta poco eficiente.
SELECT *
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.ventas`
WHERE categoria = 'TECNOLOGIA';

-- 2) Consulta mas eficiente: menos columnas y filtro sobre particion.
SELECT
  cliente_id,
  fecha_venta,
  monto
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.ventas`
WHERE categoria = 'TECNOLOGIA'
  AND fecha_venta BETWEEN '2026-03-01' AND '2026-03-31';

-- 3) Vista logica para ventas con cliente.
CREATE OR REPLACE VIEW `project-9f4fe3c2-3919-4941-805.semana9_novashop.v_ventas_clientes` AS
SELECT
  v.venta_id,
  v.fecha_venta,
  v.region,
  v.monto,
  v.categoria,
  c.cliente_id,
  c.nombre,
  c.antiguedad_meses,
  c.abandono
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.ventas` v
JOIN `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes` c
  ON v.cliente_id = c.cliente_id;

DROP MATERIALIZED VIEW `project-9f4fe3c2-3919-4941-805.semana9_novashop.mv_ventas_diarias_region`;

-- 4) Vista materializada para consumo frecuente.
CREATE MATERIALIZED VIEW IF NOT EXISTS `project-9f4fe3c2-3919-4941-805.semana9_novashop.mv_ventas_diarias_region` AS
SELECT
  fecha_venta,
  region,
  COUNT(*) AS total_transacciones,
  SUM(monto) AS ventas_totales
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.ventas`
GROUP BY fecha_venta, region;


-- 5) Consulta sobre la vista materializada.
SELECT *
FROM `project-9f4fe3c2-3919-4941-805.semana9_novashop.mv_ventas_diarias_region`
ORDER BY fecha_venta, region;
