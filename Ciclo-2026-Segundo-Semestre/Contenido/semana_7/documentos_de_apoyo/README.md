# Semana 7 - Modelado Analitico con dbt

El material vigente de esta semana esta alineado al tema **Modelado Analitico con dbt** y al Proyecto 1 nuevo: implementacion de un flujo moderno de datos con Python, Apache Airflow, dbt y PostgreSQL.

## Archivos principales

- `documento_apoyo_semana7.tex`: fuente LaTeX del documento academico.
- `documento_apoyo_semana7.pdf`: documento compilado para estudiantes.
- `referencias_s7.bib`: bibliografia usada por el documento.
- `ejemplo_dbt_sgfood/`: ejemplo vigente para clase.

## Ejemplo vigente

Hay dos ejemplos vigentes:

```text
ejemplo_dbt_sgfood/
taller_dbt_codespaces_gcp/
```

`ejemplo_dbt_sgfood/` es un ejemplo local con PostgreSQL en Docker para explicar dbt sin GCP.

`taller_dbt_codespaces_gcp/` es el mini taller recomendado para clase: los estudiantes trabajan desde GitHub Codespaces y materializan modelos en BigQuery usando infraestructura GCP administrada por el docente.

Estos proyectos demuestran:

- carga raw con `seeds`;
- declaracion de `sources`;
- modelos `staging`, `intermediate` y `marts`;
- uso de `ref` y macro simple;
- pruebas dbt;
- documentacion y linaje;
- consultas analiticas finales sobre PostgreSQL.

## Material legado

Las carpetas relacionadas con SQL Server, SSIS y SSAS corresponden al enfoque anterior de la semana 7. Se conservan en el repositorio como referencia historica, pero no son el ejemplo principal para el contenido actualizado.
