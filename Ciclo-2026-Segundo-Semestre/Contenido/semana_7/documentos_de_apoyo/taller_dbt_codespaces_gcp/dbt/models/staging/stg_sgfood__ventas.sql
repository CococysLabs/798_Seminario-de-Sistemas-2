select
  cast(venta_id as int64) as venta_id,
  cast(fecha_venta as date) as fecha_venta,
  cast(cliente_id as int64) as cliente_id,
  cast(producto_id as int64) as producto_id,
  cast(sucursal_id as int64) as sucursal_id,
  lower({{ normalizar_texto('canal') }}) as canal,
  cast(cantidad as int64) as cantidad,
  cast(precio_unitario as numeric) as precio_unitario,
  cast(descuento_unitario as numeric) as descuento_unitario,
  cast(cantidad as numeric) * cast(precio_unitario as numeric) as monto_bruto,
  cast(cantidad as numeric) * cast(descuento_unitario as numeric) as descuento_total,
  cast(cantidad as numeric) * (cast(precio_unitario as numeric) - cast(descuento_unitario as numeric)) as monto_neto
from {{ source('raw_sgfood', 'ventas') }}

