$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$envFile = Join-Path $scriptDir "proyecto2.env.ps1"

if (Test-Path $envFile) {
  . $envFile
} else {
  Write-Warning "No existe scripts/proyecto2.env.ps1. Se usaran variables de entorno ya definidas."
}

$sqlFiles = @(
  "00_create_dataset.sql",
  "01_exploracion_inicial.sql",
  "02_tabla_optimizada.sql",
  "03_consultas_analiticas.sql",
  "04_feature_engineering.sql",
  "05_bqml_clasificacion.sql",
  "06_bqml_regresion.sql",
  "07_dashboard_exports.sql"
)

foreach ($file in $sqlFiles) {
  $sqlPath = Join-Path (Join-Path $projectRoot "sql") $file
  & (Join-Path $scriptDir "Invoke-BigQuerySql.ps1") -SqlFile $sqlPath
}

Write-Host "Flujo completado."
