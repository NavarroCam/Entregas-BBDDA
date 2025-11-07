-- 1) Importar datos administración

EXEC tp.ImportarAdministracion_00

SELECT * FROM tp.Administracion

-- 2) Importar datos consorcio

--EXEC tp.ImportarConsorcio_01 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\datos varios.csv'
EXEC tp.ImportarConsorcio_01 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios.CSV' -- jaure
--EXEC tp.ImportarConsorcio_01 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\datos varios.CSV'
--EXEC tp.ImportarConsorcio_01 '/tmp/datos varios.csv'

SELECT * FROM tp.Consorcio

-- 3)Importar datos unidad funcional txt

EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT' --jaure
--EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\UF por consorcio.TXT'

select * from tp.UnidadFuncional

-- 4) Importar datos propietarios e inquilinos

--EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
EXEC tp.sp_ImportarPersonas_03 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'--jaure
--EXEC tp.sp_ImportarPropietariosInquilinos_03'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\Inquilino-propietarios-datos.csv'

select * from tp.Persona

-- 5) Cargar cbu a unidad funcional

EXEC tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-UF.csv'

select * from tp.UnidadFuncional

-- 6) IMPORTAR DATOS A PAGO

EXEC tp.sp_ImportarPagos_05 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\pagos_consorcios.csv'

select * 
from tp.Pago
WHERE CVU_CBU=2129873779400220000000

--- 7) IMPORTAR FORMATO JSON

EXEC TP.sp_ImportarFormatoJson_06 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Servicios.Servicios.json'

/*
SELECT * FROM TP.Expensa
SELECT * FROM TP.GastoGeneral
SELECT * FROM TP.GastoAdministracion
SELECT * FROM TP.ServicioPublico
SELECT * FROM TP.Seguro
SELECT * FROM TP.Limpieza
SELECT * FROM TP.EmpresaLimpieza
SELECT * FROM TP.MantenimientoCtaBancaria	*/

-- 8) Cargar Gastos Extraordinarios manualmente

EXEC tp.sp_CargarGastoExtraordinarioManual_06;
select * from tp.GastoExtraordinario
