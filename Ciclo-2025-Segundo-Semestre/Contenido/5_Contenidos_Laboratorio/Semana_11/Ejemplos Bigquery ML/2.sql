-- Como comparamos modelos para saber cual es más exacto?

-- Entrenamos dos modelos distintos
CREATE OR REPLACE MODEL `ML2.modelo_1`
OPTIONS(model_type='logistic_reg') AS
SELECT * FROM `...`;

CREATE OR REPLACE MODEL `ML2.modelo_2`
OPTIONS(model_type='logistic_reg', l1_reg=0.2) AS
SELECT * FROM `...`;

-- Comparamos sus AUC
SELECT
  'modelo_1' AS modelo,
  (SELECT auc FROM ML.EVALUATE(MODEL `ML2.modelo_1`)) AS auc
UNION ALL
SELECT
  'modelo_2',
  (SELECT auc FROM ML.EVALUATE(MODEL `ML2.modelo_2`)) AS auc;
