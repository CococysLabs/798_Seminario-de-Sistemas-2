# Infraestructura reproducible de Airflow en GCP

## Versiones

- Apache Airflow: `3.3.0`
- Python: `3.11`
- Pandas: `2.2.3`
- PostgreSQL: `15`
- Compute Engine: `n2-standard-2` (2 vCPU, 8 GB)

Las versiones están fijadas en `startup.sh.tftpl` y en el repositorio estudiantil.

## Dar de alta

Desde PowerShell:

```powershell
.\up.ps1
```

El script:

1. aplica Terraform y crea la VM;
2. sincroniza los DAGs al bucket;
3. despliega el portal en Cloud Run;
4. conecta la última versión del secreto de GitHub.

El primer arranque puede tardar entre 10 y 20 minutos porque instala Docker y
construye la imagen de Airflow. La IP pública puede cambiar en cada alta; usar
`terraform output airflow_url` para obtenerla.

## Dar de baja

```powershell
.\down.ps1
```

Se eliminan la VM, su disco y Cloud Run. Se conservan deliberadamente:

- bucket versionado de DAGs;
- Workload Identity Federation para GitHub Actions;
- cuentas de servicio e IAM;
- Secret Manager y el token de GitHub;
- estado local de Terraform.

Estos recursos conservados no ejecutan cómputo continuo. El bucket puede producir
un costo de almacenamiento mínimo. Los repositorios, PR y reglas de GitHub no se
modifican.

## Verificación después del alta

```powershell
terraform output airflow_url
gcloud compute ssh ss2-airflow --zone us-east1-b --command `
  "sudo docker compose -f /opt/ss2-airflow/docker-compose.yml ps"
```

Dentro del scheduler:

```bash
sudo docker compose -f /opt/ss2-airflow/docker-compose.yml exec -T scheduler \
  python -c "import airflow,pandas; print(airflow.__version__, pandas.__version__)"
sudo docker compose -f /opt/ss2-airflow/docker-compose.yml exec -T scheduler \
  airflow dags list-import-errors
```

## Datos locales sensibles

El portal conserva `.env` sólo como respaldo local y está excluido por Git. En
GCP, el token se encuentra en `ss2-github-invite-token`. Nunca ejecutar
`terraform destroy` sin `-target` salvo que se quiera eliminar también la
federación de GitHub, bucket e identidades.
