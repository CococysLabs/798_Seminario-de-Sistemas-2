CREATE SCHEMA IF NOT EXISTS `proyecto_demo.ht5_retencion`;

CREATE OR REPLACE TABLE `proyecto_demo.ht5_retencion.estudiantes` (
  estudiante_id INT64,
  nombre STRING,
  correo STRING,
  telefono STRING,
  facultad STRING,
  antiguedad_ciclos INT64,
  promedio NUMERIC,
  creditos_aprobados INT64,
  riesgo_desercion INT64
);

CREATE OR REPLACE TABLE `proyecto_demo.ht5_retencion.pagos` (
  pago_id INT64,
  estudiante_id INT64,
  fecha_pago DATE,
  monto NUMERIC,
  atrasado INT64
)
PARTITION BY fecha_pago;

CREATE OR REPLACE TABLE `proyecto_demo.ht5_retencion.actividad_virtual` (
  actividad_id INT64,
  estudiante_id INT64,
  fecha_actividad DATE,
  sesiones_semana INT64,
  entregas_tardias INT64
)
PARTITION BY fecha_actividad;

TRUNCATE TABLE `proyecto_demo.ht5_retencion.estudiantes`;
TRUNCATE TABLE `proyecto_demo.ht5_retencion.pagos`;
TRUNCATE TABLE `proyecto_demo.ht5_retencion.actividad_virtual`;

INSERT INTO `proyecto_demo.ht5_retencion.estudiantes` (
  estudiante_id,
  nombre,
  correo,
  telefono,
  facultad,
  antiguedad_ciclos,
  promedio,
  creditos_aprobados,
  riesgo_desercion
)
VALUES
  (1, 'Ana Ruiz', 'ana.ruiz@usac.edu.gt', '50251110001', 'Ingenieria', 8, 82.5, 210, 0),
  (2, 'Pedro Sosa', 'pedro.sosa@usac.edu.gt', '50251110002', 'Ciencias Economicas', 3, 61.0, 72, 1),
  (3, 'Lucia Morales', 'lucia.morales@usac.edu.gt', '50251110003', 'Ingenieria', 5, 74.2, 130, 0),
  (4, 'Diego Mendez', 'diego.mendez@usac.edu.gt', '50251110004', 'Medicina', 2, 58.3, 40, 1),
  (5, 'Karen Lima', 'karen.lima@usac.edu.gt', '50251110005', 'Derecho', 7, 79.1, 180, 0),
  (6, 'Marco Leon', 'marco.leon@usac.edu.gt', '50251110006', 'Ciencias Economicas', 4, 63.4, 95, 1);

INSERT INTO `proyecto_demo.ht5_retencion.pagos` (
  pago_id,
  estudiante_id,
  fecha_pago,
  monto,
  atrasado
)
VALUES
  (9001, 1, DATE '2026-02-05', 850.00, 0),
  (9002, 2, DATE '2026-02-18', 850.00, 1),
  (9003, 3, DATE '2026-02-07', 850.00, 0),
  (9004, 4, DATE '2026-02-25', 850.00, 1),
  (9005, 5, DATE '2026-02-09', 850.00, 0),
  (9006, 6, DATE '2026-02-21', 850.00, 1),
  (9007, 1, DATE '2026-03-05', 850.00, 0),
  (9008, 2, DATE '2026-03-22', 850.00, 1),
  (9009, 3, DATE '2026-03-08', 850.00, 0),
  (9010, 4, DATE '2026-03-28', 850.00, 1);

INSERT INTO `proyecto_demo.ht5_retencion.actividad_virtual` (
  actividad_id,
  estudiante_id,
  fecha_actividad,
  sesiones_semana,
  entregas_tardias
)
VALUES
  (7001, 1, DATE '2026-03-01', 5, 0),
  (7002, 2, DATE '2026-03-01', 2, 2),
  (7003, 3, DATE '2026-03-01', 4, 1),
  (7004, 4, DATE '2026-03-01', 1, 3),
  (7005, 5, DATE '2026-03-01', 5, 0),
  (7006, 6, DATE '2026-03-01', 2, 2);
