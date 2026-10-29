#!/usr/bin/env bash
set -euo pipefail

echo "== Versiones =="
python --version
dbt --version

echo
echo "== Variables =="
: "${GCP_PROJECT_ID:?Falta GCP_PROJECT_ID}"
: "${DBT_DATASET_PREFIX:?Falta DBT_DATASET_PREFIX}"

if [[ -z "${SS2_WORKSHOP_FILE:-}" || ! -f "$SS2_WORKSHOP_FILE" ]]; then
  echo "Falta preparar la conexion con BigQuery. Cierra y vuelve a abrir el Codespace; si persiste, avisa al auxiliar."
  exit 1
fi

echo
echo "== dbt debug =="
cd dbt
dbt debug

echo
echo "Ambiente valido."
