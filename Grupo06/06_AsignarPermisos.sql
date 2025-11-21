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


-- ==============  CREACION ESQUEMA SP SEGURIDAD  =======================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'csps')
BEGIN
	EXEC('CREATE SCHEMA csps')
END 
GO



-- ==============  Permiso para actualizacion de datos UF  =======================

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'csps.sp_ActualizacionDeDatosUF_00') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE csps.sp_ActualizacionDeDatosUF_00 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE csps.sp_ActualizacionDeDatosUF_00
	
	@NombreRol VARCHAR(30)

AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @SQLQuery NVARCHAR(MAX);

    SET @SQLQuery = N'GRANT UPDATE ON CT.UnidadFuncional TO [' + @NombreRol + N'];';

    EXEC sp_executesql @SQLQuery;

END
GO



-- ==============  Permiso para importancion de informacion Bancaria  =======================

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'csps.sp_ImportacionInformacionBancaria_01') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE csps.sp_ImportacionInformacionBancaria_01 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE csps.sp_ImportacionInformacionBancaria_01
	@NombreRol VARCHAR(30)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @SQLQuery NVARCHAR(MAX);

    SET @SQLQuery = N'GRANT INSERT ON CT.MantenimientoCtaBancaria TO [' + @NombreRol + N'];';

    EXEC sp_executesql @SQLQuery;
END
GO



-- ==============  Permiso para generacion de reportes  ======================= 

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'csps.sp_GeneracionReportes_02') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE csps.sp_GeneracionReportes_02 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE csps.sp_GeneracionReportes_02
	@NombreRol VARCHAR(30)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @SQLQuery NVARCHAR(MAX);

    SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_AnalizarFlujoCajaSemanal_00 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
	

	SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_RecaudacionPorMesYDepartamento_01 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

	SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_RecaudacionDesagregadaPorProcedencia_02 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;


	SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_MesesMayorGastoIngreso_03 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;


	SET @SQLQuery = N'GRANT EXECUTE ON cspr.SP_Reporte_Top3Morosos_04 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
	
	SET @SQLQuery = N'GRANT EXECUTE ON cspr.SP_Reporte_SecuenciaPagosXML_05 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
END
GO