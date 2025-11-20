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
 - csps -> Creacion de Store Procedure de Segurida
 - cspc -> Creacion de Store Procedure de Cifrado
*/

USE Com5600G06;
GO


-- ==============  CREACION ESQUEMA SP GENERAR CIFRADO  =======================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'cspc')
BEGIN
	EXEC('CREATE SCHEMA cspc')
END 
GO


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspc.sp_ActualizarEstructuraYHashing') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspc.sp_ActualizarEstructuraYHashing AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE cspc.sp_ActualizarEstructuraYHashing
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. ELIMINAR RESTRICCIONES E ÍNDICES EXISTENTES
        -- Eliminar Clave Foránea:
    IF OBJECT_ID('ct.UnidadFuncional', 'U') IS NOT NULL AND EXISTS (
        SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_UF_Persona'
    )
    BEGIN
        ALTER TABLE ct.UnidadFuncional DROP CONSTRAINT FK_UF_Persona;
    END
        -- Eliminar Primary Key:
    IF OBJECT_ID('ct.Persona', 'U') IS NOT NULL AND EXISTS (
        SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Persona'
    )
    BEGIN
        ALTER TABLE ct.Persona DROP CONSTRAINT PK_Persona;
    END
        -- Eliminar Índices:
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UF_Persona' AND object_id = OBJECT_ID('ct.UnidadFuncional'))
        DROP INDEX IX_UF_Persona ON ct.UnidadFuncional;

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_Recaudacion' AND object_id = OBJECT_ID('ct.Pago'))
        DROP INDEX IX_Pago_Recaudacion ON ct.Pago;

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_Fecha_Expensa' AND object_id = OBJECT_ID('ct.Pago'))
        DROP INDEX IX_Pago_Fecha_Expensa ON ct.Pago;

        -- Eliminar restricción UNIQUE en DNI_Persona:
    DECLARE @ConstraintName nvarchar(256);
    SELECT @ConstraintName = kc.name
    FROM sys.key_constraints kc
    JOIN sys.index_columns ic ON kc.unique_index_id = ic.index_id AND kc.parent_object_id = ic.object_id
    JOIN sys.columns c ON ic.column_id = c.column_id AND ic.object_id = c.object_id
    WHERE kc.parent_object_id = OBJECT_ID('ct.Persona') AND kc.type = 'U' AND c.name = 'DNI_Persona';

    IF @ConstraintName IS NOT NULL
    BEGIN
        EXEC('ALTER TABLE ct.Persona DROP CONSTRAINT ' + @ConstraintName);
    END

    -- 2. AMPLIAR COLUMNAS A CHAR(64)
    ALTER TABLE ct.Persona ALTER COLUMN CVU_CBU CHAR(64) NOT NULL;
    ALTER TABLE ct.Persona ALTER COLUMN Nombres CHAR(64) NOT NULL;
    ALTER TABLE ct.Persona ALTER COLUMN Apellido CHAR(64) NOT NULL;
    ALTER TABLE ct.Persona ALTER COLUMN DNI_Persona CHAR(64) NOT NULL;
    ALTER TABLE ct.UnidadFuncional ALTER COLUMN CVU_CBU CHAR(64) NULL;
    ALTER TABLE ct.Pago ALTER COLUMN CVU_CBU CHAR(64) NULL;

    -- 3. APLICAR HASHING SHA2_256
    UPDATE ct.Persona
    SET
        CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2),
        Nombres = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), Nombres)), 2),
        Apellido = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), Apellido)), 2),
        DNI_Persona = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), DNI_Persona)), 2);

    UPDATE ct.UnidadFuncional
    SET CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2)
    WHERE CVU_CBU IS NOT NULL;

    UPDATE ct.Pago
    SET CVU_CBU = CONVERT(CHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(8000), CVU_CBU)), 2)
    WHERE CVU_CBU IS NOT NULL;

    -- 4. RECREAR RESTRICCIONES Y ÍNDICES
    ALTER TABLE ct.Persona ADD CONSTRAINT PK_Persona PRIMARY KEY (CVU_CBU, Tipo);
    ALTER TABLE ct.UnidadFuncional
    ADD CONSTRAINT FK_UF_Persona
    FOREIGN KEY (CVU_CBU, Tipo) REFERENCES ct.Persona (CVU_CBU, Tipo);

    CREATE NONCLUSTERED INDEX IX_UF_Persona ON ct.UnidadFuncional (CVU_CBU, Tipo);
    CREATE NONCLUSTERED INDEX IX_Pago_Recaudacion ON ct.Pago (Fecha_Pago, CVU_CBU) INCLUDE (Importe);
    CREATE NONCLUSTERED INDEX IX_Pago_Fecha_Expensa ON ct.Pago (Fecha_Pago, ID_Expensa) INCLUDE (Importe, CVU_CBU);
END
GO