# Hoja de Trabajo 6 - Modelo de Clasificacion con BigQuery ML

## Objetivo

El estudiante debe construir un modelo de clasificacion binaria con BigQuery ML usando el dataset de taxis trabajado en el Proyecto 2.

La actividad se centra en:

1. preparar una tabla de features para clasificacion;
2. entrenar un modelo `LOGISTIC_REG`;
3. evaluar el modelo con una metrica de clasificacion;
4. mostrar la matriz de confusion;
5. interpretar brevemente los resultados.

## Caso

Se desea predecir si un viaje de taxi tendra una propina alta.

La etiqueta sera:

```text
is_high_tip = 1  -> propina alta
is_high_tip = 0  -> no propina alta
```

La clase positiva es `is_high_tip = 1`.

## Archivos

- `enunciado.md`: instrucciones completas de la hoja.
- `sql/01_plantilla_ht6.sql`: plantilla que debe completar el estudiante.
- `sql/99_solucion_referencia.sql`: posible solucion de referencia.
- `moodle_publicacion.html`: version HTML lista para incrustar en Moodle.

## Requisitos previos

Antes de iniciar, debe existir al menos una de estas tablas del Proyecto 2:

- `TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
- `TU_PROYECTO.proyecto2_taxi.ml_features_taxi_2022`

Si ya existe `ml_features_taxi_2022`, la hoja es mas corta. Si no existe, la plantilla incluye un bloque para crear una tabla de features desde `taxi_trips_2022_optimized`.

## Flujo sugerido

1. Crear o verificar la tabla de features.
2. Revisar la distribucion de `is_high_tip`.
3. Entrenar un modelo `LOGISTIC_REG`.
4. Ejecutar `ML.EVALUATE`.
5. Reportar al menos una metrica de clasificacion.
6. Ejecutar `ML.CONFUSION_MATRIX`.
7. Interpretar un falso positivo o un falso negativo.

## Entregable sugerido

El estudiante debe entregar:

- script SQL final;
- captura o resultado de `ML.EVALUATE`;
- captura o resultado de `ML.CONFUSION_MATRIX`;
- explicacion breve de una metrica de clasificacion;
- conclusion de 3 a 5 lineas sobre el desempeno del modelo.

