USE Com5600G06

-- importar informacion bancaria
INSERT INTO ct.MantenimientoCtaBancaria(EntidadBanco, Importe) values('entidad', 89)

-- Generar reportes

GO
EXEC cspr.sp_AnalizarFlujoCajaSemanal_00 
    @FechaInicio = '2025-04-01',
    @FechaFin = '2025-04-30',
    @NombreConsorcio = 'Azcuenaga';
GO


-- Actualizacion de datos UF (error)
update ct.UnidadFuncional set M2_Unidad=101