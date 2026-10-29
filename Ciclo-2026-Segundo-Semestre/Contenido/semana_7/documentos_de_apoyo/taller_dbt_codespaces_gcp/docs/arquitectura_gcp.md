# Arquitectura GCP

## Componentes

| Componente | Uso |
|---|---|
| BigQuery | Destino principal de dbt. Materializa raw, staging, intermediate y marts. |
| GCS | Bucket opcional para datos raw, evidencias o archivos compartidos. |
| IAM Service Account | Identidad usada por Codespaces para ejecutar dbt. |
| VM opcional | Recurso preparado para futuras demostraciones, desactivado por defecto. |

## Datasets

dbt genera datasets usando el prefijo del estudiante o grupo:

```text
${DBT_DATASET_PREFIX}_raw
${DBT_DATASET_PREFIX}_staging
${DBT_DATASET_PREFIX}_intermediate
${DBT_DATASET_PREFIX}_marts
```

Ejemplo:

```text
grupo_demo_raw
grupo_demo_staging
grupo_demo_intermediate
grupo_demo_marts
```

## Permisos minimos

La service account necesita:

- ejecutar jobs de BigQuery;
- crear, actualizar y borrar tablas dentro de los datasets del taller;
- leer/escribir objetos en el bucket del taller si se usa GCS.

## VM opcional

La VM esta incluida en Terraform con `create_vm = false`. Puede activarse en el futuro si se desea mostrar un entorno administrado por el docente.

Uso sugerido de la VM futura:

- ejecutar dbt desde una maquina central;
- hospedar scripts de carga;
- demostrar conexion remota controlada;
- integrarse con Airflow administrado por el docente.
