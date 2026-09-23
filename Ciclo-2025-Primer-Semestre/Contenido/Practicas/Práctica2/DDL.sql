CREATE DATABASE SGFood;
GO
USE SGFood;
GO

CREATE TABLE Dim_Cliente (
    id_cliente NVARCHAR(50) PRIMARY KEY,
    nombre_cliente NVARCHAR(255),
    tipo_cliente NVARCHAR(255),
    direccion_cliente NVARCHAR(255),
    numero_cliente NVARCHAR(100),
);
GO

CREATE TABLE Dim_Proveedor (
    id_proveedor NVARCHAR(50) PRIMARY KEY,
    nombre_proveedor NVARCHAR(255),
    direccion_proveedor NVARCHAR(255),
    numero_proveedor NVARCHAR(255),
    web_proveedor NVARCHAR(255)
);
GO

CREATE TABLE Dim_Producto (
    id_producto NVARCHAR(50) PRIMARY KEY,
    nombre_producto NVARCHAR(255),
    marca_producto NVARCHAR(255),
    categoria_producto NVARCHAR(255)
);
GO

CREATE TABLE Dim_Sucursal (
    id_sucursal NVARCHAR(50) PRIMARY KEY,
    nombre_sucursal NVARCHAR(255),
    direccion_sucursal NVARCHAR(255),
    region NVARCHAR(255),
    departamento NVARCHAR(255)
);
GO

CREATE TABLE Dim_Fecha (
    id_fecha INT PRIMARY KEY,
    fecha DATE,
    dia INT,
    mes INT,
    trimestre INT,
    año INT
);
GO

CREATE TABLE Dim_Vendedor (
    id_vendedor NVARCHAR(50) PRIMARY KEY,
    nombre_vendedor NVARCHAR(255),
    vacacionista BIT
);
GO

CREATE TABLE Hechos_Ventas (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    id_fecha INT,
    id_cliente NVARCHAR(50),
    id_producto NVARCHAR(50),
    id_sucursal NVARCHAR(50),
    unidades INT,
    precio_unitario DECIMAL(18, 2),
    id_vendedor NVARCHAR(50),
    FOREIGN KEY (id_fecha) REFERENCES Dim_Fecha(id_fecha),
    FOREIGN KEY (id_cliente) REFERENCES Dim_Cliente(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES Dim_Producto(id_producto),
    FOREIGN KEY (id_sucursal) REFERENCES Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_vendedor) REFERENCES Dim_Vendedor(id_vendedor)
);
GO

CREATE TABLE Hechos_Compras (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    id_fecha INT,
    id_proveedor NVARCHAR(50),
    id_producto NVARCHAR(50),
    id_sucursal NVARCHAR(50),
    unidades INT,
    costo_unitario DECIMAL(18, 2),
    FOREIGN KEY (id_fecha) REFERENCES Dim_Fecha(id_fecha),
    FOREIGN KEY (id_proveedor) REFERENCES Dim_Proveedor(id_proveedor),
    FOREIGN KEY (id_producto) REFERENCES Dim_Producto(id_producto),
    FOREIGN KEY (id_sucursal) REFERENCES Dim_Sucursal(id_sucursal)
);
GO

CREATE INDEX idx_fecha_ventas ON Hechos_Ventas(id_fecha);
CREATE INDEX idx_cliente_ventas ON Hechos_Ventas(id_cliente);
CREATE INDEX idx_producto_ventas ON Hechos_Ventas(id_producto);
CREATE INDEX idx_sucursal_ventas ON Hechos_Ventas(id_sucursal);
CREATE INDEX idx_vendedor_ventas ON Hechos_Ventas(id_vendedor);
GO

CREATE INDEX idx_fecha_compras ON Hechos_Compras(id_fecha);
CREATE INDEX idx_proveedor_compras ON Hechos_Compras(id_proveedor);
CREATE INDEX idx_producto_compras ON Hechos_Compras(id_producto);
CREATE INDEX idx_sucursal_compras ON Hechos_Compras(id_sucursal);
GO