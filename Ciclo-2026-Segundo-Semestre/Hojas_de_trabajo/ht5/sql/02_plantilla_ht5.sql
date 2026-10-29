-- Hoja de Trabajo 5
-- Completa los espacios indicados.

-- 1) Crear una vista segura para negocio sin exponer correo ni telefono.
CREATE OR REPLACE VIEW `proyecto_demo.ht5_retencion.v_estudiantes_negocio` AS
SELECT
  -- TODO: agrega las columnas permitidas
FROM `proyecto_demo.ht5_retencion.estudiantes`;

-- 2) Escribe una consulta poco eficiente.
-- TODO

-- 3) Escribe una version optimizada de la consulta anterior.
-- TODO

-- 4) Crear una vista materializada con indicadores por facultad.
CREATE MATERIALIZED VIEW IF NOT EXISTS `proyecto_demo.ht5_retencion.mv_indicadores_facultad` AS
SELECT
  -- TODO
FROM `proyecto_demo.ht5_retencion.estudiantes` e
LEFT JOIN `proyecto_demo.ht5_retencion.pagos` p
  ON e.estudiante_id = p.estudiante_id
LEFT JOIN `proyecto_demo.ht5_retencion.actividad_virtual` a
  ON e.estudiante_id = a.estudiante_id
GROUP BY
  -- TODO
;
