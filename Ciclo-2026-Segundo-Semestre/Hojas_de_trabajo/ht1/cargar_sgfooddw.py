"""
cargar_sgfooddw.py
------------------
Script de Python para conectarse a SQL Server y cargar (DDL + data) un data warehouse
(Esquema estrella + "vista cubo") para la práctica SG-Food.

Requisitos:
  - Python 3.9+
  - pip install pyodbc
  - Tener instalado el ODBC Driver de Microsoft para SQL Server (17 o 18) en la máquina donde corra este script.

Uso rápido:
  1) Edita la sección CONFIG de abajo (host, puerto, usuario, contraseña, base).
  2) Coloca los archivos .sql (DDL y DATA) en la misma carpeta del .py (o ajusta rutas).
  3) Ejecuta:
       python cargar_sgfooddw.py

Opcional:
  - python cargar_sgfooddw.py --wipe-first
  - python cargar_sgfooddw.py --ddl 01_DDL_SGFoodDW.sql --data 02_Data_SGFoodDW.sql
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

import pyodbc


# =========================
# CONFIG (EDITA AQUÍ)
# =========================
CONFIG = {
    "host": "34.44.163.250",       # IP pública o DNS del SQL Server
    "port": 1433,                   # puerto (default 1433)
    "database": "SGFoodDW",          # base de datos objetivo
    "user": "sa",                    # login SQL (o el que uses)
    "password": "P@ssw0rd123!",  # contraseña

    # Driver ODBC: ajusta según lo que tengas instalado.
    "odbc_driver": "ODBC Driver 18 for SQL Server",

    # Recomendado para laboratorio:
    "encrypt": "yes",                 # "yes" o "no"
    "trust_server_certificate": "yes" # "yes" o "no"
}


_GO_SPLIT_RE = re.compile(r"^\s*GO\s*;$|^\s*GO\s*$", re.IGNORECASE)


def build_connection_string(cfg: dict) -> str:
    server = f"{cfg['host']},{cfg['port']}"
    driver = cfg["odbc_driver"]
    encrypt = cfg.get("encrypt", "yes")
    trust = cfg.get("trust_server_certificate", "yes")
    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={cfg['database']};"
        f"UID={cfg['user']};"
        f"PWD={cfg['password']};"
        f"Encrypt={encrypt};"
        f"TrustServerCertificate={trust};"
    )


def split_batches(sql_text: str) -> list[str]:
    """Divide por líneas 'GO' (separador de batch usado por SSMS/sqlcmd)."""
    lines = sql_text.splitlines()
    batches: list[str] = []
    buff: list[str] = []

    for line in lines:
        if _GO_SPLIT_RE.match(line):
            batch = "\n".join(buff).strip()
            if batch:
                batches.append(batch)
            buff = []
        else:
            buff.append(line)

    last = "\n".join(buff).strip()
    if last:
        batches.append(last)

    return batches


def run_script_file(cursor: pyodbc.Cursor, path: Path) -> None:
    sql_text = path.read_text(encoding="utf-8")
    batches = split_batches(sql_text)

    print(f"\n==> Ejecutando: {path.name}  ({len(batches)} batches)")
    for i, batch in enumerate(batches, start=1):
        try:
            cursor.execute(batch)
        except Exception as e:
            print("\n[ERROR] Falló un batch.")
            print(f"Archivo: {path}")
            print(f"Batch #: {i}/{len(batches)}")
            snippet = batch[:800].replace("\n", "\\n")
            print(f"Batch (primeros 800 chars): {snippet}")
            raise


def wipe_tables(cursor: pyodbc.Cursor) -> None:
    """Vacía el DW en orden correcto (Fact -> Dims) y reseed de IDENTITY."""
    print("\n==> Wipe (DELETE uno por uno)")

    wipe_sql = """
    USE SGFoodDW;
    SET NOCOUNT ON;

    IF OBJECT_ID('dwh.vw_CuboVentas','V') IS NOT NULL
      DROP VIEW dwh.vw_CuboVentas;

    IF OBJECT_ID('dwh.FactVentas','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.FactVentas;
      DBCC CHECKIDENT ('dwh.FactVentas', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimVendedor','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimVendedor;
      DBCC CHECKIDENT ('dwh.DimVendedor', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimTienda','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimTienda;
      DBCC CHECKIDENT ('dwh.DimTienda', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimCanal','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimCanal;
      DBCC CHECKIDENT ('dwh.DimCanal', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimCliente','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimCliente;
      DBCC CHECKIDENT ('dwh.DimCliente', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimProducto','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimProducto;
      DBCC CHECKIDENT ('dwh.DimProducto', RESEED, 0);
    END

    IF OBJECT_ID('dwh.DimDate','U') IS NOT NULL
    BEGIN
      DELETE FROM dwh.DimDate;
    END
    """
    cursor.execute(wipe_sql)


def main() -> int:
    parser = argparse.ArgumentParser(description="Cargar SGFoodDW (DDL + Data) en SQL Server")
    parser.add_argument("--ddl", default="01_DDL_SGFoodDW.sql", help="Ruta al archivo DDL .sql")
    parser.add_argument("--data", default="02_Data_SGFoodDW.sql", help="Ruta al archivo de data .sql")
    parser.add_argument("--wipe-first", action="store_true", help="Vaciar tablas antes de cargar")
    args = parser.parse_args()

    base_dir = Path(__file__).resolve().parent
    ddl_path = (base_dir / args.ddl).resolve() if not Path(args.ddl).is_absolute() else Path(args.ddl)
    data_path = (base_dir / args.data).resolve() if not Path(args.data).is_absolute() else Path(args.data)

    if not ddl_path.exists():
        print(f"[ERROR] No existe el archivo DDL: {ddl_path}")
        return 2
    if not data_path.exists():
        print(f"[ERROR] No existe el archivo DATA: {data_path}")
        return 2

    conn_str = build_connection_string(CONFIG)

    print("==> Conectando a SQL Server...")
    print(f"    Host: {CONFIG['host']}:{CONFIG['port']}")
    print(f"    DB:   {CONFIG['database']}")
    print(f"    User: {CONFIG['user']}")
    print(f"    Driver: {CONFIG['odbc_driver']}")

    with pyodbc.connect(conn_str, autocommit=True) as conn:
        cur = conn.cursor()

        if args.wipe_first:
            wipe_tables(cur)

        run_script_file(cur, ddl_path)
        run_script_file(cur, data_path)

        print("\n✅ Listo. DW cargado correctamente.")
        print("   Prueba rápida: SELECT TOP 5 * FROM dwh.vw_CuboVentas;")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
