param(
  [Parameter(Mandatory = $true)]
  [string]$SqlFile,

  [string]$ProjectId = $env:PROJECT_ID,
  [string]$DatasetId = $env:DATASET_ID,
  [string]$Location = $env:BQ_LOCATION,
  [string]$SourceStartDate = $env:SOURCE_START_DATE,
  [string]$SourceEndDate = $env:SOURCE_END_DATE,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-ActiveGcloudProject {
  try {
    $project = (& gcloud config get-value project 2>$null)
    if ($LASTEXITCODE -eq 0 -and $project) {
      $project = $project.Trim()
      if ($project -and $project -ne "(unset)") {
        return $project
      }
    }
  } catch {
    # Si gcloud no responde o no existe configuracion, se maneja mas abajo.
  }

  return $null
}

function Get-GcloudAccessToken {
  try {
    $token = (& gcloud auth print-access-token 2>$null)
    if ($LASTEXITCODE -eq 0 -and $token) {
      $token = $token.Trim()
      if ($token) {
        return $token
      }
    }
  } catch {
    # Se reporta mas abajo.
  }

  throw "No se pudo obtener un access token con gcloud auth print-access-token."
}

function Invoke-BigQueryApiQuery {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Query,

    [Parameter(Mandatory = $true)]
    [string]$ProjectId,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [switch]$DryRun
  )

  $token = Get-GcloudAccessToken
  $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
  }

  $body = @{
    configuration = @{
      query = @{
        query = $Query
        useLegacySql = $false
      }
    }
    jobReference = @{
      projectId = $ProjectId
      location = $Location
    }
  }

  if ($DryRun) {
    $body.configuration.dryRun = $true
  }

  $payload = $body | ConvertTo-Json -Depth 10
  $jobsBaseUrl = "https://bigquery.googleapis.com/bigquery/v2/projects/$ProjectId/jobs"
  try {
    $job = Invoke-RestMethod -Method Post -Uri $jobsBaseUrl -Headers $headers -Body $payload
  } catch {
    $response = $_.Exception.Response
    if ($response) {
      $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
      $errorBody = $reader.ReadToEnd()
      throw "Fallo al crear el job de BigQuery: $errorBody"
    }
    throw
  }

  if ($DryRun) {
    return $job
  }

  $jobId = $job.jobReference.jobId
  if (-not $jobId) {
    $jobJson = $job | ConvertTo-Json -Depth 10 -Compress
    throw "No se pudo obtener jobId desde la respuesta de BigQuery: $jobJson"
  }
  $jobStatusUrl = "${jobsBaseUrl}/${jobId}?location=$Location"

  do {
    Start-Sleep -Seconds 3
    try {
      $jobStatus = Invoke-RestMethod -Method Get -Uri $jobStatusUrl -Headers $headers
    } catch {
      $response = $_.Exception.Response
      if ($response) {
        $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        throw "Fallo consultando el estado del job de BigQuery ($jobStatusUrl): $errorBody"
      }
      throw
    }
  } while ($jobStatus.status.state -ne "DONE")

  if ($jobStatus.status.errorResult) {
    $errorJson = $jobStatus.status | ConvertTo-Json -Depth 10 -Compress
    throw "BigQuery reporto un error: $errorJson"
  }

  return $jobStatus
}

if (-not $ProjectId) {
  $ProjectId = Get-ActiveGcloudProject
}

if (-not $ProjectId) {
  throw "PROJECT_ID no esta definido y no se pudo obtener el proyecto activo desde gcloud."
}

if (-not $DatasetId) {
  $DatasetId = "proyecto2_taxi"
}

if (-not $Location) {
  $Location = "US"
}

if (-not $SourceStartDate) {
  $SourceStartDate = "2022-01-01"
}

if (-not $SourceEndDate) {
  $SourceEndDate = "2022-12-31"
}

$resolvedSqlFile = Resolve-Path $SqlFile
$sql = Get-Content $resolvedSqlFile -Raw
$sql = $sql.Replace('${PROJECT_ID}', $ProjectId)
$sql = $sql.Replace('${DATASET_ID}', $DatasetId)
$sql = $sql.Replace('${BQ_LOCATION}', $Location)
$sql = $sql.Replace('${SOURCE_START_DATE}', $SourceStartDate)
$sql = $sql.Replace('${SOURCE_END_DATE}', $SourceEndDate)

$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "proyecto2_bigquery"
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
$renderedPath = Join-Path $tmpDir ([System.IO.Path]::GetFileName($resolvedSqlFile))
Set-Content -Path $renderedPath -Value $sql -Encoding UTF8

Write-Host "Ejecutando: $resolvedSqlFile"
Write-Host "Proyecto activo: $ProjectId"
Write-Host "Dataset destino: $DatasetId"
Write-Host "Rango fuente: $SourceStartDate a $SourceEndDate"

$jobStatus = Invoke-BigQueryApiQuery -Query $sql -ProjectId $ProjectId -Location $Location -DryRun:$DryRun

if ($DryRun) {
  $totalBytes = $jobStatus.statistics.totalBytesProcessed
  Write-Host "Dry run completado. Bytes procesados estimados: $totalBytes"
} else {
  Write-Host "Consulta completada. Job ID: $($jobStatus.jobReference.jobId)"
}
