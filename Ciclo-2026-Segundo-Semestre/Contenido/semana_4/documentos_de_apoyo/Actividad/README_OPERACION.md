# Operación del laboratorio de Airflow — Semana 4

Última verificación: 12 de agosto de 2026.

## Enlaces

| Servicio | Enlace | Acceso |
|---|---|---|
| Portal de inscripción | <https://ss2-github-inscripcion-377555586238.us-central1.run.app> | Inactivo mientras la arquitectura está dada de baja |
| Apache Airflow | IP efímera; consultar `terraform output airflow_url` después del alta | Inactivo mientras la arquitectura está dada de baja |
| Repositorio estudiantil | <https://github.com/SS2-USAC/apache_airflow> | Miembros de la organización |
| Ejecuciones CI/CD | <https://github.com/SS2-USAC/apache_airflow/actions> | Según visibilidad del repositorio |
| Prueba CI de Airflow 3 exitosa | <https://github.com/SS2-USAC/apache_airflow/actions/runs/31616296861> | Según visibilidad del repositorio |

## Cuentas de Airflow

- `admin`: cuenta del docente, con capacidad de ejecutar y administrar DAGs.
- `estudiantes`: cuenta compartida con rol `Viewer`, destinada únicamente a
  consultar DAGs, ejecuciones y registros.

Si el correo de GitHub no llega, la invitación pendiente puede revisarse en
<https://github.com/orgs/SS2-USAC/invitation> después de iniciar sesión con la
misma cuenta solicitada en el portal.

Las contraseñas no se documentan en este archivo. Se entregan por un canal
separado y deben rotarse después de las pruebas del curso.

## Flujo de la actividad

1. El estudiante solicita acceso en el portal usando su usuario de GitHub.
2. GitHub envía la invitación para pertenecer a `SS2-USAC`.
3. El estudiante acepta la invitación, crea una rama y agrega su archivo dentro
   de `dags/`.
4. El estudiante abre un pull request.
5. GitHub Actions compila e importa los DAGs con Airflow y ejecuta las pruebas.
6. Si la validación falla, el estudiante corrige la misma rama y vuelve a hacer
   push.
7. El docente aprueba y fusiona el pull request.
8. El workflow de despliegue usa Workload Identity Federation para sincronizar
   los DAGs al bucket de GCP, sin llaves JSON.
9. La VM de Airflow descarga los cambios del bucket cada minuto.
10. El docente ejecuta el DAG; los estudiantes consultan el resultado con la
    cuenta `Viewer`.

## Arquitectura desplegada

```text
Portal Cloud Run -> GitHub API -> organización SS2-USAC

Pull request -> validación GitHub Actions
       |
merge a main
       v
GitHub Actions --OIDC--> bucket GCS --> sincronización cada minuto
                                           |
                                           v
                               Airflow en Compute Engine
                               API Server + scheduler + DAG Processor + PostgreSQL
```

Recursos principales:

- Proyecto: `project-643d2a1a-b690-4d08-b00`.
- VM: `ss2-airflow`, zona `us-east1-b`, tipo `n2-standard-2`.
- Bucket: `project-643d2a1a-b690-4d08-b00-airflow-dags`.
- Cloud Run: `ss2-github-inscripcion`, región `us-central1`.
- Secret Manager: `ss2-github-invite-token`.
- Apache Airflow `3.3.0`, Python `3.11` y Pandas `2.2.3`.

La guía reproducible de alta y baja se encuentra en
`gcp_airflow_platform/README.md`.

## Pruebas realizadas

### Portal

- `GET /health`: HTTP 200, estado `ok`.
- Credencial de GitHub detectada: `github_configured=true`.
- Token aceptado por GitHub para `SS2-USAC` con membresía administrativa activa.
- Usuario con formato inválido: HTTP 400.
- La prueba de salud no generó invitaciones.

### CI/CD

- Autenticación de GitHub Actions a GCP mediante OIDC: correcta.
- Sincronización del directorio `dags/` al bucket: correcta.
- Ejecución verificada para Airflow 3.3.0: `31616296861`, conclusión `success`.

### Airflow y Pandas

- API Server, scheduler, DAG Processor y PostgreSQL: activos.
- Scheduler y metabase: saludables.
- Airflow ejecutado dentro del scheduler: versión `3.3.0`.
- Pandas instalado y ejecutado dentro del scheduler: versión `2.2.3`.
- Operación de prueba `Series([10, 20, 30]).sum()`: resultado `60`.
- Errores de importación de DAGs: ninguno.
- DAG: `201700703_conceptos_basicos`.
- Ejecución de prueba del 12 de agosto de 2026: `success`.
- Valores observados: datos `[2, 4, 6, 8, 10]`, promedio `6.0` y rama
  seleccionada `promedio_alto`.
- DAG `estudiante_123456789`: `success`; Pandas calculó promedio `80.0`, nota
  máxima `92.0` y `5` aprobados.
- Salud del API v2: metabase, scheduler y DAG Processor en estado `healthy`.

## Comprobaciones rápidas

Portal:

```bash
curl -fsS https://ss2-github-inscripcion-377555586238.us-central1.run.app/health
```

Airflow desde la VM:

```bash
curl -fsS http://localhost:8080/api/v2/monitor/health
sudo docker compose -f /opt/ss2-airflow/docker-compose.yml ps
sudo docker compose -f /opt/ss2-airflow/docker-compose.yml exec -T scheduler airflow dags list-import-errors
```

## Observaciones operativas

- La IP de Airflow es efímera. Si la VM se detiene y vuelve a iniciar, el enlace
  puede cambiar. Para un enlace estable se debe reservar una IP estática.
- Airflow usa HTTP en el puerto 8080. Para uso prolongado se recomienda añadir
  HTTPS mediante un balanceador o proxy administrado.
- El portal es público; conviene añadir rate limiting o reCAPTCHA antes de
  compartirlo ampliamente.
- El token de GitHub debe rotarse al finalizar el semestre.
