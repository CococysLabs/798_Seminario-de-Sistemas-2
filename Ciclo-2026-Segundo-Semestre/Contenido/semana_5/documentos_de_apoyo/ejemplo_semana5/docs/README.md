# Ejemplo Semana 5 - Datamart de Ventas en SQL Server (GCP)

Estructura:
- `terraform/`: infraestructura en GCP (VM + SQL Server en Docker).
- `sql/01_create_datamart.sql`: DDL del datamart (`dim_*`, `fact_*`, `key_*`, indices).
- `data/ventas_raw.csv`: datos de entrada para el ETL.
- `notebooks/etl_ventas_datamart.ipynb`: ETL incremental con espera activa.

## 1) Provisionar infraestructura
1. Ir a `terraform/`.
2. Crear `terraform.tfvars` a partir de `terraform.tfvars.example`.
3. Ejecutar:
   - `terraform init`
   - `terraform plan`
   - `terraform apply`

## 2) Ejecutar ETL
1. Abrir `notebooks/etl_ventas_datamart.ipynb`.
2. Ajustar variables `SQL_SERVER_HOST`, `SQL_SERVER_USER`, `SQL_SERVER_PASSWORD`.
3. Ejecutar celdas en orden.

El notebook espera hasta que la BD y tabla `dwh.fact_ventas` existan antes de cargar.
