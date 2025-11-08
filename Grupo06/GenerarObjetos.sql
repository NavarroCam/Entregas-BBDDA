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
Juchani Javier Andres-36938637-jajuchani 
Maria Jose Mariscal-92869937-majomariscal 
Navarro Ojeda Camila Micaela-44689707-NavarroCam 
Franchetti Luciana-42775831-LuFranchetti 
Jaureguiberry Facundo Agustin-42056476-JaureFacu 
Gambaro Lartigue Guadalupe-45206331-GuadaGambaro
*/



USE MASTER

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Com5600G06')
BEGIN
   
   -- Terminar conexiones activas
   ALTER DATABASE [Com5600G06] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   
    -- Eliminar la base
    DROP DATABASE Com5600G06;
END


--CREACION DE BASE DE DATOS
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name='Com5600G06') 
BEGIN
CREATE DATABASE Com5600G06
END
go

ALTER DATABASE Com5600G06 SET MULTI_USER WITH ROLLBACK IMMEDIATE; --- PARA USAR EN VARIAS QUERYS A LA VEZ

USE Com5600G06

--CREACION DE SCHEMA
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'tp')
BEGIN
	EXEC('CREATE SCHEMA tp')
END 
go

---CREACION DE TABLAS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Administracion')
BEGIN

CREATE TABLE tp.Administracion (
 ID_Administracion INT IDENTITY(1,1) PRIMARY KEY,
 Nombre VARCHAR(50) NOT NULL UNIQUE,
 Direccion VARCHAR(50) NOT NULL,
 CorreoElectronico VARCHAR(50) NOT NULL,
 Telefono CHAR(10) NOT NULL CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') 
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Consorcio')
BEGIN

CREATE TABLE tp.Consorcio (
  ID_Consorcio VARCHAR (15),
  Nombre VARCHAR(30) primary key,
  Direccion VARCHAR(50) NOT NULL,
  CantUF INT NOT NULL,
  SuperficieTotal DECIMAL(20,2) NULL,
  ID_Administracion INT NOT NULL,
  CONSTRAINT FK_Administracion FOREIGN KEY (ID_Administracion) REFERENCES tp.Administracion(ID_Administracion)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EstadoFinanciero')
BEGIN

CREATE TABLE tp.EstadoFinanciero (
 ID_EF INT IDENTITY (1,1) PRIMARY KEY,
 Fecha SMALLDATETIME NULL, --
 SaldoAnterior DECIMAL(20,2) DEFAULT (0),
 IngresoPagoEnTermino DECIMAL(20,2) DEFAULT (0),
 IngresoPagoAdeudado DECIMAL(20,2)  DEFAULT (0),
 IngresoPagoAdelantado DECIMAL(20,2) DEFAULT (0),
 EgresoGastoMensual DECIMAL(20,2)   DEFAULT (0),
 SaldoAlCierre DECIMAL(20,2) DEFAULT(0), --VER COMO SE CALCULA (SP, TRIGGER, ETC.)
 NombreConsorcio VARCHAR(30) NOT NULL,
 CONSTRAINT FK_Consorcio FOREIGN KEY (NombreConsorcio) REFERENCES tp.Consorcio(Nombre)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Persona')
BEGIN

CREATE TABLE tp.Persona (
  CVU_CBU varchar(22),
  Tipo bit,
  DNI_Persona INT,
  Apellido VARCHAR(30) NOT NULL,
  Nombres VARCHAR(30) NOT NULL,
  CorreoElectronico VARCHAR(50) NOT NULL,
  Telefono CHAR(10) NOT NULL CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CONSTRAINT PK_Persona PRIMARY KEY (CVU_CBU, Tipo)
);
END
go 
go 


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'UnidadFuncional')
BEGIN

CREATE TABLE tp.UnidadFuncional (
  ID_UF INT,
  NombreConsorcio VARCHAR(30),
  Piso VARCHAR(2) NOT NULL,
  Departamento VARCHAR(3) NOT NULL,
  PorcentajeProrrateo DECIMAL (5,4) NOT NULL,
  M2_Unidad DECIMAL(4,2) NULL,
  Baulera CHAR(2) NOT NULL,
  Cochera CHAR(2) NOT NULL,
  M2_Baulera INT NOT NULL CHECK (M2_BAULERA>=0),
  M2_Cochera INT NOT NULL CHECK (M2_COCHERA>=0),
  CVU_CBU varchar(22),
  Tipo BIT,
  CONSTRAINT PK_UNIDAD_FUNCIONAL PRIMARY KEY (ID_UF,NombreConsorcio),
  CONSTRAINT FK_UF_Consorcio FOREIGN KEY (NombreConsorcio) REFERENCES tp.Consorcio(Nombre),
  CONSTRAINT FK_UF_Persona FOREIGN KEY (CVU_CBU,Tipo) REFERENCES tp.Persona(CVU_CBU,Tipo),
);
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EstadodeCuenta')
BEGIN

CREATE TABLE tp.EstadodeCuenta (
  ID_EstadodeCuenta INT IDENTITY(1,1) PRIMARY KEY,
  Fecha SMALLDATETIME,
  SaldoAnterior DECIMAL(20,2) NOT NULL CHECK(SaldoAnterior >= 0),
  PagoRecibido DECIMAL(20,2) NOT NULL CHECK(PagoRecibido >= 0),
  InteresPorMora1V DECIMAL (20,2) NOT NULL DEFAULT 0,
  InteresPorMora2V DECIMAL (20,2) NOT NULL DEFAULT 0, 
  Deuda DECIMAL(20,2) NOT NULL DEFAULT 0,
  ImporteCochera DECIMAL(20,2) NOT NULL CHECK (ImporteCochera >=0) DEFAULT 0,
  ImporteBaulera DECIMAL(20,2) NOT NULL CHECK (ImporteBaulera >=0) DEFAULT 0,
  ID_UF INT,
  NombreConsorcio VARCHAR(30),
  CONSTRAINT FK_ESTADO_DE_CUENTA FOREIGN KEY (ID_UF,NombreConsorcio) REFERENCES TP.UnidadFuncional (ID_UF,NombreConsorcio)
  );
END
go



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Expensa')
BEGIN

CREATE TABLE tp.Expensa (
  ID_Expensa INT IDENTITY(1,1) PRIMARY KEY,
  FechaEmision SMALLDATETIME NOT NULL,
  TotalAPagar DECIMAL(20,4) NULL,
  PrimerFechaVencimiento SMALLDATETIME NULL,
  SegundaFechaVencimiento SMALLDATETIME NULL,
  ID_UF INT NULL,
  NombreConsorcio VARCHAR(30),
  CONSTRAINT FK_EX_ID_UF FOREIGN KEY (ID_UF,NombreConsorcio) REFERENCES tp.UnidadFuncional(ID_UF,NombreConsorcio),
);
END
go



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'GastoExtraordinario')
BEGIN

CREATE TABLE tp.GastoExtraordinario (
  ID_GastoExtraordinario INT IDENTITY(1,1) PRIMARY KEY,
  Tipo CHAR(1) NOT NULL CHECK(Tipo IN ('R', 'C')),
  Importe DECIMAL(20,4) NOT NULL CHECK (Importe > 0),
  Detalle VARCHAR (100) NOT NULL,
  NroCuota INT NOT NULL,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_GE_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa (ID_Expensa)  
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'GastoGeneral')

BEGIN
CREATE TABLE tp.GastoGeneral (
  NRO_Factura INT IDENTITY(1,1) PRIMARY KEY,
  NombreEmpresa VARCHAR(30) DEFAULT ('EMPRESA DESCONOCIDA'),
  NombrePersona VARCHAR(30) DEFAULT ('PERSONA DESCONOCIDA'),
  Importe DECIMAL(20,2) DEFAULT (0),
  ID_Expensa INT,
  CONSTRAINT FK_GG_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'GastoAdministracion')

BEGIN
CREATE TABLE tp.GastoAdministracion (
  NRO_Factura INT IDENTITY(1,1) PRIMARY KEY,
  Importe DECIMAL(20,2) NOT NULL,
  ID_Expensa INT NULL,
  CONSTRAINT FK_GA_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'ServicioPublico')

BEGIN
CREATE TABLE tp.ServicioPublico (
  NRO_Factura INT IDENTITY(1,1) PRIMARY KEY,
  ImporteLuz DECIMAL(20,2)  DEFAULT 0,
  ImporteAgua DECIMAL(20,2) DEFAULT 0,
  ImporteInternet DECIMAL(20,2) DEFAULT 0,
  ID_Expensa INT  NULL,
  CONSTRAINT FK_SP_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Seguro')

BEGIN
CREATE TABLE tp.Seguro (
  NRO_Factura INT IDENTITY(1,1) PRIMARY KEY,
  NombreEmpresaSeguro VARCHAR(30) DEFAULT ('EMPRESA DESCONOCIDA'),
  Importe DECIMAL(20,2) NULL,
  ID_Expensa INT NULL,
  CONSTRAINT FK_S_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Limpieza')

BEGIN
CREATE TABLE tp.Limpieza (
  NRO_Factura INT IDENTITY(1,1) PRIMARY KEY,
  ID_Expensa INT NULL,
  Importe DECIMAL(20,2) NULL,
  NombreEmpresaLimpieza VARCHAR(30) DEFAULT('SIN NOMBRE'),
  CONSTRAINT FK_L_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'MantenimientoCtaBancaria')

BEGIN
CREATE TABLE tp.MantenimientoCtaBancaria (
  NRO_Cuenta INT IDENTITY(1,1) PRIMARY KEY,
  EntidadBanco VARCHAR(30)  NULL,
  Importe DECIMAL(20,2) NOT NULL,
  ID_Expensa INT NULL,
  CONSTRAINT FK_MCB_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Pago')

BEGIN
CREATE TABLE tp.Pago (
  ID_Pago INT PRIMARY KEY,
  Fecha_Pago DATE NOT NULL,
  Importe DECIMAL (20,4) NOT NULL,
  CVU_CBU VARCHAR(22),
  ID_Expensa INT NULL,
  CONSTRAINT FK_P_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);
END
go


--=======CREACIÓN DE SPs============================================================================

-- 1) SP Importar datos administración
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarAdministracion_00') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarAdministracion_00 AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarAdministracion_00
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM tp.Administracion 
        WHERE Nombre = 'ADMINISTRACION DE CONSORCIOS ALTOS DE SAINT JUST'
    )

    BEGIN

        INSERT INTO tp.Administracion (Nombre, Direccion, CorreoElectronico, Telefono)
        VALUES ('ADMINISTRACION DE CONSORCIOS ALTOS DE SAINT JUST', 'FLORENCIO VARELA 1900', 'SAINT.JUST@email.com', '1157736960')
    END

END;
GO

-- 2) SP Importar datos consorcio
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarConsorcio_01') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarConsorcio_01 AS BEGIN SET NOCOUNT ON; END') --SE NECESITA SQL DINAMICO PORQUE SQL NO PERMITE CREAR UN SP DENTRO DE UN BLOQUE CONDICIONAL DIRECTAMENTE
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarConsorcio_01
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
        SuperficieTotal DECIMAL(20,2)
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

    -- Obtener ID_Administracion (ejemplo: el primero disponible)
    DECLARE @ID_Administracion INT;
    SELECT TOP 1 @ID_Administracion = ID_Administracion FROM tp.Administracion;

    -- Insertar evitando duplicados
    INSERT INTO tp.Consorcio (ID_Consorcio, Nombre, Direccion, CantUF, SuperficieTotal, ID_Administracion)
    SELECT t.ID_Consorcio, t.Nombre, t.Direccion, t.CantUF, t.SuperficieTotal, @ID_Administracion
    FROM #ConsorcioTemp t
    WHERE NOT EXISTS (
        SELECT 1 FROM tp.Consorcio c WHERE c.Nombre = t.Nombre);
	
END;
GO

-- 3) SP Importar datos Unidad Funcional txt

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarUnidadFuncional_02 ') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarUnidadFuncional_02 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarUnidadFuncional_02
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
		CODEPAGE = ''65001''  );';
		
		
		EXEC(@Sql);

		INSERT INTO tp.UnidadFuncional ( ID_UF, NombreConsorcio, Piso, Departamento, PorcentajeProrrateo, M2_Unidad, Baulera, Cochera, M2_Baulera, M2_Cochera)
		SELECT SUB.NUM_UNIDAD_FUNCIONAL, SUB.NombreConsorcio,SUB.PISO,SUB.DEPARTAMENTO, 
		 CAST(REPLACE(SUB.COEFICIENTE, ',', '.') AS DECIMAL(5,2)) ,
		SUB.M2_UNIDAD_FUNCIONAL,SUB.BAULERA,SUB.COCHERA,
		CAST(SUB.M2_BAULERA AS INT),
		CAST(SUB.M2_COCHERA AS INT)
		FROM (
				SELECT *,
				ROW_NUMBER() OVER(PARTITION BY NUM_UNIDAD_FUNCIONAL,NombreConsorcio ORDER BY NUM_UNIDAD_FUNCIONAL) AS PRIMERO
				FROM #Temp
				WHERE NUM_UNIDAD_FUNCIONAL IS NOT NULL) SUB
		LEFT JOIN tp.UnidadFuncional U 
            ON U.ID_UF = SUB.NUM_UNIDAD_FUNCIONAL
            AND U.NombreConsorcio = SUB.NombreConsorcio
		WHERE SUB.PRIMERO = 1
        AND U.ID_UF IS NULL;

		DROP TABLE #TEMP

END

-- 4) SP Importar datos personas (propietarios e inquilinos)

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPersonas_03') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPersonas_03 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE or ALTER PROCEDURE tp.sp_ImportarPersonas_03
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE #TempDatos (
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    DNI int ,
    Email_Personal VARCHAR(100),
    Telefono_De_Contacto char (10),
    CVU_CBU varchar(22),
    Boleano int
	);

	 -- Importar archivo CSV
	 DECLARE @Sql NVARCHAR(MAX);
	 SET @Sql = '
		BULK INSERT #TempDatos 
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		 FIRSTROW = 2
		);';

	EXEC(@Sql);

	-- insertamos personas
	INSERT INTO tp.Persona(Nombres,apellido,DNI_Persona,CorreoElectronico,telefono,CVU_CBU, Tipo)
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.telefono_De_Contacto),sub.CVU_CBU, 
	sub.boleano AS Tipo            
    FROM (  SELECT nombre, apellido, dni, email_personal, telefono_de_contacto, CVU_CBU, boleano,
		    ROW_NUMBER() OVER (PARTITION BY CVU_CBU,boleano ORDER BY dni) AS primero  -- elige el primero
			FROM #TempDatos
		  ) sub
	where sub.primero=1 
	AND sub.Nombre IS NOT NULL AND LTRIM(RTRIM(sub.Nombre)) <> '' 
	AND NOT EXISTS (SELECT 1 FROM tp.Persona p WHERE p.CVU_CBU = sub.CVU_CBU AND p.Tipo = sub.boleano)

	DROP TABLE #TempDatos;

END
GO

-- 5) SP Importar CBU_CVU a unidad funcional

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarPropietariosInquilinosUnidadFuncional_04
@RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
	
	CREATE TABLE #TempDatos ( 
	CVU_CBU VARCHAR(22),
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
	
	    UPDATE uf
        SET uf.CVU_CBU = t.CVU_CBU,uf.Tipo = p.Tipo
		FROM tp.UnidadFuncional AS uf
		INNER JOIN #TempDatos AS t ON uf.ID_UF = t.NUM_UNIDAD_FUNCIONAL
        AND uf.NombreConsorcio = t.NOMBRE_CONSORCIO
        AND uf.Piso = t.PISO
        AND uf.Departamento = t.Departamento
		INNER JOIN tp.Persona AS p
        ON p.CVU_CBU = t.CVU_CBU;
	
	DROP TABLE #TempDatos;
END
GO


-- 6) Sp importar pagos

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarPagos_05') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarPagos_05 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarPagos_05
@RutaArchivo NVARCHAR(260)
AS
BEGIN
	
	SET NOCOUNT ON;

	CREATE TABLE #PagosTemp (
        IdPago INT,
        Fecha NVARCHAR(20),
        CVU_CBU VARCHAR(22),
        Valor NVARCHAR(30));

	DECLARE @Sql NVARCHAR(MAX);
	SET @Sql = '
		BULK INSERT #PagosTemp 
		FROM ''' + @RutaArchivo + '''
		WITH (
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2
		);';

	EXEC(@Sql);

	INSERT INTO tp.Pago(ID_Pago,Fecha_Pago,CVU_CBU,Importe)
    SELECT T.IdPago,
    CONVERT(DATE, Fecha, 103),  -- formato dd/mm/yyyy
    T.CVU_CBU,
    TRY_CAST(REPLACE((REPLACE(Valor, '$', '')),'.','') AS DECIMAL(13,4))/10
    FROM #PagosTemp T
	LEFT JOIN tp.Pago P ON P.ID_Pago = T.IdPago
	WHERE t.IdPago IS NOT NULL 
	AND T.cvu_cbu IN (SELECT CVU_CBU FROM tp.Persona)
	AND p.ID_Pago IS NULL;

    DROP TABLE #PagosTemp; 

END 
GO


-- 7) IMPORTAR DATOS DE SERVICIO

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_ImportarServicios_06') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_ImportarServicios_06 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE tp.sp_ImportarServicios_06
@RutaArchivo NVARCHAR(260),@numero_mes int
AS
BEGIN
	
	CREATE TABLE #temp(
	NOMBRE_CONSORCIO VARCHAR(100),
	FECHA DATE,
	BANCARIOS DECIMAL(20,2),
	LIMPIEZA DECIMAL(20,2),
	ADMINISTRACION DECIMAL(20,2),
	SEGUROS DECIMAL(20,2),
	GASTOS_GENERALES DECIMAL(20,2),
	SERVICIOS_PUBLICOS_Agua DECIMAL(20,2),
	SERVICIOS_PUBLICOS_Luz DECIMAL(20,2));

	DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    INSERT INTO #temp
    SELECT 
        NOMBRE_CONSORCIO,
        DATEFROMPARTS(
            2025,
            CASE LOWER(MES)
                WHEN ''enero'' THEN 1
                WHEN ''febrero'' THEN 2
                WHEN ''marzo'' THEN 3
                WHEN ''abril'' THEN 4
                WHEN ''mayo'' THEN 5
                WHEN ''junio'' THEN 6
                WHEN ''julio'' THEN 7
                WHEN ''agosto'' THEN 8
                WHEN ''septiembre'' THEN 9
                WHEN ''octubre'' THEN 10
                WHEN ''noviembre'' THEN 11
                WHEN ''diciembre'' THEN 12
            END,
            25
        ),
        TRY_CAST(REPLACE(REPLACE(BANCARIOS, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(LIMPIEZA, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(ADMINISTRACION, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(SEGUROS, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(GASTOS_GENERALES, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(SERVICIOS_PUBLICOS_Agua, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100,
        TRY_CAST(REPLACE(REPLACE(SERVICIOS_PUBLICOS_Luz, '','', ''''), ''.'','''') AS DECIMAL(20,2)) / 100
    FROM OPENROWSET (BULK ''' + @RutaArchivo + ''', SINGLE_CLOB) AS json
    CROSS APPLY OPENJSON(json.BulkColumn)
    WITH (
        NOMBRE_CONSORCIO VARCHAR(100) ''$."Nombre del consorcio"'',
        MES VARCHAR(20) ''$."Mes"'',
        BANCARIOS VARCHAR(30) ''$."BANCARIOS"'',
        LIMPIEZA VARCHAR(30) ''$."LIMPIEZA"'',
        ADMINISTRACION VARCHAR(30) ''$."ADMINISTRACION"'',
        SEGUROS VARCHAR(30) ''$."SEGUROS"'',
        GASTOS_GENERALES VARCHAR(30) ''$."GASTOS GENERALES"'',
        SERVICIOS_PUBLICOS_Agua VARCHAR(30) ''$."SERVICIOS PUBLICOS-Agua"'',
        SERVICIOS_PUBLICOS_Luz VARCHAR(30) ''$."SERVICIOS PUBLICOS-Luz"''
    ) AS JsonData;';

    -- Ejecutar la consulta dinámica por importar desde un archivo del tipo jason
    EXEC sp_executesql @SQL;

	INSERT INTO TP.EstadoFinanciero (NombreConsorcio,EgresoGastoMensual,Fecha)
	SELECT NOMBRE_CONSORCIO,BANCARIOS+LIMPIEZA+ADMINISTRACION+SEGUROS+GASTOS_GENERALES+SERVICIOS_PUBLICOS_Agua+SERVICIOS_PUBLICOS_Luz,FECHA
	FROM #temp T
	WHERE NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.Expensa(NombreConsorcio,FechaEmision,PrimerFechaVencimiento,SegundaFechaVencimiento,ID_UF,TotalAPagar) 
	SELECT T.NOMBRE_CONSORCIO,T.FECHA, DATEADD(DAY,10, T.FECHA), DATEADD(DAY,15, T.FECHA),U.ID_UF,
	((t.ADMINISTRACION+t.BANCARIOS+t.GASTOS_GENERALES+t.LIMPIEZA+t.SEGUROS+t.SERVICIOS_PUBLICOS_Agua+t.SERVICIOS_PUBLICOS_Luz)*0.01*U.PorcentajeProrrateo)
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.GastoGeneral(Importe,ID_Expensa) 
	SELECT T.GASTOS_GENERALES*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.GastoAdministracion(Importe,ID_Expensa) 
	SELECT T.ADMINISTRACION*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.Seguro (Importe,ID_Expensa)
	SELECT T.SEGUROS*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.MantenimientoCtaBancaria (Importe,id_expensa)
	SELECT T.BANCARIOS*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	INSERT INTO TP.ServicioPublico (ImporteAgua,ImporteLuz,ID_Expensa)
	SELECT T.SERVICIOS_PUBLICOS_Agua*0.01*U.PorcentajeProrrateo,T.SERVICIOS_PUBLICOS_Luz*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	
	INSERT INTO TP.Limpieza(Importe,ID_Expensa)
	SELECT T.LIMPIEZA*0.01*U.PorcentajeProrrateo,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Expensa
	FROM #temp T
	INNER JOIN TP.UnidadFuncional U ON U.NombreConsorcio=T.NOMBRE_CONSORCIO
	WHERE  T.NOMBRE_CONSORCIO IS NOT NULL and month (T.FECHA)=@numero_mes;

	DROP TABLE #temp
END
GO


-- 8) SP cargar tabla Gastos extraordinarios manualmente

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_CargarGastoExtraordinarioManual_07') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_CargarGastoExtraordinarioManual_07 AS BEGIN SELECT 1 END') 
END
GO

CREATE OR ALTER PROCEDURE tp.sp_CargarGastoExtraordinarioManual_07
AS
BEGIN
    SET NOCOUNT ON;
    
    CREATE TABLE #TempGastosExt (
        Tipo CHAR(1),
        Importe DECIMAL(8,4),
        Detalle VARCHAR (100),
        NroCuota INT,
        ID_Expensa INT
    );
    
    -- 2. Carga manual de los datos de ejemplo en la tabla temporal
    INSERT INTO #TempGastosExt (Tipo, Importe, Detalle, NroCuota, ID_Expensa)
    VALUES 
    -- Datos de ejemplo
    ('R', 1500.5000, 'Reparación de ascensor (cuota 1/3)', 1, 101),
    ('C', 8500.0000, 'Fondo de reserva para pintura exterior', 5, 102),
    ('R', 230.7500, 'Cambio de luminarias en pasillo', 1, 103),
    ('C', 9999.9999, 'Instalación de cámaras de seguridad', 1, 104), 
    ('R', 450.0000, 'Arreglo de bomba de agua (cuota 2/2)', 2, 105),
    ('R', 1500.5000, 'Reparación de ascensor (cuota 2/3)', 2, 101),
    ('C', 3000.0000, 'Compra de extintores nuevos', 1, 106),
    ('R', 75.2500, 'Desobstrucción de cañería', 1, 107),
    ('R', 1500.5000, 'Reparación de ascensor (cuota 3/3)', 3, 101),
    ('C', 500.0000, 'Reemplazo de buzón roto', 1, 108);
    
    -- 3. Mover los datos de la tabla temporal a la tabla final (tp.GastoExtraordinario)
    INSERT INTO tp.GastoExtraordinario (Tipo, Importe, Detalle, NroCuota, ID_Expensa)
    SELECT Tipo, Importe, Detalle, NroCuota, ID_Expensa 
    FROM  #TempGastosExt;

	UPDATE E
	SET E.TotalAPagar = ISNULL(E.TotalAPagar, 0) + T.TotalImporte
	FROM tp.Expensa AS E
	INNER JOIN (
    SELECT  ID_Expensa,SUM(Importe) AS TotalImporte
    FROM #TempGastosExt
    GROUP BY ID_Expensa
	) AS T ON E.ID_Expensa = T.ID_Expensa;
    
	DROP TABLE #TempGastosExt
    
	-- La tabla temporal #TempGastosExt se elimina automáticamente al finalizar el SP.
END
GO


-- 9) SP CARGAR AL IMPORTE TOTAL EL COSTO DE LAS BAULERAS Y COCHERAS

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_SumarCocheraBauleraAImporteTotalExpensas_08') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_SumarCocheraBauleraAImporteTotalExpensas_08 AS BEGIN SELECT 1 END') 
END
GO

CREATE or ALTER PROCEDURE tp.sp_SumarCocheraBauleraAImporteTotalExpensas_08
@numero_mes INT,@COSTE_M2_BAULERA INT, @COSTE_M2_COCHERA INT, @CONSORCIO VARCHAR(30)
AS
BEGIN

	UPDATE E
	SET	E.TotalAPagar= E.TotalAPagar + @COSTE_M2_BAULERA*U.M2_Baulera
	FROM TP.Expensa E
	INNER JOIN TP.UnidadFuncional U ON E.ID_UF=U.ID_UF AND E.NombreConsorcio=U.NombreConsorcio
	WHERE U.Baulera='si' AND U.NombreConsorcio=@CONSORCIO AND MONTH (E.FechaEmision)=@numero_mes;

	UPDATE E
	SET	E.TotalAPagar= E.TotalAPagar + @COSTE_M2_COCHERA*U.M2_Cochera
	FROM TP.Expensa E
	INNER JOIN TP.UnidadFuncional U ON E.ID_UF=U.ID_UF AND E.NombreConsorcio=U.NombreConsorcio
	WHERE U.Cochera='si' AND U.NombreConsorcio=@CONSORCIO AND MONTH (E.FechaEmision)=@numero_mes;

END
GO


-- 10) SP PARA AGREGAR EL ID EXPENSA EN LA TABLA PAGOS


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_RellenarPagoConIdExpensa_09') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_RellenarPagoConIdExpensa_09 AS BEGIN SELECT 1 END') 
END
GO

CREATE or ALTER PROCEDURE tp.sp_RellenarPagoConIdExpensa_09
AS
BEGIN

	UPDATE  P
	SET P.ID_EXPENSA=E.ID_Expensa
	FROM TP.Expensa E
	INNER JOIN TP.UnidadFuncional U ON U.ID_UF=E.ID_UF AND U.NombreConsorcio=E.NombreConsorcio
	INNER JOIN TP.PAGO P ON P.CVU_CBU=U.CVU_CBU
	WHERE DATEADD(MONTH, 1, E.FechaEmision)> P.Fecha_Pago AND P.Fecha_Pago>=E.FechaEmision

END
GO

-- 11) SP CARGAR TABLA ESTADO DE CUENTA 


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'tp.sp_GenerarEstadoDeCuentA_10') AND type = 'P')
BEGIN
    EXEC('CREATE PROCEDURE tp.sp_GenerarEstadoDeCuentA_10 AS BEGIN SELECT 1 END') 
END
GO

CREATE or ALTER PROCEDURE tp.sp_GenerarEstadoDeCuentA_10
@numero_mes INT,@COSTE_M2_BAULERA int, @COSTE_M2_COCHERA int,@primer_estado_cuenta bit,@NOMBRE_CONSORCIO VARCHAR (30)
AS
BEGIN
	
	WITH PagosCalculados AS (
    SELECT  E.FechaEmision,U.ID_UF, U.NombreConsorcio,
        CASE WHEN U.BAULERA = 'si' THEN U.M2_BAULERA * @COSTE_M2_BAULERA ELSE 0 END AS ImporteBaulera,
        CASE WHEN U.COCHERA = 'si' THEN U.M2_COCHERA * @COSTE_M2_COCHERA ELSE 0 END AS ImporteCochera,
        ISNULL((
            SELECT SUM(P.Importe)
            FROM TP.Pago P
            WHERE P.CVU_CBU = U.CVU_CBU
            AND MONTH(P.Fecha_Pago) = @numero_mes
            AND YEAR(P.Fecha_Pago) = YEAR(E.FechaEmision)
            AND DAY(P.Fecha_Pago) < DAY(E.FechaEmision)), 0) AS PagoRecibido
    FROM TP.Expensa E
    INNER JOIN TP.UnidadFuncional U ON U.ID_UF = E.ID_UF AND U.NombreConsorcio = E.NombreConsorcio
    WHERE MONTH(E.FechaEmision) = @numero_mes AND U.NombreConsorcio = @NOMBRE_CONSORCIO)
	INSERT INTO TP.EstadodeCuenta(FECHA, ID_UF, NombreConsorcio, ImporteBaulera, ImporteCochera,deuda, SaldoAnterior, InteresPorMora1V, InteresPorMora2V, PagoRecibido)
	SELECT FechaEmision,ID_UF,NombreConsorcio,ImporteBaulera,ImporteCochera,
    -PagoRecibido,
    CASE WHEN @primer_estado_cuenta = 1 THEN 0 ELSE 0 END AS SaldoAnterior,
    CASE WHEN @primer_estado_cuenta = 1 THEN 0 ELSE 0 END AS InteresPorMora1V,
    CASE WHEN @primer_estado_cuenta = 1 THEN 0 ELSE 0 END AS InteresPorMora2V,
    PagoRecibido
	FROM PagosCalculados PC;

END 
GO


