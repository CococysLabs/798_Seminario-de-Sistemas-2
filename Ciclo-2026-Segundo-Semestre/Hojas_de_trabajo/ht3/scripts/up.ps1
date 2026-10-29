$ErrorActionPreference = "Stop"

function Get-PythonCommand {
    foreach ($cmd in @("py", "python", "python3")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            return $cmd
        }
    }
    throw "No se encontro un ejecutable de Python (py/python/python3) en PATH."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ht3Dir = Resolve-Path (Join-Path $scriptDir "..")
$terraformDir = Join-Path $ht3Dir "terraform"

Push-Location $terraformDir
terraform init
terraform apply -auto-approve
$bucketName = terraform output -raw bucket_name
Pop-Location

$pythonCmd = Get-PythonCommand

Push-Location $ht3Dir
& $pythonCmd -m pip install -r requirements.txt
& $pythonCmd .\spark_connect_carnet_to_gcs.py
Pop-Location

Write-Host "Proceso completado. Bucket usado: $bucketName"
Write-Host "Recuerda ajustar CARNET/BUCKET_NAME/SPARK_CONNECT_URL en spark_connect_carnet_to_gcs.py"
