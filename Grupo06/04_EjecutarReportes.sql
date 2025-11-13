/*  
ENTREGA 6 � Reportes y API
FECHA DE ENTREGA: 14/11/2025
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

Notaci�n y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importaci�n
 - cspr -> Creacion de Store Procedures de Reportes

*/


USE Com5600G06

-- REPORTE 1
/* Se desea analizar el flujo de caja en forma semanal. Debe presentar la recaudaci�n por
pagos ordinarios y extraordinarios de cada semana, el promedio en el periodo, y el
acumulado progresivo.*/

EXEC cspr.sp_AnalizarFlujoCajaSemanal_00 
    @FechaInicio = '2025-04-01',
    @FechaFin = '2025-04-30',
    @NombreConsorcio = 'Azcuenaga';
GO



-- REPORTE 2
/* Presente el total de recaudaci�n por mes y departamento en formato de tabla cruzada. */


-- REPORTE 3
/* Presente un cuadro cruzado con la recaudaci�n total desagregada seg�n su procedencia
(ordinario, extraordinario, etc.) seg�n el periodo. */
PRINT '1. Todos los consorcios - Período mensual:'
EXEC cspr.sp_RecaudacionDesagregadaPorProcedencia_02 
    @FechaInicio = '2025-04-01',
    @FechaFin = '2025-05-01',
    @NombreConsorcio = NULL,
    @ID_Administracion = NULL,
    @TipoPeriodo = 'MENSUAL';
GO


-- REPORTE 4
/* Obtenga los 5 (cinco) meses de mayores gastos y los 5 (cinco) de mayores ingresos. */

EXEC cspr.sp_mesesmayorgastoingreso_04
	@Fechadesde='2025-03-01',
	@FechaHasta = '2025-06-30', 
	@nombreconsorcio= 'Azcuenaga';
GO

--select * from ct.estadofinanciero where nombreconsorcio= 'Azcuenaga'



-- REPORTE 5
/* Obtenga los 3 (tres) propietarios con mayor morosidad. Presente informaci�n de contacto y
DNI de los propietarios para que la administraci�n los pueda contactar o remitir el tr�mite al
estudio jur�dico.*/

EXEC cspr.SP_Reporte_Top3Morosos_04 
    @FechaDesde = '2025-03-01', 
    @FechaHasta = '2025-06-30', 
    @TipoPersona = 0;
GO


-- REPORTE 6
/* Muestre las fechas de pagos de expensas ordinarias de cada UF y la cantidad de d�as que
pasan entre un pago y el siguiente, para el conjunto examinado.*/



--API

EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Alberdi'; 
GO
EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Azcuenaga'; 
GO