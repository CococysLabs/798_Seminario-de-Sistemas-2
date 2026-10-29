import concurrent.futures
import csv
import os
import statistics
import subprocess
import sys
import time
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
TARGET_SCRIPT = BASE_DIR / "spark_connect_carnet_to_gcs.py"
RESULTS_CSV = BASE_DIR / "load_test_results.csv"
SUMMARY_CSV = BASE_DIR / "load_test_summary.csv"
CONCURRENCY_LEVELS = [1, 5, 10, 20, 30, 50]
RUN_TIMEOUT_SECONDS = 180


def run_one(level: int, run_id: int) -> dict:
    carnet = f"2026{level:02d}{run_id:06d}"
    env = os.environ.copy()
    env["HT3_CARNET"] = carnet
    t0 = time.time()
    try:
        proc = subprocess.run(
            [sys.executable, str(TARGET_SCRIPT)],
            cwd=str(BASE_DIR),
            env=env,
            capture_output=True,
            text=True,
            timeout=RUN_TIMEOUT_SECONDS,
        )
        return {
            "level": level,
            "run_id": run_id,
            "carnet": carnet,
            "elapsed_sec": round(time.time() - t0, 4),
            "returncode": proc.returncode,
            "status": "ok" if proc.returncode == 0 else "fail",
            "stdout": proc.stdout.strip(),
            "stderr": proc.stderr.strip(),
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "level": level,
            "run_id": run_id,
            "carnet": carnet,
            "elapsed_sec": round(time.time() - t0, 4),
            "returncode": -1,
            "status": "timeout",
            "stdout": (exc.stdout or "").strip(),
            "stderr": f"Timeout despues de {RUN_TIMEOUT_SECONDS}s",
        }


def write_results_csv(rows: list[dict]) -> None:
    fieldnames = [
        "level",
        "run_id",
        "carnet",
        "elapsed_sec",
        "returncode",
        "status",
        "stdout",
        "stderr",
    ]
    with RESULTS_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def write_summary_csv(rows: list[dict]) -> None:
    fieldnames = [
        "level",
        "total_runs",
        "ok",
        "fail",
        "timeout",
        "total_wall_sec",
        "avg_run_sec",
        "p95_run_sec",
    ]
    with SUMMARY_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def p95(values: list[float]) -> float:
    if not values:
        return 0.0
    if len(values) == 1:
        return values[0]
    return statistics.quantiles(values, n=100)[94]


def main() -> None:
    all_results = []
    summary_rows = []

    print(f"Usando Python: {sys.executable}")
    print(f"Script objetivo: {TARGET_SCRIPT}")

    for level in CONCURRENCY_LEVELS:
        batch_start = time.time()
        level_results = []
        with concurrent.futures.ThreadPoolExecutor(max_workers=level) as ex:
            futures = [ex.submit(run_one, level, run_id) for run_id in range(1, level + 1)]
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                level_results.append(result)
                if result["status"] != "ok":
                    print(f"\n[ERROR] level={level} run={result['run_id']} rc={result['returncode']}")
                    if result["stderr"]:
                        print("stderr:")
                        print(result["stderr"])
                    if result["stdout"]:
                        print("stdout:")
                        print(result["stdout"])

        level_results.sort(key=lambda r: r["run_id"])
        all_results.extend(level_results)

        ok = sum(1 for r in level_results if r["status"] == "ok")
        fail = sum(1 for r in level_results if r["status"] == "fail")
        timeout = sum(1 for r in level_results if r["status"] == "timeout")
        elapsed_values = [r["elapsed_sec"] for r in level_results]
        total_wall = round(time.time() - batch_start, 2)
        avg_run = round(sum(elapsed_values) / len(elapsed_values), 3) if elapsed_values else 0.0
        p95_run = round(p95(elapsed_values), 3) if elapsed_values else 0.0

        print(
            f"{level} ok {ok} fail {fail} timeout {timeout} "
            f"batch_secs {total_wall} avg_run {avg_run} p95_run {p95_run}"
        )

        summary_rows.append(
            {
                "level": level,
                "total_runs": len(level_results),
                "ok": ok,
                "fail": fail,
                "timeout": timeout,
                "total_wall_sec": total_wall,
                "avg_run_sec": avg_run,
                "p95_run_sec": p95_run,
            }
        )

    write_results_csv(all_results)
    write_summary_csv(summary_rows)
    print(f"\nDetalle guardado en: {RESULTS_CSV}")
    print(f"Resumen guardado en: {SUMMARY_CSV}")


if __name__ == "__main__":
    main()
