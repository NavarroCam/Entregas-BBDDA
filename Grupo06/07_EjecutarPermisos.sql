/*Entrega 7 - Requisitos de seguridad
Asigne los roles correspondientes para poder cumplir con este requisito, según el área a la
cual pertenece.
*/

/*
FECHA DE ENTREGA: 21/11/2025
NRO DE COMISION: 02-5600
NRO DE GRUPO: GRUPO 06
NOMBRE DE LA MATERIA: BASE DE DATOS APLICADAS

NOMBRE, APELLIDO,  DNI Y NICK DE LOS INTEGRANTES:
Juchani Javier Andres-36938637-jajuchani 
Maria Jose Mariscal-92869937-majomariscal 
Navarro Ojeda Camila Micaela-44689707-NavarroCam 
Franchetti Luciana-42775831-LuFranchetti 
Jaureguiberry Facundo Agustin-42056476-JaureFacu 
Gambaro Lartigue Guadalupe-45206331-GuadaGambaro

Notacion y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importacion
 - cspr -> Creacion de Store Procedures de Reportes
 - csps -> Creacion de Store Procedure de Seguridad
*/

USE Com5600G06
GO


-- ==============  Permisos Administrativo General  =======================

EXEC csps.sp_ActualizacionDeDatosUF_00 'Rol_AdministrativoGeneral'
EXEC csps.sp_GeneracionReportes_02 'Rol_AdministrativoGeneral'


-- ==============  Permisos Administrativo Bancario  =======================

EXEC csps.sp_ImportacionInformacionBancaria_01 'Rol_AdministrativoBancario'
EXEC csps.sp_GeneracionReportes_02 'Rol_AdministrativoBancario'


-- ==============  Permisos Administrativo Operativo  =======================

EXEC csps.sp_ActualizacionDeDatosUF_00 'Rol_AdministrativoOperativo'
EXEC csps.sp_GeneracionReportes_02 'Rol_AdministrativoOperativo'


-- ==============  Permisos del Sistema  =======================

EXEC csps.sp_GeneracionReportes_02 'Rol_Sistemas'


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