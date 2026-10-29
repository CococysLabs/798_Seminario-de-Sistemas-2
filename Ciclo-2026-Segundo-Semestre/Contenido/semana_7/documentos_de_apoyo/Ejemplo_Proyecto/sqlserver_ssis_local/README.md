# SQL Server local para SSIS

Este `docker-compose` levanta una instancia de `SQL Server 2022 Developer` utilizable desde Visual Studio y SSIS como origen o destino de datos.

## Limite importante

Docker aqui te resuelve el motor de base de datos (`SQL Server Database Engine`), autenticacion SQL, puerto TCP y una base inicial para pruebas.

No instala el runtime completo de `SQL Server Integration Services` ni `SSISDB`, porque Microsoft no distribuye SSIS completo para contenedores Linux oficiales. Si solo necesitas desarrollar y probar paquetes SSIS conectandote a SQL Server, este entorno si te funciona.

## Archivos

- `docker-compose.yml`: levanta SQL Server 2022 y un contenedor auxiliar que crea la base y el usuario.
- `.env.example`: variables de entorno base.
- `init/01_create_ssis_lab.sql`: crea la base `SSISLab`, un login SQL y tablas de ejemplo.

## Uso

1. Copia `.env.example` a `.env`.
2. Cambia las contrasenas por valores fuertes.
3. Ejecuta:

```powershell
docker compose up -d
```

4. Verifica:

```powershell
docker compose ps
docker compose logs sqlserver-init
```

## Prerequisitos en Windows para SSIS

En tu maquina host, fuera de Docker, necesitas:

- Visual Studio con la extension `SQL Server Integration Services Projects`
- `Microsoft OLE DB Driver for SQL Server` o `ODBC Driver for SQL Server`
- Docker Desktop corriendo

Esos componentes son los que usa SSIS para disenar y abrir conexiones; el contenedor solo hospeda SQL Server.

## Conexion desde SSIS

Usa estos valores en tu `Connection Manager`:

- `Server name`: `localhost,1433`
- `Authentication`: `SQL Server Authentication`
- `User name`: el valor de `APP_LOGIN`
- `Password`: el valor de `APP_PASSWORD`
- `Database`: `SSISLab`

Si usas `OLE DB Driver 19 for SQL Server` o componentes recientes, activa una de estas opciones:

- `Trust server certificate = True`
- o `Encrypt = Optional/False`

Esto evita problemas por el certificado autofirmado del contenedor.

## Datos de prueba creados

El script deja:

- Base `SSISLab`
- Schema `staging`
- Tabla `dbo.Clientes`
- Tabla `staging.ClientesRaw`
- Usuario SQL con permisos `db_owner` sobre `SSISLab`

## Recomendacion para tu proyecto SSIS

Si tu meta es:

- `Desarrollar paquetes y probar conexiones`: este compose es suficiente.
- `Desplegar al catalogo SSISDB y ejecutar paquetes en Integration Services`: necesitas una instalacion de SQL Server en Windows con Integration Services, fuera de Docker.
