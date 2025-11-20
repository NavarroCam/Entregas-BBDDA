/*  Entrega 6: Reportes y API
Genere Indices para optimizar la ejecucion de las consultas de los reportes. Debe existir un
script adicional con la generacion de indices.

FECHA DE ENTREGA: 14/11/2025
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
*/

USE Com5600G06


IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Pago_Recaudacion' 
    AND object_id = OBJECT_ID('ct.Pago')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pago_Recaudacion
    ON ct.Pago (Fecha_Pago, CVU_CBU)
    INCLUDE (Importe);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_FechaEmision' AND object_id = OBJECT_ID('ct.Expensa'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_FechaEmision
    ON ct.Expensa (FechaEmision);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_UFConsorcio' AND object_id = OBJECT_ID('ct.Expensa'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_UFConsorcio
    ON ct.Expensa (ID_UF, NombreConsorcio);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_UF_ID' AND object_id = OBJECT_ID('ct.Expensa'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_UF_ID
    ON ct.Expensa (ID_UF, ID_Expensa);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UF_Consorcio' AND object_id = OBJECT_ID('ct.UnidadFuncional'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_UF_Consorcio
    ON ct.UnidadFuncional (ID_UF, NombreConsorcio);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UF_Persona' AND object_id = OBJECT_ID('ct.UnidadFuncional'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_UF_Persona
    ON ct.UnidadFuncional (CVU_CBU, Tipo);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Persona_Tipo' AND object_id = OBJECT_ID('ct.Persona'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Persona_Tipo
    ON ct.Persona (Tipo);
END
GO


IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Pago_Fecha_Expensa' AND object_id = OBJECT_ID('ct.Pago')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pago_Fecha_Expensa
    ON ct.Pago (Fecha_Pago, ID_Expensa)
    INCLUDE (Importe, CVU_CBU);
END
GO


IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_GastoExtraordinario_Expensa' AND object_id = OBJECT_ID('ct.GastoExtraordinario')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_GastoExtraordinario_Expensa
    ON ct.GastoExtraordinario (ID_Expensa);
END
GO