--• Usar ML.EVALUATE para obtener métricas; presentar una tabla comparativa por modelo con la métrica primaria y secundarias. • Justificar la selección del modelo final con base en métricas y consideraciones de interpretabilidad/costo.

SELECT *
FROM ML.EVALUATE(MODEL `ML2.modelo_propinas`);

-- . Comparar múltiples modelos
WITH eval1 AS (
  SELECT 'Modelo_Logistic' AS modelo, * 
  FROM ML.EVALUATE(MODEL `ML2.modelo_propinas`)
),
eval2 AS (
  SELECT 'Modelo_DNN' AS modelo, *
  FROM ML.EVALUATE(MODEL `ML2.income_model`)
)
SELECT 
  modelo,
  accuracy,
  precision,
  recall,
  f1_score,
  log_loss,
  roc_auc
FROM eval1
UNION ALL
SELECT 
  modelo,
  accuracy,
  precision,
  recall,
  f1_score,
  log_loss,
  roc_auc
FROM eval2;

/*
DOCU QUE QUIERO
Se compararon dos modelos: uno de regresión logística y otro de red neuronal profunda.
Aunque la red neuronal alcanzó un AUC ligeramente superior (0.91 vs. 0.89), el modelo de regresión logística fue seleccionado por su mayor interpretabilidad, menor costo computacional y estabilidad en validaciones. Además, permite explicar fácilmente la contribución de cada variable a la predicción final.



| Modelo          | Tipo                | Métrica principal | Valor | Métricas secundarias             | Interpretabilidad        | Costo (tiempo/recursos) | Seleccionado |
| --------------- | ------------------- | ----------------- | ----- | -------------------------------- | ------------------------ | ----------------------- | ------------ |
| modelo_propinas | Logistic Regression | AUC               | 0.89  | Accuracy = 0.87, Log Loss = 0.31 | Alta (fácil de explicar) | Bajo                    | SI           |
| modelo_dnn      | Deep Neural Network | AUC               | 0.91  | Accuracy = 0.89, Log Loss = 0.29 | Media (compleja)         | Medio-Alto              | NO           |

*/