### Capítulo 11 - Sistemas de Mensajes - Rabbit MQ

## Introducción

RabbitMQ es una de las muchas implementaciones de intermediarios de mensajes.
Proporciona muchas funciones, como cola de mensajes, compatibilidad con
múltiples protocolos de mensajería y acuse de recibo de entrega. Discutiremos
algunas de estas características en este capítulo.

Ejecutaremos RabbitMQ de la misma manera que ejecutamos NATS en el capítulo 6:
Docker lo hace fácil. Seguiremos la mayoría de los mismos pasos pero con un
archivo docker-compose.yml ligeramente diferente.

## Ejecutémoslo

Ejecutemos un servidor RabbitMQ local y enviémosle mensajes. Incluiremos una
imagen de Ruby para que podamos crear un cliente Ruby para enviar y recibir
mensajes de colas en el servidor RabbitMQ. Con NATS usamos telnet para enviar y
recibir mensajes simples de pruebas; con RabbitMQ necesitaremos construir
mensajes binarios que enviaremos a RabbitMQ.

_**Paso #1**_ Fichero de Docker Compose con RabbitMQ y Ruby

```yml
# ~/projects/rabbitmq/docker-compose.yml
# usage: docker-compose up

version: "3.4"

services:
  rabbit:
    image: rabbitmq:latest
    ports:
      - 5672:5672
    stdin_open: true
  ruby:
    image: ruby:2.6.5
    stdin_open: true
```

Cree un archivo con el nombre `docker-compose.yml` e incluya el código anterior
como su contenido. Ahora cambiemos a ese directorio y ejecutemos los
contenedores. Las versiones del software y la salida pueden diferir de lo que ve
en su terminal.

_**Paso #2**_ Ejecutar RabbitMQ y Ruby

```console
$ cd ~/projects/rabbitmq
$ docker-compose up
Starting rabbitmq_ruby_1 ... done
Creating rabbitmq_rabbit_1  ... done
Attaching to rabbitmq_ruby_1, rabbitmq_rabbit_1
ruby_1    | Switch to inspect mode.
rabbit_1   |  Starting RabbitMQ 3.8.2 on Erlang 22.2.3
...
rabbit_1   |   ##  ##      RabbitMQ 3.8.2
rabbit_1   |   ##  ##
rabbit_1   |   ##########  Copyright (c) 2007-2019 Pivotal Software, Inc.
rabbit_1   |   ######  ##
rabbit_1   |   ##########  Licensed under the MPL 1.1. Website: https://rabbitmq.com
...
rabbit_1   |   Starting broker...2020-01-25 14:18:45.535 [info] <0.267.0>
...
rabbit_1   | 2020-01-25 14:18:46.099 [info] <0.8.0> Server startup complete; 0 plugins started.
```

Ahora vamos a utilizar el patrón productor/comsumidor para una mayor y mejor
comprensión. Crear un productor es simple: nos conectaremos al contenedor Ruby y
ejecutaremos IRB para crear una conexión, un canal y una cola. Crearemos un
mensaje en una nueva ventana de terminal.

_**Paso #3**_ Crear un mensage

```console
$ docker-compose exec ruby bash
/# gem install bunny # install the bunny gem
...
/# irb
irb(main):001:0> require 'bunny'
irb(main):002:0> connection = Bunny.new(hostname: 'rabbit') # the 'rabbit' hostname was defined as the service name in the docker-compose.yml file
irb(main):003:0> connection.start
irb(main):004:0> channel = connection.create_channel # create a new channel
irb(main):005:0> queue = channel.queue('hello') # create a queue
irb(main):006:0> channel.default_exchange.publish('Hello World', routing_key: queue.name) # encode a string to a byte array and publish the message to the 'hello' queue
```

Crear un consumidor es casi tan simple como crear un productor. Crearemos una
conexión, un canal y una cola. El comando `queue` se suscribirá a colas con el
mismo nombre o, si no existe, creará una nueva cola.

Abramos otra ventana de terminal y ejecutemos los comandos listados en el paso
#4.

_**Paso #4**_ Consumir mensajes

```console
$ docker-compose exec ruby bash
/# irb
irb(main):001:0> require 'bunny'
irb(main):002:0> connection = Bunny.new(hostname: 'rabbit') # the 'rabbit' hostname was defined as the service name in the docker-compose.yml file
irb(main):003:0> connection.start
irb(main):004:0> channel = connection.create_channel # create a new channel
irb(main):005:0> queue = channel.queue('hello') # create a queue (or connect to an existing queue if it already exists)
irb(main):006:0> queue.subscribe(block: true) do |_delivery_info, _properties, body|
irb(main):007:1*     puts "- Received #{body}"
irb(main):008:0> end
- Received Hello World
```

Deberíamos ver el mensaje "- Received Hello World" en la ventana de terminal
donde consumimos el mensaje (Listado 11-4). Esto demuestra que tenemos el
servidor RabbitMQ ejecutándose, publicamos un mensaje en una cola y nuestro
consumidor recibió el mensaje. Volvamos a la sesión IRB que comenzamos en el
paso #3 y publiquemos otro mensaje.

_**Paso #5**_ Publicar un segundo mensaje

```console
irb(main):007:0> channel.default_exchange.publish('We thought you were a toad!', routing_key: queue.name) # encode and publish another message
irb(main):008:0> connection.close # the message has been sent, so let's close the connection
```

Si regresamos a la terminal en el paso #4 donde creamos un consumidor,
deberíamos ver tanto '- Received Hello World' como '- Received We thought you
were a toad!'. ¡Felicidades! Hemos iniciado con éxito un servidor RabbitMQ y un
par de clientes Ruby para publicar y consumir mensajes.

Cuando hayamos terminado, usemos `Ctrl-C` para salir de la terminal de
consumidor RabbitMQ y luego `Ctrl-D` o escribir `exit` para regresar al símbolo
del sistema de la máquina host.

## Recursos

* https://www.rabbitmq.com/tutorials

## Recapitulando

Los sistemas de mensajería basados en eventos son una capa en la arquitectura
del sistema que le permite construir una plataforma asincrónica, confiable,
desacoplada y escalable. Junto con NATS, RabbitMQ es uno de esos sistemas de
mensajería fácil de configurar y usar.

En este capítulo, pusimos en marcha con éxito un servidor RabbitMQ local,
creamos una cola y luego publicamos y consumimos mensajes en esa cola.

En el próximo capítulo analizaremos un par de gemas de Ruby que facilitan la
configuración y puesta en marcha de nuestros clientes RabbitMQ.

[Siguiente >>](130-chapter-12.es.md)
