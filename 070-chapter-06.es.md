### Chapter 6 - Messaging Systems - NATS
### Capítulo 6 - Sistemas de Mensajes - NATS

> Existen alrededor de 7 octillones de atómos en el cuerpo humano. Eso es una
cantidad absurda de átomos para desensamblar, retroceder en el espacio-tiempo y
luego reensamblar en perfecto orden. - Elan Mastai, Todos nuestros presentes
equivocados

## Introducción

Los sistemas de mensajes son un componente crítico cuando se diseñan sistemas
distribuidos. Se utilizan para proporcionar a la arquitectura de su plataforma,
una capa que se utiliza para mezclar mensajes entre servicios. Una capa de
mensaje proporciona un punto de acceso para que los servicios se comuniquen.
Cada servicio solo necesita saber cómo comunicarse con la cola de mensajes, a
qué colas suscribirse y en qué colas escuchar.

NATS es uno de esos sistemas de mensajes que brinda seguridad, flexibilidad,
es escalable y puede cumplir con los requisitos de rendimiento de la mayoría de
las plataformas. Al momento de escribir este libro, NATS tiene clientes escritos
en más de 30 lenguajes de programación.

En este capítulo, pondremos en marcha un servidor NATS. Lo probaremos publicando
y suscribiéndonos a los mensajes usando un cliente telnet.

## Hagámoslo

Usemos Docker para ejecutar un servidor NATS local y enviarle mensajes.
Incluiremos una imagen de BusyBox para que podamos ejecutar comandos de telnet
para probar NATS.

**Ejemplo 6-1** Fichero Docker compose, NATS y BusyBox

```yml
# ~/projects/nats/docker-compose.yml
# usage: docker-compose up

version: "3.4"

services:
  nats:
    image: nats:latest
    ports:
      - 4222:4222
      - 8222:8222
    stdin_open: true
  busybox:
    image: busybox:latest
    stdin_open: true
```

Guarde el archivo con el nombre de archivo `docker-compose.yml`. Ahora cambiemos
a ese directorio y ejecutemos los contenedores. Las versiones del software y la
salida pueden diferir de lo que ve en su terminal.

**Ejemplo 6-2** Iniciar NATS y Busybox

```console
$ cd ~/projects/nats
$ docker-compose up
Starting nats_nats_1    ... done
Starting nats_busybox_1 ... done
Attaching to nats_busybox_1, nats_nats_1
nats_1     | [1] 2019/10/07 13:53:36.029873 [INF] Starting nats-server version 2.0.2
...
nats_1     | [1] 2019/10/07 13:53:36.032328 [INF] Listening for client connections on 0.0.0.0:4222
...
nats_1     | [1] 2019/10/07 13:53:36.033766 [INF] Server is ready
```

Crear un suscriptor es simple. Abriremos una sesión NATS con telnet. Telnet es
una aplicación cliente que nos permitirá enviar comandos basados en texto a
NATS. Proporcionaremos un subject (en el ejemplo 6-3 crearemos un asunto llamado
'mensajes') y también proporcionaremos un _identificador de suscripción_. El
identificador de suscripción puede ser un número o una cadena. Usaremos la
palabra clave `sub` para crear y suscribirnos al subject. Docker Compose
proporciona un conveniente comando `exec` para conectarse y acceder a un
contenedor en ejecución. Usaremos el comando `exec` para iniciar sesión en el
contenedor BusyBox en ejecución y suscribirnos a través de telnet.

**Ejemplo 6-3** Suscribirse a un subject

```console
$ docker-compose exec busybox sh
/ # telnet nats 4222 # you'll need to type this line
...
sub messages 1 # and this line
+OK # this is the acknowledgement from NATS
```

Abramos una nueva terminal y creemos un publisher. El cliente del publisher
deberá proporcionar el nombre del subject en el que desea publicar el mensaje.
Junto con el subject, el cliente también proporcionará la cantidad de bytes que
se publicarán. Si falta el número de bytes o es incorrecto, el editor no está
siguiendo el protocolo NATS y el mensaje será rechazado.

Ejecutemos un comando telnet para publicar mensajes en NATS.

**Ejemplo 6-4** Publicar en un subject

```console
$ docker-compose exec busybox sh
/ # telnet nats 4222 # you'll need to type this line
...
pub messages 12 # and this line
Hello WORLD! # and this line
+OK
```

Deberíamos ver el mensaje `Hello WORLD!` en la ventana de la terminal donde nos
suscribimos al subject (Ejemplo 6-3). Esto demuestra que tenemos un servidor
NATS en ejecución, publicamos un mensaje en un subject y nuestro suscriptor
recibió el mensaje. Puede presionar `Ctrl-C` y luego la letra `e` para salir de
la sesión de telnet, y luego `Ctrl-D` o escribir `exit` para volver al símbolo
del sistema de la máquina host.

NATS también proporciona una API de monitoreo que podemos consultar para
controlar cuántos mensajes se envían a través del servidor, etc. Debido a que
estamos exponiendo el puerto NATS 8222 fuera del entorno de Docker (consulte el
archivo `docker-compose.yml` en Ejemplo 6-2), podemos ver el resultado abriendo
el navegador en nuestra máquina host en la siguiente dirección:
[http://localhost:8222](http://localhost:8222). Una página debe aparecer en su
navegador, con un puñado de enlaces. Si tuviéramos que configurar un grupo de
servidores NATS, aparecerían enlaces adicionales.

En el momento de escribir este libro, hay 5 enlaces en la página. Veamos
brevemente cada uno de ellos:

* [varz](http://localhost:8222/varz) - Información general acerca del estado
del servidor y la configuración
* [connz](http://localhost:8222/connz) - Información más detallada sobre las
connexiones actuales y las que han sido cerradas.
* [routez](http://localhost:8222/routez) - Información sobre las rutas activas
para un clúster.
* [subsz](http://localhost:8222/subsz) - Información detallada sobre las
suscripciones actuales y la estructura de datos de enrutamiento.
* [help](https://docs.nats.io/nats-server/configuration/monitoring) - Un enlace
a la documentación de NATS.

Algunos de los puntos de acceso anteriores también pueden recibir querystrings
a la hora de hacer el request, Ej. http://localhost:8222/connz?sort=start,
lo que ordenará las conexiones por hora de inicio. Consulte la documentación de
NATS para obtener más información sobre estos puntos de accesoy sus opciones.

## Recursos

* https://docs.docker.com/compose
* https://hub.docker.com/_/nats
* https://nats.io
* https://docs.nats.io/nats-server/configuration/monitoring

## Recapitulando

Los sistemas de mensajes son una capa en una arquitectura de sistema que le
permite construir una plataforma asincrónica, confiable, desacoplada y
escalable. NATS es un sistema de mensajes que es simple de configurar y usar.

En este capítulo, levantamos con éxito un servidor NATS local, creamos un
subject, luego publicamos y nos suscribimos a los mensajes de ese subject.
También aprendimos sobre la instrumentación que proporciona NATS.

En el próximo capítulo, analizaremos los datos estructurados y qué tipos de
llaves usar para compartir datos entre sistemas. En el capítulo 9,
configuraremos un entorno de microservicio que consiste en dos aplicaciones
Rails que usarán NATS para compartir datos.

[Next >>](080-chapter-07.md)
