-- Script de referencia para gobierno de datos.
-- Algunas partes son conceptuales y requieren permisos especificos.

-- 1) Vista para negocio sin columnas sensibles.
--   correo STRING,
--   telefono STRING,
CREATE OR REPLACE VIEW `semana9_novashop.v_clientes_negocio` AS
SELECT
  cliente_id,
  nombre,
  region,
  antiguedad_meses,
  consumo_promedio,
  sesiones_mes,
  abandono
FROM `semana9_novashop.clientes`;

select * 
from `semana9_novashop.v_clientes_negocio`;

-- 2) Politica de acceso por fila.
-- Ejemplo: un grupo regional solo puede ver clientes de OCCIDENTE.
-- Reemplazar por un usuario o grupo real del entorno.
CREATE OR REPLACE ROW ACCESS POLICY rap_occidente
ON `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes`
GRANT TO ("user:usac.seminario.sistemas.2@gmail.com")
FILTER USING (region = 'OCCIDENTE');

DROP ALL ROW ACCESS POLICIES
ON `project-9f4fe3c2-3919-4941-805.semana9_novashop.clientes`;

CREATE OR REPLACE VIEW `semana9_novashop.v_ventas_agregadas_region` AS
SELECT
  region,
  COUNT(*) AS transacciones,
  SUM(monto) AS ventas_totales
FROM `semana9_novashop.ventas`
GROUP BY region;

-- 3) Consulta segura para validar que el analista de negocio
-- no necesita ver correo ni telefono.
SELECT *
FROM `semana9_novashop.v_clientes_negocio`
ORDER BY cliente_id;
