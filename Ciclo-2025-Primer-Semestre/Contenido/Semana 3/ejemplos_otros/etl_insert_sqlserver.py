
import pyodbc
import pandas as pd

# Conexión a SQL Server
conn = pyodbc.connect("DRIVER={SQL Server};SERVER=TU_SERVIDOR;DATABASE=TU_DB;Trusted_Connection=yes")
cursor = conn.cursor()

# Función para insertar datos
def insertar(tabla, columnas, datos):
    query = f"INSERT INTO {{tabla}} ({','.join(columnas)}) VALUES ({','.join(['?' for _ in columnas])})"
    for fila in datos:
        cursor.execute(query, fila)
    conn.commit()

# Cargar datos
dim_producto = pd.read_csv('DimProducto.csv').values.tolist()
dim_cliente = pd.read_csv('DimCliente.csv').values.tolist()
dim_vendedor = pd.read_csv('DimVendedor.csv').values.tolist()
dim_tiempo = pd.read_csv('DimTiempo.csv').values.tolist()
fact_ventas = pd.read_csv('FactVentas.csv').values.tolist()

# Insertar en las tablas
insertar('DimProducto', ['id_producto', 'nombre_producto', 'categoria', 'marca'], dim_producto)
insertar('DimCliente', ['id_cliente', 'nombre_cliente', 'ciudad', 'pais'], dim_cliente)
insertar('DimVendedor', ['id_vendedor', 'nombre_vendedor', 'region'], dim_vendedor)
insertar('DimTiempo', ['id_tiempo', 'fecha', 'dia', 'mes', 'año', 'trimestre'], dim_tiempo)
insertar('FactVentas', ['id_venta', 'id_tiempo', 'id_producto', 'id_cliente', 'id_vendedor', 'cantidad', 'precio_unitario', 'total'], fact_ventas)

# Cerrar conexión
cursor.close()
conn.close()
