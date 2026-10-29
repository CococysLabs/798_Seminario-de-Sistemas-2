# Proyecto 2 - Guia de uso de scripts

Este proyecto deja una base reproducible para resolver el `Proyecto_2.docx-2.pdf` usando el dataset publico `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` en BigQuery.

Los archivos en `sql/` ya quedaron listos para copiar y pegar directamente en el editor de BigQuery. Cada archivo tiene un bloque inicial con variables como `project_id`, `dataset_id` y, cuando aplica, rango de fechas. Si prefieres, puedes seguir usando los scripts de PowerShell, pero ya no son obligatorios para ejecutar el flujo.

El objetivo del repositorio es que puedas:

- explorar el dataset publico;
- crear una tabla derivada optimizada con particiones y clustering;
- preparar una tabla de features para BigQuery ML;
- entrenar 2 modelos;
- generar tablas y vistas listas para dashboard;
- documentar evidencias para la rubrica.

## 1. Estructura del proyecto

- `sql/00_create_dataset.sql`
  Crea el dataset donde se guardaran tablas, modelos y vistas.

- `sql/01_exploracion_inicial.sql`
  Ejecuta consultas exploratorias sobre el dataset publico para validar volumen, fechas, distribuciones y rutas frecuentes.

- `sql/02_tabla_optimizada.sql`
  Crea `taxi_trips_2022_optimized`, una tabla derivada con filtros de limpieza, particion por fecha y clustering por variables de consulta frecuente.

- `sql/03_consultas_analiticas.sql`
  Ejecuta consultas de negocio y una comparacion entre una consulta estandar y otra contra la tabla optimizada.

- `sql/04_feature_engineering.sql`
  Crea `ml_features_taxi_2022`, la tabla usada para ML, con una columna `split_col` para separar entrenamiento, evaluacion y prediccion.

- `sql/05_bqml_clasificacion.sql`
  Entrena un modelo de clasificacion para predecir si un viaje tendra propina alta.

- `sql/06_bqml_regresion.sql`
  Entrena un modelo de regresion para estimar el monto de propina.

- `sql/07_dashboard_exports.sql`
  Crea vistas y tablas finales para conectar Looker Studio o Google Sheets.

- `scripts/proyecto2.env.example.ps1`
  Archivo base con variables de entorno.

- `scripts/Invoke-BigQuerySql.ps1`
  Script auxiliar que reemplaza placeholders como `${PROJECT_ID}` y ejecuta el SQL con `bq`.

- `scripts/Run-Proyecto2.ps1`
  Script principal que corre todos los `.sql` en orden.

- `evidencias/`
  Carpeta para guardar capturas de BigQuery, evaluaciones de modelos y bytes procesados.

- `dashboard/`
  Carpeta para dejar notas, enlaces o material de apoyo del tablero.

## 2. Requisitos previos

Antes de ejecutar los scripts necesitas:

1. Tener una cuenta de Google Cloud con BigQuery habilitado.
2. Tener permisos para crear datasets, tablas, vistas y modelos en BigQuery.
3. Tener instalado `gcloud` y `bq` en tu maquina.
4. Haber iniciado sesion en GCP desde la terminal.

Comandos utiles de validacion:

```powershell
gcloud auth login
gcloud config set project TU_PROJECT_ID
bq version
```

Si usas varias cuentas o proyectos, valida tambien:

```powershell
gcloud config list
```

## 3. Configuracion inicial

### Paso 1. Crear el archivo de variables

Copia el archivo de ejemplo:

```powershell
Copy-Item .\scripts\proyecto2.env.example.ps1 .\scripts\proyecto2.env.ps1
```

### Paso 2. Editar variables

Abre `scripts/proyecto2.env.ps1` y ajusta:

- `PROJECT_ID`
  Opcional. Si no lo defines, los scripts usaran automaticamente el proyecto activo de `gcloud config`.

- `DATASET_ID`
  El nombre del dataset donde se crearan las tablas del proyecto.

- `BQ_LOCATION`
  La region de BigQuery. Para el dataset publico de NYC Taxi normalmente funciona `US`.

- `SOURCE_START_DATE`
  Fecha inicial del rango que se copiara desde el dataset publico.

- `SOURCE_END_DATE`
  Fecha final del rango que se copiara desde el dataset publico.

El flujo ahora usa un rango de fechas explicito en lugar de `LIMIT`, lo cual hace la extraccion determinista y mas facil de justificar en el reporte tecnico.

Ejemplo:

```powershell
# Opcional si ya tienes el proyecto activo en gcloud:
# $env:PROJECT_ID = "mi-proyecto-123456"
$env:DATASET_ID = "proyecto2_taxi"
$env:BQ_LOCATION = "US"
$env:SOURCE_START_DATE = "2022-01-01"
$env:SOURCE_END_DATE = "2022-12-31"
```

Si quieres validar cual proyecto esta activo en tu CLI:

```powershell
gcloud config get-value project
```

## 4. Como ejecutar todo el flujo

Desde la carpeta `Proyecto2`, ejecuta:

```powershell
cd proyectos/Proyecto2
powershell -ExecutionPolicy Bypass -File .\scripts\Run-Proyecto2.ps1
```

Ese script ejecuta en este orden:

1. `00_create_dataset.sql`
2. `01_exploracion_inicial.sql`
3. `02_tabla_optimizada.sql`
4. `03_consultas_analiticas.sql`
5. `04_feature_engineering.sql`
6. `05_bqml_clasificacion.sql`
7. `06_bqml_regresion.sql`
8. `07_dashboard_exports.sql`

Si `PROJECT_ID` no esta definido en el archivo `.env`, el flujo usara automaticamente el proyecto actual de `gcloud`.

Si quieres procesar solo una parte del anio para pruebas o para controlar costo, cambia el rango en `SOURCE_START_DATE` y `SOURCE_END_DATE`.

## 5. Como ejecutar un solo script

Si no quieres correr todo, puedes ejecutar un archivo puntual:

```powershell
cd proyectos/Proyecto2
.\\scripts\\Invoke-BigQuerySql.ps1 -SqlFile .\\sql\\02_tabla_optimizada.sql
```

Tambien puedes hacer `dry run` para revisar bytes procesados sin ejecutar realmente:

```powershell
cd proyectos/Proyecto2
.\\scripts\\Invoke-BigQuerySql.ps1 -SqlFile .\\sql\\03_consultas_analiticas.sql -DryRun
```

Esto te sirve para tomar evidencia de costo estimado y para comparar la consulta estandar contra la optimizada.

## 6. Que hace cada script y que debes revisar

### `00_create_dataset.sql`

Crea el dataset de trabajo.

Debes revisar:

- que el dataset exista en BigQuery;
- que la ubicacion sea la correcta;
- que el nombre coincida con `DATASET_ID`.

### `01_exploracion_inicial.sql`

Hace consultas sobre el dataset publico para:

- contar registros;
- validar fechas minimas y maximas;
- ver distribucion por mes;
- revisar medios de pago;
- identificar horas pico;
- identificar rutas frecuentes.

Debes guardar evidencia de:

- conteo total del dataset;
- al menos una tabla con agregaciones por mes;
- al menos una tabla de patrones por hora o por ruta.

### `02_tabla_optimizada.sql`

Crea la tabla derivada:

- `taxi_trips_2022_optimized`

Incluye:

- filtros de limpieza;
- filtro explicito por rango de fechas;
- columnas derivadas;
- particion por `pickup_date`;
- clustering por `vendor_id`, `PULocationID`, `DOLocationID`, `payment_type`.

Debes revisar:

- que la tabla se haya creado;
- que tenga particiones;
- que tenga clustering configurado;
- que el volumen de filas sea suficiente para la rubrica.

Debes guardar evidencia de:

- definicion de la tabla;
- propiedades de particion y clustering;
- conteo de registros cargados.

### `03_consultas_analiticas.sql`

Incluye:

- una consulta estandar sobre el dataset publico;
- una consulta equivalente sobre la tabla optimizada;
- consultas por hora, ruta y dia de semana.

Debes usar este archivo para demostrar:

- comparacion de bytes procesados;
- mejora por optimizacion;
- hallazgos del analisis exploratorio.

### `04_feature_engineering.sql`

Crea:

- `ml_features_taxi_2022`

Incluye:

- limpieza adicional para ML;
- variable objetivo `is_high_tip`;
- variable de regresion `tip_amount`;
- columna `split_col`.

Los splits quedan asi:

- `TRAIN`: enero a septiembre 2022
- `EVAL`: octubre y noviembre 2022
- `PREDICT`: diciembre 2022

Esto evita `data leakage` porque el modelo entrena con datos del pasado y evalua con datos posteriores.

### `05_bqml_clasificacion.sql`

Crea:

- modelo `modelo_clasificacion_propina_alta`
- tabla `pred_clasificacion_propina_alta`

Este modelo predice si la propina sera alta.

Debes revisar:

- salida de `ML.EVALUATE`;
- salida de `ML.ROC_CURVE`;
- salida de `ML.CONFUSION_MATRIX`.

Metricas recomendadas para documentar:

- `precision`
- `recall`
- `accuracy`
- `f1_score`
- `roc_auc`

### `06_bqml_regresion.sql`

Crea:

- modelo `modelo_regresion_propina`
- tabla `pred_regresion_propina`

Este modelo estima el monto de propina.

Debes revisar:

- salida de `ML.EVALUATE`;
- salida de `ML.FEATURE_IMPORTANCE`;
- comparacion entre `actual_tip_amount` y `predicted_tip_amount`.

Metricas recomendadas para documentar:

- `mean_absolute_error`
- `mean_squared_error`
- `r2_score`

### `07_dashboard_exports.sql`

Crea:

- `vw_daily_kpis`
- `vw_hourly_patterns`
- `dashboard_model_comparison`
- `vw_prediction_summary`

Estas vistas son las que deberias conectar a Looker Studio o Google Sheets para el informe visual.

## 7. Objetos esperados al final

Si todo corre bien, en tu dataset deberias tener al menos:

- tabla `taxi_trips_2022_optimized`
- tabla `ml_features_taxi_2022`
- modelo `modelo_clasificacion_propina_alta`
- modelo `modelo_regresion_propina`
- tabla `pred_clasificacion_propina_alta`
- tabla `pred_regresion_propina`
- tabla `dashboard_model_comparison`
- vista `vw_daily_kpis`
- vista `vw_hourly_patterns`
- vista `vw_prediction_summary`

## 8. Recomendacion para el dashboard

Conecta Looker Studio o Google Sheets a estas fuentes:

- `vw_daily_kpis`
- `vw_hourly_patterns`
- `vw_prediction_summary`
- `dashboard_model_comparison`

Visualizaciones recomendadas:

1. Viajes por fecha y revenue diario.
2. Viajes por hora y dia de la semana.
3. Top rutas por ingreso.
4. Comparacion entre propina real y propina predicha.
5. Promedio de probabilidad de propina alta por hora.

## 9. Evidencias que deberias guardar

En la carpeta `evidencias/` guarda capturas de:

1. Dataset creado.
2. Conteo de registros del dataset publico.
3. Tabla optimizada con particiones y clustering.
4. Comparacion de bytes procesados en consulta estandar vs optimizada.
5. `ML.EVALUATE` del modelo de clasificacion.
6. `ML.CONFUSION_MATRIX` o `ML.ROC_CURVE`.
7. `ML.EVALUATE` del modelo de regresion.
8. `ML.FEATURE_IMPORTANCE`.
9. Tabla de predicciones.
10. Dashboard final con al menos 3 visualizaciones.

## 10. Problemas comunes

### Error: `Access Denied`

Tu cuenta no tiene permisos suficientes en BigQuery para crear datasets, tablas o modelos. Debes revisar IAM del proyecto.

### Error: `Not found: Dataset`

El dataset no existe o `DATASET_ID` no coincide. Ejecuta primero `00_create_dataset.sql`.

### Error: `PROJECT_ID no esta definido`

El script no encontro `PROJECT_ID` en variables de entorno y tampoco pudo resolver el proyecto activo de `gcloud`. Verifica:

```powershell
gcloud config get-value project
```

### Error por ubicacion

Si el dataset se crea en una region distinta de la esperada, revisa `BQ_LOCATION`. Para este proyecto normalmente debes usar `US`.

### Error por costo o tiempo de ejecucion

Reduce temporalmente el rango de fechas para probar con menos datos, por ejemplo:

```powershell
$env:SOURCE_START_DATE = "2022-01-01"
$env:SOURCE_END_DATE = "2022-03-31"
```

Luego, cuando todo funcione, vuelve a ampliar el rango.

### Error en modelos por tipos de datos

Revisa primero que `02_tabla_optimizada.sql` y `04_feature_engineering.sql` hayan corrido sin errores. Los modelos dependen completamente de esas tablas.

## 11. Sugerencia de orden para documentar el README final del curso

Cuando ya tengas resultados, puedes completar este mismo README con:

1. Descripcion del dataset.
2. Transformaciones aplicadas.
3. Estrategia de particion y clustering.
4. Comparacion de consultas estandar vs optimizadas.
5. Hallazgos del analisis exploratorio.
6. Explicacion de ambos modelos.
7. Metricas obtenidas.
8. Enlace al dashboard.

## 12. Resumen rapido de uso

1. Copiar `scripts/proyecto2.env.example.ps1` a `scripts/proyecto2.env.ps1`.
2. Configurar `PROJECT_ID`, `DATASET_ID`, `BQ_LOCATION`, `SOURCE_START_DATE` y `SOURCE_END_DATE`.
3. Autenticar `gcloud` y seleccionar el proyecto correcto.
4. Ejecutar `Run-Proyecto2.ps1`.
5. Revisar objetos creados en BigQuery.
6. Tomar capturas para `evidencias/`.
7. Crear el dashboard usando las vistas finales.
