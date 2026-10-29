/* =========================================================
   Consultas_Basicas_SGFoodDW.sql
   SGFoodDW - Exploración básica del Data Warehouse (Esquema estrella)
   ---------------------------------------------------------
   Instrucción para el estudiante:
   - Coloca tu carné y nombre en el comentario de CADA consulta.
   - Ejecuta y toma captura (consulta + resultados).
   ========================================================= */

USE SGFoodDW;
SET NOCOUNT ON;
GO

/* =========================================================
   A) Exploración básica (SELECT + TOP)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- A1) Ver 20 filas de DimProducto
SELECT TOP (20) * FROM dwh.DimProducto;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- A2) Ver 20 filas de DimCliente
SELECT TOP (20) * FROM dwh.DimCliente;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- A3) Ver 20 filas de DimDate
SELECT TOP (20) * FROM dwh.DimDate ORDER BY Fecha DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- A4) Ver 20 filas de FactVentas
SELECT TOP (20) * FROM dwh.FactVentas ORDER BY FactVentaKey DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- A5) Ver 20 filas de la vista "cubo"
SELECT TOP (20)
  Fecha, Producto, Categoria, Canal, Cliente, Cantidad, ImporteNeto
FROM dwh.vw_CuboVentas
ORDER BY Fecha DESC;
GO


/* =========================================================
   B) INNER JOIN (Fact + dimensiones)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- B1) Ventas detalladas (JOIN completo)
SELECT TOP (50)
  d.Fecha,
  p.Producto,
  p.Categoria,
  ca.Canal,
  c.Cliente,
  t.Tienda,
  v.Vendedor,
  f.Cantidad,
  (f.Cantidad * f.PrecioUnitario - f.Descuento) AS ImporteNeto
FROM dwh.FactVentas f
INNER JOIN dwh.DimDate d      ON d.DateKey = f.DateKey
INNER JOIN dwh.DimProducto p  ON p.ProductoKey = f.ProductoKey
INNER JOIN dwh.DimCliente c   ON c.ClienteKey = f.ClienteKey
INNER JOIN dwh.DimCanal ca    ON ca.CanalKey = f.CanalKey
INNER JOIN dwh.DimTienda t    ON t.TiendaKey = f.TiendaKey
INNER JOIN dwh.DimVendedor v  ON v.VendedorKey = f.VendedorKey
ORDER BY d.Fecha DESC;
GO


/* =========================================================
   C) WHERE (filtros básicos)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- C1) Filtrar por categoría (Bebidas)
SELECT TOP (50)
  Fecha, Producto, Categoria, Canal, Cantidad, ImporteNeto
FROM dwh.vw_CuboVentas
WHERE Categoria = 'Bebidas'
ORDER BY Fecha DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- C2) Filtrar por rango de fechas (últimos 30 días)
SELECT
  Fecha, Producto, Categoria, Canal, Cantidad, ImporteNeto
FROM dwh.vw_CuboVentas
WHERE Fecha >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
ORDER BY Fecha DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- C3) Filtrar por cliente y canal
SELECT TOP (50)
  Fecha, Cliente, Canal, Producto, Cantidad, ImporteNeto
FROM dwh.vw_CuboVentas
WHERE Cliente LIKE '%Central%'
  AND Canal = 'Mayorista'
ORDER BY Fecha DESC;
GO


/* =========================================================
   D) GROUP BY (agregaciones)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- D1) Total de ventas por canal
SELECT
  Canal,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Canal
ORDER BY TotalVentas DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- D2) Total de ventas por categoría
SELECT
  Categoria,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Categoria
ORDER BY TotalVentas DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- D3) Ventas por mes (Año - Mes)
SELECT
  Anio,
  MesNumero,
  MesNombre,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Anio, MesNumero, MesNombre
ORDER BY Anio DESC, MesNumero DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- D4) Top 10 productos por total de ventas
SELECT TOP (10)
  Producto,
  Categoria,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Producto, Categoria
ORDER BY TotalVentas DESC;
GO


/* =========================================================
   E) GROUP BY + WHERE (filtrar antes de agrupar)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- E1) Top 5 productos por ventas en los últimos 60 días
SELECT TOP (5)
  Producto,
  Categoria,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
WHERE Fecha >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
GROUP BY Producto, Categoria
ORDER BY TotalVentas DESC;
GO

-- Carné: 20XXXXXXX | Nombre: ____________________
-- E2) Ventas por tienda para una categoría (Abarrotes)
SELECT
  Tienda,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
WHERE Categoria = 'Abarrotes'
GROUP BY Tienda
ORDER BY TotalVentas DESC;
GO


/* =========================================================
   F) GROUP BY + HAVING (filtrar después de agrupar)
   ========================================================= */

-- Carné: 20XXXXXXX | Nombre: ____________________
-- F1) Clientes con ventas mayores a 2000 (ajusta el umbral si lo deseas)
SELECT
  Cliente,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Cliente
HAVING SUM(ImporteNeto) > 2000
ORDER BY TotalVentas DESC;
GO
