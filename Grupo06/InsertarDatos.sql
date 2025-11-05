--Importar datos administración

EXEC tp.ImportarAdministracion_00

SELECT * FROM tp.Administracion

--Importar datos consorcio
--EXEC tp.ImportarConsorcio_01 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\datos varios.csv'
EXEC tp.ImportarConsorcio_01 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios.CSV'
--EXEC tp.ImportarConsorcio_01 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\datos varios.CSV'
--EXEC tp.ImportarConsorcio_01 '/tmp/datos varios.csv'


SELECT * FROM tp.Consorcio

--Importar datos unidad funcional txt
EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT'
EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\UF por consorcio.TXT'


select * from tp.UnidadFuncional

--Importar datos propietarios e inquilinos
--EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
EXEC tp.sp_ImportarPropietariosInquilinos_03 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
EXEC tp.sp_ImportarPropietariosInquilinos_03'C:\Users\majo_\Documents\Bdaa25\Tp_Aplicada2025\Entregas-BBDDA\consorcios\Inquilino-propietarios-datos.csv'


select * from tp.Inquilino
select * from tp.Propietario
