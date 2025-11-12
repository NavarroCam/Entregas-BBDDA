/* Entrega 6 – Reportes y API
Cada reporte debe demostrarse con la ejecución de una consulta, que deberá estar incluida
en un store procedure. El SP admitirá parámetros (al menos tres) para filtrar los resultados,
quedando a criterio del grupo determinar los mismos. Pueden combinar en un script la
creación de todos los reportes, luego en otro script harían las invocaciones.

Reporte 1
Se desea analizar el flujo de caja en forma semanal. Debe presentar la recaudación por
pagos ordinarios y extraordinarios de cada semana, el promedio en el periodo, y el
acumulado progresivo.

Reporte 2
Presente el total de recaudación por mes y departamento en formato de tabla cruzada.

Reporte 3
Presente un cuadro cruzado con la recaudación total desagregada según su procedencia
(ordinario, extraordinario, etc.) según el periodo.

Reporte 4
Obtenga los 5 (cinco) meses de mayores gastos y los 5 (cinco) de mayores ingresos.

Reporte 5
Obtenga los 3 (tres) propietarios con mayor morosidad. Presente información de contacto y
DNI de los propietarios para que la administración los pueda contactar o remitir el trámite al
estudio jurídico.

Reporte 6
Muestre las fechas de pagos de expensas ordinarias de cada UF y la cantidad de días que
pasan entre un pago y el siguiente, para el conjunto examinado.


Al menos dos de los reportes deberán generarse en XML, que mostrarán en SSMS. No es
necesario que lo creen en el filesystem.

Genere índices para optimizar la ejecución de las consultas de los reportes. Debe existir un
script adicional con la generación de índices.

Deberán incorporar al menos una API como fuente de datos externa. Queda a criterio del
grupo qué API utilizar y para qué. Algunas ideas: pueden usar la API que devuelve la
cotización del dólar para convertir valores (en ese caso podrían guardar valores en dólares
y pesos); la API de feriados para no emitir comprobantes o generar vencimientos en
domingos o feriados; una API para enviar notificaciones por whatsapp o email, o para
generar PDFs en base a reportes, etc. No es necesario que codifiquen la API (tampoco está
prohibido). Deben consumir al menos UNA API para sumar una funcionalidad al sistema.
Esto pueden realizarlo con T-SQL tal como se ve en la unidad 2.


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


Notación y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importación
 - cspr -> Creacion de Store Procedures de Reportes
*/


-- Finalmente un ejemplo con una API falsa:
-- https://jsonplaceholder.typicode.com
-- Lo interesante de este ejemplo es como pasarle los parametros, 
-- los dos anteriores eran ejemplos de llamadas GET donde el parametro 
-- va en la url, pero no tiene porque ser asi.
 
/*
Esta API rebota lo que vos le mandas. Lo que le pasas te lo devuelve.
Para el TP si NO encontramos ninguna API que nos sirva para lo que queremos, podemos usar 
la API falsa para fabricar algun dato y hacer de cuenta que lo devuelve una API. 
*/
 
USE Com5600G06
go

-- ==============  CREACION ESQUEMA SP GENERAR REPORTES  =======================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'cspr')
BEGIN
	EXEC('CREATE SCHEMA cspr')
END 
GO

-- ==============  REPORTE 1  =======================


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspr.sp_AnalizarFlujoCajaSemanal_00') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.sp_AnalizarFlujoCajaSemanal_00 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE cspr.sp_AnalizarFlujoCajaSemanal_00
    @FechaInicio DATE,
    @FechaFin DATE,
    @NombreConsorcio VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- CTE 1: Filtra y Agrupa los pagos por semana y consorcio
    WITH PagosFiltrados AS (
        SELECT
            P.Fecha_Pago,
            P.Importe
        FROM
            ct.Pago P
        INNER JOIN ct.Persona PE ON PE.CVU_CBU = P.CVU_CBU
        INNER JOIN ct.UnidadFuncional U ON U.CVU_CBU = PE.CVU_CBU
        WHERE
            U.NombreConsorcio = @NombreConsorcio
            AND P.Fecha_Pago >= @FechaInicio
            AND P.Fecha_Pago <= @FechaFin
    ),
    PagosSemanales AS (
        SELECT
            CAST(DATEPART(yy, Fecha_Pago) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(DATEPART(wk, Fecha_Pago) AS VARCHAR(2)), 2) AS SemanaID,
            MIN(Fecha_Pago) AS FechaInicioSemana,
            SUM(Importe) AS RecaudacionSemanal
        FROM
            PagosFiltrados
        GROUP BY
            DATEPART(yy, Fecha_Pago), DATEPART(wk, Fecha_Pago)
    )
    -- CTE 2: Aplicar Windows Functions para el acumulado y promedio
    SELECT
        PS.SemanaID,
        PS.FechaInicioSemana,
        PS.RecaudacionSemanal AS RecaudacionSemanalTotal,
        
        AVG(PS.RecaudacionSemanal) OVER (ORDER BY PS.SemanaID ROWS UNBOUNDED PRECEDING) AS PromedioAcumulado,
        
        SUM(PS.RecaudacionSemanal) OVER (ORDER BY PS.SemanaID ROWS UNBOUNDED PRECEDING) AS AcumuladoProgresivo
    FROM
        PagosSemanales PS
    ORDER BY
        PS.SemanaID
    FOR XML PATH('Semana'), ROOT('ReporteFlujoCaja');
END
GO




-- ==============  REPORTE 5  =======================
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspr.SP_Reporte_Top3Morosos_04') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.SP_Reporte_Top3Morosos_04 AS BEGIN SET NOCOUNT ON; END')
END
GO


CREATE OR ALTER PROCEDURE cspr.SP_Reporte_Top3Morosos_04(
    @FechaDesde DATE,
    @FechaHasta DATE,
    @TipoPersona BIT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        P.DNI_Persona AS DNI,
        P.CorreoElectronico AS Email,
        P.Telefono AS Telefono,
        P.Nombres AS Nombres,
        P.Apellido AS Apellido,
        SUM(EC.Deuda + EC.InteresPorMora1V + EC.InteresPorMora2V) AS MorosidadTotal
    FROM ct.EstadoDeCuenta EC

    INNER JOIN ct.Expensa E ON EC.ID_EstadoDeCuenta = E.ID_Expensa
    INNER JOIN ct.UnidadFuncional UF ON E.ID_UF = UF.ID_UF AND E.NombreConsorcio = UF.NombreConsorcio
    INNER JOIN ct.Persona P ON UF.CVU_CBU = P.CVU_CBU AND UF.Tipo = P.Tipo
    WHERE E.FechaEmision >= @FechaDesde AND E.FechaEmision <= @FechaHasta AND (@TipoPersona IS NULL OR P.Tipo = @TipoPersona)
    GROUP BY P.DNI_Persona, P.CorreoElectronico, P.Telefono, P.Nombres, P.Apellido, P.CVU_CBU
    HAVING SUM(EC.Deuda + EC.InteresPorMora1V + EC.InteresPorMora2V) > 0
    ORDER BY MorosidadTotal DESC;
END
GO



