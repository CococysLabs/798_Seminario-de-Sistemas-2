select
  cast(sucursal_id as int64) as sucursal_id,
  {{ normalizar_texto('nombre_sucursal') }} as nombre_sucursal,
  {{ normalizar_texto('region') }} as region,
  {{ normalizar_texto('ciudad') }} as ciudad
from {{ source('raw_sgfood', 'sucursales') }}

