-- Habilitar operaciones en archivos planos
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
-- Cargar DimProducto
BULK INSERT DimProducto
FROM 'DimProducto.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    FORMAT = 'CSV'
);

-- Cargar DimCliente
BULK INSERT DimCliente
FROM 'DimCliente.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    FORMAT = 'CSV'
);

-- Cargar DimVendedor
BULK INSERT DimVendedor
FROM 'DimVendedor.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    FORMAT = 'CSV'
);

-- Cargar DimTiempo
BULK INSERT DimTiempo
FROM 'DimTiempo.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    FORMAT = 'CSV'
);

-- Cargar FactVentas
BULK INSERT FactVentas
FROM 'FactVentas.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    FORMAT = 'CSV'
);
