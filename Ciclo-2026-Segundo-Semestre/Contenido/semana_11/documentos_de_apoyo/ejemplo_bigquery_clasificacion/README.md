# Ejemplo Semana 11 - Clasificacion de propina alta en taxis con BigQuery ML

Este ejemplo continua el enfoque del Proyecto 2 de NYC Taxi Trips, pero en una version pequena y didactica. La idea es predecir si un viaje de taxi tendra una propina alta usando como insumo la tabla optimizada que ya se preparo en el Proyecto 2.

El ejemplo usa una muestra tomada de:

```sql
`TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
```

Esa tabla se genera en el Proyecto 2 con el script `02_tabla_optimizada.sql`. A partir de esa tabla, este ejemplo crea una muestra pequena para clase:

- cada fila es un viaje de taxi;
- la etiqueta es `is_high_tip`;
- la clase positiva es `is_high_tip = 1`;
- el modelo es de clasificacion binaria;
- se evalua con metricas, matriz de confusion y curva ROC;
- se aplica el modelo sobre viajes reservados como datos nuevos.

No vuelve a crear datos manuales ni usa `UNNEST` con registros inventados. El objetivo es reutilizar el trabajo de semanas anteriores y explicar el flujo de clasificacion con una muestra controlada.

## Estructura

- `sql/01_crear_datos.sql`: crea una muestra pequena desde `taxi_trips_2022_optimized` y prepara la tabla de features.
- `sql/02_entrenar_modelo.sql`: entrena un modelo de clasificacion binaria con BigQuery ML.
- `sql/03_evaluar_modelo.sql`: calcula metricas, matriz de confusion y curva ROC.
- `sql/04_predecir_nuevos_viajes.sql`: aplica el modelo sobre viajes nuevos.
- `sql/05_limpieza_opcional.sql`: elimina los objetos creados.

## Caso

El Proyecto 2 trabaja con viajes de taxi y modelos predictivos. En este ejemplo reducido se quiere responder:

```text
Este viaje tendra propina alta?
```

La respuesta posible es binaria:

```text
is_high_tip = 1  -> propina alta
is_high_tip = 0  -> no propina alta
```

La etiqueta `is_high_tip` se calcula con una regla sencilla:

```sql
IF(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) >= 0.20, 1, 0)
```

Es decir, un viaje se considera de propina alta si la propina representa al menos el 20% de la tarifa base.

## Columnas utilizadas

| Columna | Uso | Explicacion |
| --- | --- | --- |
| `vendor_id` | Feature | Proveedor del servicio |
| `passenger_count` | Feature | Cantidad de pasajeros |
| `trip_distance` | Feature | Distancia del viaje |
| `rate_code` | Feature | Tipo de tarifa |
| `store_and_fwd_flag` | Feature | Indicador operativo del viaje |
| `pickup_location_id` | Feature | Zona de origen |
| `dropoff_location_id` | Feature | Zona de destino |
| `payment_type` | Feature | Tipo de pago |
| `fare_amount` | Feature | Tarifa base |
| `trip_duration_minutes` | Feature | Duracion del viaje |
| `pickup_hour` | Feature | Hora de inicio |
| `pickup_day_of_week` | Feature | Dia de la semana |
| `pickup_month` | Feature | Mes |
| `is_high_tip` | Label | Clase que se quiere predecir |

Tambien aparecen `tip_amount` y `tip_pct`, pero se usan para construir la etiqueta y explicar el ejemplo. No se usan como features del modelo, porque revelarian directamente la respuesta.

## Conceptos utilizados

- **Observacion:** un viaje de taxi.
- **Features:** columnas conocidas que describen el viaje.
- **Label:** columna objetivo que se desea predecir.
- **Clase positiva:** `is_high_tip = 1`.
- **Clasificacion binaria:** solo hay dos clases posibles.
- **Regresion logistica:** modelo que estima la probabilidad de pertenecer a la clase positiva.
- **Umbral:** regla para convertir probabilidad en clase.
- **Matriz de confusion:** tabla de aciertos y errores.
- **Precision:** de lo predicho como propina alta, cuanto realmente fue propina alta.
- **Recall:** de todos los viajes con propina alta, cuantos encontro el modelo.
- **F1-score:** equilibrio entre precision y recall.
- **ROC-AUC:** capacidad general de separar la clase positiva de la negativa.

## Requisitos

1. Tener un proyecto de Google Cloud con BigQuery habilitado.
2. Tener permisos para crear datasets, tablas y modelos.
3. Haber ejecutado antes el flujo del Proyecto 2 hasta crear la tabla optimizada.
4. Verificar que exista esta tabla:

```sql
`TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
```

5. Abrir el editor de consultas de BigQuery.
6. Reemplazar `TU_PROYECTO` por el ID real del proyecto.

Ejemplo:

```sql
`TU_PROYECTO.proyecto2_taxi.taxi_trips_2022_optimized`
```

debe quedar como:

```sql
`mi-proyecto-123.proyecto2_taxi.taxi_trips_2022_optimized`
```

## Paso 1: preparar muestra desde Proyecto 2

Ejecuta:

```text
sql/01_crear_datos.sql
```

Este script crea:

- dataset `semana11_taxi_demo`;
- tabla `taxi_trips_demo`, tomada como muestra desde `proyecto2_taxi.taxi_trips_2022_optimized`;
- tabla `ml_features_taxi_demo`.

La tabla `taxi_trips_demo` ya no contiene datos inventados. Es una muestra pequena de la tabla optimizada del Proyecto 2. La tabla `ml_features_taxi_demo` agrega:

- `tip_pct`: porcentaje de propina respecto a la tarifa;
- `is_high_tip`: etiqueta binaria;
- `split_col`: separacion pedagogica de datos.

La separacion queda asi:

- `TRAIN`: datos para entrenamiento;
- `EVAL`: datos para evaluacion;
- `PREDICT`: datos reservados como nuevos viajes.

## Paso 2: entrenar el modelo

Ejecuta:

```text
sql/02_entrenar_modelo.sql
```

El modelo se llama:

```text
modelo_clasificacion_propina_alta_demo
```

Usa `LOGISTIC_REG`, igual que el modelo de clasificacion del Proyecto 2.

La parte central es:

```sql
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['is_high_tip'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  auto_class_weights = TRUE
)
```

Interpretacion:

- `model_type = 'LOGISTIC_REG'`: entrena un clasificador de regresion logistica.
- `input_label_cols = ['is_high_tip']`: define la etiqueta.
- `data_split_method = 'CUSTOM'`: usa una separacion controlada por nosotros.
- `data_split_col = 'is_eval'`: usa una columna booleana para indicar evaluacion.
- `auto_class_weights = TRUE`: ayuda si una clase aparece menos que la otra.

Nota tecnica: para `CUSTOM` sin ajuste de hiperparametros, BigQuery ML espera una columna booleana. Por eso el ejemplo conserva `split_col` para explicar `TRAIN`, `EVAL` y `PREDICT`, pero crea `is_eval` dentro del entrenamiento:

```sql
split_col = 'EVAL' AS is_eval
```

Asi:

- `FALSE`: registro usado para entrenamiento;
- `TRUE`: registro usado para evaluacion.

Los registros `PREDICT` no se usan para entrenar. Se reservan para `ML.PREDICT`.

## Paso 3: evaluar el modelo

Ejecuta:

```text
sql/03_evaluar_modelo.sql
```

Este script muestra tres resultados.

### 3.1 Metricas generales

`ML.EVALUATE` devuelve metricas como:

- `precision`;
- `recall`;
- `accuracy`;
- `f1_score`;
- `roc_auc`;
- `log_loss`.

No se debe usar solo `accuracy`. En clasificacion, especialmente si hay desbalance, se deben revisar precision, recall y F1-score.

### 3.2 Matriz de confusion

`ML.CONFUSION_MATRIX` permite explicar los errores:

| Resultado | Interpretacion en taxis |
| --- | --- |
| Verdadero positivo | Predijo propina alta y si fue propina alta |
| Verdadero negativo | Predijo no propina alta y no fue propina alta |
| Falso positivo | Predijo propina alta, pero no fue propina alta |
| Falso negativo | No predijo propina alta, pero si fue propina alta |

El ejemplo usa:

```sql
STRUCT(0.50 AS threshold)
```

Esto significa que una probabilidad mayor o igual a 0.50 se convierte en clase 1.

### 3.3 Curva ROC

`ML.ROC_CURVE` permite revisar como cambia el modelo con distintos umbrales.

Idea base:

- umbral mas bajo: mas viajes se clasifican como propina alta;
- umbral mas alto: menos viajes se clasifican como propina alta;
- cambiar el umbral cambia precision y recall.

## Paso 4: predecir viajes nuevos

Ejecuta:

```text
sql/04_predecir_nuevos_viajes.sql
```

Este script crea:

```text
pred_clasificacion_propina_alta_demo
```

Incluye:

- identificador del viaje;
- fecha y hora;
- zonas de origen y destino;
- clase real del ejemplo, si existe;
- clase predicha;
- probabilidades del modelo.

La clase predicha aparece en:

```text
predicted_is_high_tip
```

Las probabilidades aparecen en:

```text
predicted_is_high_tip_probs
```

Ese arreglo permite explicar que el modelo no "adivina" directamente una clase, sino que calcula probabilidades y luego aplica un umbral.

## Paso 5: limpiar objetos

Si quieres eliminar las tablas y el modelo, ejecuta:

```text
sql/05_limpieza_opcional.sql
```

## Orden recomendado

1. `sql/01_crear_datos.sql`
2. `sql/02_entrenar_modelo.sql`
3. `sql/03_evaluar_modelo.sql`
4. `sql/04_predecir_nuevos_viajes.sql`
5. `sql/05_limpieza_opcional.sql` si se desea limpiar

## Relacion con el Proyecto 2

Este ejemplo es una miniatura del flujo real del Proyecto 2:

| Proyecto 2 completo | Ejemplo semana 11 |
| --- | --- |
| `taxi_trips_2022_optimized` | `taxi_trips_demo` |
| `ml_features_taxi_2022` | `ml_features_taxi_demo` |
| `modelo_clasificacion_propina_alta` | `modelo_clasificacion_propina_alta_demo` |
| `pred_clasificacion_propina_alta` | `pred_clasificacion_propina_alta_demo` |

La diferencia es que aqui se usa una muestra pequena de la tabla optimizada para que se puedan ver las bases sin costo alto ni tiempos largos de consulta.

## Como explicarlo en clase

Una explicacion breve puede ser:

> Este ejemplo entrena un modelo de clasificacion binaria para predecir si un viaje de taxi tendra propina alta. La etiqueta es `is_high_tip`, donde 1 representa la clase positiva. El modelo usa variables del viaje como distancia, tarifa, duracion, hora, dia, proveedor, forma de pago y zonas. Luego se evalua con metricas de clasificacion, matriz de confusion y curva ROC. Finalmente, se aplica sobre viajes reservados como datos nuevos mediante `ML.PREDICT`.

## Limitaciones

- El dataset usado por el ejemplo es una muestra pequena de la tabla optimizada del Proyecto 2.
- Las metricas no representan rendimiento real.
- El objetivo es pedagogico.
- En el Proyecto 2 completo se debe usar una muestra mucho mas amplia o todo el periodo 2022.
- No se deben usar `tip_amount` ni `tip_pct` como features del clasificador, porque contienen informacion directa de la respuesta.
