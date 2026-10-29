# Apache Airflow — Semana 8

Entorno local para explorar los ejemplos del documento de apoyo. Usa Airflow **3.1.1**, Python **3.12**, CeleryExecutor, Redis y PostgreSQL 16. dbt Core **1.8.9** y dbt-postgres **1.8.2** están instalados en un entorno Python independiente dentro de la imagen.

## Acceso

- Interfaz: **http://localhost:8083**.
- Usuario administrador: **admin**.
- Contraseña: consultar la entrada `admin` de [auth/simple_auth_passwords.json](auth/simple_auth_passwords.json). Se conservaron las credenciales entregadas en la carpeta original.
- Los seis DAGs del laboratorio tienen la etiqueta `semana8`.

Esta carpeta publica el puerto **8083**, aunque la guía genérica del PDF utiliza 8080. La versión 3.1.1 también corresponde al Compose que se recibió; los ejemplos del PDF usan la API de Airflow 3.

## Ejemplos

| DAG | Qué permite explorar |
| --- | --- |
| `s8_saludo` | Dos tareas TaskFlow y transferencia del resultado con XCom. |
| `s8_ventas` | Código completo del PDF: extraer, transformar, validar y cargar. Produce tres ventas con total **95.00**. |
| `s8_sql_idempotente` | Ejecuta dos veces el UPSERT y comprueba que queda una venta con total **50.00**. |
| `s8_dbt_sgfood` | Comprueba CSV, carga seeds, ejecuta `dbt build` y concilia el mart con raw mediante SQL. |
| `s8_fallos_controlados` | Simula fallos temporales y errores de calidad utilizando parámetros de ejecución. |
| `s8_programacion` | Muestra un intervalo diario en `America/Guatemala`; el calendario queda pausado al finalizar las pruebas. |

El proyecto dbt es una copia de `semana_7/ejemplo_dbt_sgfood`, con su perfil adaptado al warehouse local. Contiene 5 clientes, 5 productos, 3 sucursales y 10 ventas. Las fechas originales de los datos se conservan; son datos de demostración, no ventas del día actual.

En las copias de los cuatro CSV se retiraron líneas vacías finales que dbt interpretaba como registros nulos. El DAG comprueba esa condición antes de cargar. Los archivos originales de la semana 7 se conservaron.

## Explorar desde la interfaz

1. Abrir un DAG y consultar el grafo y sus ejecuciones.
2. Pulsar **Trigger** para crear una ejecución manual.
3. Abrir una tarea y revisar **Logs** y **XCom**.
4. En `s8_ventas`, abrir también `logs/s8_resultados/` en esta carpeta para comprobar el JSON.

En `s8_fallos_controlados`, los parámetros predeterminados son `false`:

- `fallo_transitorio=true`: `extraer` falla en el primer intento, espera 15 segundos y funciona en el segundo.
- `dato_invalido=true`: `validar` falla y `publicar` queda bloqueada (`upstream_failed`).
- Ambos en `false`: ejecución normal. Crear una ejecución nueva con estos valores permite demostrar la recuperación después del fallo de calidad.

La ejecución fallida intencional se conserva para inspeccionar los logs. Limpiar esa misma ejecución sin cambiar su configuración vuelve a provocar el error, porque conserva `dato_invalido=true`.

En `s8_ventas`, limpiar solamente la tarea `cargar` vuelve a escribir el mismo archivo de esa ejecución. Una ejecución nueva genera otro archivo: la clave usa `run_id`, tal como explica el documento.

## Arranque y comandos

Ejecutar en PowerShell desde esta carpeta. Docker Desktop debe estar iniciado y utilizar contenedores Linux.

```powershell
# Solo hace falta preparar y construir si se recrea el entorno:
python scripts/preparar_local.py
docker compose -f docker-compose.airflow.yml build airflow-init

docker compose -f docker-compose.airflow.yml up -d
docker compose -f docker-compose.airflow.yml ps
docker compose -f docker-compose.airflow.yml exec airflow-scheduler airflow dags list-import-errors
```

La preparación genera secretos locales y conserva los archivos existentes. No es necesario instalar dependencias al arrancar cada contenedor. `airflow-init` debe terminar con código 0: es un trabajo de inicialización, no un servicio permanente.

```powershell
# Consultar los resultados de negocio:
docker compose -f docker-compose.airflow.yml exec warehouse psql -U sgfood -d sgfood_dw -c "SELECT COUNT(*) AS ventas, SUM(monto_neto) AS total_neto FROM analytics_marts.fact_ventas;"
docker compose -f docker-compose.airflow.yml exec warehouse psql -U sgfood -d sgfood_dw -c "SELECT * FROM raw.ventas;"

# Consultar logs de los servicios:
docker compose -f docker-compose.airflow.yml logs --tail 100 airflow-worker
docker compose -f docker-compose.airflow.yml logs --tail 100 airflow-dag-processor

# Detener cuando hayas terminado de explorar, conservando datos:
docker compose -f docker-compose.airflow.yml down
```

`postgres` contiene metadatos de Airflow; `warehouse` contiene los datos SGFood. La conexión `warehouse_sgfood` se suministra por variable de entorno y puede no aparecer en el listado de conexiones de la interfaz. Los DAGs sí la resuelven al ejecutarse. dbt recibe el mismo destino mediante su perfil y variables de entorno.

## Archivos y persistencia

- `dags/`: ejemplos ejecutables.
- `dbt/sgfood/`: modelos, seeds y pruebas del proyecto dbt.
- `dbt_config/profiles.yml`: perfil que lee credenciales del entorno.
- `logs/`: registros de Airflow y resultados JSON del ETL.
- `dbt/sgfood/target/run_results.json`: resultados de la ejecución más reciente de dbt.
- `evidencias/`: comprobaciones realizadas durante la puesta en marcha.
- Los dos PostgreSQL conservan sus datos en volúmenes de Docker.

## Resultado de la verificación — 9 de septiembre de 2026

Se comprobaron los seis DAGs mediante ejecuciones reales del scheduler y los workers. Las evidencias están en [evidencias/pruebas_semana8.json](evidencias/pruebas_semana8.json) y [evidencias/resultados_negocio.json](evidencias/resultados_negocio.json).

- ETL: 3 ventas, total 95.00. Repetir `cargar` conservó exactamente el contenido del archivo (mismo SHA-256).
- SQL: dos UPSERT dejaron una sola venta de 50.00.
- dbt: dos ejecuciones completas terminaron correctamente, con 10 ventas únicas y total neto 3766.75, conciliado contra el CSV. Pasaron **38 pruebas**, con **52 recursos** procesados entre seeds, modelos y pruebas.
- Reintento: la extracción terminó en el segundo intento.
- Fallo de calidad: `validar=failed` y `publicar=upstream_failed`, como se esperaba; la ejecución posterior con datos válidos terminó correctamente.
- Calendario: ejecución programada exitosa para el intervalo del 8 al 9 de septiembre, de medianoche a medianoche en Guatemala. Después se pausó únicamente este DAG.
- Interfaz y consulta autenticada de logs: HTTP 200.

Las primeras ejecuciones de dbt registran fallos por los registros nulos originados por líneas vacías. Se corrigieron las copias de los CSV y se recuperaron **las mismas ejecuciones** limpiando sus tareas; los intentos anteriores siguen disponibles para estudiar el incidente.

Los servicios se dejaron en ejecución. Los cinco DAGs manuales permanecen habilitados y el DAG de calendario permanece pausado para que puedas decidir cuándo activarlo.

Guía oficial de referencia: [Airflow 3.1.1 con Docker](https://airflow.apache.org/docs/apache-airflow/3.1.1/howto/docker-compose/index.html).
