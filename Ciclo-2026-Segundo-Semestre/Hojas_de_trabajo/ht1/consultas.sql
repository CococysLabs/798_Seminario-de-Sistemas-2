-- Carné: 20XXXXXXX | Nombre: ____________________
SELECT
  Anio,
  MesNumero,
  MesNombre,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY Anio, MesNumero, MesNombre
ORDER BY TotalVentas DESC;


SELECT
  Canal,
  Categoria,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY ROLLUP (Canal, Categoria)
ORDER BY Canal, Categoria;


SELECT
  Departamento,
  Categoria,
  SUM(ImporteNeto) AS TotalVentas
FROM dwh.vw_CuboVentas
GROUP BY CUBE (Departamento, Categoria)
ORDER BY Departamento, Categoria;


WITH base AS (
  SELECT Categoria, Canal, ImporteNeto
  FROM dwh.vw_CuboVentas
)
SELECT
  Categoria,
  ISNULL([Mayorista],0)      AS Mayorista,
  ISNULL([Minorista],0)      AS Minorista,
  ISNULL([Ecommerce],0)      AS Ecommerce,
  ISNULL([Institucional],0)  AS Institucional
FROM base
PIVOT (
  SUM(ImporteNeto)
  FOR Canal IN ([Mayorista],[Minorista],[Ecommerce],[Institucional])
) p
ORDER BY Categoria;
