/* ============================================================
   DEMO: 2 "cubos" (modelos dimensionales) para comparación
   - Cubo_Mal (malas prácticas: tabla plana, texto en hechos, grano inconsistente)
   - Cubo_Bien (buenas prácticas: estrella + SCD 0/1/2/3 claros)
   Target: SQL Server (T-SQL)
   ============================================================ */

-- CREATE DATABASE OLAP_Demo;
-- GO
-- USE OLAP_Demo;
-- GO

/* ============================================================
   1) CUBO MAL (ESQUEMA MALO) - visualmente obvio el error
   ============================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cubo_mal')
    EXEC('CREATE SCHEMA cubo_mal AUTHORIZATION dbo;');
GO

-- Tabla "hechos" plana: mezcla dimensiones como texto, sin surrogate keys,
-- fechas en VARCHAR, medidas pre-calculadas y grano inconsistente.
IF OBJECT_ID('cubo_mal.FactVentas_Plana', 'U') IS NOT NULL
    DROP TABLE cubo_mal.FactVentas_Plana;
GO

CREATE TABLE cubo_mal.FactVentas_Plana
(
    VentaId            INT IDENTITY(1,1) PRIMARY KEY,

    -- MAL: fechas como texto (no soporta jerarquías naturales ni particionado limpio)
    FechaTexto         VARCHAR(30) NOT NULL,  -- ej: '2026-02-04' o '2026-02' (mezcla día/mes)

    -- MAL: "dimensiones" incrustadas como texto, alta cardinalidad, duplicación, errores tipográficos
    ClienteNombre      NVARCHAR(200) NOT NULL,
    ClienteCorreo      NVARCHAR(200) NULL,
    ClienteCiudad      NVARCHAR(120) NULL,
    ClienteCiudadAlt   NVARCHAR(120) NULL,    -- MAL: duplicado confuso
    ProductoNombre     NVARCHAR(200) NOT NULL,
    ProductoCategoria  NVARCHAR(120) NULL,
    ProductoMarca      NVARCHAR(120) NULL,
    Canal              NVARCHAR(80)  NULL,
    VendedorNombre     NVARCHAR(150) NULL,
    VendedorRegion     NVARCHAR(120) NULL,

    -- MAL: medidas como texto y/o no normalizadas
    Moneda             NVARCHAR(10) NULL,     -- mezclada en el hecho
    Cantidad           INT NOT NULL,
    PrecioUnitario     DECIMAL(18,2) NOT NULL,
    Descuento          DECIMAL(18,2) NOT NULL DEFAULT (0),

    -- MAL: medida derivada almacenada (riesgo de inconsistencias)
    TotalNeto          AS (Cantidad * PrecioUnitario - Descuento) PERSISTED,

    -- MAL: métrica no aditiva almacenada sin regla (ej. porcentaje)
    PorcentajeMargen   DECIMAL(9,4) NULL
);
GO

-- Índice "parche": aunque exista, no corrige los errores de modelo
CREATE INDEX IX_FactVentasPlana_Fecha_Canal
ON cubo_mal.FactVentas_Plana(FechaTexto, Canal);
GO


/* ============================================================
   2) CUBO BIEN (ESQUEMA BUENO) - estrella + SCD 0/1/2/3
   ============================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cubo_bien')
    EXEC('CREATE SCHEMA cubo_bien AUTHORIZATION dbo;');
GO

/* ---------- Dimensión Fecha (con jerarquía natural Año->Mes->Día) ---------- */
IF OBJECT_ID('cubo_bien.DimFecha', 'U') IS NOT NULL DROP TABLE cubo_bien.DimFecha;
GO

CREATE TABLE cubo_bien.DimFecha
(
    FechaKey     INT NOT NULL PRIMARY KEY,  -- YYYYMMDD
    Fecha        DATE NOT NULL,
    Anio         SMALLINT NOT NULL,
    Trimestre    TINYINT NOT NULL,
    Mes          TINYINT NOT NULL,
    NombreMes    NVARCHAR(20) NOT NULL,
    Dia          TINYINT NOT NULL,
    DiaSemana    TINYINT NOT NULL,
    NombreDia    NVARCHAR(20) NOT NULL
);
GO

/* ---------- SCD Tipo 0: Dimensión "congelada" (no se actualiza) ---------- */
IF OBJECT_ID('cubo_bien.DimProducto_T0', 'U') IS NOT NULL DROP TABLE cubo_bien.DimProducto_T0;
GO

CREATE TABLE cubo_bien.DimProducto_T0
(
    ProductoKey     INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key
    ProductoBK      NVARCHAR(50) NOT NULL UNIQUE,    -- business key (SKU)
    NombreProducto  NVARCHAR(200) NOT NULL,
    CategoriaAlta   NVARCHAR(120) NULL,              -- "valor al alta" (no cambia)
    MarcaAlta       NVARCHAR(120) NULL,              -- "valor al alta" (no cambia)
    FechaAlta       DATE NOT NULL
);
GO

/* ---------- SCD Tipo 1: Dimensión que se sobrescribe (sin historial) ---------- */
IF OBJECT_ID('cubo_bien.DimCanal_T1', 'U') IS NOT NULL DROP TABLE cubo_bien.DimCanal_T1;
GO

CREATE TABLE cubo_bien.DimCanal_T1
(
    CanalKey      INT IDENTITY(1,1) PRIMARY KEY,
    CanalBK       NVARCHAR(50) NOT NULL UNIQUE,   -- ej: 'WEB', 'TIENDA'
    NombreCanal   NVARCHAR(120) NOT NULL,
    UltimaActualizacion DATETIME2(0) NOT NULL DEFAULT (SYSDATETIME())
);
GO

/* ---------- SCD Tipo 2: Dimensión con histórico completo ---------- */
IF OBJECT_ID('cubo_bien.DimCliente_T2', 'U') IS NOT NULL DROP TABLE cubo_bien.DimCliente_T2;
GO

CREATE TABLE cubo_bien.DimCliente_T2
(
    ClienteKey      INT IDENTITY(1,1) PRIMARY KEY,  -- surrogate key (cambia por versión)
    ClienteBK       NVARCHAR(50) NOT NULL,          -- business key (id CRM / documento)
    NombreCliente   NVARCHAR(200) NOT NULL,
    Correo          NVARCHAR(200) NULL,

    Ciudad          NVARCHAR(120) NULL,
    Segmento        NVARCHAR(80) NULL,

    FechaInicio     DATE NOT NULL,
    FechaFin        DATE NOT NULL,
    EsActual        BIT  NOT NULL
);
GO

CREATE INDEX IX_DimClienteT2_BK_Actual
ON cubo_bien.DimCliente_T2(ClienteBK, EsActual)
INCLUDE(ClienteKey, Ciudad, Segmento);
GO

/* ---------- SCD Tipo 3: Historial limitado (último cambio) ---------- */
IF OBJECT_ID('cubo_bien.DimVendedor_T3', 'U') IS NOT NULL DROP TABLE cubo_bien.DimVendedor_T3;
GO

CREATE TABLE cubo_bien.DimVendedor_T3
(
    VendedorKey        INT IDENTITY(1,1) PRIMARY KEY,
    VendedorBK         NVARCHAR(50) NOT NULL UNIQUE,
    NombreVendedor     NVARCHAR(150) NOT NULL,

    RegionActual       NVARCHAR(120) NULL,
    RegionAnterior     NVARCHAR(120) NULL,          -- guarda solo el último valor anterior
    FechaCambioRegion  DATE NULL
);
GO

/* ---------- Tabla de Hechos (grano: línea de venta por día) ---------- */
IF OBJECT_ID('cubo_bien.FactVentas', 'U') IS NOT NULL DROP TABLE cubo_bien.FactVentas;
GO

CREATE TABLE cubo_bien.FactVentas
(
    FactVentaKey   BIGINT IDENTITY(1,1) PRIMARY KEY,

    FechaKey       INT NOT NULL,
    ProductoKey    INT NOT NULL,
    CanalKey       INT NOT NULL,
    ClienteKey     INT NOT NULL,
    VendedorKey    INT NOT NULL,

    Cantidad       INT NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL,
    Descuento      DECIMAL(18,2) NOT NULL DEFAULT (0),

    CONSTRAINT FK_FactVentas_Fecha    FOREIGN KEY (FechaKey)    REFERENCES cubo_bien.DimFecha(FechaKey),
    CONSTRAINT FK_FactVentas_Producto FOREIGN KEY (ProductoKey) REFERENCES cubo_bien.DimProducto_T0(ProductoKey),
    CONSTRAINT FK_FactVentas_Canal    FOREIGN KEY (CanalKey)    REFERENCES cubo_bien.DimCanal_T1(CanalKey),
    CONSTRAINT FK_FactVentas_Cliente  FOREIGN KEY (ClienteKey)  REFERENCES cubo_bien.DimCliente_T2(ClienteKey),
    CONSTRAINT FK_FactVentas_Vendedor FOREIGN KEY (VendedorKey) REFERENCES cubo_bien.DimVendedor_T3(VendedorKey)
);
GO

CREATE INDEX IX_FactVentas_Fecha_Producto
ON cubo_bien.FactVentas(FechaKey, ProductoKey)
INCLUDE(Cantidad, PrecioUnitario, Descuento, CanalKey, ClienteKey, VendedorKey);
GO
/* ============================================================
   FIN DEL SCRIPT
   ============================================================ */