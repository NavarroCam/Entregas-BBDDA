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



----------------------------------------SP IMPORTACION DE DATOS TABLA ADMINISTRACION------------------------------


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

    -- Tabla temporal para cargar el archivo
    CREATE TABLE #TempDatos (
        Nombre VARCHAR(30),
        Apellido VARCHAR(30),
        DNI INT,
        Email VARCHAR(50),
        Telefono CHAR(10),
        CVU_CBU CHAR(22),
        Inquilino BIT
    );

    -- Importar archivo CSV
    DECLARE @sql NVARCHAR(MAX) = '
        BULK INSERT #TempDatos     
        FROM ''' + @RutaArchivo + '''
        WITH (
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';
    EXEC sp_executesql @sql;

    -- Insertar en Propietario (Inquilino = 0)
    INSERT INTO tp.Propietario (DNI_Propietario, Apellido, Nombres, CorreoElectronico, Telefono, CVU_CBU)
    SELECT DNI, Apellido, Nombre, Email, Telefono, CVU_CBU
    FROM #TempDatos
    WHERE Inquilino = 0
      AND NOT EXISTS (SELECT 1 FROM tp.Propietario p WHERE p.DNI_Propietario = #TempDatos.DNI);

    -- Insertar en Inquilino (Inquilino = 1)
    INSERT INTO tp.Inquilino (DNI_Inquilino, Apellido, Nombres, CorreoElectronico, Telefono, CVU_CBU)
    SELECT DNI, Apellido, Nombre, Email, Telefono, CVU_CBU
    FROM #TempDatos
    WHERE Inquilino = 1
      AND NOT EXISTS (SELECT 1 FROM tp.Inquilino i WHERE i.DNI_Inquilino = #TempDatos.DNI);

    DROP TABLE #TempDatos;

END;
GO

EXEC tp.sp_ImportarPropietariosInquilinos '\\DESKTOP-JKOJ5PF\consorcios\Inquilino-propietarios-datos.csv'

SELECT* FROM tp.Propietario


--Majo
