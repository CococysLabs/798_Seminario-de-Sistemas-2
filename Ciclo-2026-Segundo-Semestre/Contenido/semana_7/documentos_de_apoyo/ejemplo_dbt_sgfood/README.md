# Ejemplo Semana 7 - Modelado analitico con dbt para SG-Food

Este ejemplo acompana el documento de apoyo de la sesion 7. Muestra como transformar datos crudos de SG-Food hacia modelos analiticos usando dbt, SQL, pruebas, documentacion y linaje.

El ejemplo esta pensado para clase. Es pequeno a proposito: permite explicar el flujo completo sin depender de la infraestructura anterior en GCP.

## Que conceptos demuestra

- ELT: primero se cargan datos raw y luego se transforman.
- `seeds`: archivos CSV usados como datos raw de demostracion.
- `sources`: declaracion formal de las tablas raw.
- `ref`: dependencias entre modelos dbt.
- Capas `staging`, `intermediate` y `marts`.
- Materializaciones: vistas para staging/intermediate y tablas para marts.
- Pruebas: `not_null`, `unique`, `relationships` y `accepted_values`.
- Documentacion: descripciones de modelos y columnas.
- Linaje: grafo generado por dbt Docs.

## Estructura

```text
ejemplo_dbt_sgfood/
  dbt_project.yml
  profiles.example.yml
  docker-compose.yml
  requirements.txt
  seeds/raw/
  models/staging/
  models/intermediate/
  models/marts/
  macros/
  analisis/
```

## Requisitos

- Docker Desktop
- Python 3.10 o superior
- dbt Core con adapter PostgreSQL

Instalacion sugerida en un ambiente virtual:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Levantar PostgreSQL local

```powershell
docker compose up -d
```

La base queda disponible en:

- Host: `localhost`
- Puerto: `5432`
- Base: `sgfood_dw`
- Usuario: `sgfood_user`
- Password: `sgfood_pass`

## Configurar dbt

Copia el archivo `profiles.example.yml` a tu carpeta de perfiles de dbt:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.dbt"
Copy-Item .\profiles.example.yml "$env:USERPROFILE\.dbt\profiles.yml"
```

## Ejecutar el flujo

```powershell
dbt debug
dbt seed
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Orden para explicarlo en clase

1. Mostrar los CSV en `seeds/raw` como datos operacionales simplificados.
2. Ejecutar `dbt seed` y explicar que simula la carga raw.
3. Abrir `models/staging` y explicar limpieza tecnica minima.
4. Abrir `models/intermediate/int_ventas_enriquecidas.sql` y explicar integracion.
5. Abrir `models/marts` y explicar dimensiones, hechos e indicadores.
6. Ejecutar `dbt test` y revisar pruebas aprobadas.
7. Ejecutar `dbt docs serve` y mostrar documentacion y linaje.
8. Ejecutar las consultas de `analisis/consultas_clase.sql`.

## Relacion con Proyecto 1

El Proyecto 1 solicita una solucion con Python, Airflow, PostgreSQL y dbt. Este ejemplo cubre la parte de dbt sobre PostgreSQL. En una entrega completa, los `seeds` se reemplazan por tablas raw cargadas con Python y orquestadas desde Airflow.

