"""Cliente de verificacion local; nunca imprime contrasenas ni tokens.

Ejecutar dentro de airflow-scheduler: python /opt/airflow/lab_scripts/lab_api.py ...
"""
import argparse
import json
from pathlib import Path

import requests

BASE = "http://airflow-api-server:8080"


def client():
    passwords = json.loads(Path("/opt/airflow/auth/simple_auth_passwords.json").read_text())
    response = requests.post(
        BASE + "/auth/token",
        json={"username": "admin", "password": passwords["admin"]},
        timeout=30,
    )
    response.raise_for_status()
    session = requests.Session()
    session.headers["Authorization"] = "Bearer " + response.json()["access_token"]
    return session


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["list", "trigger", "runs", "tasks", "pause", "unpause", "schema", "clear"])
    parser.add_argument("dag", nargs="?")
    parser.add_argument("run", nargs="?")
    parser.add_argument("--conf", default="{}")
    args = parser.parse_args()
    session = client()
    url = BASE + "/api/v2/dags"
    if args.action == "schema":
        response = session.get(BASE + "/api/v2/openapi.json", timeout=30)
    elif args.action == "list":
        response = session.get(url, params={"limit": 100}, timeout=30)
    elif args.action in ("pause", "unpause"):
        response = session.patch(url + "/" + args.dag, json={"is_paused": args.action == "pause"}, timeout=30)
    elif args.action == "trigger":
        response = session.post(
            url + f"/{args.dag}/dagRuns",
            json={"dag_run_id": args.run, "logical_date": None, "conf": json.loads(args.conf)},
            timeout=30,
        )
    elif args.action == "runs":
        response = session.get(url + f"/{args.dag}/dagRuns", params={"limit": 100}, timeout=30)
    elif args.action == "clear":
        response = session.post(
            url + f"/{args.dag}/clearTaskInstances",
            json={"dag_run_id": args.run, "task_ids": ["cargar"], "dry_run": False, "only_failed": False, "reset_dag_runs": True},
            timeout=30,
        )
    else:
        response = session.get(url + f"/{args.dag}/dagRuns/{args.run}/taskInstances", timeout=30)
    if not response.ok:
        print(response.text[:2000])
    response.raise_for_status()
    data = response.json()
    if args.action == "list":
        data = [{k: d.get(k) for k in ("dag_id", "is_paused", "has_import_errors")} for d in data["dags"]]
    elif args.action == "runs":
        data = [{k: d.get(k) for k in ("dag_run_id", "state", "start_date", "end_date")} for d in data["dag_runs"]]
    elif args.action == "tasks":
        data = [{k: d.get(k) for k in ("task_id", "state", "try_number")} for d in data["task_instances"]]
    elif args.action in ("pause", "unpause", "trigger"):
        data = {k: data.get(k) for k in ("dag_id", "dag_run_id", "state", "is_paused") if k in data}
    print(json.dumps(data, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
