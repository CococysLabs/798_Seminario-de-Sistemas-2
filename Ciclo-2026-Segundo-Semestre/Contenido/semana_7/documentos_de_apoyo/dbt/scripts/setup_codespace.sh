#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.dbt" "$HOME/.ss2"

if [[ -f "dbt/profiles.yml" ]]; then
  cp dbt/profiles.yml "$HOME/.dbt/profiles.yml"
fi

if [[ -n "${SS2_WORKSHOP_CONFIG:-}" ]]; then
  printf '%s' "$SS2_WORKSHOP_CONFIG" > "$HOME/.ss2/workshop.json"
  chmod 600 "$HOME/.ss2/workshop.json"
  export SS2_WORKSHOP_FILE="$HOME/.ss2/workshop.json"
  if ! grep -q "SS2_WORKSHOP_FILE" "$HOME/.bashrc"; then
    {
      echo ''
      echo '# SS2 dbt workshop'
      echo 'export SS2_WORKSHOP_FILE="$HOME/.ss2/workshop.json"'
    } >> "$HOME/.bashrc"
  fi
fi

if [[ -z "${DBT_DATASET_PREFIX:-}" ]]; then
  export DBT_DATASET_PREFIX="${CODESPACE_NAME:-grupo_demo}"
  if ! grep -q "DBT_DATASET_PREFIX" "$HOME/.bashrc"; then
    echo 'export DBT_DATASET_PREFIX="${CODESPACE_NAME:-grupo_demo}"' >> "$HOME/.bashrc"
  fi
fi

cat <<'MSG'
Codespace preparado.

Variables esperadas:
- GCP_PROJECT_ID
- DBT_DATASET_PREFIX

Siguiente paso:
  cd dbt
  dbt debug
MSG
