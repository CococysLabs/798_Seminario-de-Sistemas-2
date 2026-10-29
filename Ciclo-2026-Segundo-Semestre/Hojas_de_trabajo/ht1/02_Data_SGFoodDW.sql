USE SGFoodDW;
GO

/* =========================
   DimDate: rango 120 días
   ========================= */
DECLARE @start DATE = DATEADD(DAY, -120, CAST(GETDATE() AS DATE));
DECLARE @end   DATE = CAST(GETDATE() AS DATE);

;WITH d AS (
  SELECT @start AS Fecha
  UNION ALL
  SELECT DATEADD(DAY, 1, Fecha)
  FROM d
  WHERE Fecha < @end
)
INSERT INTO dwh.DimDate (DateKey, Fecha, Anio, Trimestre, MesNumero, MesNombre, DiaMes, DiaSemanaNombre)
SELECT
  CONVERT(INT, FORMAT(Fecha, 'yyyyMMdd')) AS DateKey,
  Fecha,
  YEAR(Fecha) AS Anio,
  DATEPART(QUARTER, Fecha) AS Trimestre,
  MONTH(Fecha) AS MesNumero,
  DATENAME(MONTH, Fecha) AS MesNombre,
  DAY(Fecha) AS DiaMes,
  DATENAME(WEEKDAY, Fecha) AS DiaSemanaNombre
FROM d
OPTION (MAXRECURSION 0);
GO

/* =========================
   DimCanal
   ========================= */
INSERT INTO dwh.DimCanal (Canal)
VALUES ('Mayorista'), ('Minorista'), ('Ecommerce'), ('Institucional');
GO

/* =========================
   DimProducto (ejemplo)
   ========================= */
INSERT INTO dwh.DimProducto (SKU, Producto, Marca, Categoria, Subcategoria, Presentacion)
VALUES
('LAC-001','Leche Entera 1L','LactoPlus','Lácteos','Leche','Tetra 1L'),
('LAC-002','Yogurt Fresa 200ml','LactoPlus','Lácteos','Yogurt','Botella 200ml'),
('BEB-001','Soda Cola 2L','Fizzy','Bebidas','Gaseosas','Botella 2L'),
('BEB-002','Agua 600ml','AquaPure','Bebidas','Agua','Botella 600ml'),
('SNK-001','Papas Clásicas 45g','Crunchy','Snacks','Papas','Bolsa 45g'),
('SNK-002','Galletas Chocolate 6u','Dulci','Snacks','Galletas','Paquete'),
('ABA-001','Arroz 5lb','GranoFino','Abarrotes','Granos','Bolsa 5lb'),
('ABA-002','Frijol Negro 2lb','GranoFino','Abarrotes','Granos','Bolsa 2lb'),
('ABA-003','Aceite 1L','CocinaMax','Abarrotes','Aceites','Botella 1L'),
('CON-001','Atún 140g','MarAzul','Abarrotes','Enlatados','Lata 140g'),
('CON-002','Salsa Tomate 400g','CasaRoja','Abarrotes','Salsas','Lata 400g'),
('BEB-003','Jugo Naranja 1L','VitaFruit','Bebidas','Jugos','Tetra 1L');
GO

/* =========================
   DimCliente
   ========================= */
INSERT INTO dwh.DimCliente (ClienteId, Cliente, Segmento, Departamento, Municipio)
VALUES
('C-1001','Super Mercado Central','Supermercado','Guatemala','Guatemala'),
('C-1002','Tienda La Esquina','Tienda','Guatemala','Mixco'),
('C-1003','Hotel Mirador','HORECA','Sacatepéquez','Antigua Guatemala'),
('C-1004','Restaurante El Buen Sabor','HORECA','Guatemala','Villa Nueva'),
('C-1005','Market Online GT','Online','Guatemala','Guatemala'),
('C-1006','MiniMarket Los Pinos','Tienda','Quetzaltenango','Quetzaltenango'),
('C-1007','Distribuidora Norte','Mayorista','Alta Verapaz','Cobán'),
('C-1008','Super Ahorro Xela','Supermercado','Quetzaltenango','Quetzaltenango'),
('C-1009','Comedor Universitario','Institucional','Guatemala','Guatemala'),
('C-1010','Bodega Sur','Mayorista','Escuintla','Escuintla');
GO

/* =========================
   DimTienda
   ========================= */
INSERT INTO dwh.DimTienda (Tienda, TipoTienda, Departamento, Municipio)
VALUES
('Centro Distribución Guatemala','CD','Guatemala','Guatemala'),
('Sucursal Mixco','Sucursal','Guatemala','Mixco'),
('Sucursal Villa Nueva','Sucursal','Guatemala','Villa Nueva'),
('Sucursal Antigua','Sucursal','Sacatepéquez','Antigua Guatemala'),
('Sucursal Cobán','Sucursal','Alta Verapaz','Cobán'),
('Sucursal Xela','Sucursal','Quetzaltenango','Quetzaltenango');
GO

/* =========================
   DimVendedor
   ========================= */
INSERT INTO dwh.DimVendedor (Vendedor, Region)
VALUES
('Ana López','Centro'),
('Carlos Méndez','Sur'),
('Diana Pérez','Occidente'),
('Jorge Castillo','Norte'),
('María González','Centro');
GO

/* =========================
   FactVentas: carga demo (500 filas) con distribución aleatoria
   ========================= */
DECLARE @i INT = 1;

WHILE @i <= 500
BEGIN
  INSERT INTO dwh.FactVentas
  (DateKey, ProductoKey, ClienteKey, CanalKey, TiendaKey, VendedorKey, Cantidad, PrecioUnitario, Descuento, CostoUnitario)
  SELECT
    (SELECT TOP 1 DateKey FROM dwh.DimDate ORDER BY NEWID()),
    (SELECT TOP 1 ProductoKey FROM dwh.DimProducto ORDER BY NEWID()),
    (SELECT TOP 1 ClienteKey FROM dwh.DimCliente ORDER BY NEWID()),
    (SELECT TOP 1 CanalKey FROM dwh.DimCanal ORDER BY NEWID()),
    (SELECT TOP 1 TiendaKey FROM dwh.DimTienda ORDER BY NEWID()),
    (SELECT TOP 1 VendedorKey FROM dwh.DimVendedor ORDER BY NEWID()),
    CAST(1 + (ABS(CHECKSUM(NEWID())) % 20) AS INT) AS Cantidad,
    CAST(5 + (ABS(CHECKSUM(NEWID())) % 95) AS DECIMAL(18,2)) AS PrecioUnitario,
    CAST((ABS(CHECKSUM(NEWID())) % 15) AS DECIMAL(18,2)) AS Descuento,
    CAST(3 + (ABS(CHECKSUM(NEWID())) % 70) AS DECIMAL(18,2)) AS CostoUnitario;

  SET @i += 1;
END
GO
