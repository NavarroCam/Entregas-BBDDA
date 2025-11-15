USE Com5600G06


-- Generacion de reportes
EXEC cspr.sp_RecaudacionDesagregadaPorProcedencia_02
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-12-31',
    @TipoPeriodo = 'MENSUAL';
GO


-- Actualizacion de datos UF
update ct.UnidadFuncional set M2_Unidad=99


-- Importacion de informacion bancaria (error)

insert into ct.MantenimientoCtaBancaria(EntidadBanco, Importe) values('entidad', 98)