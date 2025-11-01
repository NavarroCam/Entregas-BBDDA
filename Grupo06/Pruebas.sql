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




-- Lu (~-~)
-- jaure UWU :3 
-- Javi



--Guada


----------------------------------------SP IMPORTACION DE DATOS TABLA ADMINISTRACION------------------------------


--ESTO IRIA EN LA CONSULTA DE "GenerarObjetos.sql"

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.ImportarAdministracion') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.ImportarAdministracion AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

ALTER PROCEDURE tp.ImportarAdministracion
AS
BEGIN

    SET NOCOUNT ON; --NO MUESTRA LAS FILAS AFECTADAS. MEJORA EL RENDIMIENTO

    DECLARE @Cantidad INT = FLOOR(RAND() * 8) + 3; --NUMERO ALEATORIO ENTRE 3 Y 10


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
END;
GO


--ESTO IRIA EN LA CONSULTA DE "InsertarDatos.sql"

EXEC tp.ImportarAdministracion



----------------------------------------SP IMPORTACION DE DATOS TABLA PROPIETARIOS E INQUILINOS------------------------------


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPropietariosInquilinos') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPropietariosInquilinos AS BEGIN SET NOCOUNT ON; END')
END
GO

ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinos
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para datos crudos
    CREATE TABLE #TempDatos (
        Nombre VARCHAR(100),
        Apellido VARCHAR(100),
        DNI VARCHAR(20),
        Email VARCHAR(100),
        Telefono VARCHAR(20),
        CVU_CBU VARCHAR(50),
        Inquilino BIT
    );

    -- Cargar CSV
    DECLARE @sql NVARCHAR(MAX) = '
        BULK INSERT #TempDatos
        FROM ''' + @RutaArchivo + '''
        WITH (
           FIELDTERMINATOR = '','',
           ROWTERMINATOR = ''\r\n'',
           FIRSTROW = 2,
           CODEPAGE = ''65001'',
           TABLOCK
        );';
    EXEC sp_executesql @sql;

    -- Insertar Propietarios
    INSERT INTO tp.Propietario (DNI_Propietario, Apellido, Nombres, CorreoElectronico, Telefono, CVU_CBU)
    SELECT
        CAST(DNI AS INT),
        LTRIM(RTRIM(Apellido)),
        LTRIM(RTRIM(Nombre)),
        LTRIM(RTRIM(Email)),
        RIGHT('0000000000' + Telefono, 10),
        LEFT(REPLACE(REPLACE(CVU_CBU, ',', ''), 'E+021', ''), 22)
    FROM #TempDatos
    WHERE Inquilino = 0
      AND NOT EXISTS (SELECT 1 FROM tp.Propietario p WHERE p.DNI_Propietario = #TempDatos.DNI);

    -- Insertar Inquilinos
    INSERT INTO tp.Inquilino (DNI_Inquilino, Apellido, Nombres, CorreoElectronico, Telefono, CVU_CBU)
    SELECT
        CAST(DNI AS INT),
        LTRIM(RTRIM(Apellido)),
        LTRIM(RTRIM(Nombre)),
        LTRIM(RTRIM(Email)),
        RIGHT('0000000000' + Telefono, 10),
        LEFT(REPLACE(REPLACE(CVU_CBU, ',', ''), 'E+021', ''), 22)
    FROM #TempDatos
    WHERE Inquilino = 1
      AND NOT EXISTS (SELECT 1 FROM tp.Inquilino i WHERE i.DNI_Inquilino = #TempDatos.DNI);

    DROP TABLE #TempDatos;
END;
GO

--######################################################################################################################################################################

EXEC tp.sp_ImportarPropietariosInquilinos 'C:\Users\Administrator\Desktop\TP_Base_de_datos_aplicada\Grupo06\consorcios\Inquilino-propietarios-datos.csv'

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
    CVU_CBU varchar(22),
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
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),sub.CVU_CBU -- ltrim saca espacios de la izquierda
    FROM (  SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
		    ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			FROM #TempDatos
		    WHERE boleano = 1
		  ) sub
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.Inquilino i WHERE i.DNI_inquilino = sub.DNI);

	-- insertamos propietarios 0
	INSERT INTO tp.Propietario(Nombres,apellido,DNI_Propietario,CorreoElectronico,telefono,CVU_CBU)
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),sub.CVU_CBU -- ltrim saca espacios de la izquierda
    FROM (   SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
			 ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			 FROM #TempDatos
			 WHERE boleano = 0
		 ) sub --- la sub sirve para que no inserte duplicados del archivo csv 
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.propietario i WHERE i.DNI_propietario = sub.DNI);

	DROP TABLE #TempDatos;

end
go

select * from tp.Inquilino
select * from tp.Propietario

delete from tp.inquilino
delete from tp.propietario