/*  
ENTREGA 6 – Reportes y API
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

Notación y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importación
 - cspr -> Creacion de Store Procedures de Reportes

*/


USE Com5600G06

-- REPORTE 1
/* Se desea analizar el flujo de caja en forma semanal. Debe presentar la recaudación por
pagos ordinarios y extraordinarios de cada semana, el promedio en el periodo, y el
acumulado progresivo.*/

EXEC cspr.sp_AnalizarFlujoCajaSemanal_00 
    @FechaInicio = '2025-04-01',
    @FechaFin = '2025-04-30',
    @NombreConsorcio = 'Azcuenaga';
GO



-- REPORTE 2
/* Presente el total de recaudación por mes y departamento en formato de tabla cruzada. */


-- REPORTE 3
/* Presente un cuadro cruzado con la recaudación total desagregada según su procedencia
(ordinario, extraordinario, etc.) según el periodo. */



-- REPORTE 4
/* Obtenga los 5 (cinco) meses de mayores gastos y los 5 (cinco) de mayores ingresos. */



-- REPORTE 5
/* Obtenga los 3 (tres) propietarios con mayor morosidad. Presente información de contacto y
DNI de los propietarios para que la administración los pueda contactar o remitir el trámite al
estudio jurídico.*/

EXEC cspr.SP_Reporte_Top3Morosos_04 
    @FechaDesde = '2025-03-01', 
    @FechaHasta = '2025-06-30', 
    @TipoPersona = 0;
GO


-- REPORTE 6
/* Muestre las fechas de pagos de expensas ordinarias de cada UF y la cantidad de días que
pasan entre un pago y el siguiente, para el conjunto examinado.*/



--API

EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Alberdi'; 
GO
EXEC cspr.sp_FichaInformacionConsorcio_06 @NombreConsorcio = 'Azcuenaga'; 
GO