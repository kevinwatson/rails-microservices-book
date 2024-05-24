### Capítulo 12 - El Sandbox de Mensajes Orientados a Eventos

> ¡Te voy a dar una patada por el culo, mongólico, hijo de la gran puta!
> No le dices a papá lo que tiene que hacer. Aquí no estamos cada uno por
> su lado. ¡Estamos comunicándonos MASIVAMENTE!
>
> Pappy O'Daniel, O Brother Where Art Thou?

## Introducción

En el capítulo 9, configuramos un entorno sandbox para experimentar con el
envío de mensajes Protobuf a través de una cola NATS. En este capítulo,
usaremos Docker y Docker Compose para crear un entorno y analizar exactamente
qué dependencias necesitaremos para que un publicador (traducción literal del
término en inglés _«publisher»_) y un consumidor estén en funcionamiento. El
patrón de arquitectura _«pub-sub»_ (por sus siglas en Inglés) nos permite
publicar eventos para 0 o más suscriptores, sin saber nada sobre los
destinatarios individuales.

En este entorno sandbox, crearemos un publicador y un único suscriptor. No estamos
limitados a un solo suscriptor, como lo ilustra la Listado 12-1. Usaremos el
patrón de disparar y olvidar (_«fire and forget»_) para publicar un mensaje y
se notificará a todas las partes interesadas.

![texto alternativo](images/many-subscribers-sequence-diagram.png "Editor con
muchos suscriptores que recibe un mensaje de creación de empleado")

_**Listado 12-1**_ Dispara y olvida

Para este entorno sandbox, crearemos un único publicador y un único suscriptor.

## Lo que necesitaremos

* Gemas de ruby
   * Publicador activo
   * Action Subscriber
   * Protobuf
   * Rails
* RabbitMQ
* Ruby
* SQLite

Active Publisher es una gema que facilita la configuración de un publicador
RabbitMQ en una aplicación Rails. Depende de la gema bunny que usamos
para probar en el capítulo 11.

Action Subscriber es otra gema que usaremos y que facilita la configuración de
un consumidor RabbitMQ en una aplicación Rails. Action Subscriber también
proporciona un lenguaje específico de dominio (_«DSL»_) que facilita la
definición y suscripción a colas en el servidor RabbitMQ.

Usaremos la gema Protobuf para codificar y decodificar nuestros datos como se
describe en el capítulo 8.

## Implementación

### Estructura del directorio del proyecto

Vamos a crear un directorio para nuestro proyecto. Necesitaremos tres
subdirectorios del proyecto, uno para nuestros mensajes Protobuf compartidos,
uno para nuestra aplicación Ruby on Rails de ActivePublisher que usaremos
para publicar mensajes, y un consumidor. Puede crear múltiples consumidores
para demostrar que varios clientes pueden escuchar los mismos eventos
publicados sobre la misma cola, si así lo desea.

En el capítulo 9, creamos un directorio `rails-microservices-sample-code` en
nuestro directorio principal. La ruta específica no es importante, pero si ha
estado siguiendo, podemos reutilizar algo del código que generamos en el
capítulo 9. Siguiendo el tutorial a continuación, deberíamos terminar con los
siguientes directorios (y muchos archivos y directorios en cada uno).

* rails-microservices-sample-code
  * chapter-12
    * active-publisher
    * action-subscriber
  * protobuf

### Configurar un Entorno de Desarrollo

Algunos de los pasos a continuación son los mismos que los cubiertos en el
capítulo 9. Reutilizaremos algunos de los mismos Dockerfiles lo cual mantendrá
nuestras versiones de Ruby consistentes. Los incluiremos aquí, para que no
tengamos que saltar de un capítulo a otro. Si seguimos el capítulo 9 y creamos
estos archivos, podemos saltarnos algunos de estos pasos.

Vamos a crear un builder (constructor) Dockerfile y un archivo Docker Compose.
Usaremos el archivo Dockerfile para construir una imagen con las aplicaciones
de línea de comandos que necesitamos, y usaremos un archivo de configuración de
Docker Compose para reducir la cantidad de parámetros que necesitaremos usar
para ejecutar cada comando.

Crea el siguiente archivo Dockerfile en el directorio
`rails-microservices-sample-code`. Usaremos el nombre `Dockerfile.builder` para
diferenciar el Dockerfile que usaremos para generar nuevos servicios de Rails
versus el Dockerfile que usaremos para construir y ejecutar nuestras
aplicaciones Rails.

_**Listado 12-1**_ Dockerfile usado para crear una imagen que usaremos para
generar nuestra aplicación Rails.

```dockerfile
# rails-microservices-sample-code/Dockerfile.builder

FROM ruby:2.6.5

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
    build-essential \
    protobuf-compiler \
    nodejs \
    vim

WORKDIR /home/root

RUN gem install rails -v 5.2.4
RUN gem install protobuf
```

Crearemos el siguiente archivo `docker-compose.builder.yml` en el directorio
`rails-microservices-sample-code`. Utilizaremos este archivo de configuración
para iniciar nuestro entorno de desarrollo con todas las herramientas de línea
de comandos que necesitaremos.

_**Listado 12-2**_ Archivo de Docker Compose para iniciar el contenedor que
usaremos para generar nuestra aplicación Rails.

```yaml
# rails-microservices-sample-code/docker-compose.builder.yml

version: "3.4"

services:
  builder:
    build:
      context: .
      dockerfile: Dockerfile.builder
    volumes:
      - .:/home/root
    stdin_open: true
    tty: true
```

Vamos a iniciar y conectarnos al contenedor builder. Luego ejecutaremos
los comandos de generación de Rails desde el contenedor, lo que creará dos
aplicaciones Rails. Debido a que hemos mapeado un volumen en el archivo `.yml`
anterior, los archivos que se generen se guardarán en el directorio
`rails-microservices-sample-code`. Si no mapeáramos un volumen, los archivos
que generamos solo existirían dentro del contenedor, y cada vez que
detuviéramos y reiniciáramos el contenedor, tendrían que ser regenerados.
Mapear un volumen a un directorio en la computadora principal hará que los
archivos estén disponibles a través del entorno del contenedor, que incluye una
versión específica de Ruby, Rails y las gemas que necesitaremos para ejecutar
nuestras aplicaciones.

_**Listado 12-3**_ Iniciando nuestro contenedor del constructor

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
```

El comando `run` de Docker Compose construirá la imagen (si aún no se ha
construido), iniciará el contenedor, se conectará al contenedor en ejecución y
nos proporcionará un símbolo del sistema utilizando el shell `bash`.

Ahora deberíamos ver que hemos iniciado sesión como usuario root en el
contenedor (veremos un símbolo del sistema que comienza con un signo de
almohadilla `#`).  Iniciar sesión como usuario root suele ser aceptable dentro
de un contenedor, porque el aislamiento del entorno del contenedor limita lo
que el usuario root puede hacer.

### Protobuf

Ahora crearemos un mensaje Protobuf y compilaremos el archivo `.proto` para
generar el archivo Ruby relacionado, que contendrá las clases que se copiarán
en cada una de nuestras aplicaciones Ruby on Rails. Este archivo definirá el
mensaje Protobuf, las solicitudes y las definiciones de llamadas a
procedimientos remotos.

Crearemos un par de directorios para nuestros archivos de entrada y salida. El
comando `mkdir -p` a continuación creará directorios con la siguiente
estructura:

* protobuf
  * definitions
  * lib

_**Listado 12-4**_ Creando los directorios necesarios

```console
$ mkdir -p protobuf/{definitions,lib}
```

El fichero de definición Protobuf:

_**Listado 12-5**_ Fichero Protobuf del Mensaje Employee

```protobuf
# rails-microservices-sample-code/protobuf/definitions/employee_message.proto

syntax = "proto3";

message EmployeeMessage {
  string guid = 1;
  string first_name = 2;
  string last_name = 3;
}

message EmployeeMessageRequest {
  string guid = 1;
  string first_name = 2;
  string last_name = 3;
}

message EmployeeMessageList {
  repeated EmployeeMessage records = 1;
}

```

El servicio EmployeeMessageService se utilizó para ActiveRemote en el capítulo 9
, pero no es necesario aquí. Si ya tenemos este servicio definido, podemos
dejarlo así si lo deseamos.


Para compilar los archivos `.proto`, utilizaremos una tarea Rake proporcionada
por la gema `protobuf`. Para acceder a las tareas Rake de la gema `protobuf`,
necesitaremos crear un `Rakefile`. Hagámoslo ahora.

_**Listing 12-6**_ Rakefile

```ruby
# rails-microservices-sample-code/protobuf/Rakefile

require "protobuf/tasks"
```

Ahora podemos ejecutar la tarea Rake `compile` para generar el archivo.

_**Listado 12-7**_ Iniciando el contenedor del constructor y compilando la
definición de protobuf.

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd protobuf
# rake protobuf:compile
```

Esto generará un archivo llamado `employee_message.pb.rb` en el directorio
`protobuf/lib`. Copiaremos este archivo al directorio `app/lib` en las
aplicaciones Rails que crearemos a continuación.

### Crear un Publicador de Mensajes en Rails

La primera aplicación Rails que generaremos utilizará la gema ActivePublisher
para publicar mensajes en RabbitMQ. Añadiremos la gema `active_publisher` al
archivo `Gemfile`. Luego ejecutaremos el comando `bundle` para obtener las
gemas desde https://rubygems.org. Después de obtener las gemas, crearemos el
andamiaje para una entidad Employee. Esta aplicación almacenará los datos en
una base de datos SQLite para que podamos experimentar con los eventos de
creación y actualización.

Generemos la aplicación Rails que actuará como el publicador de los eventos.
Llamaremos a esta aplicación `active-publisher`. También añadiremos la gema
Protobuf Active Record para que podamos serializar nuestro objeto Active Record
a un mensaje Protobuf.

_**Listado 12-8**_ Generando las aplicaciones Rails y los archivos necesarios

```console
$ mkdir chapter-12 # create a directory for this chapter
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-12
# rails new active-publisher
# cd active-publisher
# echo "gem 'active_publisher'" >> Gemfile
# echo "gem 'protobuf-activerecord'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# rails db:migrate
# exit
```

Asegúrate de inspeccionar la salida de cada uno de los comandos anteriores,
buscando errores. Si se encuentran errores, por favor verifica cada comando en
busca de errores tipográficos o caracteres adicionales.

Personalicemos la aplicación para servir nuestra entidad Employee a través de
Protobuf. Necesitaremos un directorio `app/lib`, y luego copiaremos el archivo
`employee_message.pb.rb` generado a este directorio.

_**Listado 12-9**_ Configurando el directorio app/lib

```console
$ mkdir chapter-12/active-publisher/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-12/active-publisher/app/lib/
```

A continuación, agregaremos un archivo de configuración `active_publisher` al
directorio `config`. Este archivo definirá cómo nuestra aplicación debería
conectarse al servidor RabbitMQ. El host `rabbit` se definirá en el archivo
`docker-compose` que definiremos en un par de minutos.

_**Listado 12-10**_ Configuración de ActivePublisher

```yml
# rails-microservices-sample-code/chapter-12/active-publisher/config/active_publisher.yml

default: &default
  host: rabbit
  username: guest
  password: guest

development:
  <<: *default
```

Ahora crearemos un inicializador para Active Publisher. Esto cargará la gema,
establecerá el adaptador y cargará el archivo de configuración. Lo haremos en el
directorio `config/initializers`.

_**Listado 12-11**_ Inicializador de Active Publisher

```ruby
# rails-microservices-sample-code/chapter-12/active-publisher/config/initializers/active_publisher.rb

require "active_publisher"

::ActivePublisher::Configuration.configure_from_yaml_and_cli
```

A continuación, modificaremos el modelo de Employee para que podamos enviar el
objeto de Employee Protobuf a RabbitMQ. Utilizaremos los callbacks de Active
Record para publicar mensajes en colas separadas de `created` y `updated`
después de que se haya creado o modificado un registro de Employee. Abre el
archivo `app/models/employee.rb` y agrega el siguiente código.

_**Listing 12-12**_ Modelo Employee de Active Record

```ruby
# rails-microservices-sample-code/chapter-12/active-publisher/app/models/employee.rb

require 'protobuf'

class Employee < ApplicationRecord
  protobuf_message :employee_message

  after_create :publish_created
  after_update :publish_updated

  def publish_created
    Rails.logger.info "Publishing employee object #{self.inspect} on the employee.created queue."
    ::ActivePublisher.publish("employee.created", self.to_proto.encode, "events", {})
  end

  def publish_updated
    Rails.logger.info "Publishing employee object #{self.inspect} on the employee.updated queue."
    ::ActivePublisher.publish("employee.updated", self.to_proto.encode, "events", {})
  end
end
```

Dado que estamos utilizando GUIDs para identificar de manera única los objetos
que estamos serializando y pasando entre servicios, modificaremos la acción
`new` del controlador para que genere un nuevo GUID.

_**Listado 12-13**_ Controlador de empleado

```ruby
# rails-microservices-sample-code/chapter-12/active-publisher/controllers/employees_controller.rb

def new
  @employee = Employee.new(guid: SecureRandom.uuid)
end
```

También necesitaremos agregar algunos detalles adicionales. Debido a que el
archivo `app/lib/employee_message.pb.rb` contiene varias clases, solo se carga
la clase que coincide con el nombre del archivo. En modo de desarrollo, Rails
puede cargar archivos de forma retardada (_«lazy load»_) siempre que el nombre
del archivo se pueda inferir a partir del nombre de la clase, por ejemplo, el
código que requiere la clase `EmployeeMessageService` intentará cargar
de manera retardada un archivo llamado `employee_message_service.rb`, y lanzará
un error si no se encuentra el archivo. Podemos separar las clases en el
archivo `app/lib/employee_message.pb.rb` en archivos separados, o habilitar la
carga ansiosa (_«eager load»_) en la configuración. En esta demostración
habilitaremos la carga ansiosa y también almacenaremos en caché las clases.
También necesitaremos configurar el registro para enviar la salida a los
registros de Docker.

_**Listado 12-14**_ Configuración de desarrollo

```ruby
# rails-microservices-sample-code/chapter-12/active-publisher/config/environments/development.rb

Rails.application.configure do
  ...
  config.cache_classes = true
  ...
  config.eager_load = true
  ...
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
end
```

Eso es todo. Ahora construyamos nuestro suscriptor.

### Crear un Suscriptor de Mensajes

Crearemos la aplicación `action-subscriber` la cual se suscribirá a las colas de
mensajes `created` y `updated` de Employee y simplemente registrará que
recibió un mensaje en la cola.

_**Listado 12-15**_ Generando las aplicaciones Rails y los archivos necesarios

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-12
# rails new action-subscriber --skip-active-record
# cd action-subscriber
# echo "gem 'action_subscriber'" >> Gemfile
# echo "gem 'protobuf'" >> Gemfile
# bundle
# exit
```

Ahora configuraremos Action Subscriber para escuchar eventos. Necesitaremos
agregar una clase `EmployeeSubscriber` y añadir rutas a través del método
`ActionSubscriber.draw_routes`.

Colocaremos nuestras clases suscriptoras en su propio directorio `subscribers`.
También necesitaremos el directorio `lib` donde copiaremos nuestra clase
Protobuf de Employee. Crearemos estos directorios y copiaremos los archivos a
uno de esos directorios:

_**Listado 12-16**_ Generando directorios de la aplicación Rails y copiando la
clase de mensaje

```console
$ mkdir chapter-12/action-subscriber/app/{lib,subscribers}
$ cp protobuf/lib/employee_message.pb.rb chapter-12/action-subscriber/app/lib/
```

Ahora agregaremos la clase suscriptora y para mantenerla simple: solo
registraremos que recibimos el mensaje.

_**Listado 12-17**_ Clase suscriptora de Employee

```ruby
# rails-microservices-sample-code/chapter-12/action-subscriber/app/subscribers/employee_subscriber.rb

class EmployeeSubscriber < ::ActionSubscriber::Base
  def created
    Rails.logger.info "Received created message: #{EmployeeMessage.decode(payload).inspect}"
  end

  def updated
    Rails.logger.info "Received updated message: #{EmployeeMessage.decode(payload).inspect}"
  end
end
```

Nuestra aplicación necesita saber a qué colas suscribirse, por lo que usamos el
método `default_routes_for`, que leerá nuestra clase `EmployeeSubscriber` y
generará colas para cada uno de nuestros métodos públicos o se suscribirá a
esas colas si ya existen. El nombre de host `host.docker.internal` es un nombre
de host especial de Docker, que apunta a la dirección IP de la máquina
anfitriona.

_**Listado 12-18**_ Inicializador de Action Subscriber

```ruby
# rails-microservices-sample-code/chapter-12/action-subscriber/config/initializers/action_subscriber.rb

ActionSubscriber.draw_routes do
  default_routes_for EmployeeSubscriber
end

ActionSubscriber.configure do |config|
  config.hosts = ["host.docker.internal"]
  config.port = 5672
end
```

Necesitaremos habilitar las configuraciones `cache_classes` y `eager_load`, de
la misma manera que lo hicimos para el publicador. También necesitaremos
configurar un registrador (_«logger»_) para poder ver la salida del registro desde nuestro
contenedor Docker.

_**Listado 12-19**_ Configuración de desarrollo

```ruby
# rails-microservices-sample-code/chapter-12/action-subscriber/config/environments/development.rb

config.cache_classes = true
...
config.eager_load = true
...
logger           = ActiveSupport::Logger.new(STDOUT)
logger.formatter = config.log_formatter
config.logger    = ActiveSupport::TaggedLogging.new(logger)
```

### Crear y Configurar Nuestro Entorno

Por último, pero no menos importante, agregaremos archivos `Dockerfile` y
`docker-compose.yml` para construir una imagen y poner en marcha nuestros
contenedores de Rails y RabbitMQ. Es posible que el `Dockerfile` ya exista
desde el sandbox que construimos en el capítulo 9, pero si no es así, tiene el
mismo contenido aquí. El archivo `docker-compose.yml` es nuevo.

_**Listado 12-20**_ Dockerfile del Sandbox

```dockerfile
# rails-microservices-sample-code/Dockerfile

FROM ruby:2.6.5

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential nodejs

ENV INSTALL_PATH /usr/src/service
ENV HOME=$INSTALL_PATH PATH=$INSTALL_PATH/bin:$PATH
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install rails -v 5.2.4

ADD Gemfile* ./
RUN set -ex && bundle install --no-deployment
```

El siguiente archivo Docker Compose incluye una instancia de RabbitMQ y
nuestras nuevas aplicaciones Rails `active-publisher` y `action-subscriber`.
Expondremos la aplicación web en el puerto 3001. RabbitMQ puede tardar unos
segundos en iniciarse, así que configuraremos nuestro servicio
`action-subscriber` para que se reinicie si no puede conectarse. En una
aplicación del mundo real, querremos verificar la respuesta de RabbitMQ antes
de iniciar el suscriptor.

Normalmente, agregaríamos el suscriptor al mismo archivo Docker Compose, pero
como el servicio Action Subscriber intenta conectarse inmediatamente y RabbitMQ
puede tardar unos segundos en cargarse, ejecutaremos el proceso de suscriptor
desde un archivo Docker Compose separado. También necesitaremos exponer el
puerto 5672 a la máquina host para que podamos conectar desde otro entorno de
orquestación (_«Compose environment»_).

_**Listado 12-21**_ Archivo Docker Compose del Sandbox

```yml
# rails-microservices-sample-code/chapter-12/docker-compose.yml
# Usage: docker-compose up

version: "3.4"

services:
  active-publisher:
    build:
      context: ./active-publisher
      dockerfile: ../../Dockerfile
    command: bundle exec puma -C config/puma.rb
    volumes:
    - ./active-publisher:/usr/src/service
    ports:
    - 3001:3000
    depends_on:
    - rabbit
  rabbit:
    image: rabbitmq:latest
    ports:
    - 5672:5672
```

Ahora agregaremos el archivo de configuración `action-subscriber`. Teniendo en
cuenta que debido a que el ejecutable Action Subscriber genera un proceso
secundario para escuchar eventos desde RabbitMQ, perdemos la salida de registro
si iniciamos el contenedor usando el comando `up`. Para ver toda la información
de registro en la terminal, usaremos el comando `run` de Docker Compose para
iniciar un shell bash y ejecutar nuestro ejecutable `action_subscriber` allí.

_**Listado 12-22**_ Archivo Docker Compose del suscriptor del Sandbox

```yml
# rails-microservices-sample-code/chapter-12/docker-compose-subscriber.yml
# Usage: docker-compose -f docker-compose-subscriber.yml run action-subscriber bash -c 'bundle exec action_subscriber start'

version: "3.4"

services:
  action-subscriber:
    build:
      context: ./action-subscriber
      dockerfile: ../../Dockerfile
    volumes:
    - ./action-subscriber:/usr/src/service

```

Ahora que todo está en su lugar, iniciemos nuestro entorno sandbox. Dado que ya
podríamos tener un archivo `docker-compose.yml` en el directorio, hemos
nombrado nuestros nuevos archivos de configuración `docker-compose.yml` y
`docker-compose-subscriber.yml`. Si ejecutáramos la versión más corta del
comando `docker-compose up`, por defecto buscaría y cargaría el archivo
`docker-compose.yml`. Podemos usar la opción `-f` para especificar que
queremos usar otros archivos de configuración en su lugar. Ejecutaremos esos
comandos ahora.

_**Listado 12-23**_ Iniciando el sandbox

```console
$ cd chapter-12
$ docker-compose up
```

Una vez que veas líneas como estas, RabbitMQ ha iniciado y la aplicación Rails
Active Publisher se ha conectado correctamente.

_**Listado 12-24**_ Registro del Sandbox

```console
rabbit_1            | 2020-02-09 22:54:02.253 [info] <0.8.0> Server startup complete; 0 plugins started.
rabbit_1            |  completed with 0 plugins.
72.30.0.2:5672)
rabbit_1            | 2020-02-09 22:54:37.395 [info] <0.641.0> connection <0.641.0> (172.30.0.1:53140 -> 172.30.0.2:5672): user 'guest' authenticated and granted access to vhost '/'
```

Ahora vamos a iniciar el suscriptor en otra ventana de la terminal.

_**Listado 12-25**_ Iniciando el sandbox del suscriptor

```console
$ docker-compose -f docker-compose-subscriber.yml run action-subscriber bash -c 'bundle exec action_subscriber start'
```

Deberíamos ver una salida como la siguiente.

_**Listado 12-26**_ Registro del sandbox del suscriptor

```console
I, [2020-02-09T22:54:53.900735 #1]  INFO -- : Loading configuration...
I, [2020-02-09T22:54:53.902758 #1]  INFO -- : Requiring app...
I, [2020-02-09T22:54:59.308155 #1]  INFO -- : Starting server...
I, [2020-02-09T22:54:59.374240 #1]  INFO -- : Rabbit Hosts: ["host.docker.internal"]
Rabbit Port: 5672
Threadpool Size: 1
Low Priority Subscriber: false
Decoders:
  --application/json
  --text/plain

I, [2020-02-09T22:54:59.374419 #1]  INFO -- : Middlewares [
I, [2020-02-09T22:54:59.374488 #1]  INFO -- : [ActionSubscriber::Middleware::ErrorHandler, [], nil]
I, [2020-02-09T22:54:59.374542 #1]  INFO -- : [ActionSubscriber::Middleware::Decoder, [], nil]
I, [2020-02-09T22:54:59.374944 #1]  INFO -- : ]
I, [2020-02-09T22:54:59.375946 #1]  INFO -- : EmployeeSubscriber
I, [2020-02-09T22:54:59.376504 #1]  INFO -- :   -- method: created
I, [2020-02-09T22:54:59.376856 #1]  INFO -- :     --  threadpool: default (1 threads)
I, [2020-02-09T22:54:59.378129 #1]  INFO -- :     --    exchange: events
I, [2020-02-09T22:54:59.379231 #1]  INFO -- :     --       queue: actionsubscriber.employee.created
I, [2020-02-09T22:54:59.379911 #1]  INFO -- :     -- routing_key: employee.created
I, [2020-02-09T22:54:59.380686 #1]  INFO -- :     --    prefetch: 2
I, [2020-02-09T22:54:59.382130 #1]  INFO -- :   -- method: updated
I, [2020-02-09T22:54:59.382702 #1]  INFO -- :     --  threadpool: default (1 threads)
I, [2020-02-09T22:54:59.383237 #1]  INFO -- :     --    exchange: events
I, [2020-02-09T22:54:59.383626 #1]  INFO -- :     --       queue: actionsubscriber.employee.updated
I, [2020-02-09T22:54:59.384405 #1]  INFO -- :     -- routing_key: employee.updated
I, [2020-02-09T22:54:59.384667 #1]  INFO -- :     --    prefetch: 2
I, [2020-02-09T22:54:59.393366 #1]  INFO -- : Action Subscriber connected
```

Estas líneas de registro indican que el suscriptor se ha conectado al servidor
correctamente, se ha conectado a dos colas y ahora está escuchando eventos.

Crearemos algunos eventos. Vayamos al navegador y carguemos la página
http://localhost:3001/employees. El puerto 3001 es el puerto que hemos expuesto
desde la aplicación Rails Active Publisher en el archivo `docker-compose.yml`.
Deberías ver una página web simple con el título **Empleados** y un enlace
'Nuevo Empleado'. Continuemos y hagamos clic en el enlace. Ahora deberíamos
poder crear un nuevo registro de empleado en el formulario web. Una vez que lo
completemos y hagamos clic en el botón 'Crear Empleado', varias cosas
sucederán.  Primero, los datos del formulario se enviarán de vuelta a la
aplicación Rails Active Publisher. El controlador pasará esos datos a Active
Record, que creará un nuevo registro en la base de datos SQLite. A
continuación, se ejecutará el callback `after_create`, codificando nuestro
mensaje Protobuf y colocándolo en la cola `actionsubscriber.employee.created`.
RabbitMQ notificará a los suscriptores de una cola específica de cualquier
mensaje nuevo. Nuestra aplicación Rails Action Subscriber es uno de esos
suscriptores. En nuestro método manejador de eventos (_«event handler»_)
`EmployeeSubscriber#created`, escribimos código para registrar que recibimos un
mensaje. Si inspeccionas la salida desde la ventana de la terminal donde
iniciamos la aplicación Rails Action Subscriber, deberías ver una salida como
la siguiente.

_**Listado 12-27**_ Más registro del sandbox del suscriptor

```console
I, [2020-02-09T23:14:31.163127 #1]  INFO -- : RECEIVED 7a99f6 from actionsubscriber.employee.created
I, [2020-02-09T23:14:31.163758 #1]  INFO -- : START 7a99f6 EmployeeSubscriber#created
Received created message: #<EmployeeMessage guid="8da26c71-b9a2-4219-9499-7d475fc92c6b" first_name="Rocky" last_name="Balboa">
I, [2020-02-09T23:14:31.164414 #1]  INFO -- : FINISHED 7a99f6
```

¡Felicidades! Hemos construido con éxito una plataforma de mensajería que puede
publicar y responder a eventos. Intentemos editar el registro que acabamos de
crear.  Deberíamos ver una salida similar en la aplicación Rails Action
Subscriber mientras recibe y procesa el evento y los datos. Para aún más
diversión, intentemos poner en marcha un segundo o tercer servicio suscriptor
que escuche las mismas colas y observemos cómo todos ellos responden
simultáneamente al mismo mensaje publicado.

## Recursos

* https://docs.docker.com/compose/reference/run
* https://github.com/mxenabled/active_publisher
* https://github.com/ruby-protobuf/protobuf/wiki/Serialization

## Conclusión

En este capítulo, iniciamos un servicio RabbitMQ, construimos una aplicación
Rails Active Publisher y una aplicación Rails Action Subscriber. Hicimos
funcionar esos servicios usando dos entornos Docker separados, y publicamos y
consumimos mensajes. Revisamos los registros donde pudimos ver que los mensajes
Protobuf se enviaron correctamente de una aplicación Rails a otra.

En el próximo capítulo, vamos a combinar los dos entornos para crear una
plataforma que pueda recuperar datos de otros servicios según sea necesario.
¡Pero eso no es todo! También agregaremos escuchas de eventos a nuestros
servicios para responder a eventos de otros servicios.

[Próximo >>](140-chapter-13.es.md)
