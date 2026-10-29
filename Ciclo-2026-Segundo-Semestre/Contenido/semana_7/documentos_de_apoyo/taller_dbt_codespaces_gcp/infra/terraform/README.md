# Terraform - Infraestructura GCP del taller

Este directorio prepara recursos GCP administrados por el docente para el taller dbt.

## Recursos

- Datasets BigQuery por grupo:
  - `<prefix>_raw`
  - `<prefix>_staging`
  - `<prefix>_intermediate`
  - `<prefix>_marts`
- Bucket GCS para raw/evidencias.
- Service account para Codespaces.
- Permisos minimos sobre BigQuery y GCS.
- VM opcional, desactivada por defecto.

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Obtener llave para Codespaces

```bash
terraform output -raw service_account_key_json
```

Guardar ese valor como secreto:

```text
GCP_SERVICE_ACCOUNT_KEY_JSON
```

## Limpieza

```bash
terraform destroy
```

`delete_contents_on_destroy` y `force_destroy` estan activos para facilitar limpieza del taller.

