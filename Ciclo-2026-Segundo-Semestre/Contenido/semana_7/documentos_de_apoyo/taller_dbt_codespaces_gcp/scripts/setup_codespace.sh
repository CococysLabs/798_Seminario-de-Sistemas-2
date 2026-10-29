#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ID="${GCP_PROJECT_ID:-project-643d2a1a-b690-4d08-b00}"
BIGQUERY_LOCATION="${GCP_BIGQUERY_LOCATION:-US}"
CREDENTIALS_FILE="$HOME/.gcp/ss2-dbt-workshop-sa.json"
ENV_FILE="$HOME/.ss2_dbt_workshop_env"

if [[ -n "${DBT_DATASET_PREFIX:-}" && "${DBT_DATASET_PREFIX}" != "${CODESPACE_NAME:-}" ]]; then
  DATASET_PREFIX="$DBT_DATASET_PREFIX"
else
  DATASET_PREFIX="grupo_demo"
fi

mkdir -p "$HOME/.dbt" "$HOME/.gcp"

if [[ -f "$ROOT_DIR/dbt/profiles.yml" ]]; then
  cp "$ROOT_DIR/dbt/profiles.yml" "$HOME/.dbt/profiles.yml"
fi

if [[ -n "${GCP_SERVICE_ACCOUNT_KEY_JSON:-}" ]]; then
  printf '%s' "$GCP_SERVICE_ACCOUNT_KEY_JSON" > "$CREDENTIALS_FILE"
  chmod 600 "$CREDENTIALS_FILE"
fi

cat > "$ENV_FILE" <<EOF
export GCP_PROJECT_ID="$PROJECT_ID"
export GCP_BIGQUERY_LOCATION="$BIGQUERY_LOCATION"
export DBT_DATASET_PREFIX="$DATASET_PREFIX"
export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_FILE"
export SS2_WORKSHOP_FILE="$CREDENTIALS_FILE"
EOF

if ! grep -q ".ss2_dbt_workshop_env" "$HOME/.bashrc"; then
  {
    echo ''
    echo '# SS2 dbt workshop'
    echo 'source "$HOME/.ss2_dbt_workshop_env"'
  } >> "$HOME/.bashrc"
fi

source "$ENV_FILE"

cat <<MSG
Codespace preparado.

Configuracion aplicada:
- Proyecto GCP: $PROJECT_ID
- Ubicacion BigQuery: $BIGQUERY_LOCATION
- Prefijo de datasets: $DATASET_PREFIX
- Credencial local: ~/.gcp/ss2-dbt-workshop-sa.json

Siguiente paso:
  make validate
MSG
