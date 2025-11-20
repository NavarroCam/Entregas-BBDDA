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


-- Generacion de reportes
EXEC cspr.sp_RecaudacionDesagregadaPorProcedencia_02
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-12-31',
    @TipoPeriodo = 'MENSUAL';
GO


-- Actualizacion de datos UF
UPDATE ct.UnidadFuncional SET M2_Unidad=99


-- Importacion de informacion bancaria (error)

INSERT INTO ct.MantenimientoCtaBancaria(EntidadBanco, Importe) VALUES('entidad', 98)