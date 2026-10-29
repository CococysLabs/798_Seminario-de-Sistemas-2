$ErrorActionPreference = "Stop"

$ProjectId = "project-643d2a1a-b690-4d08-b00"
$Region = "us-central1"
$ActivityDir = Split-Path -Parent $PSScriptRoot
$RepoDir = Join-Path $ActivityDir "apache_airflow"
$PortalDir = Join-Path $ActivityDir "github_enrollment_portal"
$Gcloud = "C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"

Push-Location $PSScriptRoot
try {
    terraform init
    if ($LASTEXITCODE -ne 0) { throw "Terraform init falló" }
    terraform apply -auto-approve
    if ($LASTEXITCODE -ne 0) { throw "Terraform apply falló" }
    $Bucket = terraform output -raw dag_bucket
}
finally {
    Pop-Location
}

& $Gcloud storage rsync (Join-Path $RepoDir "dags") "gs://$Bucket" --recursive --exclude="(^|/)__pycache__/|\.pyc$"
if ($LASTEXITCODE -ne 0) { throw "No se pudieron sincronizar los DAGs" }

Push-Location $PortalDir
try {
    & $Gcloud run deploy ss2-github-inscripcion `
        --source . `
        --project $ProjectId `
        --region $Region `
        --allow-unauthenticated `
        --set-env-vars GITHUB_ORG=SS2-USAC `
        --update-secrets GITHUB_TOKEN=ss2-github-invite-token:latest `
        --quiet
    if ($LASTEXITCODE -ne 0) { throw "No se pudo desplegar el portal" }
}
finally {
    Pop-Location
}

Write-Host "Alta solicitada. Airflow tarda varios minutos en construir su imagen inicial."
terraform "-chdir=$PSScriptRoot" output
