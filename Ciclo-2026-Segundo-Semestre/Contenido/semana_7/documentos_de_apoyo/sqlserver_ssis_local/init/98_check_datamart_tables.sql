USE [SSISLab];
GO

SELECT name
FROM sys.tables
WHERE name IN (N'VentasRawExcel', N'DimFecha', N'DimProducto', N'DimCliente', N'FactVentas')
ORDER BY name;
GO
