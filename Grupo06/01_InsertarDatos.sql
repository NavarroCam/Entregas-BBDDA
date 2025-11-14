/*
Entrega 5: 
Base de datos lineamientos generales
Se requiere que importe toda la información antes mencionada a la base de datos:
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
• Considere este comportamiento al generar el código. Debe admitir la importación de
novedades periódicamente sin eliminar los datos ya cargados y sin generar
duplicados.
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
realicen tareas por fuera de un SP. Se proveerán archivos para importar en MIEL.
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
estructura requerida. Estas adaptaciones deberán hacerla en la DB y no en los
archivos provistos.
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
en la fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
interpretarlo como JSON o CSV, pero los hemos verificado cuidadosamente).
Tener en cuenta que para la ampliación del software no existen datos; se deben
preparar los datos de prueba necesarios para cumplimentar los requisitos planteados.
• El código fuente no debe incluir referencias hardcodeadas a nombres o ubicaciones
de archivo. Esto debe permitirse ser provisto por parámetro en la invocación. En el
código de ejemplo se verá dónde el grupo decidió ubicar los archivos, pero si cambia
el entorno de ejecución debería adaptarse sin modificar el fuente (sí obviamente el
script de testing). La configuración escogida debe aparecer en comentarios del
módulo.
• El uso de SQL dinámico no está exigido en forma explícita… pero puede que
encuentre que es la única forma de resolver algunos puntos. No abuse del SQL
dinámico, deberá justificar su uso siempre.
• Respecto a los informes XML: no se espera que produzcan un archivo nuevo en el
filesystem, basta con que el resultado de la consulta sea XML.
• Se espera que apliquen en todo el trabajo las pautas consignadas en la Unidad 3
respecto a optimización de código y de tipos de datos.
*/

/*
FECHA DE ENTREGA: 7/11/2025
NRO DE COMISION: 02-5600
NRO DE GRUPO: GRUPO 06
NOMBRE DE LA MATERIA: BASE DE DATOS APLICADAS

NOMBRE, APELLIDO,  DNI Y NICK DE LOS INTEGRANTES:
• Juchani Javier Andres-36938637-jajuchani 
• Maria Jose Mariscal-92869937-majomariscal 
• Navarro Ojeda Camila Micaela-44689707-NavarroCam 
• Franchetti Luciana-42775831-LuFranchetti 
• Jaureguiberry Facundo Agustin-42056476-JaureFacu 
• Gambaro Lartigue Guadalupe-45206331-GuadaGambaro


ACLARACION IMPORTANTE SOBRE UBICACION DE LOS ARCHIVOS PROVISTOS:

• SI A LA CARPETA DONDE SE ENCUENTRA EL PROYECTO ("Grupo06") SE LA NOMBRA "TP_Base_de_datos_aplicada"
(DENTRO DE ELLA DEBE EXISTIR UNA CARPETA LLAMADA "consorcios" DONDE SE ENCUENTRAN LOS ARCHIVOS A IMPORTAR)
Y SE LA COLOCA EN EL DISCO C SE PUEDEN USAR TODAS LAS RUTAS A CONTINUACION.

• El archivo de "datos varios.xlsx" lo guardamos como "datos varios.csv" (CONSORCIOS-HOJA 1) y "datos varios proveedores.csv" (PROVEEDORES-HOJA 2) 
ya que nos estaba resultando complicando importar este archivo con extension .xlsx
*/

USE Com5600G06

-- 1) Importar datos administración

EXEC csp.sp_ImportarAdministracion_00


-- 2) Importar datos consorcio

EXEC csp.sp_ImportarConsorcio_01 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios.CSV'


-- 3)Importar datos unidad funcional txt

EXEC  csp.sp_ImportarUnidadFuncional_02 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT' 


-- 4) Importar datos propietarios e inquilinos

EXEC csp.sp_ImportarPersonas_03 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'


-- 5) Cargar cbu a unidad funcional

EXEC csp.sp_ImportarPropietariosInquilinosUnidadFuncional_04 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-UF.csv'


-- 6) IMPORTAR DATOS A PAGO

EXEC csp.sp_ImportarPagos_05 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\pagos_consorcios.csv'


--- 7) IMPORTAR FORMATO JSON EL PRIMER MES ESPECIFICAR EL MES EN EL STORE PROCEDURE EJEMPLO 1 = ENERO EN ESTE CASO INSERTAMOS EL MES 4

EXEC csp.sp_ImportarServicios_06 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Servicios.Servicios.json',4;


-- 8) Cargar Gastos Extraordinarios manualmente

EXEC csp.sp_CargarGastoExtraordinarioManual_07;


-- 9) SP CARGAR AL IMPORTE TOTAL EL COSTO DE LAS BAULERAS Y COCHERAS A CADA CONSORCIO, CADA CONSORCIO TIENE COSTOS DIFERENTES DE M2 POR COCHERA Y BAULERA POR ESO PIDE 3 PARAMETROS 
--	INDICAR EL MES AL PRINCIPIO

EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Alberdi';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Alzaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Azcuenaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Pereyra Iraola';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Unzue';


-- 10) SP PARA AGREGAR EL ID EXPENSA EN LA TABLA PAGOS hacerlo cada vez que se importa un nuevo mes de la importacion de servicios

EXEC csp.SP_RellenarPagoConIdExpensa_09


-- 11) SP PARA RELLENAR ESTADO FINANCIERO CON LOS PAGOS INGRESADOS 

EXEC csp.SP_RellenarEstadoFinancieroIngresos_12 4


-- 12) SP CARGAR TABLA ESTADO DE CUENTA INDICAR NUMERO DE MES COSTE DE M2 POR BAULERA, COCHERA Y DECIR SI ES LA PRIMERA VEZ QUE SE CARGA LA TABLA CON 1 = VERDADERO,
--		POR ULTIMO INDICAR EL NOMBRE DEL CONSORCIO DEBIDO A QUE NO TODOS LOS CONSORCIOS TIENEN LO MISMO EN M2 DE COCHERAS Y BAULERAS

EXEC csp.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Alberdi'
EXEC csp.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Alzaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Azcuenaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Pereyra Iraola'
EXEC csp.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Unzue'


-- 13) HAY QUE SUMAR LA DEUDA DE LA ANTERIOIR EXPENSA A LAS EXPENSAS DE ABRIL TOTAL A PAGAR

EXEC csp.sp_SumarDeudaExpensasTotalAPagar_11 1,135


-- 14) IMPORTAR FORMATO JSON EL SEGUNDO MES

EXEC csp.sp_ImportarServicios_06 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Servicios.Servicios.json',5;


-- 15) SP CARGAR AL IMPORTE TOTAL EL COSTO DE LAS BAULERAS Y COCHERAS SEGUNDO MES

EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 5,1200,1200,'Alberdi';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 5,1200,1200,'Alzaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 5,1200,1200,'Azcuenaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 5,1200,1200,'Pereyra Iraola';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 5,1200,1200,'Unzue';


-- 16) SP PARA AGREGAR EL ID EXPENSA EN LA TABLA PAGOS hacerlo cada vez que se importa un nuevo mes de la importacion de servicios

EXEC csp.SP_RellenarPagoConIdExpensa_09


-- 17) SP PARA RELLENAR ESTADO FINANCIERO CON LOS PAGOS INGRESADOS 

EXEC csp.SP_RellenarEstadoFinancieroIngresos_12 5


-- 18) SP CARGAR TABLA ESTADO DE CUENTA

EXEC csp.SP_GenerarEstadoDeCuentA_10 5,1000,1000,0,'Alberdi'
EXEC csp.SP_GenerarEstadoDeCuentA_10 5,1000,1000,0,'Alzaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 5,1000,1000,0,'Azcuenaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 5,1000,1000,0,'Pereyra Iraola'
EXEC csp.SP_GenerarEstadoDeCuentA_10 5,1000,1000,0,'Unzue'


-- 19) HAY QUE SUMAR LA DEUDA DE LA ANTERIOIR EXPENSA A LAS EXPENSAS DE MAYO TOTAL A PAGAR

EXEC csp.sp_SumarDeudaExpensasTotalAPagar_11 136,270


-- 20) IMPORTAR FORMATO JSON EL TERCER MES

EXEC csp.sp_ImportarServicios_06 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Servicios.Servicios.json',6;


-- 21) SP CARGAR AL IMPORTE TOTAL EL COSTO DE LAS BAULERAS Y COCHERAS SEGUNDO MES

EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 6,1200,1200,'Alberdi';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 6,1200,1200,'Alzaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 6,1200,1200,'Azcuenaga';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 6,1200,1200,'Pereyra Iraola';
EXEC csp.SP_SumarCocheraBauleraAImporteTotalExpensas_08 6,1200,1200,'Unzue';


-- 22) SP PARA AGREGAR EL ID EXPENSA EN LA TABLA PAGOS hacerlo cada vez que se importa un nuevo mes de la importacion de servicios

EXEC csp.SP_RellenarPagoConIdExpensa_09


-- 23) SP PARA RELLENAR ESTADO FINANCIERO CON LOS PAGOS INGRESADOS 

EXEC csp.SP_RellenarEstadoFinancieroIngresos_12 6


-- 24) HAY QUE SUMAR LA DEUDA DE LA ANTERIOIR EXPENSA A LAS EXPENSAS DE MAYO TOTAL A PAGAR

EXEC csp.sp_SumarDeudaExpensasTotalAPagar_11 271,405


-- 25) SP CARGAR TABLA ESTADO DE CUENTA

EXEC csp.SP_GenerarEstadoDeCuentA_10 6,1000,1000,0,'Alberdi'
EXEC csp.SP_GenerarEstadoDeCuentA_10 6,1000,1000,0,'Alzaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 6,1000,1000,0,'Azcuenaga'
EXEC csp.SP_GenerarEstadoDeCuentA_10 6,1000,1000,0,'Pereyra Iraola'
EXEC csp.SP_GenerarEstadoDeCuentA_10 6,1000,1000,0,'Unzue'


-- 26) Agregar nombre de empresa a Limpieza y Seguro

EXEC csp.sp_ActualizarNombresProveedoresLimpiezaSeguro_13 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios proveedores.csv'

SELECT * FROM ct.Administracion FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.Consorcio FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.EstadodeCuenta FOR XML AUTO, ELEMENTS;

SELECT *,
LAG(SALDOALCIERRE,1,0) OVER (PARTITION BY NOMBRECONSORCIO ORDER BY ID_EF) AS SaldoAnterior

FROM ct.EstadoFinanciero
FOR XML AUTO, ELEMENTS;

SELECT * FROM ct.Expensa FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.GastoAdministracion FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.GastoExtraordinario FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.GastoGeneral FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.Limpieza FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.MantenimientoCtaBancaria FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.Pago FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.Persona FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.Seguro FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.ServicioPublico FOR XML AUTO, ELEMENTS;
SELECT * FROM ct.UnidadFuncional FOR XML AUTO, ELEMENTS;

/*
SELECT * FROM ct.Expensa
SELECT * FROM ct.GastoAdministracion
SELECT * FROM ct.GastoExtraordinario
SELECT * FROM ct.GastoGeneral
SELECT * FROM ct.Limpieza
SELECT * FROM ct.MantenimientoCtaBancaria
SELECT * FROM ct.Pago
SELECT * FROM ct.Persona
SELECT * FROM ct.Seguro
SELECT * FROM ct.ServicioPublico
SELECT * FROM ct.UnidadFuncional
SELECT * FROM ct.Consorcio
*/