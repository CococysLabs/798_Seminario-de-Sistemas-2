/* =========================================================
   SGFoodDW - Esquema estrella para práctica OLAP (SG-Food)
   Motor: Microsoft SQL Server (Developer recomendado)
   ========================================================= */

IF DB_ID('SGFoodDW') IS NULL
BEGIN
  CREATE DATABASE SGFoodDW;
END
GO

USE SGFoodDW;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dwh')
  EXEC('CREATE SCHEMA dwh');
GO

/* =========================
   DIMENSIONES
   ========================= */

IF OBJECT_ID('dwh.DimDate','U') IS NOT NULL DROP TABLE dwh.DimDate;
GO
CREATE TABLE dwh.DimDate (
  DateKey        INT         NOT NULL PRIMARY KEY,   -- yyyymmdd
  Fecha          DATE        NOT NULL,
  Anio           INT         NOT NULL,
  Trimestre      TINYINT     NOT NULL,
  MesNumero      TINYINT     NOT NULL,
  MesNombre      VARCHAR(15) NOT NULL,
  DiaMes         TINYINT     NOT NULL,
  DiaSemanaNombre VARCHAR(12) NOT NULL
);
GO

IF OBJECT_ID('dwh.DimProducto','U') IS NOT NULL DROP TABLE dwh.DimProducto;
GO
CREATE TABLE dwh.DimProducto (
  ProductoKey   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  SKU           VARCHAR(30) NOT NULL,
  Producto      VARCHAR(100) NOT NULL,
  Marca         VARCHAR(60) NOT NULL,
  Categoria     VARCHAR(60) NOT NULL,
  Subcategoria  VARCHAR(60) NULL,
  Presentacion  VARCHAR(60) NULL
);
GO
CREATE UNIQUE INDEX UX_DimProducto_SKU ON dwh.DimProducto(SKU);
GO

IF OBJECT_ID('dwh.DimCliente','U') IS NOT NULL DROP TABLE dwh.DimCliente;
GO
CREATE TABLE dwh.DimCliente (
  ClienteKey     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  ClienteId      VARCHAR(30) NOT NULL,
  Cliente        VARCHAR(120) NOT NULL,
  Segmento       VARCHAR(40) NOT NULL,
  Departamento   VARCHAR(60) NOT NULL,
  Municipio      VARCHAR(60) NOT NULL
);
GO
CREATE UNIQUE INDEX UX_DimCliente_ClienteId ON dwh.DimCliente(ClienteId);
GO

IF OBJECT_ID('dwh.DimCanal','U') IS NOT NULL DROP TABLE dwh.DimCanal;
GO
CREATE TABLE dwh.DimCanal (
  CanalKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Canal    VARCHAR(40) NOT NULL
);
GO

IF OBJECT_ID('dwh.DimTienda','U') IS NOT NULL DROP TABLE dwh.DimTienda;
GO
CREATE TABLE dwh.DimTienda (
  TiendaKey     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Tienda        VARCHAR(80) NOT NULL,
  TipoTienda    VARCHAR(40) NOT NULL,
  Departamento  VARCHAR(60) NOT NULL,
  Municipio     VARCHAR(60) NOT NULL
);
GO

IF OBJECT_ID('dwh.DimVendedor','U') IS NOT NULL DROP TABLE dwh.DimVendedor;
GO
CREATE TABLE dwh.DimVendedor (
  VendedorKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Vendedor    VARCHAR(80) NOT NULL,
  Region      VARCHAR(60) NOT NULL
);
GO

/* =========================
   HECHOS (FACT)
   ========================= */

IF OBJECT_ID('dwh.FactVentas','U') IS NOT NULL DROP TABLE dwh.FactVentas;
GO
CREATE TABLE dwh.FactVentas (
  FactVentaKey   BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  DateKey        INT NOT NULL,
  ProductoKey    INT NOT NULL,
  ClienteKey     INT NOT NULL,
  CanalKey       INT NOT NULL,
  TiendaKey      INT NOT NULL,
  VendedorKey    INT NOT NULL,

  Cantidad       INT NOT NULL,
  PrecioUnitario DECIMAL(18,2) NOT NULL,
  Descuento      DECIMAL(18,2) NOT NULL,
  CostoUnitario  DECIMAL(18,2) NOT NULL,

  CONSTRAINT FK_FactVentas_DimDate     FOREIGN KEY (DateKey)     REFERENCES dwh.DimDate(DateKey),
  CONSTRAINT FK_FactVentas_DimProducto FOREIGN KEY (ProductoKey) REFERENCES dwh.DimProducto(ProductoKey),
  CONSTRAINT FK_FactVentas_DimCliente  FOREIGN KEY (ClienteKey)  REFERENCES dwh.DimCliente(ClienteKey),
  CONSTRAINT FK_FactVentas_DimCanal    FOREIGN KEY (CanalKey)    REFERENCES dwh.DimCanal(CanalKey),
  CONSTRAINT FK_FactVentas_DimTienda   FOREIGN KEY (TiendaKey)   REFERENCES dwh.DimTienda(TiendaKey),
  CONSTRAINT FK_FactVentas_DimVendedor FOREIGN KEY (VendedorKey) REFERENCES dwh.DimVendedor(VendedorKey)
);
GO

-- Índice recomendado para analítica (opcional en laboratorio)
CREATE INDEX IX_FactVentas_DateKey ON dwh.FactVentas(DateKey);
GO

/* =========================
   VISTA "CUBO" (para que el alumno consulte con SQL)
   ========================= */
IF OBJECT_ID('dwh.vw_CuboVentas','V') IS NOT NULL DROP VIEW dwh.vw_CuboVentas;
GO
CREATE VIEW dwh.vw_CuboVentas
AS
SELECT
  d.Anio,
  d.Trimestre,
  d.MesNumero,
  d.MesNombre,
  d.Fecha,

  p.SKU,
  p.Producto,
  p.Marca,
  p.Categoria,
  p.Subcategoria,

  c.ClienteId,
  c.Cliente,
  c.Segmento,
  c.Departamento,
  c.Municipio,

  ca.Canal,

  t.Tienda,
  t.TipoTienda,
  t.Departamento AS TiendaDepartamento,
  t.Municipio    AS TiendaMunicipio,

  v.Vendedor,
  v.Region,

  f.Cantidad,
  f.PrecioUnitario,
  f.Descuento,
  f.CostoUnitario,

  (f.Cantidad * f.PrecioUnitario)                 AS ImporteBruto,
  (f.Cantidad * f.PrecioUnitario - f.Descuento)   AS ImporteNeto,
  (f.Cantidad * (f.PrecioUnitario - f.CostoUnitario) - f.Descuento) AS Margen
FROM dwh.FactVentas f
JOIN dwh.DimDate d      ON d.DateKey = f.DateKey
JOIN dwh.DimProducto p  ON p.ProductoKey = f.ProductoKey
JOIN dwh.DimCliente c   ON c.ClienteKey = f.ClienteKey
JOIN dwh.DimCanal ca    ON ca.CanalKey = f.CanalKey
JOIN dwh.DimTienda t    ON t.TiendaKey = f.TiendaKey
JOIN dwh.DimVendedor v  ON v.VendedorKey = f.VendedorKey;
GO
