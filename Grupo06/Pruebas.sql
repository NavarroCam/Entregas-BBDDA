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





-- PASO 1#### GENERAR DATOS ADMINISTRACION ###### SP IMPORTACION DE DATOS TABLA ADMINISTRACION
--ESTO IRIA EN LA CONSULTA DE "GenerarObjetos.sql" 

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.ImportarAdministracion') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.ImportarAdministracion AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

use  Com5600G06

CREATE OR ALTER PROCEDURE TP.GENERAR_ADMINISTRACION
AS
BEGIN

    SET NOCOUNT ON; --NO MUESTRA LAS FILAS AFECTADAS. MEJORA EL RENDIMIENTO

    DECLARE @Cantidad INT = 10 --NUMERO ALEATORIO ENTRE 3 Y 10


    INSERT INTO tp.Administracion (Nombre, Direccion, CorreoElectronico, Telefono)
    SELECT TOP (@Cantidad) * --SELECCIONA UN CANTIDAD ALEATORIA DE FILAS
    FROM (
        VALUES
            ('Admin Uno', 'Calle 123', 'admin1@email.com', '1111111111'),
            ('Admin Dos', 'Av. Siempre Viva', 'admin2@email.com', '2222222222'),
            ('Admin Tres', 'Calle Falsa 456', 'admin3@email.com', '3333333333'),
            ('Admin Cuatro', 'Diagonal 74', 'admin4@email.com', '4444444444'),
            ('Admin Cinco', 'Ruta 8 KM 45', 'admin5@email.com', '5555555555'),
            ('Admin Seis', 'Calle 9', 'admin6@email.com', '6666666666'),
            ('Admin Siete', 'Av. Libertador', 'admin7@email.com', '7777777777'),
            ('Admin Ocho', 'Calle 10', 'admin8@email.com', '8888888888'),
            ('Admin Nueve', 'Calle 11', 'admin9@email.com', '9999999999'),
            ('Admin Diez', 'Calle 12', 'admin10@email.com', '1010101010')

    ) AS Datos (Nombre, Direccion, CorreoElectronico, Telefono)

    WHERE NOT EXISTS (
        SELECT 1 FROM tp.Administracion a WHERE a.Nombre = Datos.Nombre --EVITA DATOS DUPLICADOS
    )
    ORDER BY NEWID(); --PERMITE ALEATORIEDAD
	--- DEBEMOS INSERTAR EL NOMBRE PRINCIPAL DE NUESTRA EMPRESA EN UN REGISTRO, ESTE REGISTRO SERA ESPECIFICO
	INSERT INTO tp.Administracion (Nombre, Direccion, CorreoElectronico, Telefono)
	VALUES   ('ADMINISTRACION DE CONSORCIOS ALTOS DE SAINT JUST', 'FLORENCIO VARELA 1900', 'SAINT.JUST@email.com', '1157736960')
END;
GO

EXEC TP.GENERAR_ADMINISTRACION

SELECT * FROM TP.Administracion

--PASO 2 ##### GENERAR DATOS PARA ESTADO FINANCIERO PARA QUE EL CONSORCIO TENGA UN ID DE ESTADO FINANCIERO QUE HEREDAR

CREATE or ALTER TRIGGER tp.tr_CalcularSaldoAlCierre
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
go

exec TP.GENERAR_ESTADO_FINANCIERO 

SELECT * FROM tp.EstadoFinanciero;

--PASO 3 ##### GENERAR DATOS CONSORCIO PARA QUE LA UNIDAD FUNCIONAL TENGA NOMBRE QUE HEREDAR DEBIDO A QUE ESTE TIENE UNA CLAVE COMPUESTA PRIMARIA
--############ PERO DESPUES HABRIA QUE CALCULAR LA SUPERFICIE TOTAL EN CONSORCIO CON OTRO STORE PROCEDURE MAS ADELANTE SON SOLO 5 CONSORCIOS
--############ ESTO IRIA EN LA CONSULTA DE "InsertarDatos.sql"

CREATE OR ALTER PROCEDURE TP.GENERAR_CONSORCIO
AS
BEGIN
	INSERT INTO tp.Consorcio (Nombre, Direccion, SuperficieTotal, ID_Administracion, ID_EF)
	VALUES 
	('Azcuenaga', 'Dirección Azcuenaga', NULL,11,1),
	('Alzaga', 'Dirección Alzaga', NULL,11, 2),
	('Alberdi', 'Dirección Alberdi', NULL,11,3),
	('Unzue', 'Dirección Unzue', NULL,11,4),
	('Pereyra Iraola', 'Dirección Pereyra Iraola', NULL,11,5);
END

EXEC TP.GENERAR_CONSORCIO

SELECT * FROM TP.Consorcio C
INNER JOIN TP.Administracion A ON A.ID_Administracion=C.ID_Administracion

--PASO 4 ##### DEBIDO A QUE EN UN MOMENTO VAMOS A CARGAR LAS UNIDADES FUNCIONALES DEBERIAMOS DE TENER UN 
--		#### TRIGGER QUE CALCULE LA SUPP TOTAL DE LOS CONSORCIOS

CREATE OR ALTER TRIGGER TR_CALCULAR_SUPERFICIE_TOTAL_CONSORCIO
ON tp.UnidadFuncional
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualiza la superficie total de los consorcios involucrados
    UPDATE c
    SET c.SuperficieTotal = sub.TotalSuperficie
    FROM tp.Consorcio c
    INNER JOIN (
        SELECT NombreConsorcio,SUM(ISNULL(M2_Unidad,0) + ISNULL(M2_BAULERA,0) + ISNULL(M2_COCHERA,0)) AS TotalSuperficie
        FROM tp.UnidadFuncional
        GROUP BY NombreConsorcio
    ) AS sub
    ON c.Nombre = sub.NombreConsorcio;

END;
GO


--PASO 5 ############## SP DE IMPORTACION DE UNIDAD FUNCIONAL TXT 

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'TP.SP_IMPORTAR_UNIDAD_FUNCIONAL_POR_CONSORCIO ') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE TP.SP_IMPORTAR_UNIDAD_FUNCIONAL_POR_CONSORCIO AS BEGIN SET NOCOUNT ON; END')
END
GO


CREATE OR ALTER PROCEDURE TP.SP_IMPORTAR_UNIDAD_FUNCIONAL_POR_CONSORCIO 
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
   

EXEC  TP.SP_IMPORTAR_UNIDAD_FUNCIONAL_POR_CONSORCIO 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\UF por consorcio.TXT'

SELECT * FROM TP.UnidadFuncional
ORDER BY NombreConsorcio


--PASO 6 #### SP IMPORTACION DE DATOS TABLA PROPIETARIOS E INQUILINOS

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPropietariosInquilinos') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPropietariosInquilinos AS BEGIN SET NOCOUNT ON; END')
END
GO

create or ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinos
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

EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'

select * from tp.Inquilino
select * from tp.Propietario

delete from tp.inquilino
delete from tp.propietario

--PASO 7 ####### SP IMPORTACION DE DNI PROPIETARIO A UNIDAD FUNCIONAL

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

-- PASO 8 ##### 
