USE Com5600G06	

-- Actualiza datos en UF
GO
update ct.UnidadFuncional set M2_Unidad=97

-- Generar Reportes

GO
EXEC cspr.SP_Reporte_SecuenciaPagosXML_05
    @FechaDesde = '2025-04-01', 
    @FechaHasta = '2025-04-30', 
    @NombreConsorcio = 'Azcuenaga';


-- Importacion de informacion bancaria (error)

GO
insert into ct.MantenimientoCtaBancaria(EntidadBanco, Importe) values('entidad', 96)