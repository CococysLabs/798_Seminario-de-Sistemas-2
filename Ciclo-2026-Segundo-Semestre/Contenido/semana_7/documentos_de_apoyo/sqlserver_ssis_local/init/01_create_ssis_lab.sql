IF DB_ID(N'$(APP_DB)') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [' + N'$(APP_DB)' + N']');
END;
GO

IF SUSER_ID(N'$(APP_LOGIN)') IS NULL
BEGIN
    EXEC(N'CREATE LOGIN [' + N'$(APP_LOGIN)' + N'] WITH PASSWORD = ''$(APP_PASSWORD)'', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF');
END;
GO

DECLARE @db_name sysname = N'$(APP_DB)';
DECLARE @user_name sysname = N'$(APP_LOGIN)';
DECLARE @sql nvarchar(max);

SET @sql = N'
USE [' + @db_name + N'];

IF USER_ID(N''' + @user_name + N''') IS NULL
BEGIN
    CREATE USER [' + @user_name + N'] FOR LOGIN [' + @user_name + N'];
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
    INNER JOIN sys.database_principals mp ON drm.member_principal_id = mp.principal_id
    WHERE rp.name = N''db_owner''
      AND mp.name = N''' + @user_name + N'''
)
BEGIN
    ALTER ROLE [db_owner] ADD MEMBER [' + @user_name + N'];
END;

IF SCHEMA_ID(N''staging'') IS NULL
BEGIN
    EXEC(N''CREATE SCHEMA [staging]'');
END;

IF OBJECT_ID(N''dbo.Clientes'', N''U'') IS NULL
BEGIN
    CREATE TABLE dbo.Clientes
    (
        ClienteID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Nombre nvarchar(100) NOT NULL,
        Correo nvarchar(200) NULL,
        FechaRegistro datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;

IF OBJECT_ID(N''staging.ClientesRaw'', N''U'') IS NULL
BEGIN
    CREATE TABLE staging.ClientesRaw
    (
        Nombre nvarchar(100) NOT NULL,
        Correo nvarchar(200) NULL,
        FechaCarga datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Clientes)
BEGIN
    INSERT INTO dbo.Clientes (Nombre, Correo)
    VALUES
        (N''Ada Lovelace'', N''ada@example.com''),
        (N''Grace Hopper'', N''grace@example.com''),
        (N''Margaret Hamilton'', N''margaret@example.com'');
END;
';

EXEC(@sql);
GO
