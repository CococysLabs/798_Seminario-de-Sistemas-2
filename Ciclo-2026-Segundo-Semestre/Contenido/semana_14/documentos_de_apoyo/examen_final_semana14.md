# Examen Final

## Instrucciones

- Responde con una sola opción por pregunta.
- Cada pregunta tiene 3 opciones.
- El examen cubre los documentos de apoyo de las semanas 1 a la 12.
- Las preguntas 1 a 12 son de nivel teórico intermedio.
- Las preguntas 13 a 25 son de nivel teórico fácil.

## Preguntas teóricas intermedias

1. En una arquitectura BI, ¿cuál es la relación más correcta entre ETL, Data Warehouse y OLAP?
   - A) ETL consume reportes OLAP para poblar sistemas transaccionales.
   - B) ETL integra y prepara datos para el Data Warehouse, que luego soporta análisis OLAP.
   - C) OLAP reemplaza al Data Warehouse cuando existen dashboards.
   - Respuesta correcta: B

2. ¿Cuál es la principal ventaja de una dimensión SCD Tipo 2 frente a una SCD Tipo 1?
   - A) Permite conservar historial completo de cambios en atributos.
   - B) Reduce siempre el tamaño de la dimensión.
   - C) Evita el uso de claves sustitutas.
   - Respuesta correcta: A

3. ¿Qué problema busca evitar la idempotencia en un proceso ETL?
   - A) Que una recarga del mismo lote produzca duplicados o resultados inconsistentes.
   - B) Que los usuarios creen más visualizaciones de las necesarias.
   - C) Que los cubos OLAP tengan jerarquías de más de tres niveles.
   - Respuesta correcta: A

4. En la selección de una herramienta ETL para un entorno empresarial, ¿qué criterio suele ser más importante que la cantidad de conectores por sí sola?
   - A) La capacidad de gobernanza, monitoreo y recuperación ante fallos.
   - B) El color de la interfaz.
   - C) Que la herramienta incluya un motor OLAP embebido.
   - Respuesta correcta: A

5. ¿Cuál es la diferencia conceptual más importante entre un KPI y una visualización cualquiera?
   - A) El KPI siempre usa gráficos circulares.
   - B) El KPI está vinculado a un objetivo de desempeño y a criterios de seguimiento.
   - C) La visualización nunca puede resumir datos.
   - Respuesta correcta: B

6. En un ecosistema Big Data con Spark, ¿por qué suele preferirse trabajar sobre formatos columnares como Parquet en data lakes?
   - A) Porque obligan a usar datos no estructurados.
   - B) Porque favorecen compresión y lectura eficiente de columnas relevantes.
   - C) Porque eliminan la necesidad de particionamiento.
   - Respuesta correcta: B

7. ¿Qué describe mejor la diferencia entre SSIS, SSAS y SSRS?
   - A) SSIS procesa ETL, SSAS modela análisis y SSRS publica reportes.
   - B) SSIS diseña dashboards, SSAS limpia archivos CSV y SSRS entrena modelos ML.
   - C) Los tres cumplen exactamente la misma función en distintas interfaces.
   - Respuesta correcta: A

8. ¿Cuál es el objetivo principal de separar datos de entrenamiento y datos de evaluación en un modelo predictivo?
   - A) Medir si el modelo generaliza bien sobre datos no usados en el entrenamiento.
   - B) Garantizar que el modelo siempre obtenga 100\% de precisión.
   - C) Reducir la necesidad de definir una variable objetivo.
   - Respuesta correcta: A

9. En BigQuery, ¿qué práctica ayuda más a reducir costo y tiempo de consulta?
   - A) Usar `SELECT *` para simplificar mantenimiento.
   - B) Consultar solo columnas necesarias y filtrar particiones oportunamente.
   - C) Duplicar tablas en múltiples datasets sin control.
   - Respuesta correcta: B

10. En un problema de clasificación, ¿por qué no basta con revisar solo `accuracy` cuando hay desbalance de clases?
    - A) Porque `accuracy` puede verse alta aun si el modelo falla en la clase minoritaria.
    - B) Porque `accuracy` solo existe para regresión.
    - C) Porque `accuracy` siempre es igual a `recall`.
    - Respuesta correcta: A

11. ¿Por qué una matriz de confusión es útil al evaluar un clasificador?
    - A) Porque muestra únicamente el tiempo de entrenamiento del modelo.
    - B) Porque permite distinguir aciertos y errores por tipo de predicción.
    - C) Porque reemplaza todas las demás métricas sin excepción.
    - Respuesta correcta: B

12. En un equipo de datos, ¿por qué no conviene asumir que un científico de datos puede sustituir completamente al ingeniero de datos?
    - A) Porque el científico de datos no necesita datos confiables para modelar.
    - B) Porque ambos roles resuelven problemas distintos y dependen de entregables complementarios.
    - C) Porque el ingeniero de datos solo trabaja con reportes finales.
    - Respuesta correcta: B

## Preguntas teóricas fáciles

13. ¿Qué significa BI?
    - A) Business Intelligence.
    - B) Binary Integration.
    - C) Basic Interface.
    - Respuesta correcta: A

14. ¿Cuál es el propósito principal de OLAP?
    - A) Ejecutar transacciones operativas de alta concurrencia.
    - B) Facilitar análisis multidimensional para la toma de decisiones.
    - C) Reemplazar cualquier proceso ETL.
    - Respuesta correcta: B

15. ¿Cuál de los siguientes es un esquema dimensional común?
    - A) Estrella.
    - B) Circular.
    - C) Secuencial.
    - Respuesta correcta: A

16. ¿Qué letra de las 4V de Big Data se relaciona con la rapidez de generación y procesamiento de datos?
    - A) Velocidad.
    - B) Veracidad.
    - C) Valor.
    - Respuesta correcta: A

17. ¿Cuál es la fase de ETL donde se limpian o transforman los datos?
    - A) Extracción.
    - B) Transformación.
    - C) Publicación.
    - Respuesta correcta: B

18. ¿Qué herramienta se asocia principalmente con la orquestación de workflows de datos?
    - A) Apache Airflow.
    - B) SSRS.
    - C) Excel.
    - Respuesta correcta: A

19. ¿Qué lenguaje se usa comúnmente para medidas en modelos tabulares de Power BI?
    - A) DAX.
    - B) HTML.
    - C) CSS.
    - Respuesta correcta: A

20. ¿Qué servicio de Microsoft se enfoca en integración y carga de datos?
    - A) SSIS.
    - B) SSAS.
    - C) SSRS.
    - Respuesta correcta: A

21. ¿Qué servicio de Microsoft se enfoca en análisis semántico y modelos analíticos?
    - A) SSAS.
    - B) SSIS.
    - C) PowerShell DSC.
    - Respuesta correcta: A

22. ¿Qué plataforma de Google Cloud se estudió para análisis y consulta de grandes volúmenes de datos?
    - A) BigQuery.
    - B) Bigtable Studio.
    - C) Google Sites.
    - Respuesta correcta: A

23. ¿Qué función de BigQuery ML se usa para generar predicciones con un modelo entrenado?
    - A) `ML.PREDICT`.
    - B) `ML.CREATE_VIEW`.
    - C) `ML.EXPORT_SCHEMA`.
    - Respuesta correcta: A

24. ¿Qué concepto describe mejor un dashboard ejecutivo en BI?
    - A) Un tablero que resume indicadores clave para apoyar decisiones.
    - B) Un archivo usado exclusivamente para respaldos técnicos.
    - C) Un modelo que solo sirve para entrenar clasificadores.
    - Respuesta correcta: A

25. ¿Cuál de estos roles se enfoca principalmente en construir y operar pipelines y plataformas de datos?
    - A) Ingeniero de Datos.
    - B) Diseñador gráfico.
    - C) Auditor financiero.
    - Respuesta correcta: A
