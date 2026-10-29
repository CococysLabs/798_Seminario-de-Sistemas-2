# Hoja de Trabajo 3 - Spark Connect + GCS

## Objetivo

El estudiante debe:

1. Colocar su carnet en el script.
2. Ejecutar un proceso con Spark Connect.
3. Generar un Parquet.
4. Guardarlo en Google Cloud Storage (`gs://...`).

## Que debe hacer el estudiante

### 1) Instalar dependencias

Desde la carpeta `hojas_de_trabajo/ht3`:

```powershell
python -m pip install -r requirements.txt
```

### 2) Editar su carnet en el script

Abrir `spark_connect_carnet_to_gcs.py` y cambiar:

- `CARNET = "TU_CARNET"`

No debe cambiar el resto, a menos que el docente indique otro `BUCKET_NAME` o `SPARK_CONNECT_URL`.

### 3) Ejecutar

```powershell
python .\spark_connect_carnet_to_gcs.py
```

### 4) Resultado esperado

Si todo esta correcto, debe mostrar algo como:

```text
Parquet escrito en: gs://<bucket>/carnets/carnet=<tu_carnet>/run=<timestamp>
```

## Errores comunes

- `No FileSystem for scheme "gs"`: servidor Spark sin conector GCS.
- `403 Forbidden`: falta de permisos IAM de la service account de la VM sobre el bucket.
- Conexion a Spark Connect (timeout): URL o IP incorrecta, o VM apagada.
