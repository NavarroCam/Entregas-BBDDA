--Cam ☻
---------------------------------------- SP CALCULAR INTERESES Y DEUDA TABLA ESTADO DE CUENTAS ------------------------------
--ESTO IRIA EN LA CONSULTA DE "GenerarObjetos.sql"
CREATE OR ALTER PROCEDURE tp.SP_CalcularInteresesYDeuda
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tp.EstadodeCuenta
    SET 
        InteresPorMora1V = SaldoAnterior * 0.02,  -- Calcula el interés por mora del 1° vencimiento como el 2% del saldo anterior
        InteresPorMora2V = CASE                     -- Calcula el interés del 2° vencimiento (5%) 
                              WHEN PagoRecibido < SaldoAnterior 
                              THEN (SaldoAnterior - PagoRecibido) * 0.05   -- solo si el pago recibido es menor que el saldo anterior.
                              ELSE 0    -- Si no hay mora (pago completo o mayor), el interés es 0.
                           END,
        -- Calcula la deuda total:
        Deuda = (SaldoAnterior - PagoRecibido)
                + (SaldoAnterior * 0.02)
                + CASE 
                     WHEN PagoRecibido < SaldoAnterior THEN (SaldoAnterior - PagoRecibido) * 0.05
                     ELSE 0
                  END
                + ImporteCochera
                + ImporteBaulera;
END;
GO


--ESTO IRIA EN LA CONSULTA DE "InsertarDatos.sql"
EXEC tp.SP_CalcularInteresesYDeuda;




--ESTO IRIA EN LA CONSULTA DE "GenerarObjetos.sql" 
-- PASO 1 ####### GENERAR DATOS ADMINISTRACION 

use  Com5600G06

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.ImportarAdministracion_00') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.ImportarAdministracion_00 AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

CREATE OR ALTER PROCEDURE tp.ImportarAdministracion_00
AS
BEGIN
	INSERT INTO tp.Administracion (Nombre, Direccion, CorreoElectronico, Telefono)
	VALUES   ('ADMINISTRACION DE CONSORCIOS ALTOS DE SAINT JUST', 'FLORENCIO VARELA 1900', 'SAINT.JUST@email.com', '1157736960')
END;
GO

EXEC tp.ImportarAdministracion_00

SELECT * FROM tp.Administracion



--PASO 2 ####### SP IMPORTAR DATOS DEL CONSORCIO

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.ImportarConsorcio_01') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.ImportarConsorcio_01 AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

CREATE OR ALTER PROCEDURE tp.ImportarConsorcio_01
@RutaArchivo NVARCHAR(260)
AS
BEGIN

    SET NOCOUNT ON;

    -- Tabla temporal para staging
    CREATE TABLE #ConsorcioTemp (
        ID_Consorcio VARCHAR(15),
        Nombre VARCHAR(30),
        Direccion VARCHAR(50),
        CantUF INT,
        SuperficieTotal DECIMAL(8,2)
    );

	 -- Importar archivo CSV
	 DECLARE @Sql NVARCHAR(MAX);
	 SET @Sql = '
		BULK INSERT #ConsorcioTemp
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		 FIRSTROW = 2
		);';

	EXEC(@Sql);

	SELECT * FROM #ConsorcioTemp

    -- Obtener ID_Administracion (ejemplo: el primero disponible)
    DECLARE @ID_Administracion INT;
    SELECT TOP 1 @ID_Administracion = ID_Administracion FROM tp.Administracion;

    -- Insertar evitando duplicados
    INSERT INTO tp.Consorcio (ID_Consorcio, Nombre, Direccion, CantUF, SuperficieTotal, ID_Administracion)
    SELECT t.ID_Consorcio, t.Nombre, t.Direccion, t.CantUF, t.SuperficieTotal, @ID_Administracion
    FROM #ConsorcioTemp t
    /*WHERE NOT EXISTS (
        SELECT 1 FROM tp.Consorcio c WHERE c.Nombre = t.Nombre
    );
	*/

END;
GO

EXEC tp.ImportarConsorcio_01 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\datos varios.csv'
EXEC tp.ImportarConsorcio_01 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\datos varios.CSV'

SELECT * FROM tp.Consorcio

--PASO 3 ####### SP DE IMPORTACION DE UNIDAD FUNCIONAL TXT 

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'TP.ImportarUnidadFuncional_02 ') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE TP.ImportarUnidadFuncional_02 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE TP.ImportarUnidadFuncional_02
@RutaArchivo NVARCHAR(260)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TEMP (
		 NombreConsorcio VARCHAR(30),
		 NUM_UNIDAD_FUNCIONAL INT,
		 PISO VARCHAR(10),
		 DEPARTAMENTO CHAR(3),
		 COEFICIENTE VARCHAR(5),
		 M2_UNIDAD_FUNCIONAL VARCHAR(10),
		 BAULERA VARCHAR(5),
		 COCHERA VARCHAR(5),
		 M2_BAULERA VARCHAR(10),
		 M2_COCHERA VARCHAR(10));
	
		DECLARE @Sql NVARCHAR(MAX);

		SET @Sql = '
		BULK INSERT #Temp
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = ''\t'',  -- tabulador
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2,            -- salta encabezado
		CODEPAGE = ''65001''  );'; -- UTF-8
		
		
		EXEC(@Sql);

		INSERT INTO tp.UnidadFuncional ( ID_UF, NombreConsorcio, Piso, Departamento, PorcentajeProrrateo, M2_Unidad, Baulera, Cochera, M2_Baulera, M2_Cochera)
		SELECT NUM_UNIDAD_FUNCIONAL, NombreConsorcio,PISO,DEPARTAMENTO, 
		 CAST(REPLACE(COEFICIENTE, ',', '.') AS DECIMAL(5,2)) ,
		M2_UNIDAD_FUNCIONAL,BAULERA,COCHERA,
		CAST(M2_BAULERA AS INT),
		CAST(M2_COCHERA AS INT)
		FROM (
				SELECT *,
				ROW_NUMBER() OVER(PARTITION BY NUM_UNIDAD_FUNCIONAL,NombreConsorcio ORDER BY NUM_UNIDAD_FUNCIONAL) AS PRIMERO
				FROM #Temp
				WHERE NUM_UNIDAD_FUNCIONAL IS NOT NULL) SUB
		WHERE SUB.PRIMERO = 1;

		DROP TABLE #TEMP

END
   
EXEC  TP.ImportarUnidadFuncional_02 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT'

select * from tp.UnidadFuncional

-- PASO 4 ####### SP DE IMPORTACION DATOS PROPIETARIOS E INQUILINOS

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPropietariosInquilinos_03') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPropietariosInquilinos_03 AS BEGIN SET NOCOUNT ON; END')
END
GO

create or ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinos_03
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE #TempDatos (
    Nombre VARCHAR(100),
    apellido VARCHAR(100),
    DNI int ,
    email_personal VARCHAR(100),
    teléfono_de_contacto char (10),
    CVU_CBU varchar(50),
    boleano bit
	);

	 -- Importar archivo CSV
	 DECLARE @Sql NVARCHAR(MAX);
	 SET @Sql = '
		BULK INSERT #TempDatos 
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		 FIRSTROW = 2
		);';

	EXEC(@Sql);


	-- insertamos inquilinos 1
	INSERT INTO tp.inquilino(Nombres,apellido,DNI_Inquilino,CorreoElectronico,telefono,CVU_CBU)
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),
	        CAST(CAST(cvu_cbu AS FLOAT) AS DECIMAL(38,0))-- ltrim saca espacios de la izquierda                 #############################################################
    FROM (  SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
		    ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			FROM #TempDatos
		    WHERE boleano = 1
		  ) sub
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.Inquilino i WHERE i.DNI_inquilino = sub.DNI);

	-- insertamos propietarios 0
	INSERT INTO tp.Propietario(Nombres,apellido,DNI_Propietario,CorreoElectronico,telefono,CVU_CBU)
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),
			CAST(CAST(cvu_cbu AS FLOAT) AS DECIMAL(38,0))-- ltrim saca espacios de la izquierda           #########################################################
    FROM (   SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
			 ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			 FROM #TempDatos
			 WHERE boleano = 0
		 ) sub --- la sub sirve para que no inserte duplicados del archivo csv 
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.propietario i WHERE i.DNI_propietario = sub.DNI);--- sirve para no insertar duplicados que ya tenia en mi tabla

	DROP TABLE #TempDatos;

end
go


EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\ecgam\Documents\GuadalupeUnlam\BaseDeDatosAplicadas\TP_BaseDeDatosAplicadas\Grupo06\consorcios\Inquilino-propietarios-datos.csv'
EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Inquilino-propietarios-datostransfromado.csv'

select * from tp.Inquilino
select * from tp.Propietario

delete from tp.Inquilino
delete from tp.propietario

--PASO 5 ##### 

create or ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinosUnidadFuncional
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE #TempDatos (
    CVU_CBU VARCHAR(30),
    NOMBRE_CONSORCIO VARCHAR(100),
    NUM_UNIDAD_FUNCIONAL INT,
    PISO VARCHAR(5),
    Departamento VARCHAR(5)
   );

   	 -- Importar archivo CSV
	 DECLARE @Sql NVARCHAR(MAX);
	 SET @Sql = '
		BULK INSERT #TempDatos 
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = ''|'',
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2
		);';

	EXEC(@Sql);

	SELECT * FROM #TEMPDATOS  ----- PARA VER QUE IMPORTO BIEN 

	INSERT INTO tp.UnidadFuncional(ID_UF,DNI_Propietario,NombreConsorcio,piso, departamento)
	select t.NUM_UNIDAD_FUNCIONAL,p.DNI_Propietario,c.Nombre,t.piso,t.Departamento
	from #TEMPDATOS t
	inner join tp.Consorcio C on c.Nombre=t.NOMBRE_CONSORCIO
	inner join tp.propietario P on P.CVU_CBU=t.CVU_CBU

	DROP TABLE #TempDatos;
END


EXEC tp.sp_ImportarPropietariosInquilinosUnidadFuncional 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-UF.CSV'

SELECT * FROM TP. UNIDADFUNCIONAL

/*CREATE or ALTER TRIGGER tp.tr_CalcularSaldoAlCierre
ON tp.EstadoFinanciero
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE EF
    SET EF.SaldoAlCierre =  EF.SaldoAnterior  + EF.IngresoPagoEnTermino + EF.IngresoPagoAdeudado  + EF.IngresoPagoAdelantado  - EF.EgresoGastoMensual
    FROM tp.EstadoFinanciero EF
    INNER JOIN inserted i ON EF.ID_EF = i.ID_EF;

END;
GO

CREATE OR ALTER PROCEDURE TP.GENERAR_ESTADO_FINANCIERO --- se forma men
AS
BEGIN
	INSERT INTO tp.EstadoFinanciero (ID_EF,SaldoAnterior, IngresoPagoEnTermino, IngresoPagoAdeudado, IngresoPagoAdelantado, EgresoGastoMensual)
	VALUES
	(1,15000.00, 3000.00, 500.00, 0.00, 2500.00),
	(2,20000.00, 2500.00, 1200.00, 300.00, 2800.00),
	(3,12000.00, 4000.00, 800.00, 100.00, 3100.00),
	(4,18000.00, 3500.00, 600.00, 400.00, 2900.00),
	(5,10000.00, 5000.00, 1500.00, 200.00, 4200.00);

END
go*/

exec TP.GENERAR_ESTADO_FINANCIERO 

SELECT * FROM tp.EstadoFinanciero;

--PASO 3 ##### GENERAR DATOS CONSORCIO PARA QUE LA UNIDAD FUNCIONAL TENGA NOMBRE QUE HEREDAR DEBIDO A QUE ESTE TIENE UNA CLAVE COMPUESTA PRIMARIA
--############ PERO DESPUES HABRIA QUE CALCULAR LA SUPERFICIE TOTAL EN CONSORCIO CON OTRO STORE PROCEDURE MAS ADELANTE SON SOLO 5 CONSORCIOS
--############ ESTO IRIA EN LA CONSULTA DE "InsertarDatos.sql"



EXEC TP.GENERAR_CONSORCIO

SELECT * FROM TP.Consorcio C
INNER JOIN TP.Administracion A ON A.ID_Administracion=C.ID_Administracion

--PASO 4 ##### DEBIDO A QUE EN UN MOMENTO VAMOS A CARGAR LAS UNIDADES FUNCIONALES DEBERIAMOS DE TENER UN 
--		#### TRIGGER QUE CALCULE LA SUPP TOTAL DE LOS CONSORCIOS






SELECT * FROM TP.UnidadFuncional
ORDER BY NombreConsorcio







--PASO 7 ####### SP IMPORTACION DE DNI PROPIETARIO A UNIDAD FUNCIONAL



-- PASO 8 ##### 
