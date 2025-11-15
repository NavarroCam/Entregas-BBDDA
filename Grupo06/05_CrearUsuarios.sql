USE Com5600G06
GO

-- Eliminar Login

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'AdministrativoGeneral')
    DROP LOGIN [AdministrativoGeneral];
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'AdministrativoBancario')
    DROP LOGIN [AdministrativoBancario];
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'AdministrativoOperativo')
    DROP LOGIN [AdministrativoOperativo];
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Sistemas')
    DROP LOGIN [Sistemas];
GO

-- Elimina los usuarios

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdministrativoGeneral' AND type IN ('S', 'U', 'G'))
    DROP USER [AdministrativoGeneral];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdministrativoBancario' AND type IN ('S', 'U', 'G'))
    DROP USER [AdministrativoBancario];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdministrativoOperativo' AND type IN ('S', 'U', 'G'))
    DROP USER [AdministrativoOperativo];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Sistemas' AND type IN ('S', 'U', 'G'))
    DROP USER [Sistemas];
GO

-- Elimina Roles

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_AdministrativoGeneral' AND type = 'R')
    DROP ROLE [Rol_AdministrativoGeneral];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_AdministrativoBancario' AND type = 'R')
    DROP ROLE [Rol_AdministrativoBancario];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_AdministrativoOperativo' AND type = 'R')
    DROP ROLE [Rol_AdministrativoOperativo];
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Sistemas' AND type = 'R')
    DROP ROLE [Rol_Sistemas];
GO

-- Creacion

CREATE LOGIN AdministrativoGeneral   
   WITH PASSWORD = 'Altos1'
	,CHECK_POLICY = on
go 

CREATE LOGIN AdministrativoBancario   
   WITH PASSWORD = 'Altos2'
	,CHECK_POLICY = on
go 

CREATE LOGIN AdministrativoOperativo   
   WITH PASSWORD = 'Altos3'
	,CHECK_POLICY = on
go 

CREATE LOGIN Sistemas   
   WITH PASSWORD = 'Altos4'
	,CHECK_POLICY = on
go 

CREATE USER AdministrativoGeneral FOR LOGIN AdministrativoGeneral WITH DEFAULT_SCHEMA = [ct];
CREATE USER AdministrativoBancario FOR LOGIN AdministrativoBancario WITH DEFAULT_SCHEMA = [ct];
CREATE USER AdministrativoOperativo FOR LOGIN AdministrativoOperativo WITH DEFAULT_SCHEMA = [ct];
CREATE USER Sistemas FOR LOGIN Sistemas WITH DEFAULT_SCHEMA = [ct];
GO

CREATE ROLE Rol_AdministrativoGeneral;
CREATE ROLE Rol_AdministrativoBancario;
CREATE ROLE Rol_AdministrativoOperativo;
CREATE ROLE Rol_Sistemas;

GO
ALTER ROLE Rol_AdministrativoGeneral ADD MEMBER AdministrativoGeneral;
ALTER ROLE Rol_AdministrativoOperativo ADD MEMBER AdministrativoOperativo;
ALTER ROLE Rol_AdministrativoBancario ADD MEMBER AdministrativoBancario;
ALTER ROLE Rol_Sistemas ADD MEMBER Sistemas;

SELECT
    Rol.name AS Nombre_del_Rol,
    Miembro.name AS Usuario_Miembro
FROM 
    sys.database_role_members AS drm
INNER JOIN 
    sys.database_principals AS Rol ON drm.role_principal_id = Rol.principal_id
INNER JOIN 
    sys.database_principals AS Miembro ON drm.member_principal_id = Miembro.principal_id
WHERE
    Rol.name IN ('Rol_AdministrativoGeneral', 'Rol_AdministrativoBancario', 'Rol_AdministrativoOperativo', 'Rol_Sistemas')
ORDER BY 
    Nombre_del_Rol, Usuario_Miembro;
GO