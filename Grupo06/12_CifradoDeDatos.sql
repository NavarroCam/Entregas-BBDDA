/*
Entrega 7 - Requisitos de Seguridad
Por otra parte, se requiere que apliquen cifrado a datos sensibles/personales incluidos en el
sistema. Lea el material de la unidad 6 disponible en Miel para determinar qué datos en su
implementación encajan con esa descripción.
El cifrado tendrán que aplicarlo a posteriori de la realización de las funciones que manejen
los datos mencionados. Por ello tendrán que incorporar scripts de modificación de estructuras
de datos, modificación sobre store procedures y vistas y tal vez creación de triggers u otro
mecanismo para implementar el cifrado. Este cambio realizado al sistema es “en un solo
sentido” y se entiende que al aplicarlo no es reversible. Notar que también deberán modificar
los reportes que presenten información cifrada para que sea legible.*//*
FECHA DE ENTREGA: 21/11/2025
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

Notacion y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importacion
 - cspr -> Creacion de Store Procedures de Reportes
 - csps -> Creacion de Store Procedure de Seguridad
*/

USE Com5600G06;
GO


--------------------------------------------------------------------------------
-- 1. ELIMINAR RESTRICCIONES Y DEPENDENCIAS
--------------------------------------------------------------------------------

-- A. Eliminar Clave Foránea (FK) de la tabla hija (ct.UnidadFuncional)
IF OBJECT_ID('ct.UnidadFuncional', 'U') IS NOT NULL AND EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_UF_Persona')
BEGIN
    ALTER TABLE ct.UnidadFuncional DROP CONSTRAINT FK_UF_Persona;
END
GO

-- B. Eliminar Primary Key (PK) de la tabla padre (ct.Persona)
IF OBJECT_ID('ct.Persona', 'U') IS NOT NULL AND EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Persona')
BEGIN
    ALTER TABLE ct.Persona DROP CONSTRAINT PK_Persona;
END
GO

-- C. Eliminar Índices de ct.Persona y ct.UnidadFuncional (si existen)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Persona_CVU_Tipo' AND object_id = OBJECT_ID('ct.Persona'))
    DROP INDEX IX_Persona_CVU_Tipo ON ct.Persona;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UF_Persona' AND object_id = OBJECT_ID('ct.UnidadFuncional'))
    DROP INDEX IX_UF_Persona ON ct.UnidadFuncional;

-- D. Eliminar Índices dependientes en ct.Pago (para el ALTER COLUMN)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_Recaudacion' AND object_id = OBJECT_ID('ct.Pago'))
BEGIN
    DROP INDEX IX_Pago_Recaudacion ON ct.Pago;
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_Fecha_Expensa' AND object_id = OBJECT_ID('ct.Pago'))
BEGIN
    DROP INDEX IX_Pago_Fecha_Expensa ON ct.Pago;
END
GO

-- E. Eliminar cualquier restricción UNIQUE potencial en DNI_Persona
DECLARE @ConstraintName nvarchar(256);
SELECT @ConstraintName = name
FROM sys.objects
WHERE parent_object_id = OBJECT_ID('ct.Persona') AND type_desc = 'UNIQUE_CONSTRAINT'
  AND OBJECT_DEFINITION(OBJECT_ID(name)) LIKE '%DNI_Persona%';

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE ct.Persona DROP CONSTRAINT ' + @ConstraintName);
END
GO

--------------------------------------------------------------------------------
-- 2. AMPLIAR COLUMNAS A CHAR(64)
--------------------------------------------------------------------------------

-- A. ct.Persona (CVU_CBU, Nombres, Apellido, DNI_Persona)
ALTER TABLE ct.Persona ALTER COLUMN CVU_CBU CHAR(64) NOT NULL;
ALTER TABLE ct.Persona ALTER COLUMN Nombres CHAR(64) NOT NULL;
ALTER TABLE ct.Persona ALTER COLUMN Apellido CHAR(64) NOT NULL;
ALTER TABLE ct.Persona ALTER COLUMN DNI_Persona CHAR(64) NOT NULL;

-- B. ct.UnidadFuncional (CVU_CBU)
ALTER TABLE ct.UnidadFuncional ALTER COLUMN CVU_CBU CHAR(64) NULL;

-- C. ct.Pago (CVU_CBU)
ALTER TABLE ct.Pago ALTER COLUMN CVU_CBU CHAR(64) NULL;
GO

--------------------------------------------------------------------------------
-- 3. APLICAR HASHING (SHA2_256) Y CONVERSIÓN A CADENA HEXADECIMAL
--------------------------------------------------------------------------------

-- A. Hashing en ct.Persona (todas las columnas PII)
UPDATE ct.Persona
SET
    CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2),
    Nombres = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), Nombres)), 2),
    Apellido = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), Apellido)), 2),
    DNI_Persona = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), DNI_Persona)), 2);
GO

-- B. Hashing en ct.UnidadFuncional (Clave Foránea)
UPDATE ct.UnidadFuncional
SET CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2)
WHERE CVU_CBU IS NOT NULL;
GO

-- C. Hashing en ct.Pago (CVU_CBU)
UPDATE ct.Pago
SET CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2)
WHERE CVU_CBU IS NOT NULL;
GO

--------------------------------------------------------------------------------
-- 4. RECREAR RESTRICCIONES DE CLAVE
--------------------------------------------------------------------------------

-- A. Recrear Primary Key en ct.Persona (CVU_CBU y Tipo)
ALTER TABLE ct.Persona ADD CONSTRAINT PK_Persona PRIMARY KEY (CVU_CBU, Tipo);
GO

-- B. Recrear Clave Foránea en ct.UnidadFuncional
ALTER TABLE ct.UnidadFuncional
ADD CONSTRAINT FK_UF_Persona
FOREIGN KEY (CVU_CBU, Tipo) REFERENCES ct.Persona (CVU_CBU, Tipo);
GO


-- C. Recrear Índices para rendimiento
CREATE UNIQUE NONCLUSTERED INDEX IX_Persona_CVU_Tipo ON ct.Persona (CVU_CBU, Tipo);
GO

CREATE NONCLUSTERED INDEX IX_UF_Persona ON ct.UnidadFuncional (CVU_CBU, Tipo);
GO


