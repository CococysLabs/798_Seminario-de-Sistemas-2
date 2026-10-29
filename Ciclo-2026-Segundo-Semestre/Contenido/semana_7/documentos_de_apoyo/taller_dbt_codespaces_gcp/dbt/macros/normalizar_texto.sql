{% macro normalizar_texto(columna) -%}
  nullif(trim(cast({{ columna }} as string)), '')
{%- endmacro %}

