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

---		Creación de tablas 
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
 IngresoPagoEnTermino DECIMAL(8,2) NOT NULL CHECK(PagoEnTermino >= 0),
 IngresoPagoAdeudado DECIMAL(8,2)  NOT NULL CHECK(PagoAdeudado>= 0),
 IngresoPagoAdelantado DECIMAL(8,2)  NOT NULL CHECK(PagoAdelantado >= 0),
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