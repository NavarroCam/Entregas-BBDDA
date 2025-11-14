/*  
ENTREGA 6: Reportes y API
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

Notacion y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importacion
 - cspr -> Creacion de Store Procedures de Reportes

*/

USE Com5600G06

-- REPORTE 1
/* Se desea analizar el flujo de caja en forma semanal. Debe presentar la recaudacion por
pagos ordinarios y extraordinarios de cada semana, el promedio en el periodo, y el
acumulado progresivo.*/

EXEC cspr.sp_AnalizarFlujoCajaSemanal_00 
    @FechaInicio = '2025-04-01',
    @FechaFin = '2025-04-30',
    @NombreConsorcio = 'Azcuenaga';
GO


-- REPORTE 2
/* Presente el total de recaudacion por mes y departamento en formato de tabla cruzada. */

EXEC cspr.sp_RecaudacionPorMesYDepartamento_01  @NombreConsorcio ='Azcuenaga',@AÑO=2025,@MES=4
GO


-- REPORTE 3
/* Presente un cuadro cruzado con la recaudacion total desagregada segun su procedencia
(ordinario, extraordinario, etc.) segun el periodo. */

EXEC cspr.sp_RecaudacionDesagregadaPorProcedencia_02
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-12-31',
    @TipoPeriodo = 'MENSUAL';
GO


-- REPORTE 4
/* Obtenga los 5 (cinco) meses de mayores gastos y los 5 (cinco) de mayores ingresos. */

EXEC cspr.sp_MesesMayorGastoIngreso_03
	@Fechadesde='2025-03-01',
	@FechaHasta = '2025-06-30', 
	@nombreconsorcio= 'Azcuenaga';
GO


-- REPORTE 5
/* Obtenga los 3 (tres) propietarios con mayor morosidad. Presente informacion de contacto y
DNI de los propietarios para que la administracion los pueda contactar o remitir el tramite al
estudio juridico.*/

EXEC cspr.SP_Reporte_Top3Morosos_04 
    @FechaDesde = '2025-03-01', 
    @FechaHasta = '2025-06-30', 
    @TipoPersona = 0;
GO


-- REPORTE 6
/* Muestre las fechas de pagos de expensas ordinarias de cada UF y la cantidad de dias que
pasan entre un pago y el siguiente, para el conjunto examinado.*/

EXEC cspr.SP_Reporte_SecuenciaPagosXML_05
    @FechaDesde = '2025-04-01', 
    @FechaHasta = '2025-04-30', 
    @NombreConsorcio = 'Azcuenaga';


-- API

EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Alberdi'; 
GO
EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Azcuenaga'; 
GO