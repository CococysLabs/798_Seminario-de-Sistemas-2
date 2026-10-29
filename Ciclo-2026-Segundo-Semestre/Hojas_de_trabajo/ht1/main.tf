terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "random_password" "sql_sa" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "random_password" "sql_reader" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall: SQL Server (1433)
resource "google_compute_firewall" "allow_sql" {
  name    = "${var.name_prefix}-allow-sql-1433"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }

  source_ranges = var.allowed_cidrs
  target_tags   = ["sqlserver"]
}

# Firewall: RDP (3389) - restringido
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ssh-22"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_cidrs_rdp
  target_tags   = ["sqlserver", "ssh"]
}

# Disco de datos (para BD / datafiles) recomendado
resource "google_compute_disk" "data_disk" {
  name = "${var.name_prefix}-sqldata"
  type = var.data_disk_type
  zone = var.zone
  size = var.data_disk_size_gb
}

resource "google_compute_instance" "sqlserver_vm" {
  name         = "${var.name_prefix}-sqlserver"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["sqlserver", "ssh"]

  boot_disk {
    initialize_params {
      # Ubuntu LTS base
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  attached_disk {
    source      = google_compute_disk.data_disk.id
    device_name = "sqldata"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata = {
    enable-oslogin = "FALSE"
    startup-script = replace(<<-EOT
      #!/bin/bash
      set -euo pipefail
      SA_PASS="${random_password.sql_sa.result}"
      READER_PASS="${random_password.sql_reader.result}"

      export DEBIAN_FRONTEND=noninteractive
      # Pequeña función de reintento para apt
      for i in {1..5}; do
        apt-get update -y && apt-get install -y docker.io >/tmp/apt-install.log 2>&1 && break
        echo "apt retry $i" >&2
        sleep 10
      done
      systemctl enable docker
      systemctl start docker

      DATA_DEVICE="/dev/disk/by-id/google-sqldata"
      for i in {1..30}; do
        [ -e "$${DATA_DEVICE}" ] && break
        sleep 2
      done
      if ! blkid "$${DATA_DEVICE}" >/dev/null 2>&1; then
        mkfs.ext4 -F "$${DATA_DEVICE}"
      fi
      mkdir -p /var/lib/sqlserver
      mountpoint -q /var/lib/sqlserver || mount "$${DATA_DEVICE}" /var/lib/sqlserver
      grep -q "google-sqldata" /etc/fstab || echo "$${DATA_DEVICE} /var/lib/sqlserver ext4 defaults,nofail 0 2" >> /etc/fstab
      chown -R 10001:0 /var/lib/sqlserver

      docker pull mcr.microsoft.com/mssql/server:2022-latest
      docker stop sql1 || true
      docker rm sql1 || true
      docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$${SA_PASS}" -p 1433:1433 -v /var/lib/sqlserver:/var/opt/mssql --restart unless-stopped --name sql1 -d mcr.microsoft.com/mssql/server:2022-latest

      # Esperar a que SQL Server esté listo
      for i in {1..30}; do
        if docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -Q "SELECT 1" >/dev/null 2>&1; then
          ready=1
          break
        fi
        sleep 5
      done
      if [ -z "$${ready:-}" ]; then
        echo "SQL Server no inició a tiempo" >&2
        exit 1
      fi

      # Inyectar DDL
      docker exec -i sql1 /bin/bash -c 'cat > /tmp/ddl.sql' <<'SQL'
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
SQL

      # Inyectar datos
      docker exec -i sql1 /bin/bash -c 'cat > /tmp/data.sql' <<'SQL'
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
SQL

      if ! docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -W -h -1 -Q "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('SGFoodDW') IS NULL THEN 0 ELSE 1 END" | grep -q '^1$'; then
        docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -i /tmp/ddl.sql
        docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -i /tmp/data.sql
      fi
      docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -Q "IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'sgfood_reader') CREATE LOGIN sgfood_reader WITH PASSWORD = N'$${READER_PASS}', CHECK_POLICY = ON;"
      docker exec sql1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$${SA_PASS}" -d SGFoodDW -Q "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sgfood_reader') CREATE USER sgfood_reader FOR LOGIN sgfood_reader; ALTER ROLE db_datareader ADD MEMBER sgfood_reader; GRANT VIEW DEFINITION TO sgfood_reader;"
    EOT
    , "\r", "")
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

output "sqlserver_public_ip" {
  value = google_compute_instance.sqlserver_vm.network_interface[0].access_config[0].nat_ip
}

output "sqlserver_sa_password" {
  value     = random_password.sql_sa.result
  sensitive = true
}

output "sqlserver_reader_username" {
  value = "sgfood_reader"
}

output "sqlserver_reader_password" {
  value     = random_password.sql_reader.result
  sensitive = true
}
