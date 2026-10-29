-- Crea el dataset del Proyecto 2 directamente en el proyecto configurado.

CREATE SCHEMA IF NOT EXISTS `${PROJECT_ID}.${DATASET_ID}`
OPTIONS (
  location = '${BQ_LOCATION}',
  description = 'Proyecto 2 Seminario de Sistemas 2 - NYC Taxi Trips 2022'
);
