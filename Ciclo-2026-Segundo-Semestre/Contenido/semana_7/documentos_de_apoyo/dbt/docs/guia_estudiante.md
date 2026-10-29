# Guia del estudiante

## Objetivo

Ejecutar un proyecto dbt desde GitHub Codespaces para transformar datos raw de SG-Food en modelos analiticos sobre BigQuery.

## Antes de iniciar

El Codespace del taller ya contiene las herramientas necesarias. No es necesario instalar dbt localmente.

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

Si todo esta correcto, `dbt debug` debe finalizar sin errores y mostrara conexion valida con BigQuery.

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

- identificadores no nulos;
- identificadores unicos;
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
from `nombre_del_proyecto.prefijo_marts.mart_ventas_por_categoria`
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

## Cierre del taller

Cuando termines, puedes cerrar el Codespace. El objetivo del taller es practicar el ciclo de trabajo de dbt: cargar datos raw, construir modelos, ejecutar pruebas, generar documentacion y revisar linaje.

## Preguntas de reflexion

1. Que diferencia hay entre `source()` y `ref()`?
2. Por que staging debe hacer transformaciones simples?
3. Que problema detecta una prueba `relationships`?
4. Que ventaja aporta dbt Docs al trabajo en equipo?
5. Como se relaciona este taller con el Proyecto 1 de Python, Airflow, PostgreSQL y dbt?
