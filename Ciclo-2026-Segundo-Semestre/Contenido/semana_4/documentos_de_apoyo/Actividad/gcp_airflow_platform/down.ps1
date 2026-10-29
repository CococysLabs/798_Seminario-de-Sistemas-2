$ErrorActionPreference = "Stop"

$ProjectId = "project-643d2a1a-b690-4d08-b00"
$Region = "us-central1"
$Gcloud = "C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"

Push-Location $PSScriptRoot
try {
    # La VM y su disco son los recursos principales con costo continuo.
    terraform destroy -auto-approve '-target=google_compute_instance.airflow'
    if ($LASTEXITCODE -ne 0) { throw "Terraform destroy falló con código $LASTEXITCODE" }
}
finally {
    Pop-Location
}

# Cloud Run cobra por uso, pero se elimina para dejar el laboratorio fuera de servicio.
$services = & $Gcloud run services list --project $ProjectId --region $Region --format="value(metadata.name)"
if ($services -contains "ss2-github-inscripcion") {
    & $Gcloud run services delete ss2-github-inscripcion `
        --project $ProjectId `
        --region $Region `
        --quiet
    if ($LASTEXITCODE -ne 0) { throw "No se pudo eliminar Cloud Run" }
}

Write-Host "Laboratorio apagado. GitHub, bucket de DAGs, WIF y Secret Manager fueron conservados."
