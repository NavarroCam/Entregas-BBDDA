/* Entrega 6: Reportes y API
Cada reporte debe demostrarse con la ejecucion de una consulta, que debera estar incluida
en un store procedure. El SP admitira parametros (al menos tres) para filtrar los resultados,
quedando a criterio del grupo determinar los mismos. Pueden combinar en un script la
creacion de todos los reportes, luego en otro script harian las invocaciones.

Al menos dos de los reportes deberan generarse en XML, que mostraran en SSMS. No es
necesario que lo creen en el filesystem.

Deberan incorporar al menos una API como fuente de datos externa. Queda a criterio del
grupo que API utilizar y para que. Algunas ideas: pueden usar la API que devuelve la
cotizacion del dolar para convertir valores (en ese caso podrian guardar valores en dolares
y pesos); la API de feriados para no emitir comprobantes o generar vencimientos en
domingos o feriados; una API para enviar notificaciones por whatsapp o email, o para
generar PDFs en base a reportes, etc. No es necesario que codifiquen la API (tampoco esta
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

Notacion y convenciones:
Esquemas:
 - ct -> Creacion de tablas
 - csp -> Creacion de Store Procedures de Importacion
 - cspr -> Creacion de Store Procedures de Reportes
*/

 
USE Com5600G06
GO

-- ==============  CREACION ESQUEMA SP GENERAR REPORTES  =======================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'cspr')
BEGIN
	EXEC('CREATE SCHEMA cspr')
END 
GO



-- ==============  REPORTE 1  =======================

/* Se desea analizar el flujo de caja en forma semanal. Debe presentar la recaudacion por
pagos ordinarios y extraordinarios de cada semana, el promedio en el periodo, y el
acumulado progresivo. */

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
        SELECT P.Fecha_Pago, P.Importe
        FROM ct.Pago P
        INNER JOIN ct.Persona PE ON PE.CVU_CBU = P.CVU_CBU
        INNER JOIN ct.UnidadFuncional U ON U.CVU_CBU = PE.CVU_CBU
        WHERE U.NombreConsorcio = @NombreConsorcio AND P.Fecha_Pago >= @FechaInicio AND P.Fecha_Pago <= @FechaFin
    ),
    PagosSemanales AS (
        SELECT
            CAST(DATEPART(yy, Fecha_Pago) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(DATEPART(wk, Fecha_Pago) AS VARCHAR(2)), 2) AS SemanaID,
            MIN(Fecha_Pago) AS FechaInicioSemana,
            SUM(Importe) AS RecaudacionSemanal
        FROM PagosFiltrados
        GROUP BY DATEPART(yy, Fecha_Pago), DATEPART(wk, Fecha_Pago)
    )
    -- CTE 2: Aplicar Windows Functions para el acumulado y promedio
    SELECT PS.SemanaID, PS.FechaInicioSemana, PS.RecaudacionSemanal AS RecaudacionSemanalTotal,
        AVG(PS.RecaudacionSemanal) OVER (ORDER BY PS.SemanaID ROWS UNBOUNDED PRECEDING) AS PromedioAcumulado,
        SUM(PS.RecaudacionSemanal) OVER (ORDER BY PS.SemanaID ROWS UNBOUNDED PRECEDING) AS AcumuladoProgresivo
    FROM PagosSemanales PS
    ORDER BY PS.SemanaID
    FOR XML PATH('Semana'), ROOT('ReporteFlujoCaja');
END
GO



-- ==============  REPORTE 2  =======================

/* Presente el total de recaudacion por mes y departamento en formato de tabla cruzada. */

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspr.sp_RecaudacionPorMesYDepartamento_01') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.sp_RecaudacionPorMesYDepartamento_01 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE cspr.sp_RecaudacionPorMesYDepartamento_01
    @NombreConsorcio VARCHAR(30),
    @Año INT,
    @Mes INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar parámetros
    IF @NombreConsorcio IS NULL OR LTRIM(RTRIM(@NombreConsorcio)) = ''
    BEGIN
        RAISERROR('El parámetro @NombreConsorcio es obligatorio.', 16, 1);
        RETURN;
    END

    IF @Año IS NULL OR @Año < 1900 OR @Año > 2100
    BEGIN
        RAISERROR('El parámetro @Año debe estar entre 1900 y 2100.', 16, 1);
        RETURN;
    END

    IF @Mes NOT BETWEEN 1 AND 12
    BEGIN
        RAISERROR('El parámetro @Mes debe estar entre 1 y 12.', 16, 1);
        RETURN;
    END
    -- OBTENER DEPARTAMENTOS DEL CONSORCIO
    DECLARE @Columnas NVARCHAR(MAX) = '';
    DECLARE @ColumnasPivot NVARCHAR(MAX) = '';

    SELECT @Columnas = @Columnas + ', ISNULL([' + Depto + '], 0) AS [' + Depto + ']',
              @ColumnasPivot = @ColumnasPivot + ', [' + Depto + ']'
    FROM (
        SELECT DISTINCT CONCAT(Piso, Departamento) AS Depto
        FROM ct.UnidadFuncional
        WHERE NombreConsorcio = @NombreConsorcio
          AND Piso IS NOT NULL
          AND Departamento IS NOT NULL
    ) AS Deptos
    ORDER BY Depto;

    -- Si no hay departamentos
    IF @Columnas = ''
    BEGIN
        SELECT 'No se encontraron departamentos para el consorcio: ' + @NombreConsorcio AS Mensaje;
        RETURN;
    END

    -- Limpiar comas iniciales
    SET @Columnas = STUFF(@Columnas, 1, 2, '');
    SET @ColumnasPivot = STUFF(@ColumnasPivot, 1, 2, '');

    -- CONSULTA DINÁMICA
    DECLARE @SQL NVARCHAR(MAX) = '
    WITH Datos AS (
        SELECT 
            CONCAT(u.Piso, u.Departamento) AS Departamento,
            p.Importe
        FROM ct.Pago p
        INNER JOIN ct.Expensa e ON p.ID_Expensa = e.ID_Expensa
        INNER JOIN ct.UnidadFuncional u 
            ON e.ID_UF = u.ID_UF 
           AND e.NombreConsorcio = u.NombreConsorcio
        WHERE e.NombreConsorcio = @NombreConsorcio
          AND YEAR(p.Fecha_Pago) = @Año
          AND MONTH(p.Fecha_Pago) = @Mes
          AND p.Importe > 0
    ),
    Agrupado AS (
        SELECT 
            Departamento,
            SUM(Importe) AS TotalRecaudado
        FROM Datos
        GROUP BY Departamento
    )
    SELECT 
        ''' + CAST(@Año AS VARCHAR(4)) + '-' + 
        RIGHT('00' + CAST(@Mes AS VARCHAR(2)), 2) + ''' AS Mes,
        ' + @Columnas + '
    FROM Agrupado
    PIVOT (
        SUM(TotalRecaudado)
        FOR Departamento IN (' + @ColumnasPivot + ')
    ) AS PivotTable;
    ';
    
    EXEC sp_executesql 
        @SQL,
        N'@NombreConsorcio VARCHAR(30), @Año INT, @Mes INT',
        @NombreConsorcio, @Año, @Mes;
END;
GO



-- ==============  REPORTE 3  =======================

/* Presente un cuadro cruzado con la recaudacion total desagregada segun su procedencia
(ordinario, extraordinario, etc.) segun el periodo. */

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspr.sp_RecaudacionDesagregadaPorProcedencia_02') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.sp_RecaudacionDesagregadaPorProcedencia_02 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE cspr.sp_RecaudacionDesagregadaPorProcedencia_02
    @FechaInicio DATE,
    @FechaFin DATE,
    @NombreConsorcio VARCHAR(30) = NULL,
    @ID_Administracion INT = NULL,
    @TipoPeriodo VARCHAR(10) = 'MENSUAL' -- MENSUAL, TRIMESTRAL, ANUAL
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar parámetros
    IF @FechaInicio > @FechaFin
    BEGIN
        RAISERROR('La fecha de inicio no puede ser mayor que la fecha fin.', 15, 1);
        RETURN;
    END;
    -- CTE 1: Clasificación de pagos por procedencia (AGREGAR ; antes del WITH)
    ;WITH RecaudacionPorProcedencia AS (
        -- Pagos Ordinarios (sin gastos extraordinarios)
        SELECT 
            P.ID_Pago,
            P.Fecha_Pago,
            P.Importe,
            'ORDINARIO' AS Procedencia,
            E.ID_Expensa,
            E.NombreConsorcio,
            C.ID_Administracion
        FROM ct.Pago P
        INNER JOIN ct.Expensa E ON P.ID_Expensa = E.ID_Expensa
        INNER JOIN ct.Consorcio C ON E.NombreConsorcio = C.Nombre
        WHERE P.Fecha_Pago BETWEEN @FechaInicio AND @FechaFin
          AND P.ID_Expensa IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM ct.GastoExtraordinario GE 
              WHERE GE.ID_Expensa = P.ID_Expensa
          )
        
        UNION ALL
        -- Pagos Extraordinarios
        SELECT P.ID_Pago, P.Fecha_Pago, P.Importe, 'EXTRAORDINARIO' AS Procedencia,
                    E.ID_Expensa, E.NombreConsorcio, C.ID_Administracion
        FROM ct.Pago P
        INNER JOIN ct.Expensa E ON P.ID_Expensa = E.ID_Expensa
        INNER JOIN ct.Consorcio C ON E.NombreConsorcio = C.Nombre
        INNER JOIN ct.GastoExtraordinario GE ON GE.ID_Expensa = P.ID_Expensa
        WHERE P.Fecha_Pago BETWEEN @FechaInicio AND @FechaFin AND P.ID_Expensa IS NOT NULL
        UNION ALL
        -- Otros ingresos
        SELECT 
            P.ID_Pago,
            P.Fecha_Pago,
            P.Importe,
            'OTROS' AS Procedencia,
            NULL AS ID_Expensa,
            NULL AS NombreConsorcio,
            NULL AS ID_Administracion
        FROM ct.Pago P
        WHERE P.Fecha_Pago BETWEEN @FechaInicio AND @FechaFin
          AND P.ID_Expensa IS NULL
    ),
    -- CTE 2: Construcción de períodos según @TipoPeriodo
    Periodos AS (
        SELECT 
            CASE 
                WHEN @TipoPeriodo = 'ANUAL' THEN CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4))
                WHEN @TipoPeriodo = 'TRIMESTRAL' THEN 
                    CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4)) + '-T' + CAST(DATEPART(QUARTER, R.Fecha_Pago) AS VARCHAR(1))
                ELSE -- MENSUAL (default)
                    CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(R.Fecha_Pago) AS VARCHAR(2)), 2)
            END AS Periodo,

            CASE 
                WHEN @TipoPeriodo = 'ANUAL' THEN YEAR(R.Fecha_Pago)
                WHEN @TipoPeriodo = 'TRIMESTRAL' THEN YEAR(R.Fecha_Pago) * 10 + DATEPART(QUARTER, R.Fecha_Pago)
                ELSE YEAR(R.Fecha_Pago) * 100 + MONTH(R.Fecha_Pago)
            END AS OrdenPeriodo,
            R.Procedencia,
            SUM(R.Importe) AS TotalRecaudado,
            R.NombreConsorcio,
            R.ID_Administracion
        FROM RecaudacionPorProcedencia R
        WHERE (@NombreConsorcio IS NULL OR R.NombreConsorcio = @NombreConsorcio)
          AND (@ID_Administracion IS NULL OR R.ID_Administracion = @ID_Administracion)
        GROUP BY
            CASE 
                WHEN @TipoPeriodo = 'ANUAL' THEN CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4))
                WHEN @TipoPeriodo = 'TRIMESTRAL' THEN 
                    CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4)) + '-T' + CAST(DATEPART(QUARTER, R.Fecha_Pago) AS VARCHAR(1))
                ELSE 
                    CAST(YEAR(R.Fecha_Pago) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(R.Fecha_Pago) AS VARCHAR(2)), 2)
            END,
            CASE 
                WHEN @TipoPeriodo = 'ANUAL' THEN YEAR(R.Fecha_Pago)
                WHEN @TipoPeriodo = 'TRIMESTRAL' THEN YEAR(R.Fecha_Pago) * 10 + DATEPART(QUARTER, R.Fecha_Pago)
                ELSE YEAR(R.Fecha_Pago) * 100 + MONTH(R.Fecha_Pago)
            END,
            R.Procedencia,
            R.NombreConsorcio,
            R.ID_Administracion
    )

    -- PIVOT
    SELECT Periodo,
        ISNULL([ORDINARIO], 0) AS Ordinario,
        ISNULL([EXTRAORDINARIO], 0) AS Extraordinario,
        ISNULL([OTROS], 0) AS Otros,
        ISNULL([ORDINARIO], 0) + ISNULL([EXTRAORDINARIO], 0) + ISNULL([OTROS], 0) AS TotalPeriodo,
        NombreConsorcio, ID_Administracion
    FROM (
        SELECT Periodo, OrdenPeriodo, Procedencia, TotalRecaudado, NombreConsorcio, ID_Administracion
        FROM Periodos
    ) AS SourceTable
    PIVOT (
        SUM(TotalRecaudado)
        FOR Procedencia IN ([ORDINARIO], [EXTRAORDINARIO], [OTROS])
    ) AS PivotTable
    ORDER BY OrdenPeriodo;
END
GO



-- ==============  REPORTE 4  =======================

/* Obtenga los 5 (cinco) meses de mayores gastos y los 5 (cinco) de mayores ingresos. */

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'cspr.sp_MesesMayorGastoIngreso_03') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.sp_MesesMayorGastoIngreso_03 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE or ALTER PROCEDURE cspr.sp_MesesMayorGastoIngreso_03
	@fechaDesde DATE,
	@fechaHasta DATE,
	@nombreconsorcio VARCHAR(30)
AS
BEGIN	
	SET NOCOUNT ON;
-- VERIFICAR QUE EL CONSORCIO EXISTA
IF NOT EXISTS (SELECT 1 FROM CT.Consorcio WHERE Nombre= @nombreconsorcio)
BEGIN
	SELECT 'Error: El consorcio no se encuentra regristrado' AS Resultado;
	RETURN;
END;
-- CTE PARA OBTENER LOS 5 MESES DE MAYORES GASTOS
WITH topGastos AS (
		SELECT TOP 5
		FORMAT (E.Fecha, 'yyyy-MM') AS Periodo,
		E.EgresoGastoMensual AS Importe,
		'GASTO' AS Tipo
		FROM ct.EstadoFinanciero E
		WHERE E.NombreConsorcio	= @nombreconsorcio
		AND E.Fecha >= @fechaDesde
		AND E.Fecha <= @fechaHasta
		ORDER BY E.EgresoGastoMensual DESC
		),
-- CTE 2 PARA OBTENER LOS 5 MESES CON MAYORES INGRESOS
 TOPINGRESOS AS (
	SELECT TOP 5
	FORMAT (E.FECHA, 'yyyy-MM') AS Periodo, 
	E.IngresoPagoMensual AS Importe,
	'INGRESO' AS Tipo
	FROM ct.EstadoFinanciero E
	WHERE E.NombreConsorcio = @nombreconsorcio
	AND E.Fecha >= @fechaDesde
	AND E.Fecha <= @fechaHasta
	ORDER BY E.IngresoPagoMensual DESC
	)
SELECT Periodo, Importe, Tipo, @nombreconsorcio AS NombreConsorcio
FROM topgastos
UNION ALL
SELECT Periodo, Importe, Tipo, @nombreconsorcio AS NombreConsorcio
FROM TOPINGRESOS
ORDER BY Importe DESC
FOR XML AUTO, ELEMENTS;
END
GO



-- ==============  REPORTE 5  =======================

/* Obtenga los 3 (tres) propietarios con mayor morosidad. Presente informacion de contacto y
DNI de los propietarios para que la administracion los pueda contactar o remitir el tramite al
estudio juridico. */

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



-- ==============  REPORTE 6  =======================
/* Muestre las fechas de pagos de expensas ordinarias de cada UF y la cantidad de dias que
pasan entre un pago y el siguiente, para el conjunto examinado.*/ 







-- ==============  API  =======================
/*
La API actua como un eco: recibe los datos de un determinado consorcio 
y devuelve la misma informacion junto con un ID de transaccion (generalmente 101) 
para confirmar que el envio y recepcion de datos fue exitoso 
y que el formato JSON es correcto
*/

EXEC sp_configure 'show advanced options', 1;	--Permite editar los permisos avanzados.
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;	-- Aqui habilitamos esta opcion avanzada
RECONFIGURE;
GO

IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'cspr.sp_FichaInformacionConsorcio_06') AND type = 'P'
)
BEGIN
    EXEC('CREATE PROCEDURE cspr.sp_FichaInformacionConsorcio_06 AS BEGIN SET NOCOUNT ON; END')
END
GO

CREATE OR ALTER PROCEDURE cspr.sp_FichaInformacionConsorcio_06
    @NombreConsorcio VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url NVARCHAR(64) = 'https://jsonplaceholder.typicode.com/posts';
    DECLARE @Object INT;
    DECLARE @respuesta NVARCHAR(MAX);
    DECLARE @json TABLE(DATA NVARCHAR(MAX));
    DECLARE @body NVARCHAR(MAX);

    DECLARE @DireccionConsorcio NVARCHAR(100);
    DECLARE @CantUF INT;
    DECLARE @SuperficieTotal DECIMAL(20, 2);

    SELECT TOP 1 
        @DireccionConsorcio = C.Direccion,
        @CantUF = C.CantUF, 
        @SuperficieTotal = C.SuperficieTotal
    FROM ct.Consorcio C
    WHERE C.Nombre = @NombreConsorcio;

    SET @DireccionConsorcio = ISNULL(@DireccionConsorcio, 'Direccion no encontrada');
    SET @CantUF = ISNULL(@CantUF, 0);
    SET @SuperficieTotal = ISNULL(@SuperficieTotal, 0.00);

    SET @body =
    '{
	  "title":"' + @NombreConsorcio + '",
	  "body":"Direccion: ' + @DireccionConsorcio + '",
	  "CantUF": ' + CAST(@CantUF AS NVARCHAR(10)) + ', 
      "SuperficieTotal": ' + CAST(@SuperficieTotal AS NVARCHAR(20)) + '
    }';

    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
    EXEC sp_OAMethod @Object, 'OPEN', NULL, 'POST', @url, 'FALSE';
    EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
    EXEC sp_OAMethod @Object, 'SEND', NULL, @body;
    EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT;

    INSERT INTO @json EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

    SET @respuesta = (SELECT TOP 1 DATA FROM @json);

    DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)

    SELECT 
        [Titulo Enviado] = J.[NombreConsorcio],
        [Mensaje Enviado (Detalle)] = J.[Direccion],
        [Cantidad UF Confirmada] = J.[CantUF], 
        [Superficie Total Confirmada] = J.[SuperficieTotal], 
        [ID de Transaccion API] = J.[Id]
    FROM OPENJSON(@datos)
    WITH
    (
        [NombreConsorcio] NVARCHAR(256) '$.title',
        [Direccion] NVARCHAR(256) '$.body',
        [CantUF] int '$.CantUF',
        [SuperficieTotal] DECIMAL(10, 2) '$.SuperficieTotal',
        [Id] int '$.id'
    ) AS J;

    SELECT @respuesta AS [Respuesta_JSON_de_la_API];

    EXEC sp_OADestroy @Object;
END
GO