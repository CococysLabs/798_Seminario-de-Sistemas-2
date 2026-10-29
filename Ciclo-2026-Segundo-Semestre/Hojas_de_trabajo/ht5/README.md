# Hoja de Trabajo 5 - Gobierno de Datos y BigQuery

## Objetivo

El estudiante debe aplicar los conceptos de la semana 9 en un caso distinto al ejemplo del documento:

1. crear tablas en BigQuery;
2. identificar datos sensibles;
3. proponer controles de gobierno de datos;
4. optimizar consultas;
5. crear una vista y una vista materializada.

## Caso

La universidad `USAC Analytics Lab` quiere analizar permanencia estudiantil. Se entregan tres tablas:

- `estudiantes`
- `pagos`
- `actividad_virtual`

Con estos datos se debe construir una solución analítica gobernada en BigQuery.

## Archivos

- `enunciado.md`: instrucciones completas de la hoja.
- `data/`: datos CSV de muestra.
- `sql/01_crear_fuentes.sql`: creación y carga base.
- `sql/02_plantilla_ht5.sql`: archivo que el estudiante debe completar.
- `sql/99_solucion_referencia.sql`: una posible solución de referencia.

## Flujo sugerido

1. Crear un dataset en BigQuery para la hoja.
2. Subir los CSV a Cloud Storage o cargarlos manualmente.
3. Ejecutar `sql/01_crear_fuentes.sql`.
4. Completar y ejecutar `sql/02_plantilla_ht5.sql`.
5. Comparar el resultado con `sql/99_solucion_referencia.sql`.

## Entregable sugerido

El estudiante puede entregar:

- capturas o consultas ejecutadas;
- script SQL final;
- explicación breve de:
  - qué columnas son sensibles;
  - qué vista se usaría para negocio;
  - qué consulta fue optimizada;
  - qué indicadores contiene la vista materializada.
