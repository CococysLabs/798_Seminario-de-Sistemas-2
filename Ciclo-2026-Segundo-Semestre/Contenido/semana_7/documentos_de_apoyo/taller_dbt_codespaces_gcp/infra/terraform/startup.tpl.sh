#!/usr/bin/env bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl git jq python3 python3-venv python3-pip

python3 -m pip install --upgrade pip
python3 -m pip install "dbt-core>=1.8,<2.0" "dbt-bigquery>=1.8,<2.0"

mkdir -p /opt/ss2-dbt-workshop
cat > /opt/ss2-dbt-workshop/README.txt <<'EOF'
VM opcional para el taller dbt.

El flujo principal del taller se ejecuta desde GitHub Codespaces.
Esta VM queda preparada para futuras demostraciones administradas por el docente.
EOF

