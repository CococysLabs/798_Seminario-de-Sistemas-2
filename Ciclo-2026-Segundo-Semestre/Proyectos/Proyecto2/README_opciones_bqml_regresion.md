# Explicacion de opciones de BigQuery ML usadas en los modelos de regresion

Este documento explica las opciones que aparecen en [06_bqml_regresion.sql](/abs/path/c:/Users/javie/Desktop/Universidad/actividades_ss2/proyectos/Proyecto2/sql/06_bqml_regresion.sql), especificamente estas dos configuraciones:

```sql
model_type = 'LINEAR_REG',
input_label_cols = ['tip_amount'],
l2_reg = 1.0
```

y

```sql
model_type = 'BOOSTED_TREE_REGRESSOR',
input_label_cols = ['tip_amount'],
max_iterations = 25,
subsample = 0.8,
learn_rate = 0.1,
max_tree_depth = 6
```

La idea es que entiendas no solo "que poner", sino que significa cada opcion y por que se eligio.

## 1. Contexto general

En BigQuery ML, la sentencia `CREATE MODEL` sirve para entrenar un modelo directamente desde SQL. Dentro de `OPTIONS (...)` defines el tipo de modelo y varios hiperparametros. Un hiperparametro no es algo que el modelo aprende automaticamente desde los datos, sino una configuracion que tu eliges antes del entrenamiento para controlar su comportamiento.

En tu script se estan usando dos familias de modelos distintas:

- `LINEAR_REG`
- `BOOSTED_TREE_REGRESSOR`

Ambas intentan predecir `tip_amount`, pero lo hacen con logicas matematicas diferentes.

## 2. `model_type`

### `model_type = 'LINEAR_REG'`

Esto le dice a BigQuery ML que entrene un modelo de regresion lineal.

La regresion lineal intenta aproximar la variable objetivo como una combinacion lineal de las variables de entrada. En terminos intuitivos, el modelo aprende pesos para cada feature.

La idea conceptual es algo como:

\[
\hat{y} = b_0 + b_1x_1 + b_2x_2 + b_3x_3 + \dots
\]

donde:

- `\hat{y}` es la prediccion;
- `b_0` es el intercepto;
- `b_1`, `b_2`, `b_3` son coeficientes aprendidos;
- `x_1`, `x_2`, `x_3` son las variables de entrada.

En tu proyecto, eso significa que el modelo intenta aprender algo como:

- a mayor `fare_amount`, podria haber mayor `tip_amount`;
- a mayor `trip_distance`, podria cambiar el valor esperado de la propina;
- cierto `payment_type` o cierta zona podria modificar esa estimacion.

### Cuándo conviene `LINEAR_REG`

Conviene cuando:

- quieres un baseline interpretable;
- crees que una parte importante de la relacion entre variables puede aproximarse linealmente;
- necesitas un modelo facil de explicar en un informe academico;
- quieres comparar un modelo simple contra uno mas flexible.

### Ventajas

- es facil de interpretar;
- es rapido de entrenar;
- sirve muy bien como baseline;
- permite entender mejor el efecto de las variables.

### Limitaciones

- no capta relaciones no lineales complejas tan bien como modelos basados en arboles;
- puede quedarse corto si las interacciones entre variables son mas complejas.

## 3. `model_type = 'BOOSTED_TREE_REGRESSOR'`

Esto le dice a BigQuery ML que entrene un modelo de regresion basado en arboles potenciados.

Un boosted tree no intenta ajustar una sola ecuacion lineal. En cambio, construye muchos arboles de decision pequeños, donde cada nuevo arbol intenta corregir los errores cometidos por los anteriores.

La idea intuitiva es:

1. se entrena un primer arbol simple;
2. se observan los errores;
3. se entrena otro arbol para corregir parte de esos errores;
4. se repite el proceso varias veces.

Al final, la prediccion es una combinacion de muchos arboles.

### Cuándo conviene `BOOSTED_TREE_REGRESSOR`

Conviene cuando:

- hay relaciones no lineales;
- hay interacciones entre variables;
- quieres mayor capacidad predictiva;
- no te importa sacrificar algo de simplicidad interpretativa a cambio de mejor ajuste.

### Ventajas

- suele capturar mejor patrones complejos;
- maneja bien interacciones entre variables;
- muchas veces supera a un modelo lineal en desempeño predictivo.

### Limitaciones

- es menos interpretable que una regresion lineal;
- puede sobreajustarse si los hiperparametros son demasiado agresivos;
- requiere mas cuidado al configurar entrenamiento.

## 4. `input_label_cols = ['tip_amount']`

Esta opcion define la variable objetivo.

Le dice a BigQuery ML:

- "la columna que quiero predecir es `tip_amount`"

Eso significa que todas las demas columnas del `SELECT` se tratan como variables de entrada, excepto la etiqueta.

### Por qué importa

Si no defines bien la etiqueta, el modelo puede:

- intentar predecir la columna equivocada;
- fallar por tipos incompatibles;
- mezclar features con labels.

### Por qué `tip_amount` tiene sentido aquí

Porque el problema de regresion que planteaste es:

- estimar el monto de propina de un viaje.

Como `tip_amount` es un valor numerico continuo, es una etiqueta natural para regresion.

## 5. `l2_reg = 1.0`

Esta opcion aparece en el modelo lineal.

`l2_reg` significa regularizacion L2.

### Qué hace la regularizacion L2

La regularizacion L2 penaliza coeficientes demasiado grandes en el modelo lineal.

La intuicion es esta:

- si el modelo asigna pesos enormes a ciertas variables, puede estar ajustandose demasiado al ruido;
- la regularizacion agrega una penalizacion que empuja al modelo a mantener coeficientes mas moderados.

Eso ayuda a reducir sobreajuste.

### Qué significa `1.0`

Es la intensidad de la penalizacion.

- valores mas bajos: menos penalizacion;
- valores mas altos: mas penalizacion.

Con `1.0` estas diciendo:

- "quiero una regularizacion moderada, no extrema, pero si lo bastante visible para controlar el modelo"

### En términos prácticos

Un `LINEAR_REG` sin regularizacion puede:

- memorizar demasiado las particularidades del training set;
- volverse inestable si hay correlacion entre variables.

Con `l2_reg = 1.0`, el modelo se vuelve mas conservador.

### Por qué tiene sentido en este proyecto

Porque estas usando varias variables:

- categoricas;
- derivadas;
- temporales;
- geograficas.

Y es razonable querer que el baseline lineal no sea demasiado sensible a combinaciones particulares del training set.

## 6. `max_iterations = 25`

Esta opcion aparece en el modelo de arboles potenciados.

### Qué significa

Indica cuantas iteraciones de boosting se van a realizar.

En la practica, puedes pensarlo como:

- cuántos pasos de corrección del error va a intentar hacer el modelo;
- o, de forma simplificada, cuántos "arboles efectivos" va a construir el proceso.

### Efecto

- pocas iteraciones: modelo mas simple, menos capacidad;
- muchas iteraciones: modelo mas potente, pero con mayor riesgo de sobreajuste.

### Por qué `25`

`25` es un valor intermedio razonable para un primer modelo:

- no es demasiado pequeño;
- tampoco es tan alto como para volver el ajuste excesivamente agresivo.

En un contexto academico, funciona bien como configuracion base para comparar contra el modelo lineal.

## 7. `subsample = 0.8`

Esta opcion indica que en cada iteracion el modelo usa una muestra aleatoria del 80 % de las filas para construir el siguiente arbol.

### Qué efecto tiene

Esto introduce aleatoriedad controlada en el entrenamiento y puede ayudar a:

- reducir sobreajuste;
- mejorar generalizacion;
- hacer que el modelo no dependa demasiado de patrones accidentales de todo el dataset en cada paso.

### Interpretacion

Con `0.8` estas diciendo:

- "en cada ronda, usa 80 % de los datos para ajustar ese paso"

Es una practica comun para hacer el boosting un poco mas robusto.

### Por qué no `1.0`

Si usaras `1.0`, en cada iteracion el algoritmo veria todos los datos.

Eso no siempre es malo, pero con boosting muchas veces conviene usar un valor menor para evitar que el modelo se vuelva demasiado rigido o sobreajustado.

## 8. `learn_rate = 0.1`

Esta opcion controla el tamaño del paso con el que el boosting corrige errores.

### Idea intuitiva

Cada nuevo arbol intenta corregir parte del error acumulado.

`learn_rate` controla qué tan fuerte se aplica esa correccion.

- valor alto: correcciones grandes;
- valor bajo: correcciones mas pequeñas y conservadoras.

### Qué implica `0.1`

Un `learn_rate = 0.1` suele considerarse conservador y razonable.

Eso ayuda a:

- entrenar de manera mas estable;
- reducir sobreajuste;
- permitir que el modelo aprenda de forma gradual.

### Trade-off

Si el `learn_rate` es muy pequeño, tal vez necesites mas iteraciones.
Si es muy grande, el modelo puede ajustarse demasiado rapido y sobreajustarse.

Por eso `0.1` es una eleccion muy comun y defendible.

## 9. `max_tree_depth = 6`

Esta opcion controla la profundidad maxima de cada arbol.

### Qué significa profundidad

La profundidad de un arbol indica cuantas divisiones sucesivas puede hacer.

Un arbol mas profundo:

- puede capturar reglas mas complejas;
- puede separar mejor casos particulares;
- pero tambien puede sobreajustarse mas facilmente.

### Efecto de `6`

Con una profundidad maxima de `6`, cada arbol tiene una capacidad moderada:

- suficientemente flexible para modelar patrones no triviales;
- no tan profunda como para volverse excesivamente compleja desde el inicio.

### Por qué es razonable

Porque en este proyecto:

- hay relaciones no lineales probables;
- hay variables categoricas y numericas mezcladas;
- pero tampoco quieres un modelo exageradamente complejo para una primera comparacion.

## 10. Cómo se relacionan entre sí estas opciones

### En el modelo lineal

```sql
model_type = 'LINEAR_REG',
input_label_cols = ['tip_amount'],
l2_reg = 1.0
```

la logica es:

- usar un modelo simple e interpretable;
- definir claramente la etiqueta;
- agregar regularizacion para evitar inestabilidad y sobreajuste.

### En el modelo boosted tree

```sql
model_type = 'BOOSTED_TREE_REGRESSOR',
input_label_cols = ['tip_amount'],
max_iterations = 25,
subsample = 0.8,
learn_rate = 0.1,
max_tree_depth = 6
```

la logica es:

- usar un modelo mas flexible;
- controlar su complejidad para que no se sobreajuste demasiado;
- hacer que el aprendizaje sea gradual y robusto.

## 11. Cómo justificar estas opciones en tu informe

Puedes escribir algo como esto:

> Se entrenaron dos modelos de regresión distintos para estimar `tip_amount`. El primero fue un modelo de regresión lineal (`LINEAR_REG`), utilizado como baseline interpretable, con regularización L2 (`l2_reg = 1.0`) para reducir sobreajuste y estabilizar los coeficientes. El segundo fue un modelo de árboles potenciados (`BOOSTED_TREE_REGRESSOR`), configurado con `max_iterations = 25`, `subsample = 0.8`, `learn_rate = 0.1` y `max_tree_depth = 6`, buscando capturar relaciones no lineales entre las variables sin llevar el modelo a una complejidad excesiva. Ambos modelos se compararon mediante MAE, MSE, RMSE y R2 sobre el conjunto de evaluación.

## 12. Lectura correcta de las opciones

Una forma simple de recordarlas es esta:

- `model_type`
  define qué familia de modelo vas a usar.

- `input_label_cols`
  define qué columna quieres predecir.

- `l2_reg`
  en regresión lineal, controla regularización para evitar que los coeficientes crezcan demasiado.

- `max_iterations`
  en boosting, define cuántas rondas de aprendizaje se hacen.

- `subsample`
  define qué proporción de filas usa cada ronda.

- `learn_rate`
  define qué tan agresiva es cada corrección.

- `max_tree_depth`
  define qué tan complejos pueden ser los árboles.

## 13. Qué opción sería "mejor"

No hay una respuesta universal.

La mejor configuración depende de:

- el dataset;
- el ruido;
- la complejidad de las relaciones;
- el nivel de sobreajuste;
- las métricas en evaluación.

Por eso la comparación final no debe basarse en intuición, sino en:

- `MAE`
- `MSE`
- `RMSE`
- `R2`

Si el boosted tree mejora claramente esas métricas, puedes justificar que captura mejor la estructura del problema. Si no mejora mucho o empeora, el modelo lineal puede ser preferible por simplicidad e interpretabilidad.

## 14. Resumen corto

En una frase:

- `LINEAR_REG` con `l2_reg` sirve como modelo base simple y estable.
- `BOOSTED_TREE_REGRESSOR` con `max_iterations`, `subsample`, `learn_rate` y `max_tree_depth` sirve como modelo más flexible para capturar patrones complejos.

## Fuentes oficiales

- BigQuery ML generalised linear models: https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm
- BigQuery ML boosted tree models: https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree
- BigQuery ML evaluate: https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate
