### Chapter 10 - Event Driven Messaging

## Introducción

Hasta este punto, hemos creado una plataforma que se comunica entre servicios de
forma sincrónica. Un sistema de mensajes se encuentra comunicando las
aplicaciones, pero las aplicaciones emiten solicitudes y esperan respuestas
inmediatas. Este patrón funciona muy bien para recuperar y modificar datos. ¿Qué
pasa si deseáramos notificar a los servicios cuando sucede algo en otro servicio
? Nos adentramos en la arquitectura basada en eventos.

Una arquitectura basada en eventos se puede mostrar con el siguiente ejemplo:
imaginemos dos servicios, uno es un sistema de recursos humanos y otro es un
sistema de nómina. En un sistema sincrónico, se podría crear un nuevo registro
de empleado en el registro de los recursos humanos y luego, siguiendo el flujo
de trabajo sincrónico (un callback a Active Model, una llamada desde un service
object, etc.), se podría realizar una llamada para pasar información al sistema
de nómina para crear un nuevo registro de nómina de empleado. Una ventaja de
crear software de esta manera es que el proceso es sincrónico y los errores se
pueden informar inmediatamente al usuario. Una desventaja es que estos dos
servicios están estrechamente acoplados. Si el servicio de nómina estuviera
desconectado por algún motivo, el servicio de recursos humanos parecería tener
problemas y el usuario podría percibir que todo el sistema fall y podría
proporcionar información incorrecta al informar sobre el problema.

Hay una serie de ventajas al construir sobre esta arquitectura. Una es que los
servicios pueden tener un acoplamiento flexible. Si los servicios se
construyeran sobre una arquitectura basada en eventos y el sistema de recursos
humanos estuviera en línea, el usuario podría agregar nuevos empleados y la
nómina (u otros servicios que vigilan los eventos creados por los mismos
empleados) realizarían su procesamiento en segundo plano. La experiencia
percibida por el usuario sería mejor porque el usuario interactúa con un pequeño
servicio que realiza pocas tareas; debido a que tiene menos responsabilidad,
podríamos esperar que sea una aplicación con mayor capacidad de respuesta. Lo
que sucede en segundo plano no es asunto del usuario ni está obligado a esperar
a que todos los demás servicios completen el procesamiento antes de devolver el
control al usuario.

Otra ventaja del procesamiento asincrónico en una plataforma basada en eventos
es que se pueden agregar servicios adicionales para observar los mismos eventos,
como el evento creado por los empleados mencionado anteriormente. Por ejemplo,
si más adelante se decide que todos los empleados nuevos reciban una tarjeta de
regalo para cenar semanalmente, se podría agregar un nuevo servicio a la
plataforma que observe el evento creado por el empleado. Agregar este nuevo
servicio para observar un evento existente no requeriría ninguna configuración
ni tiempo de inactividad para los servicios existentes.

## Implementación

El software que proporciona mensajes basados en eventos a veces se denomina
intermediario (broker). Algunos de los brokers más populares incluyen, entre
otros: Apache Kafka, RabbitMQ y Amazon Simple Queue Service (Amazon SQS).

Las gemas que usaremos para implementar nuestra arquitectura basada en eventos
en los próximos capítulos están diseñadas en torno a RabbitMQ, por lo que a
partir de aquí nos centraremos en las funciones proporcionadas por el agente de
mensajes RabbitMQ.

## Recapitulando

Las arquitecturas de mensajes impulsadas por eventos ofrecen numerosas ventajas.
Algunas de estas ventajas son la falta de conexión de servicios, cero tiempo de
inactividad al agregar nuevos servicios y, en algunos casos, una mejor
experiencia de usuario.

Anteriormente, implementamos el servicio NATS para enrutar mensajes entre
nuestros servicios. En el próximo capítulo, pondremos en marcha un servicio
RabbitMQ, nos suscribiremos y publicaremos eventos para ver cómo funciona un
broker de mensajes.

[Siguiente >>](120-chapter-11.es.md)
