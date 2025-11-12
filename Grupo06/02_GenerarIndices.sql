USE Com5600G06

CREATE NONCLUSTERED INDEX IX_Expensa_FechaEmision 
ON ct.Expensa (FechaEmision);

CREATE NONCLUSTERED INDEX IX_Expensa_UFConsorcio 
ON ct.Expensa (ID_UF, NombreConsorcio);

CREATE NONCLUSTERED INDEX IX_EstadoDeCuenta_ID 
ON ct.EstadoDeCuenta (ID_EstadoDeCuenta);

CREATE NONCLUSTERED INDEX IX_UF_Consorcio 
ON ct.UnidadFuncional (ID_UF, NombreConsorcio);

CREATE NONCLUSTERED INDEX IX_UF_Persona 
ON ct.UnidadFuncional (CVU_CBU, Tipo);

CREATE NONCLUSTERED INDEX IX_Persona_CVU_Tipo 
ON ct.Persona (CVU_CBU, Tipo);

CREATE NONCLUSTERED INDEX IX_Persona_Tipo 
ON ct.Persona (Tipo);
