# Terraform - Semana 9

Este modulo crea un entorno minimo para ejecutar el ejemplo practico:

- 1 dataset de BigQuery;
- 1 bucket de Cloud Storage para cargas y exportaciones;
- 1 archivo `.env` local con valores utiles.

## Uso

1. Copia `terraform.tfvars.example` como `terraform.tfvars`.
2. Ajusta `project_id` y `bucket_name`.
3. Ejecuta:

```powershell
terraform init
terraform plan
terraform apply
```

## Recursos creados

- Dataset: `semana9_novashop` por defecto.
- Bucket: lo defines en `bucket_name`.

## Despliegue del ejemplo

Despues de aplicar:

1. Sube los CSV de `../data/` al bucket en la carpeta `semana9/`.
2. Usa las rutas de `terraform output`.
3. Ejecuta los SQL de `../sql/`.
