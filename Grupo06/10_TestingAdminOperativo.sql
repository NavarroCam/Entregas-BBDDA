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

-- Actualiza datos en UF

update ct.UnidadFuncional set M2_Unidad=97
GO


-- Generar Reportes

EXEC cspr.SP_Reporte_SecuenciaPagosXML_05
    @FechaDesde = '2025-04-01', 
    @FechaHasta = '2025-04-30', 
    @NombreConsorcio = 'Azcuenaga';
GO


-- Importacion de informacion bancaria (error)

insert into ct.MantenimientoCtaBancaria(EntidadBanco, Importe) values('entidad', 96)
GO