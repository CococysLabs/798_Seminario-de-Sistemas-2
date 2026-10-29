# Guia del estudiante

## Objetivo

Ejecutar un proyecto dbt desde GitHub Codespaces para transformar datos raw de SG-Food en modelos analiticos sobre BigQuery.

## Antes de iniciar

El docente ya debe haber configurado:

- proyecto GCP;
- datasets de BigQuery;
- service account;
- secretos del repositorio;
- permisos de acceso.

El estudiante no administra GCP.
El estudiante tampoco debe crear archivos de credenciales manualmente. Al abrir Codespaces, el repositorio prepara la conexion con BigQuery usando los secretos configurados por el docente.

## Paso 1: abrir Codespaces

1. Entrar al repositorio del taller en GitHub.
2. Seleccionar `Code`.
3. Abrir la pestana `Codespaces`.
4. Crear un nuevo Codespace.
5. Esperar a que termine la instalacion automatica.

## Paso 2: validar ambiente

```bash
bash scripts/validate_environment.sh
```

Tambien puede usarse:

```bash
make validate
```

Si todo esta correcto, `dbt debug` debe finalizar sin errores.

La configuracion por defecto del taller usa:

```text
GCP_PROJECT_ID=project-643d2a1a-b690-4d08-b00
GCP_BIGQUERY_LOCATION=US
DBT_DATASET_PREFIX=grupo_demo
```

Si el taller se trabaja por grupos, el docente puede cambiar `DBT_DATASET_PREFIX` desde los secretos o variables del repositorio.

## Paso 3: cargar datos raw

```bash
cd dbt
dbt seed
```

Esto crea tablas raw en BigQuery a partir de los CSV de `seeds/raw`.

## Paso 4: construir modelos

```bash
dbt run
```

dbt construye:

- vistas de staging;
- vistas intermedias;
- tablas finales en marts.

## Paso 5: ejecutar pruebas

```bash
dbt test
```

Las pruebas validan:

- llaves no nulas;
- llaves unicas;
- relaciones entre hechos y dimensiones;
- valores aceptados en columnas categoricas.

## Paso 6: generar documentacion

```bash
dbt docs generate
dbt docs serve --host 0.0.0.0 --port 8080
```

Ruta corta para ejecutar carga, modelos, pruebas y documentacion:

```bash
make workshop
```

Abrir el puerto `8080` desde Codespaces para ver:

- modelos;
- columnas;
- sources;
- pruebas;
- linaje.

## Paso 7: consulta analitica

En BigQuery, buscar el dataset:

```text
${DBT_DATASET_PREFIX}_marts
```

Consultar la tabla:

```sql
select
  categoria,
  sum(venta_neta) as venta_neta,
  sum(margen_estimado) as margen_estimado
from `GCP_PROJECT_ID.DBT_DATASET_PREFIX_marts.mart_ventas_por_categoria`
group by categoria
order by venta_neta desc;
```

Ejemplo si el proyecto es `ss2-dbt-workshop` y el prefijo es `grupo_demo`:

```sql
select
  categoria,
  sum(venta_neta) as venta_neta,
  sum(margen_estimado) as margen_estimado
from `ss2-dbt-workshop.grupo_demo_marts.mart_ventas_por_categoria`
group by categoria
order by venta_neta desc;
```

## Preguntas de reflexion

1. Que diferencia hay entre `source()` y `ref()`?
2. Por que staging debe hacer transformaciones simples?
3. Que problema detecta una prueba `relationships`?
4. Que ventaja aporta dbt Docs al trabajo en equipo?
5. Como se relaciona este taller con el Proyecto 1 de Python, Airflow, PostgreSQL y dbt?
