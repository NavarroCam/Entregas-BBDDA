USE Com5600G06

-- REPORTE 1



-- REPORTE 2


-- REPORTE 3


-- REPORTE 4









-- REPORTE 5
EXEC cspr.SP_Reporte_Top3Morosos 
    @FechaDesde = '2025-01-01', 
    @FechaHasta = '2025-12-31', 
    @TipoPersona = 0;

-- 1. Crear tabla temporal
IF OBJECT_ID('tempdb..#Morosos') IS NOT NULL
    DROP TABLE #Morosos;

CREATE TABLE #Morosos (
    DNI INT,
    Email VARCHAR(100),
    Telefono VARCHAR(20),
    Nombres VARCHAR(100),
    Apellido VARCHAR(100),
    MorosidadTotal DECIMAL(18,2)
);

-- 2. Insertar resultado del SP
INSERT INTO #Morosos
EXEC cspr.SP_Reporte_Top3Morosos
    @FechaDesde = '2025-01-01', 
    @FechaHasta = '2025-12-31', 
    @TipoPersona = 0;

-- 3. Generar XML desde la tabla
SELECT * FROM #Morosos FOR XML PATH('Propietario'), ROOT('InformeMorosidad');

-- REPORTE 6