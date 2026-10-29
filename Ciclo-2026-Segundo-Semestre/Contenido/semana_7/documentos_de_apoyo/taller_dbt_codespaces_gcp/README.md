# Taller dbt + Codespaces + GCP

Mini taller para Seminario de Sistemas 2. El objetivo es que cada estudiante ejecute dbt desde GitHub Codespaces y materialice modelos analiticos en BigQuery, usando infraestructura GCP administrada por el docente.

## Flujo general

```text
GitHub Codespaces
  |
  | dbt Core + dbt-bigquery
  v
GCP administrado por docente
  |
  +-- BigQuery: datasets raw, staging, intermediate, marts
  +-- GCS: bucket opcional para archivos raw/evidencias
  +-- VM opcional: preparada en Terraform, desactivada por defecto
```

## Que aprende el estudiante

- Ejecutar un proyecto dbt en Codespaces.
- Cargar datos raw con `dbt seed`.
- Declarar `sources`.
- Construir modelos `staging`, `intermediate` y `marts`.
- Crear dimensiones, hechos y marts agregados.
- Ejecutar pruebas de calidad.
- Generar documentacion y revisar linaje.
- Consultar tablas finales en BigQuery.

## Ejecucion rapida para estudiante

El docente debe configurar primero los secretos de Codespaces indicados en `docs/guia_docente.md`.

Luego el estudiante abre el repositorio en Codespaces y ejecuta:

```bash
make validate
make workshop
```

Tambien puede ejecutar los comandos paso a paso:

```bash
cd dbt
dbt debug
dbt seed
dbt run
dbt test
dbt docs generate
dbt docs serve --host 0.0.0.0 --port 8080
```

## Estructura del repositorio

```text
taller_dbt_codespaces_gcp/
  .devcontainer/
  dbt/
    dbt_project.yml
    profiles.yml
    seeds/raw/
    models/staging/
    models/intermediate/
    models/marts/
    macros/
    analyses/
  docs/
    guia_estudiante.md
    guia_docente.md
    arquitectura_gcp.md
  infra/terraform/
  scripts/
```

## Nota

Este taller no pide que los estudiantes administren GCP. Ellos solo ejecutan dbt. El docente controla proyecto, datasets, bucket, service account, permisos y limpieza posterior.
