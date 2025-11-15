USE Com5600G06
GO

--permisos Administrativo general--

exec csps.sp_ActualizacionDeDatosUF_00 'Rol_AdministrativoGeneral'
exec csps.sp_GeneracionReportes_02 'Rol_AdministrativoGeneral'


--permisos Administrativo Bancario--

exec csps.sp_ImportacionInformacionBancaria_01 'Rol_AdministrativoBancario'
exec csps.sp_GeneracionReportes_02 'Rol_AdministrativoBancario'

--permisos Administrativo Operativo--

exec csps.sp_ActualizacionDeDatosUF_00 'Rol_AdministrativoOperativo'
exec csps.sp_GeneracionReportes_02 'Rol_AdministrativoOperativo'

--permisos del Sistema--

exec csps.sp_GeneracionReportes_02 'Rol_Sistemas'


SELECT
    perms.state_desc AS State,
    permission_name AS [Permission],
    obj.name AS [on Object],
    dp.name AS [to User Name]
FROM sys.database_permissions AS perms
JOIN sys.database_principals AS dp
    ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects AS obj
    ON perms.major_id = obj.object_id;