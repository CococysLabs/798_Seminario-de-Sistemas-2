#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$HOME/.ss2_dbt_workshop_env"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
elif [[ -f "$ROOT_DIR/scripts/setup_codespace.sh" ]]; then
  bash "$ROOT_DIR/scripts/setup_codespace.sh"
  source "$ENV_FILE"
fi

echo "== Versiones =="
python --version
dbt --version

echo
echo "== Variables =="
: "${GCP_PROJECT_ID:?Falta GCP_PROJECT_ID}"
: "${DBT_DATASET_PREFIX:?Falta DBT_DATASET_PREFIX}"
: "${GOOGLE_APPLICATION_CREDENTIALS:?Falta GOOGLE_APPLICATION_CREDENTIALS}"
: "${SS2_WORKSHOP_FILE:?Falta SS2_WORKSHOP_FILE}"

if [[ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
  echo "Falta preparar la conexion con BigQuery."
  echo "El docente debe configurar el secret GCP_SERVICE_ACCOUNT_KEY_JSON en Codespaces."
  exit 1
fi

test -f "$SS2_WORKSHOP_FILE"

echo
echo "== dbt debug =="
cd "$ROOT_DIR/dbt"
dbt debug

echo
echo "Ambiente valido."
