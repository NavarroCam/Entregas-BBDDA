USE Com5600G06
-- 1) Importar datos administración

EXEC tp.sp_ImportarAdministracion_00


-- 2) Importar datos consorcio

-- #### SI A LA CARPETA LA LLAMAN TP_Base_de_datos_aplicada Y LO PEGAN EN EL DISCO C PUEDEN USAR TODAS LAS RUTAS DESMARCADAS #####

EXEC tp.sp_ImportarConsorcio_01 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios.CSV'

--EXEC tp.ImportarConsorcio_01 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\datos varios.csv'
--EXEC tp.ImportarConsorcio_01 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\datos varios.CSV'
--EXEC tp.ImportarConsorcio_01 '/tmp/datos varios.csv'
--EXEC tp.sp_ImportarConsorcio_01 'C:\Users\Camila Navarro\Grupo06\consorcios\datos varios.CSV'


-- 3)Importar datos unidad funcional txt

EXEC  tp.sp_ImportarUnidadFuncional_02 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT' 

--EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\UF por consorcio.TXT'
--EXEC  tp.sp_ImportarUnidadFuncional_02 'C:\Users\Camila Navarro\Grupo06\consorcios\UF por consorcio.TXT'

 

-- 4) Importar datos propietarios e inquilinos

EXEC tp.sp_ImportarPersonas_03 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
--EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
--EXEC tp.sp_ImportarPropietariosInquilinos_03'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\Inquilino-propietarios-datos.csv'
--EXEC tp.sp_ImportarPersonas_03 'C:\Users\Camila Navarro\Grupo06\consorcios\Inquilino-propietarios-datos.csv'


-- 5) Cargar cbu a unidad funcional

EXEC tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-UF.csv'
--EXEC tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04 'C:\Users\Camila Navarro\Grupo06\consorcios\Inquilino-propietarios-UF.csv'

--select * from tp.UnidadFuncional

-- 6) IMPORTAR DATOS A PAGO

EXEC tp.sp_ImportarPagos_05 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\pagos_consorcios.csv'

--EXEC tp.sp_ImportarPagos_05 'C:\Users\Camila Navarro\Grupo06\consorcios\pagos_consorcios.csv'

--select * 
--from tp.Pago
--FOR XML AUTO, ELEMENTS;

--- 7) IMPORTAR FORMATO JSON EL PRIMER MES ESPECIFICAR EL MES EN EL STORE PROCEDURE EJEMPLO 1 = ENERO

EXEC tp.sp_ImportarServicios_06 'C:\TP_Base_de_datos_aplicada\Grupo06\consorcios\Servicios.Servicios.json',4;
--EXEC tp.sp_ImportarServicios_06 'C:\Users\Camila Navarro\Grupo06\consorcios\Servicios.Servicios.json'

-- 8) Cargar Gastos Extraordinarios manualmente

EXEC tp.sp_CargarGastoExtraordinarioManual_07;

-- 9) SP CARGAR AL IMPORTE TOTAL EL COSTO DE LAS BAULERAS Y COCHERAS A CADA CONSORCIO, CADA CONSORCIO TIENE COSTOS DIFERENTES DE M2 POR COCHERA Y BAULERA POR ESO PIDE 3 PARAMETROS 
--	INDICAR EL MES AL PRINCIPIO

EXEC TP.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Alberdi';
EXEC TP.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Alzaga';
EXEC TP.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Azcuenaga';
EXEC TP.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Pereyra Iraola';
EXEC TP.SP_SumarCocheraBauleraAImporteTotalExpensas_08 4,1000,1000,'Unzue';

-- 10) SP PARA AGREGAR EL ID EXPENSA EN LA TABLA PAGOS DEL PRIMER MES, INDICAR MES, EN ESTE CASO 4 = ABRIL

EXEC TP.SP_RellenarPagoConIdExpensa_09

-- 11) SP CARGAR TABLA ESTADO DE CUENTA INDICAR NUMERO DE MES COSTE DE M2 POR BAULERA, COCHERA Y DECIR SI ES LA PRIMERA VEZ QUE SE CARGA LA TABLA CON 1 = VERDADERO,
--		POR ULTIMO INDICAR EL NOMBRE DEL CONSORCIO DEBIDO A QUE NO TODOS LOS CONSORCIOS PARA LO MISMO EN M2 DE COCHERAS Y BAULERAS

EXEC TP.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Alberdi'
EXEC TP.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Alzaga'
EXEC TP.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Azcuenaga'
EXEC TP.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Pereyra Iraola'
EXEC TP.SP_GenerarEstadoDeCuentA_10 4,1000,1000,1,'Unzue'




SELECT * FROM TP.Administracion FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Consorcio FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.EstadodeCuenta FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.EstadoFinanciero FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Expensa FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.GastoAdministracion FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.GastoExtraordinario FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.GastoGeneral FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Limpieza FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.MantenimientoCtaBancaria FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Pago FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Persona FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.Seguro FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.ServicioPublico FOR XML AUTO, ELEMENTS;
SELECT * FROM TP.UnidadFuncional FOR XML AUTO, ELEMENTS;
