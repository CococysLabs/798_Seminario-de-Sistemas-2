#!/usr/bin/env bash
set -euo pipefail

SQLCMD_BIN=""

if [ -x "/opt/mssql-tools18/bin/sqlcmd" ]; then
  SQLCMD_BIN="/opt/mssql-tools18/bin/sqlcmd"
elif [ -x "/opt/mssql-tools/bin/sqlcmd" ]; then
  SQLCMD_BIN="/opt/mssql-tools/bin/sqlcmd"
else
  echo "sqlcmd no esta disponible en la imagen de inicializacion."
  exit 1
fi

echo "Esperando a que SQL Server acepte conexiones..."
for _ in $(seq 1 60); do
  if "${SQLCMD_BIN}" -S "${SQLSERVER_HOST},${SQLSERVER_PORT}" -U sa -P "${SA_PASSWORD}" -C -Q "SELECT 1" >/dev/null 2>&1; then
    echo "SQL Server listo. Ejecutando scripts de inicializacion."
    sed \
      -e "s/\$(APP_DB)/${APP_DB}/g" \
      -e "s/\$(APP_LOGIN)/${APP_LOGIN}/g" \
      -e "s/\$(APP_PASSWORD)/${APP_PASSWORD//\//\\/}/g" \
      /workspace/01_create_ssis_lab.sql > /tmp/01_create_ssis_lab.sql

    "${SQLCMD_BIN}" \
      -S "${SQLSERVER_HOST},${SQLSERVER_PORT}" \
      -U sa \
      -P "${SA_PASSWORD}" \
      -C \
      -i /tmp/01_create_ssis_lab.sql

    "${SQLCMD_BIN}" \
      -S "${SQLSERVER_HOST},${SQLSERVER_PORT}" \
      -U sa \
      -P "${SA_PASSWORD}" \
      -C \
      -i /workspace/02_create_datamart_ventas.sql

    echo "Inicializacion completada."
    exit 0
  fi

  sleep 2
done

echo "No fue posible conectarse a SQL Server despues de varios intentos."
exit 1
