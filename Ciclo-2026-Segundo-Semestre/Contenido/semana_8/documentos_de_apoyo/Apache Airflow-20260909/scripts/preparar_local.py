"""Prepara carpetas y secretos locales sin sobrescribir la configuracion existente."""
import base64
import json
from pathlib import Path
import secrets
import shutil

lab = Path(__file__).resolve().parents[1]
for name in ("dags", "logs", "plugins", "config", "auth", "dbt", "dbt_config", "evidencias"):
    (lab / name).mkdir(exist_ok=True)

auth = lab / "auth/simple_auth_passwords.json"
if not auth.exists():
    supplied = lab / "simple_auth_passwords.json"
    if supplied.exists():
        shutil.copy2(supplied, auth)
    else:
        auth.write_text(json.dumps({user: secrets.token_urlsafe(16) for user in ("admin", "bi", "analyst")}, indent=2))

envfile = lab / ".env"
if not envfile.exists():
    password = secrets.token_hex(18)
    values = {
        "AIRFLOW_UID": "50000",
        "SECRET_KEY": secrets.token_hex(32),
        "FERNET_KEY": base64.urlsafe_b64encode(secrets.token_bytes(32)).decode(),
        "JWT_SECRET": secrets.token_hex(32),
        "WAREHOUSE_PASSWORD": password,
        "AIRFLOW_CONN_WAREHOUSE_SGFOOD": json.dumps({
            "conn_type": "postgres", "host": "warehouse", "login": "sgfood",
            "password": password, "schema": "sgfood_dw", "port": 5432,
        }),
    }
    envfile.write_text("\n".join(key + "=" + value for key, value in values.items()) + "\n", encoding="utf-8")
    print("Configuracion local generada.")
else:
    print("Se conserva el archivo .env existente.")
print("Credenciales de acceso: auth/simple_auth_passwords.json")
