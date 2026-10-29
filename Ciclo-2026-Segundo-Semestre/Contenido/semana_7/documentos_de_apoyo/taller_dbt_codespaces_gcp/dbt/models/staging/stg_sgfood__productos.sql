select
  cast(producto_id as int64) as producto_id,
  {{ normalizar_texto('nombre_producto') }} as nombre_producto,
  lower({{ normalizar_texto('categoria') }}) as categoria,
  {{ normalizar_texto('marca') }} as marca,
  cast(costo_unitario as numeric) as costo_unitario,
  cast(precio_lista as numeric) as precio_lista,
  cast(precio_lista as numeric) - cast(costo_unitario as numeric) as margen_lista
from {{ source('raw_sgfood', 'productos') }}

