/*
Entrega 7 - Requisitos de Seguridad
Por otra parte, se requiere que apliquen cifrado a datos sensibles/personales incluidos en el
sistema. Lea el material de la unidad 6 disponible en Miel para determinar qué datos en su
implementación encajan con esa descripción.
El cifrado tendrán que aplicarlo a posteriori de la realización de las funciones que manejen
los datos mencionados. Por ello tendrán que incorporar scripts de modificación de estructuras
de datos, modificación sobre store procedures y vistas y tal vez creación de triggers u otro
mecanismo para implementar el cifrado. Este cambio realizado al sistema es “en un solo
sentido” y se entiende que al aplicarlo no es reversible. Notar que también deberán modificar
los reportes que presenten información cifrada para que sea legible.
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
 - csps -> Creacion de Store Procedure de Segurida
 - cspc -> Creacion de Store Procedure de Cifrado
*/

USE Com5600G06

EXEC cspc.sp_ActualizarEstructuraYHashing

SELECT * FROM ct.Persona
 
SELECT * FROM ct.UnidadFuncional

SELECT * FROM ct.Pago

EXEC cspr.SP_Reporte_Top3Morosos_04 
    @FechaDesde = '2025-03-01', 
    @FechaHasta = '2025-06-30', 
    @TipoPersona = 0;
GO