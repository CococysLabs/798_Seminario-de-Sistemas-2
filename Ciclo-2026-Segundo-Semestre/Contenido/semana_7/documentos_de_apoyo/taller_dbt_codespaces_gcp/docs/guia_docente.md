# Guia docente

## Proposito

Este taller permite simular una experiencia real de modelado analitico con dbt sin pedir a los estudiantes que administren GCP. El estudiante abre Codespaces, ejecuta dbt y observa tablas materializadas en BigQuery.

## Arquitectura recomendada

```text
GitHub Codespaces
  |
  | dbt Core + dbt-bigquery
  v
BigQuery
  |
  +-- <grupo>_raw
  +-- <grupo>_staging
  +-- <grupo>_intermediate
  +-- <grupo>_marts
```

GCS queda disponible para archivos raw o evidencias, pero este taller inicial usa `dbt seed` para simplificar la clase.

## Preparacion de GCP

1. Crear o seleccionar un proyecto GCP exclusivo para el taller.
2. Habilitar APIs:

```bash
gcloud services enable bigquery.googleapis.com storage.googleapis.com iam.googleapis.com
```

3. Aplicar Terraform desde `infra/terraform`:

```bash
cd infra/terraform
terraform init
terraform apply
```

4. Guardar los outputs:

```bash
terraform output
terraform output -raw service_account_key_json
```

## Secretos de Codespaces

Configurar este secreto en GitHub antes de la clase:

| Secreto | Valor |
|---|---|
| `GCP_SERVICE_ACCOUNT_KEY_JSON` | JSON completo de la llave de service account |

El repositorio ya define valores por defecto para que el estudiante no tenga que exportar variables:

| Variable | Valor por defecto |
|---|---|
| `GCP_PROJECT_ID` | `project-643d2a1a-b690-4d08-b00` |
| `GCP_BIGQUERY_LOCATION` | `US` |
| `DBT_DATASET_PREFIX` | `grupo_demo` |

Para una clase con varios grupos, se recomienda que cada grupo tenga su propio fork o Codespace con un valor distinto de `DBT_DATASET_PREFIX`.

## Simular como estudiante

1. Crear un Codespace del repositorio.
2. Confirmar que los secretos esten disponibles.
3. Ejecutar:

```bash
bash scripts/validate_environment.sh
bash scripts/run_workshop.sh
```

Ruta corta equivalente:

```bash
make validate
make workshop
```

4. Abrir dbt Docs:

```bash
cd dbt
dbt docs serve --host 0.0.0.0 --port 8080
```

5. Revisar en BigQuery:

```text
${DBT_DATASET_PREFIX}_raw
${DBT_DATASET_PREFIX}_staging
${DBT_DATASET_PREFIX}_intermediate
${DBT_DATASET_PREFIX}_marts
```

## Actividad sugerida de clase

1. Ejecutar `dbt seed` y mostrar los datasets raw.
2. Abrir `stg_sgfood__ventas.sql` y explicar limpieza tecnica.
3. Ejecutar `dbt run` y mostrar el orden de ejecucion.
4. Abrir `int_ventas_enriquecidas.sql` y explicar integracion.
5. Abrir `fact_ventas.sql` y `mart_ventas_por_categoria.sql`.
6. Ejecutar `dbt test`.
7. Romper un dato en `ventas.csv`, por ejemplo cambiar `mayorista` por `online`.
8. Ejecutar `dbt seed --full-refresh` y `dbt test` para mostrar una prueba fallida.
9. Corregir el dato y ejecutar de nuevo.
10. Generar dbt Docs y explicar linaje.

## Limpieza posterior

Si solo se desea limpiar modelos de un grupo:

```bash
bq rm -r -f "${GCP_PROJECT_ID}:${DBT_DATASET_PREFIX}_raw"
bq rm -r -f "${GCP_PROJECT_ID}:${DBT_DATASET_PREFIX}_staging"
bq rm -r -f "${GCP_PROJECT_ID}:${DBT_DATASET_PREFIX}_intermediate"
bq rm -r -f "${GCP_PROJECT_ID}:${DBT_DATASET_PREFIX}_marts"
```

Si se desea eliminar toda la infraestructura del taller:

```bash
cd infra/terraform
terraform destroy
```

## Seguridad

- Usar un proyecto GCP aislado para el taller.
- Rotar la llave de service account al finalizar.
- No reutilizar la llave para proyectos personales.
- Mantener permisos limitados a BigQuery y GCS del taller.
- Evitar datasets compartidos entre grupos si todos ejecutan al mismo tiempo.
