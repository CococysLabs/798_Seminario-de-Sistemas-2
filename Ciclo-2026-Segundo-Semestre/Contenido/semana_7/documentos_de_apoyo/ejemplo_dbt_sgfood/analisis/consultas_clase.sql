-- Consultas para mostrar despues de ejecutar:
-- dbt seed
-- dbt run
-- dbt test

-- 1. Venta neta por categoria.
select
    categoria,
    sum(venta_neta) as venta_neta,
    sum(margen_estimado) as margen_estimado
from analytics_marts.mart_ventas_por_categoria
group by categoria
order by venta_neta desc;

-- 2. Top clientes por venta neta.
select
    c.nombre_cliente,
    c.segmento_cliente,
    sum(f.monto_neto) as venta_neta
from analytics_marts.fact_ventas f
inner join analytics_marts.dim_cliente c
    on f.cliente_id = c.cliente_id
group by c.nombre_cliente, c.segmento_cliente
order by venta_neta desc;

-- 3. Validacion rapida del hecho.
select
    count(*) as lineas_venta,
    sum(cantidad) as unidades,
    sum(monto_neto) as venta_neta
from analytics_marts.fact_ventas;

