#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../dbt"

dbt debug
dbt seed
dbt run
dbt test
dbt docs generate

echo
echo "Taller ejecutado. Para ver documentacion:"
echo "  cd dbt"
echo "  dbt docs serve --host 0.0.0.0 --port 8080"

