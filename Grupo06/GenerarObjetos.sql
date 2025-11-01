IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name='Com5600G06') 
BEGIN
CREATE DATABASE Com5600G06
END
go

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
 Nombre VARCHAR(30) NOT NULL UNIQUE,
 Direccion VARCHAR(30) NOT NULL,
 CorreoElectronico VARCHAR(30) NOT NULL,
 Telefono CHAR(10) NOT NULL CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') 
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'EstadoFinanciero')
BEGIN

CREATE TABLE tp.EstadoFinanciero (
 ID_EF INT IDENTITY(1,1) PRIMARY KEY,
 SaldoAnterior DECIMAL(8,2) NOT NULL CHECK(SaldoAnterior >= 0),
 IngresoPagoEnTermino DECIMAL(8,2) NOT NULL CHECK(IngresoPagoEnTermino >= 0),
 IngresoPagoAdeudado DECIMAL(8,2)  NOT NULL CHECK(IngresoPagoAdeudado>= 0),
 IngresoPagoAdelantado DECIMAL(8,2)  NOT NULL CHECK(IngresoPagoAdelantado >= 0),
 EgresoGastoMensual DECIMAL(8,2) NOT NULL CHECK(EgresoGastoMensual >= 0),
 SaldoAlCierre DECIMAL(8,2) NOT NULL --VER COMO SE CALCULA (SP, TRIGGER, ETC.)
);
END
go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'tp' AND TABLE_NAME = 'Consorcio')
BEGIN

CREATE TABLE tp.Consorcio (
  ID_Consorcio INT IDENTITY(1,1) PRIMARY KEY,
  Nombre VARCHAR(30) NOT NULL UNIQUE,
  Direccion VARCHAR(30) NOT NULL,
  SuperficieTotal DECIMAL(8,2) NOT NULL,
  ID_Administracion INT NOT NULL,
  ID_EF INT NOT NULL,
  CONSTRAINT FK_Administracion FOREIGN KEY (ID_Administracion) REFERENCES tp.Administracion(ID_Administracion),
  CONSTRAINT FK_EstadoFinanciero FOREIGN KEY (ID_EF) REFERENCES tp.EstadoFinanciero(ID_EF)
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
  CVU_CBU varchar(100) NOT NULL,
  boleano bit
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
  ID_UF INT IDENTITY(1,1) PRIMARY KEY,
  ID_Consorcio INT NOT NULL,
  Piso INT NOT NULL,
  Departamento CHAR(3) NOT NULL,
  M2_Unidad DECIMAL(4,2) NULL,
  PorcentajeProrrateo DECIMAL (5,4) NOT NULL, --CALCULAR CON SP
  DNI_Propietario INT NOT NULL,
  ID_EstadodeCuenta INT NOT NULL,
  CONSTRAINT FK_UF_Consorcio FOREIGN KEY (ID_Consorcio) REFERENCES tp.Consorcio(ID_Consorcio),
  CONSTRAINT FK_UF_Propietario FOREIGN KEY (DNI_Propietario) REFERENCES tp.Propietario(DNI_Propietario),
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
  CVU_CBU varchar (100) NOT NULL,
  boleano bit
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
  ID_Consorcio INT NOT NULL,
  DNI_Propietario INT NOT NULL,
  DNI_Inquilino INT NOT NULL,
  CONSTRAINT FK_EX_Consorcio FOREIGN KEY (ID_Consorcio) REFERENCES tp.Consorcio(ID_Consorcio),
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
  ID_Pago INT IDENTITY (1,1) PRIMARY KEY,
  Importe DECIMAL (8,2) NOT NULL,
  Estado VARCHAR (15) NOT NULL CHECK (Estado IN ('Pagado', 'No Pagado')),
  ID_Expensa INT NOT NULL,
  CONSTRAINT FK_P_Expensa FOREIGN KEY (ID_Expensa) REFERENCES tp.Expensa(ID_Expensa)
);

END
go


