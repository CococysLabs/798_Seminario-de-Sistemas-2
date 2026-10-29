# Ejemplo Semana 9 - Gobierno de Datos y BigQuery ML

Este ejemplo práctico aterriza la teoría de la semana 9 con un caso de comercio electrónico orientado a:

- gobierno de datos con BigQuery;
- control de acceso por columnas, filas y vistas;
- optimización de consultas;
- uso de vistas materializadas;
- creación de un modelo predictivo con BigQuery ML;
- exportación de resultados.

## Estructura

- `data/`: archivos CSV pequeños para cargar el ejemplo.
- `sql/01_crear_tablas_y_cargas.sql`: crea tablas y carga datos de ejemplo.
- `sql/02_gobierno_de_datos.sql`: ejemplos de IAM conceptual, policy tags, row-level security y authorized views.
- `sql/03_consultas_optimizacion_y_vistas.sql`: consultas analíticas, vista lógica y vista materializada.
- `sql/04_bigquery_ml.sql`: entrenamiento, evaluación y predicción con BigQuery ML.
- `sql/05_exportacion.sql`: exportación de datos y del modelo.

## Caso

La empresa `NovaShop` quiere analizar ventas y predecir abandono de clientes. El equipo necesita:

1. Proteger columnas sensibles como correo y teléfono.
2. Compartir solo datos agregados con analistas de negocio.
3. Optimizar consultas sobre ventas y soporte.
4. Crear un modelo de churn con BigQuery ML.

## Requisitos previos

1. Tener un proyecto de Google Cloud con BigQuery habilitado.
2. Tener un dataset donde puedas crear tablas, vistas y modelos.
3. Opcional: subir los CSV de `data/` a un bucket de Cloud Storage si quieres practicar cargas externas.

## Flujo sugerido

### 1) Crear dataset

Crea un dataset, por ejemplo:

- `semana9_novashop`

### 2) Cargar datos

El script `sql/01_crear_tablas_y_cargas.sql` ya incluye inserciones SQL directas para que el ejemplo sea reproducible sin depender del cargador CSV.

Si quieres practicar la parte de almacenamiento externo, tambien puedes usar los CSV de `data/` y subirlos al bucket creado por Terraform.

### 3) Ejecutar scripts en orden

1. `sql/01_crear_tablas_y_cargas.sql`
2. `sql/02_gobierno_de_datos.sql`
3. `sql/03_consultas_optimizacion_y_vistas.sql`
4. `sql/04_bigquery_ml.sql`
5. `sql/05_exportacion.sql`

## Resultado esperado

Al final deberías tener:

- tablas base con clientes, ventas y soporte;
- una vista segura para negocio;
- una vista materializada de ventas diarias por región;
- una tabla analítica de entrenamiento;
- un modelo `modelo_churn`;
- ejemplos de exportación listos para adaptar.

## Qué explicar en clase o reporte

- Qué columnas deberían protegerse con `policy tags`.
- Qué usuarios verían la tabla completa y cuáles solo la vista.
- Por qué la vista materializada ayuda al rendimiento.
- Qué variable objetivo usa el modelo.
- Qué limitaciones tiene el ejemplo.

## Nota

Algunas instrucciones de gobierno de datos requieren permisos de administración en BigQuery, Data Catalog o IAM. Por eso en el script se incluyen partes ejecutables y partes conceptuales marcadas como referencia.
