$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ht3Dir = Resolve-Path (Join-Path $scriptDir "..")
$terraformDir = Join-Path $ht3Dir "terraform"

Push-Location $terraformDir
terraform init
terraform destroy -auto-approve
Pop-Location

Write-Host "Infraestructura destruida."

