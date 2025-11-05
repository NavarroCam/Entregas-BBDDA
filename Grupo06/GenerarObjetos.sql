USE MASTER

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Com5600G06')
BEGIN
   
   -- Terminar conexiones activas
   ALTER DATABASE [Com5600G06] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   
    -- Eliminar la base
    DROP DATABASE Com5600G06;
END



IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name='Com5600G06') 
BEGIN
CREATE DATABASE Com5600G06
END
go

ALTER DATABASE Com5600G06 SET MULTI_USER WITH ROLLBACK IMMEDIATE; --- PARA USAR EN VARIAS QUERYS A LA VEZ

USE Com5600G06

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'tp')
BEGIN
	EXEC('CREATE SCHEMA tp')
END 
go

---		Creaci�n de tablas 
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
  SuperficieTotal DECIMAL(8,2) NULL,
  ID_Administracion INT NOT NULL,
  CONSTRAINT FK_Administracion FOREIGN KEY (ID_Administracion) REFERENCES tp.Administracion(ID_Administracion)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EstadoFinanciero')
BEGIN

CREATE TABLE tp.EstadoFinanciero (
 ID_EF INT PRIMARY KEY,
 Fecha SMALLDATETIME NOT NULL, --
 SaldoAnterior DECIMAL(8,2) NOT NULL CHECK(SaldoAnterior >= 0),
 IngresoPagoEnTermino DECIMAL(8,2) NOT NULL CHECK(IngresoPagoEnTermino >= 0),
 IngresoPagoAdeudado DECIMAL(8,2)  NOT NULL CHECK(IngresoPagoAdeudado>= 0),
 IngresoPagoAdelantado DECIMAL(8,2)  NOT NULL CHECK(IngresoPagoAdelantado >= 0),
 EgresoGastoMensual DECIMAL(8,2) NOT NULL CHECK(EgresoGastoMensual >= 0),
 SaldoAlCierre DECIMAL(8,2) NULL, --VER COMO SE CALCULA (SP, TRIGGER, ETC.)
 NombreConsorcio VARCHAR(30) NOT NULL,
 CONSTRAINT FK_Consorcio FOREIGN KEY (NombreConsorcio) REFERENCES tp.Consorcio(Nombre)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Propietario')
BEGIN

CREATE TABLE tp.Propietario (
  DNI_Propietario INT PRIMARY KEY, --CHECK(LEN(DNI_Propietario)=8)
  Apellido VARCHAR(30) NOT NULL,
  Nombres VARCHAR(30) NOT NULL,
  CorreoElectronico VARCHAR(50) NOT NULL,
  Telefono CHAR(10) NOT NULL CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CVU_CBU varchar(50) NOT NULL,
);
END
go 


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EstadodeCuenta')
BEGIN

CREATE TABLE tp.EstadodeCuenta (
  ID_EstadodeCuenta INT IDENTITY(1,1) PRIMARY KEY,
  SaldoAnterior DECIMAL(8,2) NOT NULL CHECK(SaldoAnterior >= 0),
  PagoRecibido DECIMAL(8,2) NOT NULL CHECK(PagoRecibido >= 0),
  InteresPorMora1V DECIMAL (8,2) NOT NULL DEFAULT 0, --CALCULAR CON SP,
  InteresPorMora2V DECIMAL (8,2) NOT NULL DEFAULT 0, --CALCULAR CON SP,
  Deuda DECIMAL(8,2) NOT NULL DEFAULT 0, --CALCULAR CON SP
  ImporteCochera DECIMAL(8,2) NOT NULL CHECK (ImporteCochera >=0) DEFAULT 0,
  ImporteBaulera DECIMAL(8,2) NOT NULL CHECK (ImporteBaulera >=0) DEFAULT 0,
  );
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'UnidadFuncional')
BEGIN

CREATE TABLE tp.UnidadFuncional (
  ID_UF INT,
  NombreConsorcio VARCHAR(30),
  Piso VARCHAR(2) NOT NULL,
  Departamento VARCHAR(3) NOT NULL,
  PorcentajeProrrateo DECIMAL (5,4) NOT NULL, --CALCULAR CON SP --- coeficiente del TXT?????
  M2_Unidad DECIMAL(4,2) NULL,
  BAULERA CHAR(2) NOT NULL,
  COCHERA CHAR(2) NOT NULL,
  M2_BAULERA INT NOT NULL CHECK (M2_BAULERA>=0),
  M2_COCHERA INT NOT NULL CHECK (M2_COCHERA>=0),
  CVU_CBU varchar(22),
  ID_EstadodeCuenta INT NULL,
  CONSTRAINT PK_UNIDAD_FUNCIONAL PRIMARY KEY (ID_UF,NombreConsorcio),
  CONSTRAINT FK_UF_Consorcio FOREIGN KEY (NombreConsorcio) REFERENCES tp.Consorcio(Nombre),
  CONSTRAINT FK_UF_Propietario FOREIGN KEY (CVU_CBU) REFERENCES tp.Propietario(CVU_CBU),
  CONSTRAINT FK_UF_EstadodeCuenta FOREIGN KEY (ID_EstadodeCuenta) REFERENCES tp.EstadodeCuenta(ID_EstadodeCuenta)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Inquilino')
BEGIN

CREATE TABLE tp.Inquilino (
  DNI_Inquilino INT PRIMARY KEY,
  Apellido VARCHAR(30) NOT NULL,
  Nombres VARCHAR(30) NOT NULL,
  CorreoElectronico VARCHAR(50) NOT NULL,
  Telefono CHAR(10) NOT NULL CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CVU_CBU varchar (50) NOT NULL,
);
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Expensa')
BEGIN

CREATE TABLE tp.Expensa (
  ID_Expensa INT IDENTITY(1,1) PRIMARY KEY,
  FechaEmision SMALLDATETIME NOT NULL,
  TotalAPagar DECIMAL(8,4) NOT NULL, --CALCULAR CON SP
  PrimerFechaVencimiento SMALLDATETIME NOT NULL,
  SegundaFechaVencimiento SMALLDATETIME NOT NULL,
  ID_UF INT NOT NULL,
  NombreConsorcio VARCHAR(30),
  DNI_Propietario INT NOT NULL,
  DNI_Inquilino INT NOT NULL,
  CONSTRAINT FK_EX_ID_UF FOREIGN KEY (ID_UF,NombreConsorcio) REFERENCES tp.UnidadFuncional(ID_UF,NombreConsorcio),
  CONSTRAINT FK_EX_Propietario FOREIGN KEY (DNI_Propietario) REFERENCES tp.Propietario(DNI_Propietario),
  CONSTRAINT FK_EX_Inquilino FOREIGN KEY (DNI_Inquilino) REFERENCES tp.Inquilino(DNI_Inquilino)
);
END
go



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'GastoExtraordinario')
BEGIN

CREATE TABLE tp.GastoExtraordinario (
  ID_GastoExtraordinario INT IDENTITY(1,1) PRIMARY KEY,
  Tipo CHAR(1) NOT NULL CHECK(Tipo IN ('R', 'C')),
  Importe DECIMAL(8,4) NOT NULL CHECK (Importe > 0),
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
  NRO_Factura INT PRIMARY KEY,
  NombreEmpresa VARCHAR(20) NOT NULL,
  NombrePersona VARCHAR(20) NOT NULL,
  Importe DECIMAL(8,2) NOT NULL,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_GG_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'GastoAdministracion')

BEGIN
CREATE TABLE tp.GastoAdministracion (
  NRO_Factura INT PRIMARY KEY,
  Importe DECIMAL(8,2) NOT NULL,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_GA_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'ServicioPublico')

BEGIN
CREATE TABLE tp.ServicioPublico (
  NRO_Factura INT PRIMARY KEY,
  ImporteLuz DECIMAL(8,2) NOT NULL,
  ImporteAgua DECIMAL(8,2) NOT NULL,
  ImporteInternet DECIMAL(8,2) NOT NULL DEFAULT 0,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_SP_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Seguro')

BEGIN
CREATE TABLE tp.Seguro (
  NRO_Factura INT PRIMARY KEY,
  NombreEmpresaSeguro VARCHAR(20) NOT NULL,
  Importe DECIMAL(8,2) NOT NULL,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_S_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);


END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Limpieza')

BEGIN
CREATE TABLE tp.Limpieza (
  NRO_FacturaLimpieza INT PRIMARY KEY,
  ID_Expensa INT NOT NULL,
  Tipo CHAR (1) NOT NULL CHECK (Tipo IN ('S', 'E')),
  CONSTRAINT FK_L_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'ServicioDomesticoLimpieza')

BEGIN
CREATE TABLE tp.ServicioDomesticoLimpieza (
  NRO_FacturaLimpieza INT PRIMARY KEY,
  SueldoEmpleado DECIMAL (8,2) NOT NULL,
  ImporteProductos DECIMAL(8,2) NOT NULL,
  CONSTRAINT FK_SD_NRO_FacturaLimpieza FOREIGN KEY (NRO_FacturaLimpieza) REFERENCES tp.Limpieza(NRO_FacturaLimpieza)
);

END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EmpresaLimpieza')

BEGIN
CREATE TABLE tp.EmpresaLimpieza (
  NRO_FacturaLimpieza INT PRIMARY KEY,
  NombreEmpresaLimpieza VARCHAR(30) NOT NULL,
  Importe DECIMAL(8,2) NOT NULL,
  CONSTRAINT FK_EL_NRO_FacturaLimpieza FOREIGN KEY (NRO_FacturaLimpieza) REFERENCES tp.Limpieza(NRO_FacturaLimpieza)
);


END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'MantenimientoCtaBancaria')

BEGIN
CREATE TABLE tp.MantenimientoCtaBancaria (
  NRO_Cuenta INT PRIMARY KEY,
  EntidadBanco VARCHAR(30) NOT NULL,
  Importe DECIMAL(8,2) NOT NULL,
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_MCB_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Pago')

BEGIN
CREATE TABLE tp.Pago (
  ID_Pago INT PRIMARY KEY,
  --Fecha_Pago SMALLDATETIME NOT NULL,
  Importe DECIMAL (8,2) NOT NULL,
  Estado VARCHAR (15) NOT NULL CHECK (Estado IN ('Pagado', 'No Pagado')),
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_P_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);
END
go


--=======CREACIÓN DE SPs============================================================================
--SP Importar datos administración
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

--SP Importar datos consorcio
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
    WHERE NOT EXISTS (
        SELECT 1 FROM tp.Consorcio c WHERE c.Nombre = t.Nombre);
	
END;
GO

--SP Importar datos Unidad Funcional txt
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

--SP Importar datos propietarios e inquilinos
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
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),CVU_CBU                
    FROM (  SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
		    ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			FROM #TempDatos
		    WHERE boleano = 1
		  ) sub
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.Inquilino i WHERE i.DNI_inquilino = sub.DNI);

	-- insertamos propietarios 0
	INSERT INTO tp.Propietario(Nombres,apellido,DNI_Propietario,CorreoElectronico,telefono,CVU_CBU)
    SELECT 	LTRIM(sub.Nombre),LTRIM(sub.Apellido),sub.DNI,LTRIM(sub.Email_Personal),LTRIM(sub.Teléfono_De_Contacto),CVU_CBU
    FROM (   SELECT nombre, apellido, dni, email_personal, teléfono_de_contacto, CVU_CBU, boleano,
			 ROW_NUMBER() OVER (PARTITION BY dni ORDER BY dni) AS primero  -- elige el primero
			 FROM #TempDatos
			 WHERE boleano = 0
		 ) sub --- la sub sirve para que no inserte duplicados del archivo csv 
	where sub.primero=1 AND NOT EXISTS (SELECT 1 FROM tp.propietario i WHERE i.DNI_propietario = sub.DNI);--- sirve para no insertar duplicados que ya tenia en mi tabla

	DROP TABLE #TempDatos;

end
go
