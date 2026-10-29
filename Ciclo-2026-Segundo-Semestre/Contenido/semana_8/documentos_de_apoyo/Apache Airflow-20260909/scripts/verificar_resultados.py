"""Conciliacion independiente de los resultados del laboratorio local."""
import csv
from datetime import datetime, timezone
from decimal import Decimal
import json
import os
from pathlib import Path

import psycopg2
from lab_api import BASE, client


def main():
    project = Path("/opt/airflow/dbt/sgfood")
    with (project / "seeds/raw/ventas.csv").open(newline="") as file:
        sales = list(csv.DictReader(file))
    expected = sum(Decimal(s["cantidad"]) * (Decimal(s["precio_unitario"]) - Decimal(s["descuento_unitario"])) for s in sales)
    with psycopg2.connect(
        host=os.environ["DBT_HOST"], user=os.environ["DBT_USER"],
        password=os.environ["DBT_PASSWORD"], dbname=os.environ["DBT_DATABASE"],
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*), COUNT(DISTINCT venta_id), SUM(monto_neto) FROM analytics_marts.fact_ventas")
            count, unique, total = cursor.fetchone()
            assert count == unique == len(sales) and total == expected
            cursor.execute("SELECT COUNT(*), SUM(total) FROM raw.ventas WHERE venta_id=1")
            sql_count, sql_total = cursor.fetchone()
            assert sql_count == 1 and sql_total == Decimal("50.00")
    results = json.loads((project / "target/run_results.json").read_text())["results"]
    assert all(r["status"] in ("success", "pass") for r in results)
    test_count = sum(r["unique_id"].startswith("test.") for r in results)
    assert test_count == 38
    state = json.loads(Path("/opt/airflow/logs/pruebas_semana8.json").read_text())
    etl = next(c for c in state["cases"] if c["case"] == "etl")
    response = client().get(
        BASE + f"/api/v2/dags/s8_ventas/dagRuns/{etl['run']}/taskInstances/cargar/logs/2",
        headers={"Accept": "application/json"}, timeout=30,
    )
    response.raise_for_status()
    assert "Filas=" in response.text
    report = {
        "verified_at": datetime.now(timezone.utc).isoformat(),
        "warehouse_sales": count, "unique_sales": unique, "net_total": str(total),
        "source_expected_net": str(expected), "idempotent_sql_rows": sql_count,
        "idempotent_sql_total": str(sql_total), "dbt_resources": len(results),
        "dbt_tests_passed": test_count, "task_log_api_http_status": response.status_code,
    }
    Path("/opt/airflow/logs/resultados_negocio.json").write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
