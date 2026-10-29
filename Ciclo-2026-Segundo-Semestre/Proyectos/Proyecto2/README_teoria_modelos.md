# Teoria del Proyecto 2: regresion, clasificacion, evaluacion y prediccion

Este documento explica la teoria detras del requisito del proyecto que pide:

> "2 modelos distintos de regresion o clasificacion, se evaluara su desempeno mediante metricas como precision, error cuadratico medio o matriz de confusion, y se aplicara sobre nuevos datos"

La idea es que no solo ejecutes scripts, sino que entiendas que esta haciendo cada parte del pipeline y por que tiene sentido desde el punto de vista tecnico.

## 1. Que se intenta hacer en este proyecto

El proyecto no se limita a consultar datos historicos. Hay dos objetivos distintos:

1. Analizar lo que ya ocurrio.
2. Construir modelos que aprendan patrones de esos datos para estimar o predecir algo en datos nuevos.

Con el dataset de taxis, el analisis exploratorio responde preguntas como:

- En que horas hay mas viajes.
- Que rutas generan mas ingresos.
- Como cambia la propina segun horario, distancia o forma de pago.

Eso es analisis descriptivo. Explica el pasado.

En cambio, cuando entrenas un modelo, el objetivo cambia. Ya no solo quieres describir, sino aprender una relacion entre variables para luego usarla sobre registros que el modelo no ha visto antes.

Ejemplos:

- Dado un viaje con cierta distancia, hora, zona y forma de pago, estimar cuanto sera la propina.
- Dado un viaje con ciertas caracteristicas, estimar si la propina sera alta o no.

Eso ya es modelado predictivo.

## 2. Que es un modelo predictivo

Un modelo predictivo es una funcion matematica que intenta aproximar una relacion entre variables de entrada y una variable objetivo.

En terminos simples:

- Entradas o features: informacion que le das al modelo.
- Salida o target: lo que quieres que el modelo aprenda a predecir.

En este proyecto, una observacion es un viaje de taxi.

Cada viaje tiene atributos como:

- `vendor_id`
- `pickup_datetime`
- `dropoff_datetime`
- `trip_distance`
- `payment_type`
- `fare_amount`
- `pickup_location_id`
- `dropoff_location_id`

Con esas columnas puedes construir variables derivadas como:

- `pickup_hour`
- `pickup_day_of_week`
- `trip_duration_minutes`
- `tip_pct`
- `is_high_tip`

Luego defines que quieres predecir.

Por ejemplo:

- Si quieres predecir un valor numerico como `tip_amount`, estas en un problema de regresion.
- Si quieres predecir una categoria como `is_high_tip` = 0 o 1, estas en un problema de clasificacion.

## 3. Diferencia entre regresion y clasificacion

### Regresion

La regresion se usa cuando la salida esperada es numerica continua.

Ejemplos:

- predecir el monto de propina;
- predecir el tiempo de viaje;
- predecir el ingreso total de un viaje.

Si el valor real de propina fue `7.25`, el modelo deberia devolver algo cercano, por ejemplo `6.90` o `7.40`.

No importa acertar exactamente el numero, sino que el error sea pequeno.

### Clasificacion

La clasificacion se usa cuando la salida esperada es una categoria.

Ejemplos:

- propina alta vs no alta;
- pago en efectivo vs pago con tarjeta;
- viaje corto vs viaje largo.

En clasificacion el modelo no predice un numero continuo como `7.25`. Predice una clase.

Por ejemplo:

- `0` = no propina alta
- `1` = propina alta

Ademas, normalmente no solo devuelve la clase final, sino una probabilidad asociada.

Ejemplo:

- Probabilidad de clase `1`: `0.82`
- Prediccion final: `1`

Eso significa que el modelo cree con 82 % de confianza que ese viaje pertenece a la clase "propina alta".

## 4. Por que el proyecto pide dos modelos

Pedir dos modelos tiene sentido por varias razones.

### 1. Comparacion

No basta con entrenar un solo modelo y asumir que es bueno. En ciencia de datos y machine learning, casi siempre se comparan alternativas.

### 2. Aprendizaje metodologico

El curso quiere que practiques no solo la ejecucion tecnica, sino el razonamiento:

- que variable objetivo elegiste;
- por que ese problema es de regresion o clasificacion;
- que variables de entrada usaste;
- como comparaste desempeno;
- por que uno de los modelos resulta mas conveniente.

### 3. Demostrar evaluacion real

Si tienes dos modelos, puedes justificar una seleccion.

Ejemplos:

- un modelo puede tener mejor precision;
- otro puede tener menor error cuadratico medio;
- uno puede ser mas interpretable;
- otro puede generalizar mejor.

El punto no es solo entrenarlos, sino comparar.

## 5. Que significa entrenar un modelo

Entrenar es el proceso en el que el algoritmo observa ejemplos historicos y ajusta parametros internos para encontrar patrones.

Piensa en esto:

- Tienes miles o millones de viajes.
- Para cada viaje conoces sus caracteristicas.
- Tambien conoces el resultado real, por ejemplo la propina real o si fue propina alta.

El modelo usa esos ejemplos para aprender una relacion del tipo:

"cuando la distancia es mayor, la tarifa es mas alta, y si el pago es con tarjeta en ciertas zonas y horas, aumenta la probabilidad de cierta propina"

Eso no se programa a mano con reglas fijas. El algoritmo lo aprende a partir de los datos.

## 6. Variables de entrada, salida y objetivo

### Variable objetivo

Es la variable que quieres predecir.

Ejemplos en este proyecto:

- `tip_amount` para regresion;
- `is_high_tip` para clasificacion.

### Variables de entrada

Son las columnas que el modelo usa para hacer la prediccion.

Ejemplos:

- `trip_distance`
- `fare_amount`
- `pickup_hour`
- `pickup_day_of_week`
- `payment_type`
- `pickup_location_id`
- `dropoff_location_id`

### Por que no usar cualquier columna

No toda variable disponible debe usarse.

Una buena variable de entrada debe:

- estar disponible en el momento en que quieres predecir;
- tener sentido causal o al menos correlacional;
- no introducir fuga de informacion;
- aportar senal util al modelo.

## 7. Que es feature engineering

Feature engineering es el proceso de transformar columnas crudas en variables mas utiles para el modelo.

Ejemplos con este proyecto:

- `pickup_datetime` se transforma en `pickup_hour`
- `pickup_datetime` se transforma en `pickup_day_of_week`
- `dropoff_datetime - pickup_datetime` se transforma en `trip_duration_minutes`
- `tip_amount / fare_amount` se transforma en `tip_pct`
- `tip_pct >= 0.20` se transforma en `is_high_tip`

Esto importa porque muchos patrones son mas faciles de aprender con variables derivadas que con campos crudos.

Por ejemplo:

- el modelo puede captar mejor un patron por hora del dia que por timestamp completo;
- una clasificacion de propina alta se formula mucho mejor con una variable binaria como `is_high_tip`.

## 8. Que es data leakage

Data leakage o fuga de informacion ocurre cuando el modelo aprende usando informacion que en la vida real no estaria disponible en el momento de predecir.

Esto es grave porque hace que el modelo parezca mejor de lo que realmente es.

Ejemplo conceptual:

Si intentaras predecir la propina usando una variable que indirectamente ya la contiene, el modelo obtendria resultados artificialmente buenos.

Otro tipo de leakage ocurre cuando mezclas pasado y futuro de forma incorrecta en entrenamiento y evaluacion.

## 9. Por que el split temporal importa

En problemas con datos de tiempo, no conviene mezclar filas aleatoriamente como si todas fueran equivalentes.

En este proyecto, cada fila pertenece a un momento del tiempo.

Por eso el split:

- `TRAIN`: enero a septiembre
- `EVAL`: octubre y noviembre
- `PREDICT`: diciembre

tiene sentido tecnico.

El modelo aprende con meses anteriores y se evalua en meses posteriores. Eso se parece mas al uso real:

- entrenas con historia pasada;
- pruebas en un periodo futuro;
- luego predices sobre datos nuevos.

Este enfoque reduce fuga de informacion y hace la evaluacion mas realista.

## 10. Que significa evaluar un modelo

Evaluar significa medir que tan bien predice un modelo sobre datos que no se usaron para entrenarlo.

Esto es crucial.

Si mides el desempeno solo sobre datos de entrenamiento, podrias caer en sobreajuste.

## 11. Que es sobreajuste

Sobreajuste o overfitting ocurre cuando el modelo aprende demasiado bien los datos de entrenamiento, incluyendo ruido o patrones accidentales, pero luego falla en datos nuevos.

Es como memorizar respuestas en vez de entender reglas.

Un modelo con sobreajuste:

- se ve excelente en entrenamiento;
- se ve peor en evaluacion real.

Por eso necesitas separar datos de entrenamiento y evaluacion.

## 12. Por que hay metricas diferentes

La metrica depende del tipo de problema.

No puedes evaluar igual un modelo que predice montos exactos que uno que clasifica categorias.

### Para regresion

Importa que tan cerca esta el valor predicho del valor real.

### Para clasificacion

Importa cuantas veces acierta la clase correcta y como se comporta entre positivos y negativos.

## 13. Teoria de metricas para clasificacion

Supongamos que la clase positiva es:

- `1 = propina alta`

Entonces cada prediccion puede caer en uno de cuatro casos.

### Verdadero positivo

El modelo dijo "propina alta" y realmente era propina alta.

### Verdadero negativo

El modelo dijo "no propina alta" y realmente no lo era.

### Falso positivo

El modelo dijo "propina alta" pero en realidad no lo era.

### Falso negativo

El modelo dijo "no propina alta" pero en realidad si lo era.

Estos cuatro casos forman la base de casi todas las metricas de clasificacion.

## 14. Matriz de confusion

La matriz de confusion es una tabla que resume esos cuatro casos.

Sirve para ver no solo cuantos aciertos hubo, sino que tipo de errores comete el modelo.

Por ejemplo:

- si hay muchos falsos positivos, el modelo exagera la clase positiva;
- si hay muchos falsos negativos, el modelo se esta perdiendo casos importantes.

La matriz de confusion es valiosa porque da contexto que una sola metrica no da.

## 15. Accuracy

`accuracy` es la proporcion de predicciones correctas sobre el total.

Formula conceptual:

- aciertos totales / total de casos

Es util, pero puede ser enganosa cuando las clases estan desbalanceadas.

Ejemplo:

Si 90 % de los viajes no tienen propina alta, un modelo tonto que siempre prediga "no propina alta" puede tener 90 % de accuracy, pero ser inutil para detectar la clase positiva.

## 16. Precision

`precision` responde:

"de todos los casos que el modelo marco como positivos, cuantos realmente lo eran?"

Es importante cuando te preocupa no etiquetar como positivo algo que no lo es.

Ejemplo conceptual:

Si el modelo dice que muchos viajes tendran propina alta, pero la mitad en realidad no la tienen, la precision es baja.

## 17. Recall

`recall` responde:

"de todos los positivos reales, cuantos logro detectar el modelo?"

Es importante cuando te preocupa no dejar pasar casos positivos.

Precision y recall suelen estar en tension:

- si haces el modelo mas estricto, puede subir precision y bajar recall;
- si lo haces mas flexible, puede subir recall y bajar precision.

## 18. F1-score

`f1_score` combina precision y recall en una sola medida.

Sirve cuando quieres equilibrio entre ambas.

Es especialmente util cuando las clases estan desbalanceadas y no quieres depender solo de accuracy.

## 19. ROC y ROC-AUC

Un modelo de clasificacion no solo puede dar una clase, tambien puede dar probabilidades.

La curva ROC analiza el comportamiento del modelo para distintos umbrales.

Por ejemplo:

- si consideras positivo cualquier caso con probabilidad mayor a 0.50;
- o mayor a 0.70;
- o mayor a 0.30.

Cada umbral cambia precision y recall.

La curva ROC resume ese comportamiento y el area bajo esa curva, `ROC-AUC`, mide la capacidad general del modelo para separar clases.

Interpretacion general:

- cercano a 1.0: muy buena separacion;
- cercano a 0.5: parecido a adivinar al azar.

## 20. Teoria de metricas para regresion

En regresion el problema es distinto.

No hay clases correctas o incorrectas, sino diferencias entre valor real y valor predicho.

El concepto clave es el error:

- error = valor real - valor predicho

Si quieres predecir `tip_amount` y el valor real fue `8.00`, pero el modelo dijo `6.50`, el error es `1.50` en magnitud.

## 21. MAE

`MAE` o mean absolute error es el promedio del valor absoluto de los errores.

Te dice, en promedio, cuanto se equivoca el modelo en las mismas unidades de la variable.

Si predices propina en dolares, el MAE tambien esta en dolares.

Eso lo hace intuitivo.

Ejemplo:

- `MAE = 1.20`

Puede interpretarse como:

"en promedio, el modelo se equivoca por alrededor de 1.20 dolares"

## 22. MSE

`MSE` o mean squared error es el promedio del cuadrado de los errores.

Castiga mas los errores grandes que los pequenos.

Por eso es util cuando quieres penalizar fuerte predicciones muy malas.

Si un modelo comete pocos errores chicos y unos pocos errores enormes, el MSE sube mucho.

## 23. RMSE

`RMSE` es la raiz cuadrada del MSE.

Tiene la ventaja de volver a la unidad original de la variable, como dolares.

Suele ser mas interpretable que el MSE puro.

## 24. R2

`R2` o coeficiente de determinacion mide que proporcion de la variabilidad del objetivo explica el modelo.

En terminos intuitivos:

- si es alto, el modelo captura bastante del patron;
- si es bajo, el modelo explica poco.

No debe interpretarse aislado. Siempre conviene verlo junto con MAE, MSE o RMSE.

## 25. Por que el proyecto menciona "precision", "error cuadratico medio" y "matriz de confusion"

Porque son ejemplos de metricas tipicas segun el tipo de modelo.

- `precision` pertenece al mundo de clasificacion;
- `matriz de confusion` tambien pertenece a clasificacion;
- `error cuadratico medio` pertenece a regresion.

Eso ya te da una pista sobre lo que espera el proyecto:

- que no entrenes a ciegas;
- que sepas que una metrica depende del tipo de problema;
- que puedas justificar por que una metrica es adecuada.

## 26. Que significa "aplicar sobre nuevos datos"

Esta parte es central.

El modelo no se entrena para evaluar solo lo que ya conoce. Se entrena para ser usado en nuevos registros.

En este proyecto, "nuevos datos" significa filas no usadas en entrenamiento.

En tu pipeline eso corresponde al bloque:

- `PREDICT`: diciembre 2022

La logica es:

1. Entrenas con meses anteriores.
2. Evalua el modelo con otro subconjunto.
3. Luego usas el modelo para predecir sobre registros nuevos.

Eso demuestra que el modelo no solo memoriza, sino que generaliza al menos en cierta medida.

## 27. Como se ve esto en BigQuery ML

BigQuery ML te permite entrenar modelos con SQL.

La idea general es:

### Entrenamiento

```sql
CREATE OR REPLACE MODEL ...
AS
SELECT ...
```

Aqui defines:

- tipo de modelo;
- variable objetivo;
- features;
- configuracion de split.

### Evaluacion

```sql
SELECT * FROM ML.EVALUATE(MODEL ...);
```

Esto devuelve metricas.

### Matriz de confusion

```sql
SELECT * FROM ML.CONFUSION_MATRIX(MODEL ..., ...);
```

### Curva ROC

```sql
SELECT * FROM ML.ROC_CURVE(MODEL ...);
```

### Prediccion

```sql
SELECT * FROM ML.PREDICT(MODEL ..., (...));
```

Esto aplica el modelo a nuevos datos.

## 28. Como aterriza esto exactamente en tu proyecto

### Modelo 1: clasificacion

Objetivo:

- predecir `is_high_tip`

Definicion:

- `is_high_tip = 1` si `tip_pct >= 0.20`
- `is_high_tip = 0` en caso contrario

Interpretacion:

El modelo intenta responder:

"con las caracteristicas del viaje, es probable que la propina sea alta?"

Metricas apropiadas:

- precision
- recall
- f1_score
- accuracy
- roc_auc
- matriz de confusion

### Modelo 2: regresion

Objetivo:

- predecir `tip_amount`

Interpretacion:

El modelo intenta responder:

"con las caracteristicas del viaje, cuanto dinero de propina es razonable esperar?"

Metricas apropiadas:

- MAE
- MSE
- RMSE
- R2

## 29. Como justificar las variables usadas

Una parte importante del proyecto es justificar por que las variables de entrada tienen sentido.

Ejemplo de justificacion:

- `trip_distance`: viajes mas largos suelen asociarse a tarifas mayores y posiblemente propinas mayores.
- `fare_amount`: la propina suele relacionarse con la tarifa.
- `pickup_hour`: el comportamiento de usuarios cambia por horario.
- `pickup_day_of_week`: la demanda y patrones pueden variar entre semana y fin de semana.
- `payment_type`: en muchos datasets las propinas registradas se observan mejor en pagos con tarjeta que en efectivo.
- `pickup_location_id` y `dropoff_location_id`: diferentes zonas pueden tener patrones de propina y demanda distintos.

## 30. Por que un modelo puede parecer bueno y no serlo

Esto es importante para el informe.

Un modelo puede parecer bueno si:

- se evaluo con datos contaminados;
- hubo fuga de informacion;
- solo se reporto una metrica conveniente;
- se ignoro desbalance de clases;
- se comparo contra un baseline muy debil.

Por eso el analisis debe ser critico.

## 31. Que es un baseline

Un baseline es una referencia minima razonable.

Ejemplos:

- en regresion: predecir siempre la propina promedio;
- en clasificacion: predecir siempre la clase mayoritaria.

Un modelo serio deberia superar claramente ese baseline.

Aunque el proyecto no te pida implementarlo formalmente, mencionarlo en el README eleva mucho la calidad tecnica del trabajo.

## 32. Que deberias concluir cuando compares modelos

No basta con decir:

- "modelo A tuvo mejor resultado"

Debes explicar:

- en que metrica fue mejor;
- por que esa metrica importa;
- si hubo trade-off entre precision y recall;
- si el error numerico en regresion es aceptable;
- si el modelo es suficientemente util para el objetivo.

## 33. Ejemplo de razonamiento tecnico

Un ejemplo de conclusion bien formulada seria:

"El modelo de clasificacion logro un mejor equilibrio entre precision y recall, con un F1-score superior al baseline. Esto indica que puede identificar viajes con propina alta de manera mas consistente que una regla trivial. Por su parte, el modelo de regresion obtuvo un error absoluto medio moderado, lo cual sugiere que puede estimar razonablemente el monto de la propina, aunque sigue siendo sensible a valores extremos."

Eso es muy distinto a solo decir:

"El modelo salio bien"

## 34. Errores conceptuales comunes

### Error 1

Usar accuracy como unica metrica en clasificacion.

Problema:

Si la clase positiva es rara, accuracy puede enganar.

### Error 2

Usar una metrica de clasificacion para un problema de regresion.

Problema:

No tiene sentido tecnico.

### Error 3

No separar entrenamiento y evaluacion.

Problema:

No sabes si el modelo generaliza.

### Error 4

Usar variables con fuga de informacion.

Problema:

Las metricas se inflan artificialmente.

### Error 5

No justificar por que se eligio la variable objetivo.

Problema:

El modelo queda desconectado del problema de negocio o del enunciado.

## 35. Como convertir esta teoria en texto para tu entrega

Si luego quieres pasarlo a tu README final, puedes resumirlo asi:

1. Se construyeron dos modelos predictivos distintos para cubrir dos enfoques del problema:
   - un modelo de clasificacion para identificar viajes con propina alta;
   - un modelo de regresion para estimar el monto de propina.

2. La clasificacion se evaluo con metricas orientadas a clases:
   - precision;
   - recall;
   - F1-score;
   - matriz de confusion;
   - ROC-AUC.

3. La regresion se evaluo con metricas orientadas a error:
   - MAE;
   - MSE;
   - RMSE;
   - R2.

4. Se aplico particion temporal del dataset para evitar fuga de informacion y aproximar un escenario real de prediccion.

5. Los modelos se aplicaron sobre datos no usados en entrenamiento para demostrar capacidad de generalizacion.

## 36. Conclusion conceptual

La teoria detras de este requisito es simple en su estructura:

- primero entiendes el problema;
- luego decides si la salida es numerica o categorica;
- despues construyes features;
- entrenas uno o mas modelos;
- los evaluas con metricas adecuadas;
- comparas resultados;
- finalmente los aplicas sobre datos nuevos.

Eso es el ciclo basico de modelado predictivo.

El proyecto quiere que demuestres que puedes recorrer ese ciclo de forma ordenada, con criterio tecnico y con evidencia medible.

## 37. En una frase

La idea de entrenar 2 modelos y evaluarlos con metricas es demostrar que no solo sabes consultar datos, sino que tambien sabes convertir datos historicos en un sistema de prediccion que pueda ser medido, comparado y usado sobre registros nuevos.
