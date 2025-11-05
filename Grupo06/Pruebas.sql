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



--PASO 2 ####### SP IMPORTAR DATOS DEL CONSORCIO




--BUSCAR FORMA OPTIMIZADA DE PONER LA RUTA


--PASO 3 ####### SP DE IMPORTACION DE UNIDAD FUNCIONAL TXT 


   


-- PASO 4 ####### SP DE IMPORTACION DATOS PROPIETARIOS E INQUILINOS


--PASO 5 ##### 

create or ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinosUnidadFuncional
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
USE Com5600G06
	CREATE TABLE #TempDatos (
    ROW_NUMBER(), CVU_CBU VARCHAR(22),
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

	EXEC(@Sql);  --Tabla temporal con toda la info del archivo 
	--NombreConsorcio, NroUFuncional, Piso, Depto

	SELECT * FROM #TEMPDATOS  ----- PARA VER QUE IMPORTO BIEN 

	INSERT INTO tp.UnidadFuncional(CVU_CBU)
	select t.CVU_CBU
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


-- Javi	 @@@@@@@@@@

-- cargar las expensas por nombre de consorcio

GO
CREATE OR ALTER FUNCTION tp.fn_NormalizarImporte(@importe NVARCHAR(30))
RETURNS DECIMAL(15, 2)
AS
BEGIN
    DECLARE @valor NVARCHAR(30);
    DECLARE @entero NVARCHAR(30);
    DECLARE @decimales NVARCHAR(2);
	DECLARE @resultado DECIMAL(15, 2)

    SET @valor = REPLACE(REPLACE(@importe, ',', ''), '.', '');

    IF LEN(@valor) > 2
    BEGIN
        SET @entero = LEFT(@valor, LEN(@valor) - 2);
        SET @decimales = RIGHT(@valor, 2);
        SET @valor = @entero + '.' + @decimales;
    END
    ELSE
    BEGIN
        SET @valor = @valor + '.00';
    END

    SET @resultado = TRY_CAST(@valor AS DECIMAL(15, 2));

	RETURN ISNULL(@resultado, 0)
END;
GO

GO
CREATE OR ALTER FUNCTION tp.fn_ObtenerFechaEmision(
	@mes VARCHAR(10),
	@anio INT
)
RETURNS SMALLDATETIME
AS
BEGIN
    DECLARE @fecha SMALLDATETIME;
    DECLARE @mesInt INT;

	IF @anio IS NULL
		SET @anio = YEAR(GETDATE());

    SET @mesInt =
        CASE LOWER(@mes)
            WHEN 'enero' THEN 1
            WHEN 'febrero' THEN 2
            WHEN 'marzo' THEN 3
            WHEN 'abril' THEN 4
            WHEN 'mayo' THEN 5
            WHEN 'junio' THEN 6
            WHEN 'julio' THEN 7
            WHEN 'agosto' THEN 8
            WHEN 'septiembre' THEN 9
            WHEN 'octubre' THEN 10
            WHEN 'noviembre' THEN 11
            WHEN 'diciembre' THEN 12
        END;

    SET @fecha = TRY_CONVERT(SMALLDATETIME,
        CONCAT(@anio, '-', FORMAT(@mesInt, '00'), '-05')
    );

    RETURN @fecha;
END
GO

-- Vista para ver los datos
GO
CREATE OR ALTER VIEW tp.vw_GastosPorExpensa
AS
	SELECT ex.NombreConsorcio, ex.FechaEmision, ex.TotalAPagar
		, gg.Importe AS Gasto_General, ga.Importe AS Gasto_Administracion
		, sp.ImporteAgua AS Agua, sp.ImporteLuz AS Luz, sp.ImporteInternet AS Internet
		, s.Importe AS Seguro
		-- falta importe limpieza, cargar tabla!
		--, mcb.Importe AS Mant_Cta_Bancaria	Falta Cargar!!
	FROM tp.Expensa ex
	INNER JOIN tp.GastoGeneral gg ON ex.ID_Expensa=gg.ID_Expensa
	INNER JOIN tp.GastoAdministracion ga ON ex.ID_Expensa=ga.ID_Expensa
	INNER JOIN tp.ServicioPublico sp ON ex.ID_Expensa=sp.ID_Expensa
	INNER JOIN tp.Seguro s ON ex.ID_Expensa=s.ID_Expensa
	--INNER JOIN tp.Limpieza l ON ex.ID_Expensa=l.ID_Expensa
	--INNER JOIN tp.MantenimientoCtaBancaria mcb ON ex.ID_Expensa=mcb.ID_Expensa
GO

go
CREATE OR ALTER PROCEDURE tp.sp_importarGastosOrdinarios
	@rutaArchivo VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NRO_Factura INT, @ID_Expensa INT, @ID_UF INT, @cantidad INT, @i INT = 1
		, @NombreConsorcio VARCHAR(20)
		, @Mes CHAR(12)
		, @Bancarios DECIMAL(12, 2)
		, @Limpieza DECIMAL(12, 2)
		, @Administracion DECIMAL(12, 2)
		, @Seguros DECIMAL(12, 2)
		, @GastoGeneral DECIMAL(12, 2)
		, @Agua DECIMAL(12, 2)
		, @Luz DECIMAL(12, 2)
		, @Internet DECIMAL(12, 2)

	IF OBJECT_ID('tempdb..#GastosTemp') IS NOT NULL DROP TABLE #GastosTemp;
	
	CREATE TABLE #GastosTemp(
		NumeroRegistro INT,
		NombreConsorcio VARCHAR(30),
		Mes CHAR(12),
		Bancarios VARCHAR(30),
		Limpieza VARCHAR(30),
		Administracion VARCHAR(30),
		Seguros VARCHAR(30),
		GastoGeneral VARCHAR(30),
		Agua VARCHAR(30),
		Luz VARCHAR(30),
		Internet VARCHAR(30)
	);

	DECLARE @sql NVARCHAR(MAX);

	SET @sql = N'
	INSERT INTO #GastosTemp(NumeroRegistro, NombreConsorcio, Mes, Bancarios, Limpieza, Administracion, Seguros, GastoGeneral, Agua, Luz, Internet)
	SELECT
		ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NumeroRegistro,
		NombreConsorcio
		, Mes, Bancarios, Limpieza, Administracion, Seguros, GastoGeneral, Agua, Luz, Internet
	FROM OPENROWSET (BULK ''' + @rutaArchivo + ''', SINGLE_CLOB) AS j
	CROSS APPLY OPENJSON(BulkColumn)
	WITH (
		NombreConsorcio VARCHAR(30) ''$."Nombre del consorcio"'',
		Mes CHAR(12) ''$."Mes"'',
		Bancarios VARCHAR(30) ''$."BANCARIOS"'',
		Limpieza VARCHAR(30) ''$."LIMPIEZA"'',
		Administracion VARCHAR(30) ''$."ADMINISTRACION"'',
		Seguros VARCHAR(30) ''$."SEGUROS"'',
		GastoGeneral VARCHAR(30) ''$."GASTOS GENERALES"'',
		Agua VARCHAR(30) ''$."SERVICIOS PUBLICOS-Agua"'',
		Luz VARCHAR(30) ''$."SERVICIOS PUBLICOS-Luz"'',
		Internet VARCHAR(30) ''$."SERVICIOS PUBLICOS-Internet"''
	);'

	EXEC sp_executesql @sql;

	SET @cantidad = (SELECT COUNT(*) FROM #GastosTemp);

	WHILE @i <= @cantidad
	BEGIN
		SELECT 
			@NombreConsorcio = NombreConsorcio
			, @Mes = Mes
			, @Bancarios = tp.fn_NormalizarImporte(Bancarios)
			, @Limpieza = tp.fn_NormalizarImporte(Limpieza)
			, @Administracion = tp.fn_NormalizarImporte(Administracion)
			, @Seguros = tp.fn_NormalizarImporte(Seguros)
			, @GastoGeneral = tp.fn_NormalizarImporte(GastoGeneral)
			, @Agua = tp.fn_NormalizarImporte(Agua)
			, @Luz = tp.fn_NormalizarImporte(Luz)
			, @Internet = tp.fn_NormalizarImporte(Internet)
		FROM #GastosTemp
		WHERE NumeroRegistro=@i 

		-- va id de unidad funcional en la tabla?
		SET @ID_UF = (SELECT TOP 1 ID_UF FROM tp.UnidadFuncional uf
			INNER JOIN tp.Consorcio c ON uf.NombreConsorcio=c.Nombre
			WHERE c.Nombre=@NombreConsorcio
		)

		DECLARE @propietario INT = 232850890	-- hardcodeado, va propietario en la tabla?
		DECLARE @inquilino INT = 232359550	-- hardcodeado va inquilino en la tabla?

		DECLARE @fechaEmision SMALLDATETIME
		SET @fechaEmision = tp.fn_ObtenerFechaEmision(@Mes, YEAR(GETDATE()))

		IF @ID_UF IS NOT NULL
		BEGIN
			-- El primer venc es a los 7 dias despues de la fecha de emision, y el segundo a los 14 como ejemplo
			INSERT INTO tp.Expensa(FechaEmision, TotalAPagar, PrimerFechaVencimiento, SegundaFechaVencimiento, ID_UF, NombreConsorcio, DNI_Propietario, DNI_Inquilino)
				VALUES (@fechaEmision, 0, DATEADD(DAY, 7, @fechaEmision), DATEADD(DAY, 14, @fechaEmision), @ID_UF, @NombreConsorcio, @propietario, @inquilino)			-- Corregir vencimientos

			SET @ID_Expensa = SCOPE_IDENTITY();

			/*	Revisar!!! no olvidar sumar al total
			INSERT INTO tp.MantenimientoCtaBancaria(NRO_Cuenta, EntidadBanco, Importe, ID_Expensa)
				VALUES ()
			*/
			-- INSERT INTO tp.Limpieza(ID_Expensa, Tipo) VALUES (@ID_Expensa, 'S')		-- revisar!! no olvidar sumar al total

			SELECT @NRO_Factura = ISNULL(MAX(NRO_Factura), 0) + 1 FROM tp.GastoAdministracion;
			INSERT INTO tp.GastoAdministracion(NRO_Factura, Importe, ID_Expensa) VALUES (@NRO_Factura, @Administracion, @ID_Expensa)
			UPDATE tp.Expensa SET TotalAPagar = TotalAPagar + @Administracion WHERE ID_Expensa=@ID_Expensa

			SELECT @NRO_Factura = ISNULL(MAX(NRO_Factura), 0) + 1 FROM tp.Seguro;
			INSERT INTO tp.Seguro(NRO_Factura, NombreEmpresaSeguro, Importe, ID_Expensa) VALUES (@NRO_Factura, 'nombreEmpresaSeguros', @Seguros, @ID_Expensa)	-- va nombre de empresa de seguro en la tabla Seguro?
			UPDATE tp.Expensa SET TotalAPagar = TotalAPagar + @Seguros WHERE ID_Expensa=@ID_Expensa

			SELECT @NRO_Factura = ISNULL(MAX(NRO_Factura), 0) + 1 FROM tp.GastoGeneral;
			INSERT INTO tp.GastoGeneral(NRO_Factura, NombreEmpresa, NombrePersona, Importe, ID_Expensa)
				VALUES (@NRO_Factura, 'nombreEmpresa', 'nombrePersona', @GastoGeneral, @ID_Expensa)		-- que va en nombre de Persona en la tabla gasto general?
			UPDATE tp.Expensa SET TotalAPagar = TotalAPagar + @GastoGeneral WHERE ID_Expensa=@ID_Expensa

			SELECT @NRO_Factura = ISNULL(MAX(NRO_Factura), 0) + 1 FROM tp.ServicioPublico;
			INSERT INTO tp.ServicioPublico(NRO_Factura, ImporteLuz, ImporteAgua, ImporteInternet, ID_Expensa)
				VALUES (@NRO_Factura, @Luz, @Agua, @Internet, @ID_Expensa)
			UPDATE tp.Expensa SET TotalAPagar = TotalAPagar + @Luz + @Agua WHERE ID_Expensa=@ID_Expensa
		END
        SET @i = @i + 1;
	END
	DROP TABLE #GastosTemp
END

go
EXEC tp.sp_importarGastosOrdinarios 'C:\Users\Javier\Desktop\prueba\Grupo06\archivos\Servicios.Servicios.json'

GO
SELECT * FROM tp.vw_GastosPorExpensa