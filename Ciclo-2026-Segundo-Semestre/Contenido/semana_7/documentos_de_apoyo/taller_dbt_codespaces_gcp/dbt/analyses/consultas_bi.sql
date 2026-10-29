-- Ejecutar estas consultas en BigQuery despues de dbt run.
-- Compilar con dbt compile para que dbt reemplace target.project y target.schema.

select
  categoria,
  sum(venta_neta) as venta_neta,
  sum(margen_estimado) as margen_estimado
from `{{ target.project }}.{{ target.schema }}_marts.mart_ventas_por_categoria`
group by categoria
order by venta_neta desc;

select
  canal,
  sum(unidades_vendidas) as unidades,
  sum(venta_neta) as venta_neta
from `{{ target.project }}.{{ target.schema }}_marts.mart_ventas_por_categoria`
group by canal
order by venta_neta desc;
