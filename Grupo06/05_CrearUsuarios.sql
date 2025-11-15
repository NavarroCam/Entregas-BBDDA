USE Com5600G06
GO

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

ALTER ROLE Rol_AdministrativoGeneral ADD MEMBER AdministrativoGeneral;
ALTER ROLE Rol_AdministrativoOperativo ADD MEMBER AdministrativoOperativo;
ALTER ROLE Rol_AdministrativoBancario ADD MEMBER AdministrativoBancario;
ALTER ROLE Rol_Sistemas ADD MEMBER Sistemas;

SELECT SRM.role_principal_id, SP.name AS Role_Name,   
SRM.member_principal_id, SP2.name  AS Member_Name  
FROM sys.server_role_members AS SRM  
JOIN sys.server_principals AS SP  
    ON SRM.Role_principal_id = SP.principal_id  
JOIN sys.server_principals AS SP2   
    ON SRM.member_principal_id = SP2.principal_id  
ORDER BY  SP.name,  SP2.name 
