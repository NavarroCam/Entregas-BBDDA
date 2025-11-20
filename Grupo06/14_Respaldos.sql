/*
Entrega 7 - Requisitos de Seguridad
La información de cada expensa generada es de vital importancia para el negocio, por ello se
requiere que se establezcan políticas de respaldo tanto en las ventas diarias generadas como
en los reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma. No es necesario que incluya el código de creación de los respaldos.
Debe documentar la programación (Schedule) de los backups por día/semana/mes (de
acuerdo con lo que decidan) e indicar el RPO.*/

/*
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

/* La estrategia de respaldo planteada por el equipo toma en consideración que la información financiera que se maneja
en la administración es de vital importancia por este motivo proponemos una política de respaldo adecuada que tome en cuenta 
este aspecto.

Dada la importancia de la protección de los pagos nos encontramos en la necesidad de aplicar un RPO
bajo de 15 minutos, utilizando la estrategia de un modelo de Recuperación FULL junto con un log de transacciones constante.


Frecuencia de Respaldos:
------------------------
* Se realizara un respaldo Completo (full) el mismo será semanal y se programara en el periodo de mínima actividad siendo 
este un domingo a las 02.00 AM. Este tipo de respaldo nos permite una restauración íntegra ante fallas mayores.

* Se realizara un respaldo diferencial que se ejecutara de forma diaria (00:30 hs), 
se registrarán todos los cambios desde el último Full apuntando a mantener archivos livianos y tiempos de copia eficientes.

* Se realizara un respaldo de log de transacciones que se ejecutara de forma constante cada 15 minutos 24/7. El mismo nos 
permite recuperar la base de datos hasta un punto específico.

* Se generará un respaldo FULL mensual para auditorias y controles de cierre.


Tiempo de Guardado de los Respaldos:
------------------------------------
* Sobre el tiempo de guardado de respaldo optaremos para los respaldos full mensuales el guardado por 1 año en almacenamiento local y 
5 a 10 años en el almacenamiento externo de la nube, del respaldo diferencial se conservará solo hasta la ejecución del siguiente 
FULL Semanal. Los FULL Semanales se guardarán por 6 meses. Por último, el respaldo de log de transacción se guardarán por 24 horas.

* De acuerdo a la estrategia planteada el RPO será de 15 minutos, lo cual se consigue por el respaldo de Log de transacciones constante, 
así que la perdida de datos tendrá como tiempo máximo 15 minutos.


Pruebas y Validacion:
---------------------
* El tiempo de recuperación (RTO) será menor a 4 horas esto se logra por el uso del respaldo diferencial diario junto con el Log de 
transacciones.

* Con respecto a las pruebas y validaciones de integridad los simulacros de restauración serán semanalmente para garantizar la integridad
de los respaldos y validar el RTO. Los simulacros incluirán: la restauración FULL semanal, aplicar el diferencial más reciente y aplicar 
la cadena de logs correspondiente.


Politicas de Almacenamiento, Acceso y Validacion:
-------------------------------------------------
* Con respecto a las políticas de almacenamiento, acceso y validación aplicaremos las necesarias para asegurar
que los backups estén protegidos contra fallos locales o ataques externos. Por eso contaremos con un servicio
externo con almacenamiento en la Nube en donde se guardaran las copias de los respaldos semanales, diarios y mensuales las mismas  
también se guardarán en el almacenamiento local. 

* Acceso Restringido: Se deja establecido que solo el personal autorizado (DBA) podrá acceder a estos respaldos, evitando modificaciones o robo de datos.*/