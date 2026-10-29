# Enunciado - Hoja de Trabajo 6

## Contexto

En semanas anteriores se preparo el dataset de taxis de Nueva York para analisis y modelado predictivo. En esta hoja de trabajo se usara ese mismo contexto para construir un modelo de clasificacion binaria.

El objetivo del modelo sera predecir si un viaje de taxi pertenece a la clase de **propina alta**.

## Problema

Construye un modelo de clasificacion con BigQuery ML usando el dataset de taxis trabajado en el Proyecto 2.

La variable objetivo debe ser:

```text
is_high_tip
```

Donde:

- `1` significa que el viaje tuvo propina alta;
- `0` significa que el viaje no tuvo propina alta.

Se recomienda definir `is_high_tip` como:

```sql
IF(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) >= 0.20, 1, 0)
```

## Instrucciones

Trabaja en BigQuery y desarrolla lo siguiente:

1. Verifica que exista la tabla optimizada del Proyecto 2:

```sql
`TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
```

2. Crea una tabla de features para clasificacion, si aun no existe.
3. Divide los datos en entrenamiento, evaluacion y prediccion usando una columna `split_col`.
4. Entrena un modelo `LOGISTIC_REG` con BigQuery ML.
5. Evalua el modelo con `ML.EVALUATE`.
6. Reporta al menos una metrica de clasificacion, por ejemplo:
   - `precision`;
   - `recall`;
   - `f1_score`;
   - `accuracy`;
   - `roc_auc`.
7. Muestra la matriz de confusion con `ML.CONFUSION_MATRIX`.
8. Explica que significa un falso positivo y un falso negativo en este problema.

## Restricciones

- No uses `tip_amount` como feature del modelo.
- No uses `tip_pct` como feature del modelo.
- Ambas columnas pueden usarse para construir la etiqueta, pero no para predecirla.
- Usa datos de evaluacion distintos a los de entrenamiento.
- Usa `Standard SQL`.

## Preguntas para responder

1. Cual es la clase positiva del modelo?
2. Que variable objetivo se uso?
3. Que metrica de clasificacion reportaste y como se interpreta?
4. Que muestra la matriz de confusion?
5. Que significa un falso negativo en el contexto de propina alta?

## Entregable

Entrega:

- archivo SQL final;
- resultado o captura de `ML.EVALUATE`;
- resultado o captura de `ML.CONFUSION_MATRIX`;
- respuesta breve a las preguntas anteriores.

