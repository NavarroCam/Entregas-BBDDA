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
 - ct ? Creacion de tablas
 - csp ? Creacion de Store Procedures de Importación

*/