# Taller dbt + BigQuery en Codespaces

Mini taller para Seminario de Sistemas 2. El objetivo es ejecutar dbt desde GitHub Codespaces y materializar modelos analiticos en BigQuery.

## Flujo general

```text
GitHub Codespaces
  |
  | dbt Core + dbt-bigquery
  v
BigQuery
  |
  +-- raw
  +-- staging
  +-- intermediate
  +-- marts
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

## Ejecucion rapida

Abrir el repositorio en Codespaces y ejecutar:

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
  scripts/
```

## Resultado esperado

Al finalizar, dbt habra creado modelos en BigQuery y la documentacion local mostrara sources, modelos, pruebas y linaje.
