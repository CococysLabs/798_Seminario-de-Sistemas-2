"""Prueba los DAGs mediante la API: las ejecuciones quedan visibles en Airflow."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

from lab_api import BASE, client

STATE = Path("/opt/airflow/logs/pruebas_semana8.json")


def request(session, method, path, **kwargs):
    response = session.request(method, BASE + "/api/v2" + path, timeout=30, **kwargs)
    if not response.ok:
        raise RuntimeError(f"HTTP {response.status_code}: {response.text[:1000]}")
    return response.json()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["start", "status", "repetir_carga", "recuperar_dbt", "finish"])
    args = parser.parse_args()
    session = client()
    if args.action == "start":
        if STATE.exists():
            raise RuntimeError("Ya existe una prueba; consultar status para conservar sus ejecuciones.")
        prefix = "prueba_s8_" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
        cases = [
            ("s8_saludo", "saludo", {}, "success"),
            ("s8_ventas", "etl", {}, "success"),
            ("s8_sql_idempotente", "sql", {}, "success"),
            ("s8_dbt_sgfood", "dbt", {}, "success"),
            ("s8_dbt_sgfood", "dbt_repeticion", {}, "success"),
            ("s8_fallos_controlados", "reintento", {"fallo_transitorio": True}, "success"),
            ("s8_fallos_controlados", "fallo_calidad", {"dato_invalido": True}, "failed"),
            ("s8_fallos_controlados", "recuperacion", {}, "success"),
        ]
        for dag in sorted({c[0] for c in cases} | {"s8_programacion"}):
            request(session, "PATCH", f"/dags/{dag}", json={"is_paused": False})
        state = {"started_at": datetime.now(timezone.utc).isoformat(), "cases": []}
        for dag, name, conf, expected in cases:
            run = prefix + "_" + name
            request(session, "POST", f"/dags/{dag}/dagRuns", json={"dag_run_id": run, "logical_date": None, "conf": conf})
            state["cases"].append({"dag": dag, "run": run, "case": name, "expected": expected})
        STATE.write_text(json.dumps(state, indent=2))
        print("Se crearon ocho ejecuciones manuales y se habilito el calendario diario.")
        return

    state = json.loads(STATE.read_text())
    if args.action == "recuperar_dbt":
        for case in state["cases"]:
            if case["dag"] == "s8_dbt_sgfood":
                request(session, "POST", f"/dags/{case['dag']}/clearTaskInstances", json={
                    "dag_run_id": case["run"],
                    "task_ids": ["revisar_fuentes", "cargar_raw", "construir_modelos_dbt", "verificar_mart"],
                    "dry_run": False, "only_failed": False, "reset_dag_runs": True,
                })
        print("Se habilito la repeticion de ambos pipelines dbt desde las fuentes corregidas.")
        return
    if args.action == "repetir_carga":
        case = next(c for c in state["cases"] if c["case"] == "etl")
        key = hashlib.sha256(case["run"].encode()).hexdigest()[:20]
        path = Path("/opt/airflow/logs/s8_resultados") / f"ventas_{key}.json"
        state["etl_before_repeat_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
        request(session, "POST", f"/dags/{case['dag']}/clearTaskInstances", json={
            "dag_run_id": case["run"], "task_ids": ["cargar"], "dry_run": False,
            "only_failed": False, "reset_dag_runs": True,
        })
        STATE.write_text(json.dumps(state, indent=2))
        print("Se limpio cargar para comprobar la repeticion en la misma ejecucion.")
        return

    all_ok = True
    for case in state["cases"]:
        run = request(session, "GET", f"/dags/{case['dag']}/dagRuns/{case['run']}")
        tasks = request(session, "GET", f"/dags/{case['dag']}/dagRuns/{case['run']}/taskInstances")
        case["state"] = run["state"]
        case["tasks"] = [{k: t.get(k) for k in ("task_id", "state", "try_number")} for t in tasks["task_instances"]]
        all_ok = all_ok and case["state"] == case["expected"]
        print(f"{case['case']}: {case['state']} (esperado {case['expected']}) | {case['tasks']}")

    calendar = request(session, "GET", "/dags/s8_programacion/dagRuns", params={"limit": 10})
    state["calendar"] = [{k: r.get(k) for k in ("dag_run_id", "state", "run_type", "data_interval_start", "data_interval_end")} for r in calendar["dag_runs"]]
    print("Calendario:", state["calendar"])
    all_ok = all_ok and any(r["state"] == "success" and r["run_type"] == "scheduled" for r in state["calendar"])
    if args.action == "finish":
        if not all_ok:
            raise RuntimeError("Hay pruebas incompletas o con resultados inesperados.")
        retry = next(c for c in state["cases"] if c["case"] == "reintento")
        assert next(t for t in retry["tasks"] if t["task_id"] == "extraer")["try_number"] == 2
        failed = next(c for c in state["cases"] if c["case"] == "fallo_calidad")
        assert next(t for t in failed["tasks"] if t["task_id"] == "publicar")["state"] == "upstream_failed"
        etl = next(c for c in state["cases"] if c["case"] == "etl")
        key = hashlib.sha256(etl["run"].encode()).hexdigest()[:20]
        path = Path("/opt/airflow/logs/s8_resultados") / f"ventas_{key}.json"
        state["etl_after_repeat_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
        assert state["etl_after_repeat_sha256"] == state["etl_before_repeat_sha256"]
        assert next(t for t in etl["tasks"] if t["task_id"] == "cargar")["try_number"] >= 2
        from decimal import Decimal
        rows = json.loads(path.read_text())
        assert len(rows) == 3 and sum(Decimal(r["total"]) for r in rows) == Decimal("95.00")
        request(session, "PATCH", "/dags/s8_programacion", json={"is_paused": True})
        state["calendar_paused_after_test"] = True
        state["verified_at"] = datetime.now(timezone.utc).isoformat()
        print("Pruebas completadas; calendario pausado y los otros cinco DAGs habilitados.")
    STATE.write_text(json.dumps(state, indent=2))


if __name__ == "__main__":
    main()
