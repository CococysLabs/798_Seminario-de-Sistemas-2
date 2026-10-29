-- Script reproducible para crear y cargar el ejemplo sin depender del cargador CSV.
-- Dataset: semana9_novashop

CREATE SCHEMA IF NOT EXISTS `semana9_novashop`;

CREATE OR REPLACE TABLE `semana9_novashop.clientes` (
  cliente_id INT64,
  nombre STRING,
  correo STRING,
  telefono STRING,
  region STRING,
  antiguedad_meses INT64,
  consumo_promedio NUMERIC,
  sesiones_mes INT64,
  abandono INT64
);

CREATE OR REPLACE TABLE `semana9_novashop.ventas` (
  venta_id INT64,
  cliente_id INT64,
  fecha_venta DATE,
  region STRING,
  monto NUMERIC,
  categoria STRING
)
PARTITION BY fecha_venta
CLUSTER BY region, categoria;

CREATE OR REPLACE TABLE `semana9_novashop.soporte` (
  ticket_id INT64,
  cliente_id INT64,
  fecha_ticket DATE,
  tipo_ticket STRING,
  resuelto INT64
)
PARTITION BY fecha_ticket
CLUSTER BY tipo_ticket;

TRUNCATE TABLE `semana9_novashop.clientes`;
TRUNCATE TABLE `semana9_novashop.ventas`;
TRUNCATE TABLE `semana9_novashop.soporte`;

INSERT INTO `semana9_novashop.clientes` (
  cliente_id, nombre, correo, telefono, region, antiguedad_meses,
  consumo_promedio, sesiones_mes, abandono
)
VALUES
  (1, 'Ana López', 'ana.lopez@novashop.com', '50255550001', 'CENTRO', 24, 320.50, 18, 0),
  (2, 'Carlos Pérez', 'carlos.perez@novashop.com', '50255550002', 'OCCIDENTE', 8, 115.00, 7, 1),
  (3, 'María Gómez', 'maria.gomez@novashop.com', '50255550003', 'NORTE', 16, 240.75, 12, 0),
  (4, 'Luis Hernández', 'luis.hernandez@novashop.com', '50255550004', 'SUR', 5, 89.90, 4, 1),
  (5, 'Sofía Ramírez', 'sofia.ramirez@novashop.com', '50255550005', 'CENTRO', 31, 410.25, 21, 0),
  (6, 'José Castillo', 'jose.castillo@novashop.com', '50255550006', 'OCCIDENTE', 11, 150.40, 8, 1);

INSERT INTO `semana9_novashop.ventas` (
  venta_id, cliente_id, fecha_venta, region, monto, categoria
)
VALUES
  (1001, 1, DATE '2026-03-01', 'CENTRO', 120.50, 'TECNOLOGIA'),
  (1002, 1, DATE '2026-03-10', 'CENTRO', 200.00, 'HOGAR'),
  (1003, 2, DATE '2026-03-03', 'OCCIDENTE', 75.00, 'MODA'),
  (1004, 3, DATE '2026-03-07', 'NORTE', 140.25, 'TECNOLOGIA'),
  (1005, 4, DATE '2026-03-11', 'SUR', 50.00, 'HOGAR'),
  (1006, 5, DATE '2026-03-12', 'CENTRO', 210.00, 'TECNOLOGIA'),
  (1007, 6, DATE '2026-03-14', 'OCCIDENTE', 95.40, 'MODA'),
  (1008, 3, DATE '2026-03-20', 'NORTE', 180.10, 'HOGAR'),
  (1009, 5, DATE '2026-03-21', 'CENTRO', 220.25, 'MODA'),
  (1010, 2, DATE '2026-03-26', 'OCCIDENTE', 65.00, 'HOGAR');

INSERT INTO `semana9_novashop.soporte` (
  ticket_id, cliente_id, fecha_ticket, tipo_ticket, resuelto
)
VALUES
  (5001, 1, DATE '2026-03-05', 'consulta', 1),
  (5002, 2, DATE '2026-03-06', 'reclamo', 0),
  (5003, 2, DATE '2026-03-16', 'reclamo', 1),
  (5004, 3, DATE '2026-03-09', 'consulta', 1),
  (5005, 4, DATE '2026-03-15', 'reclamo', 0),
  (5006, 5, DATE '2026-03-18', 'consulta', 1),
  (5007, 6, DATE '2026-03-22', 'reclamo', 1);


