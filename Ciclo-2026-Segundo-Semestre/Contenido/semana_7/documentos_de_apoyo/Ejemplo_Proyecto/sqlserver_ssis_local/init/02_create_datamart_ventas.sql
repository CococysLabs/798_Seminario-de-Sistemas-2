USE [SSISLab];
GO

IF SCHEMA_ID(N'staging') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [staging]');
END;
GO

IF OBJECT_ID(N'staging.VentasRawExcel', N'U') IS NULL
BEGIN
    CREATE TABLE staging.VentasRawExcel
    (
        VentaID int NOT NULL,
        Fecha date NOT NULL,
        Anio smallint NOT NULL,
        Mes nvarchar(20) NOT NULL,
        Trimestre nvarchar(5) NOT NULL,
        ProductoID nvarchar(20) NOT NULL,
        Producto nvarchar(100) NOT NULL,
        Categoria nvarchar(50) NOT NULL,
        Marca nvarchar(50) NOT NULL,
        ClienteID nvarchar(20) NOT NULL,
        Cliente nvarchar(120) NOT NULL,
        SegmentoCliente nvarchar(50) NOT NULL,
        Ciudad nvarchar(80) NOT NULL,
        Pais nvarchar(80) NOT NULL,
        Canal nvarchar(50) NOT NULL,
        Cantidad int NOT NULL,
        PrecioUnitario decimal(12,2) NOT NULL,
        CostoUnitario decimal(12,2) NOT NULL,
        DescuentoPct decimal(5,4) NOT NULL,
        MontoVenta decimal(14,2) NOT NULL,
        MontoCosto decimal(14,2) NOT NULL,
        Utilidad decimal(14,2) NOT NULL,
        FechaCarga datetime2(0) NOT NULL CONSTRAINT DF_staging_VentasRawExcel_FechaCarga DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'staging.VentasRawExcel')
      AND name = N'ProductoID'
      AND system_type_id = TYPE_ID(N'varchar')
)
BEGIN
    ALTER TABLE staging.VentasRawExcel
    ALTER COLUMN ProductoID nvarchar(20) NOT NULL;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'staging.VentasRawExcel')
      AND name = N'ClienteID'
      AND system_type_id = TYPE_ID(N'varchar')
)
BEGIN
    ALTER TABLE staging.VentasRawExcel
    ALTER COLUMN ClienteID nvarchar(20) NOT NULL;
END;
GO

IF OBJECT_ID(N'dbo.DimFecha', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimFecha
    (
        FechaKey int NOT NULL CONSTRAINT PK_DimFecha PRIMARY KEY,
        Fecha date NOT NULL,
        Anio smallint NOT NULL,
        Semestre tinyint NOT NULL,
        Trimestre tinyint NOT NULL,
        MesNumero tinyint NOT NULL,
        MesNombre nvarchar(20) NOT NULL,
        DiaDelMes tinyint NOT NULL,
        NombreDia nvarchar(20) NOT NULL,
        EsFinDeSemana bit NOT NULL
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_DimFecha_Fecha'
      AND object_id = OBJECT_ID(N'dbo.DimFecha')
)
BEGIN
    CREATE UNIQUE INDEX UX_DimFecha_Fecha
        ON dbo.DimFecha (Fecha);
END;
GO

IF OBJECT_ID(N'dbo.DimProducto', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimProducto
    (
        ProductoKey int IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimProducto PRIMARY KEY,
        ProductoID nvarchar(20) NOT NULL,
        Producto nvarchar(100) NOT NULL,
        Categoria nvarchar(50) NOT NULL,
        Marca nvarchar(50) NOT NULL,
        FechaCreacion datetime2(0) NOT NULL CONSTRAINT DF_DimProducto_FechaCreacion DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.DimProducto')
      AND name = N'ProductoID'
      AND system_type_id = TYPE_ID(N'varchar')
)
BEGIN
    ALTER TABLE dbo.DimProducto
    ALTER COLUMN ProductoID nvarchar(20) NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_DimProducto_ProductoID'
      AND object_id = OBJECT_ID(N'dbo.DimProducto')
)
BEGIN
    CREATE UNIQUE INDEX UX_DimProducto_ProductoID
        ON dbo.DimProducto (ProductoID);
END;
GO

IF OBJECT_ID(N'dbo.DimCliente', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCliente
    (
        ClienteKey int IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimCliente PRIMARY KEY,
        ClienteID nvarchar(20) NOT NULL,
        Cliente nvarchar(120) NOT NULL,
        SegmentoCliente nvarchar(50) NOT NULL,
        Ciudad nvarchar(80) NOT NULL,
        Pais nvarchar(80) NOT NULL,
        Canal nvarchar(50) NOT NULL,
        FechaCreacion datetime2(0) NOT NULL CONSTRAINT DF_DimCliente_FechaCreacion DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.DimCliente')
      AND name = N'ClienteID'
      AND system_type_id = TYPE_ID(N'varchar')
)
BEGIN
    ALTER TABLE dbo.DimCliente
    ALTER COLUMN ClienteID nvarchar(20) NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_DimCliente_ClienteID'
      AND object_id = OBJECT_ID(N'dbo.DimCliente')
)
BEGIN
    CREATE UNIQUE INDEX UX_DimCliente_ClienteID
        ON dbo.DimCliente (ClienteID);
END;
GO

IF OBJECT_ID(N'dbo.FactVentas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactVentas
    (
        VentaKey bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactVentas PRIMARY KEY,
        VentaID int NOT NULL,
        FechaKey int NOT NULL,
        ProductoKey int NOT NULL,
        ClienteKey int NOT NULL,
        Cantidad int NOT NULL,
        PrecioUnitario decimal(12,2) NOT NULL,
        CostoUnitario decimal(12,2) NOT NULL,
        DescuentoPct decimal(5,4) NOT NULL,
        MontoVenta decimal(14,2) NOT NULL,
        MontoCosto decimal(14,2) NOT NULL,
        Utilidad decimal(14,2) NOT NULL,
        FechaCarga datetime2(0) NOT NULL CONSTRAINT DF_FactVentas_FechaCarga DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_FactVentas_DimFecha FOREIGN KEY (FechaKey) REFERENCES dbo.DimFecha (FechaKey),
        CONSTRAINT FK_FactVentas_DimProducto FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto (ProductoKey),
        CONSTRAINT FK_FactVentas_DimCliente FOREIGN KEY (ClienteKey) REFERENCES dbo.DimCliente (ClienteKey)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_FactVentas_VentaID'
      AND object_id = OBJECT_ID(N'dbo.FactVentas')
)
BEGIN
    CREATE UNIQUE INDEX UX_FactVentas_VentaID
        ON dbo.FactVentas (VentaID);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_FactVentas_FechaKey'
      AND object_id = OBJECT_ID(N'dbo.FactVentas')
)
BEGIN
    CREATE INDEX IX_FactVentas_FechaKey
        ON dbo.FactVentas (FechaKey);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_FactVentas_ProductoKey'
      AND object_id = OBJECT_ID(N'dbo.FactVentas')
)
BEGIN
    CREATE INDEX IX_FactVentas_ProductoKey
        ON dbo.FactVentas (ProductoKey);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_FactVentas_ClienteKey'
      AND object_id = OBJECT_ID(N'dbo.FactVentas')
)
BEGIN
    CREATE INDEX IX_FactVentas_ClienteKey
        ON dbo.FactVentas (ClienteKey);
END;
GO
