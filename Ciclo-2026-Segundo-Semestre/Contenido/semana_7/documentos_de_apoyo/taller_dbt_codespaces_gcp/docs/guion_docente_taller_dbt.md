# Guion docente: mini taller dbt con Codespaces y BigQuery

## 1. Proposito de la sesion

El objetivo del taller es que los estudiantes entiendan como dbt ayuda a transformar datos dentro de un data warehouse moderno. En este caso, el entorno usa:

- GitHub Codespaces como ambiente de trabajo.
- dbt Core como herramienta de transformacion.
- BigQuery como data warehouse.
- CSV de ejemplo como datos raw de SG-Food.

El estudiante no administra infraestructura de GCP. Su trabajo es ejecutar dbt, observar como se crean las capas del modelo analitico y entender la relacion entre codigo SQL, pruebas, documentacion y tablas finales.

## 2. Idea principal que deben entender

dbt no reemplaza a la base de datos. dbt organiza, ejecuta, prueba y documenta transformaciones SQL dentro del data warehouse.

En este taller:

```text
CSV raw
  -> dbt seed
  -> BigQuery raw
  -> modelos staging
  -> modelo intermediate
  -> dimensiones, hechos y mart final
  -> pruebas y documentacion
```

Explicacion para estudiantes:

- `dbt seed` carga archivos CSV como tablas.
- `source()` apunta a tablas de entrada externas o raw.
- `ref()` conecta modelos dbt entre si.
- `dbt run` construye los modelos en orden segun dependencias.
- `dbt test` valida calidad de datos.
- `dbt docs` genera documentacion y linaje.

## 3. Arquitectura del taller

La arquitectura logica es:

```text
Codespaces
  |
  | ejecuta comandos dbt
  v
BigQuery
  |
  +-- <prefijo>_raw
  +-- <prefijo>_staging
  +-- <prefijo>_intermediate
  +-- <prefijo>_marts
```

Para esta instalacion se pueden usar estos valores:

```text
GCP_PROJECT_ID=project-643d2a1a-b690-4d08-b00
GCP_BIGQUERY_LOCATION=US
DBT_DATASET_PREFIX=grupo_demo
```

Si cada grupo trabaja separado, cambie `DBT_DATASET_PREFIX` por el prefijo asignado, por ejemplo:

```text
grupo_01
grupo_02
```

## 4. Antes de iniciar con los estudiantes

Verifique que el repositorio tenga configurados los secretos necesarios en GitHub Codespaces:

```text
GCP_PROJECT_ID
GCP_BIGQUERY_LOCATION
DBT_DATASET_PREFIX
GCP_SERVICE_ACCOUNT_KEY_JSON
```

Explique que `GCP_SERVICE_ACCOUNT_KEY_JSON` no debe compartirse en chats, capturas ni commits. Es una credencial privada que permite a dbt conectarse con BigQuery.

## 5. Paso 1: abrir Codespaces

Indicaciones para estudiantes:

1. Abrir el repositorio del taller en GitHub.
2. Presionar `Code`.
3. Entrar a la pestana `Codespaces`.
4. Crear un nuevo Codespace.
5. Esperar a que termine la instalacion.

Concepto a explicar:

Codespaces es un entorno de desarrollo remoto. Todos ejecutan los mismos comandos en un ambiente controlado, sin instalar Python, dbt o dependencias manualmente en su computadora.

## 6. Paso 2: preparar el ambiente

Desde la raiz del taller:

```bash
make setup
```

Este comando instala dependencias y ejecuta:

```bash
bash scripts/setup_codespace.sh
```

Que hace este script:

- Copia `dbt/profiles.yml` hacia `~/.dbt/profiles.yml`.
- Si existe `GCP_SERVICE_ACCOUNT_KEY_JSON`, crea el archivo de credencial local.
- Define `GOOGLE_APPLICATION_CREDENTIALS`.
- Define `DBT_DATASET_PREFIX` si no existe.

Concepto a explicar:

dbt necesita un `profile` para saber a que motor conectarse. En este taller el profile indica que se usara BigQuery y que el proyecto/dataset salen de variables de ambiente.

## 7. Paso 3: validar ambiente

Ejecutar:

```bash
make validate
```

O directamente:

```bash
bash scripts/validate_environment.sh
```

Este paso valida:

- Version de Python.
- Version de dbt.
- Variables de ambiente requeridas.
- Archivo de credenciales.
- Conexion con BigQuery usando `dbt debug`.

Resultado esperado:

```text
Ambiente valido.
```

Si falla:

- Falta una variable de ambiente.
- No existe el archivo definido en `GOOGLE_APPLICATION_CREDENTIALS`.
- La llave no tiene permisos.
- El prefijo de dataset no existe en BigQuery.

Concepto a explicar:

Antes de transformar datos, se valida conectividad. `dbt debug` es el primer diagnostico cuando algo no conecta.

## 8. Paso 4: revisar estructura del proyecto dbt

Antes de ejecutar todo, muestre la estructura:

```text
dbt/
  dbt_project.yml
  profiles.yml
  seeds/raw/
  models/staging/
  models/intermediate/
  models/marts/
  macros/
  analyses/
```

Explique cada parte:

- `dbt_project.yml`: configuracion del proyecto.
- `profiles.yml`: conexion con BigQuery.
- `seeds/raw`: datos CSV iniciales.
- `models/staging`: limpieza y normalizacion simple.
- `models/intermediate`: integracion entre tablas.
- `models/marts`: tablas finales para analisis.
- `macros`: funciones reutilizables.
- `analyses`: consultas analiticas que no se materializan como modelo.

## 9. Paso 5: cargar datos raw con dbt seed

Ejecutar:

```bash
cd dbt
dbt seed
```

Que crea:

```text
<DBT_DATASET_PREFIX>_raw.clientes
<DBT_DATASET_PREFIX>_raw.productos
<DBT_DATASET_PREFIX>_raw.sucursales
<DBT_DATASET_PREFIX>_raw.ventas
```

Ejemplo con `grupo_demo`:

```text
grupo_demo_raw.clientes
grupo_demo_raw.productos
grupo_demo_raw.sucursales
grupo_demo_raw.ventas
```

Concepto a explicar:

Los seeds sirven para cargar datos pequenos de referencia o datos de ejemplo desde CSV. En un proyecto real, la capa raw normalmente vendria de procesos ETL/ELT, APIs, archivos en cloud storage o herramientas de ingesta.

## 10. Paso 6: explicar source()

Abra:

```text
dbt/models/staging/sources.yml
```

Explique que `source()` declara las tablas de entrada:

```sql
from {{ source('raw_sgfood', 'ventas') }}
```

Idea clave:

`source()` se usa cuando dbt lee datos que vienen de fuera del flujo de modelos dbt. En este taller son tablas raw creadas por `dbt seed`.

Tambien muestre que `sources.yml` documenta y prueba datos raw:

- `not_null`
- `unique`
- `accepted_values`

## 11. Paso 7: explicar staging

Abra:

```text
dbt/models/staging/stg_sgfood__ventas.sql
```

Explique que staging hace transformaciones simples:

- Convertir tipos: `cast(... as int64)`, `cast(... as date)`.
- Normalizar texto.
- Calcular columnas tecnicas basicas.
- Mantener una estructura cercana a la fuente.

Ejemplo:

```sql
cast(fecha_venta as date) as fecha_venta,
lower({{ normalizar_texto('canal') }}) as canal
```

Concepto a explicar:

Staging no debe contener logica de negocio compleja. Su proposito es limpiar y estandarizar para que las siguientes capas trabajen con datos confiables.

## 12. Paso 8: explicar ref()

Abra:

```text
dbt/models/intermediate/int_ventas_enriquecidas.sql
```

Explique que `ref()` conecta modelos dbt:

```sql
from {{ ref('stg_sgfood__ventas') }} as v
inner join {{ ref('stg_sgfood__clientes') }} as c
```

Idea clave:

`ref()` le dice a dbt que un modelo depende de otro. Con eso dbt construye el orden correcto de ejecucion y genera el grafo de linaje.

Diferencia importante:

```text
source() = datos de entrada externos/raw
ref()    = modelos creados por dbt
```

## 13. Paso 9: construir modelos con dbt run

Ejecutar:

```bash
dbt run
```

Que construye:

- Vistas en `<prefijo>_staging`.
- Vistas en `<prefijo>_intermediate`.
- Tablas en `<prefijo>_marts`.

Explique las capas:

```text
raw: datos de entrada
staging: datos limpios y tipados
intermediate: datos integrados
marts: datos listos para analisis
```

Modelos finales importantes:

```text
dim_cliente
dim_producto
dim_sucursal
fact_ventas
mart_ventas_por_categoria
```

Concepto a explicar:

dbt no ejecuta archivos al azar. Calcula dependencias usando `ref()` y `source()` y ejecuta el DAG de modelos en el orden correcto.

## 14. Paso 10: explicar dimensiones, hechos y marts

Abra los modelos de `dbt/models/marts/`.

Explique:

- `dim_cliente`: datos descriptivos de clientes.
- `dim_producto`: datos descriptivos de productos.
- `dim_sucursal`: datos descriptivos de sucursales.
- `fact_ventas`: eventos medibles de ventas.
- `mart_ventas_por_categoria`: tabla agregada para responder una pregunta de negocio.

Pregunta de negocio del mart:

```text
Cuanto se vendio y cuanto margen hubo por categoria, canal y fecha?
```

Ejemplo de agregacion:

```sql
select
  fecha_venta,
  categoria,
  canal,
  sum(cantidad) as unidades_vendidas,
  sum(monto_neto) as venta_neta,
  sum(margen_estimado) as margen_estimado
from {{ ref('int_ventas_enriquecidas') }}
group by fecha_venta, categoria, canal
```

## 15. Paso 11: ejecutar pruebas con dbt test

Ejecutar:

```bash
dbt test
```

Explique que dbt permite probar datos, no solo codigo.

Pruebas usadas:

- `not_null`: el campo no debe venir vacio.
- `unique`: no debe repetirse.
- `relationships`: valida integridad referencial.
- `accepted_values`: restringe valores permitidos.

Ejemplo:

```yaml
- name: canal
  tests:
    - accepted_values:
        values: ['mayorista', 'minorista']
```

Concepto a explicar:

Las pruebas automatizadas evitan que datos incorrectos lleguen a reportes, dashboards o decisiones de negocio.

## 16. Paso 12: generar documentacion

Ejecutar:

```bash
dbt docs generate
dbt docs serve --host 0.0.0.0 --port 8080
```

En Codespaces, abrir el puerto `8080`.

Mostrar:

- Lista de modelos.
- Columnas.
- Descripciones.
- Pruebas.
- Sources.
- Linaje.

Concepto a explicar:

dbt Docs convierte el proyecto en documentacion navegable. Esto ayuda a que otros analistas o ingenieros entiendan de donde vienen los datos y como se transforman.

## 17. Paso 13: ejecutar el taller completo

Cuando ya se explicaron las partes, se puede ejecutar todo con:

```bash
make workshop
```

Este comando ejecuta:

```bash
dbt debug
dbt seed
dbt run
dbt test
dbt docs generate
```

## 18. Paso 14: consulta final en BigQuery

Pedir a los estudiantes consultar el mart final:

```sql
select
  categoria,
  sum(venta_neta) as venta_neta,
  sum(margen_estimado) as margen_estimado
from `project-643d2a1a-b690-4d08-b00.grupo_demo_marts.mart_ventas_por_categoria`
group by categoria
order by venta_neta desc;
```

Si usan otro prefijo, reemplazar `grupo_demo_marts` por:

```text
<DBT_DATASET_PREFIX>_marts
```

Concepto a explicar:

El resultado final del pipeline no es solo una tabla. Es un modelo analitico confiable, versionado, probado y documentado.

## 19. Actividad corta para comprobar aprendizaje

Pida a los estudiantes responder:

1. Que diferencia hay entre `source()` y `ref()`?
2. En que capa se deben hacer conversiones de tipos?
3. Que capa deberia alimentar un dashboard?
4. Que detecta una prueba `relationships`?
5. Por que `dbt docs` es util para equipos de datos?

Luego haga una demostracion controlada:

1. Abrir `dbt/seeds/raw/ventas.csv`.
2. Cambiar un valor de `canal` de `mayorista` o `minorista` a `online`.
3. Ejecutar:

```bash
dbt seed --full-refresh
dbt test
```

Resultado esperado:

La prueba `accepted_values` debe fallar.

Despues corregir el CSV y ejecutar:

```bash
dbt seed --full-refresh
dbt test
```

Concepto a explicar:

El valor `online` puede ser valido en otro negocio, pero no esta permitido por la regla definida para este modelo. dbt ayuda a hacer explicitas esas reglas.

## 20. Cierre conceptual

Mensajes finales para reforzar:

- dbt transforma datos con SQL, pero agrega estructura de proyecto.
- `source()` representa entradas.
- `ref()` representa dependencias entre modelos.
- Las capas ayudan a separar responsabilidades.
- Las pruebas convierten reglas de calidad en validaciones automaticas.
- La documentacion y el linaje facilitan trabajo en equipo.
- BigQuery ejecuta el procesamiento; dbt orquesta y organiza las transformaciones.

## 21. Checklist para el docente

Antes de clase:

- Confirmar que los datasets existen en BigQuery.
- Confirmar que `GCP_SERVICE_ACCOUNT_KEY_JSON` esta configurado en Codespaces.
- Confirmar que `DBT_DATASET_PREFIX` apunta al grupo correcto.
- Probar `make validate`.

Durante clase:

- Explicar arquitectura.
- Ejecutar `dbt seed`.
- Mostrar tablas raw.
- Explicar `source()`.
- Ejecutar `dbt run`.
- Explicar `ref()` y linaje.
- Ejecutar `dbt test`.
- Generar y abrir `dbt docs`.
- Consultar el mart final en BigQuery.

Despues de clase:

- Revisar si los estudiantes pudieron ejecutar el flujo completo.
- Rotar o eliminar la llave de service account si ya no se usara.
- Mantener o limpiar datasets segun la planificacion del curso.
