#!/bin/bash
set -euo pipefail

SA_PASS="${sa_password}"
DB_NAME="${datamart_db}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

docker pull mcr.microsoft.com/mssql/server:2022-latest
docker stop sqlserver || true
docker rm sqlserver || true

docker run   -e "ACCEPT_EULA=Y"   -e "MSSQL_SA_PASSWORD=$SA_PASS"   -p 1433:1433   --name sqlserver   -d mcr.microsoft.com/mssql/server:2022-latest

for i in {1..60}; do
  if docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -Q "SELECT 1" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 5
done

if [ -z "$\{ready:-\}" ]; then
  echo "SQL Server no quedo listo a tiempo" >&2
  exit 1
fi

docker exec -i sqlserver /bin/bash -c 'cat > /tmp/01_create_datamart.sql' <<SQL
IF DB_ID(N'$DB_NAME') IS NULL
BEGIN
  CREATE DATABASE [$DB_NAME];
END
GO

USE [$DB_NAME];
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dwh')
  EXEC(N'CREATE SCHEMA dwh');
GO

IF OBJECT_ID(N'dwh.dim_fecha', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.dim_fecha (
    key_fecha     INT       NOT NULL PRIMARY KEY,
    fecha         DATE      NOT NULL,
    anio          SMALLINT  NOT NULL,
    trimestre     TINYINT   NOT NULL,
    mes           TINYINT   NOT NULL,
    nombre_mes    VARCHAR(20) NOT NULL,
    dia           TINYINT   NOT NULL,
    nombre_dia    VARCHAR(20) NOT NULL,
    es_fin_semana BIT       NOT NULL,
    CONSTRAINT UQ_dim_fecha_fecha UNIQUE (fecha)
  );
END
GO

IF OBJECT_ID(N'dwh.dim_producto', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.dim_producto (
    key_producto       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    codigo_producto    VARCHAR(50) NOT NULL,
    nombre_producto    VARCHAR(150) NOT NULL,
    categoria_producto VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_dim_producto_codigo UNIQUE (codigo_producto)
  );
END
GO

IF OBJECT_ID(N'dwh.dim_cliente', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.dim_cliente (
    key_cliente       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    codigo_cliente    VARCHAR(50) NOT NULL,
    nombre_cliente    VARCHAR(150) NOT NULL,
    segmento_cliente  VARCHAR(80) NOT NULL,
    CONSTRAINT UQ_dim_cliente_codigo UNIQUE (codigo_cliente)
  );
END
GO

IF OBJECT_ID(N'dwh.dim_tienda', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.dim_tienda (
    key_tienda      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    codigo_tienda   VARCHAR(50) NOT NULL,
    nombre_tienda   VARCHAR(150) NOT NULL,
    region_tienda   VARCHAR(80) NOT NULL,
    CONSTRAINT UQ_dim_tienda_codigo UNIQUE (codigo_tienda)
  );
END
GO

IF OBJECT_ID(N'dwh.fact_ventas', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.fact_ventas (
    key_fact_venta    BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    key_fecha         INT NOT NULL,
    key_producto      INT NOT NULL,
    key_cliente       INT NOT NULL,
    key_tienda        INT NOT NULL,
    numero_factura    VARCHAR(40) NOT NULL,
    linea_factura     INT NOT NULL,
    cantidad          INT NOT NULL,
    precio_unitario   DECIMAL(18,2) NOT NULL,
    descuento         DECIMAL(18,2) NOT NULL,
    monto_bruto       AS (cantidad * precio_unitario) PERSISTED,
    monto_neto        AS ((cantidad * precio_unitario) - descuento) PERSISTED,
    fecha_carga       DATETIME2(0) NOT NULL CONSTRAINT DF_fact_ventas_fecha_carga DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_fact_ventas_dim_fecha FOREIGN KEY (key_fecha) REFERENCES dwh.dim_fecha(key_fecha),
    CONSTRAINT FK_fact_ventas_dim_producto FOREIGN KEY (key_producto) REFERENCES dwh.dim_producto(key_producto),
    CONSTRAINT FK_fact_ventas_dim_cliente FOREIGN KEY (key_cliente) REFERENCES dwh.dim_cliente(key_cliente),
    CONSTRAINT FK_fact_ventas_dim_tienda FOREIGN KEY (key_tienda) REFERENCES dwh.dim_tienda(key_tienda),
    CONSTRAINT UQ_fact_ventas_grano UNIQUE (key_fecha, key_producto, key_cliente, key_tienda, numero_factura, linea_factura),

    CONSTRAINT CK_fact_ventas_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_fact_ventas_precio CHECK (precio_unitario >= 0),
    CONSTRAINT CK_fact_ventas_descuento CHECK (descuento >= 0)
  );
END
GO

IF OBJECT_ID(N'dwh.stg_ventas', N'U') IS NULL
BEGIN
  CREATE TABLE dwh.stg_ventas (
    fecha_venta         DATE NOT NULL,
    codigo_producto     VARCHAR(50) NOT NULL,
    nombre_producto     VARCHAR(150) NOT NULL,
    categoria_producto  VARCHAR(100) NOT NULL,
    codigo_cliente      VARCHAR(50) NOT NULL,
    nombre_cliente      VARCHAR(150) NOT NULL,
    segmento_cliente    VARCHAR(80) NOT NULL,
    codigo_tienda       VARCHAR(50) NOT NULL,
    nombre_tienda       VARCHAR(150) NOT NULL,
    region_tienda       VARCHAR(80) NOT NULL,
    numero_factura      VARCHAR(40) NOT NULL,
    linea_factura       INT NOT NULL,
    cantidad            INT NOT NULL,
    precio_unitario     DECIMAL(18,2) NOT NULL,
    descuento           DECIMAL(18,2) NOT NULL
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_fact_ventas_key_fecha' AND object_id = OBJECT_ID(N'dwh.fact_ventas'))
BEGIN
  CREATE NONCLUSTERED INDEX IX_fact_ventas_key_fecha
    ON dwh.fact_ventas (key_fecha)
    INCLUDE (key_producto, key_tienda, monto_neto, cantidad);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_fact_ventas_key_producto_fecha' AND object_id = OBJECT_ID(N'dwh.fact_ventas'))
BEGIN
  CREATE NONCLUSTERED INDEX IX_fact_ventas_key_producto_fecha
    ON dwh.fact_ventas (key_producto, key_fecha)
    INCLUDE (monto_neto, cantidad);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_fact_ventas_key_tienda_fecha' AND object_id = OBJECT_ID(N'dwh.fact_ventas'))
BEGIN
  CREATE NONCLUSTERED INDEX IX_fact_ventas_key_tienda_fecha
    ON dwh.fact_ventas (key_tienda, key_fecha)
    INCLUDE (monto_neto, cantidad);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_fact_ventas_key_cliente' AND object_id = OBJECT_ID(N'dwh.fact_ventas'))
BEGIN
  CREATE NONCLUSTERED INDEX IX_fact_ventas_key_cliente
    ON dwh.fact_ventas (key_cliente)
    INCLUDE (monto_neto, cantidad);
END
GO
SQL

docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASS" -i /tmp/01_create_datamart.sql
