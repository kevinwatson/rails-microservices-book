### Capítulo 13 - Entorno de Eventos con Active Remote

## Introducción

Hasta ahora, hemos construido dos servicios de Rails que pueden comunicarse
entre sí mediante Active Remote y NATS. También hemos construido dos servicios
de Rails diferentes que se comunican entre sí mediante Active Publisher, Action
Subscriber y RabbitMQ. A medida que crecen los requisitos de tu negocio, puedes
encontrar la necesidad de usar ambos en tu entorno: Active Remote para la
comunicación en tiempo real entre servicios y Active Subscriber para la
mensajería basada en eventos.

Afortunadamente, ya hemos sentado las bases para este tipo de plataforma. En
este capítulo, pondremos en marcha un nuevo entorno sandbox que utiliza tanto
NATS como RabbitMQ para comunicar y publicar mensajes.

_**Figura 13-1**_ Creando un empleado y notificando a todas las partes
interesadas

![alt text][]

## Qué Necesitaremos

* NATS
* RabbitMQ
* Ruby
* Gems de Ruby
  * Active Publisher
  * Active Remote
  * Action Subscriber
  * Protobuf
  * Rails
* SQLite

## Implementación

### Estructura del Directorio del Proyecto

Vamos a crear un directorio para nuestro proyecto. Necesitaremos tres
subdirectorios del proyecto: uno para nuestros mensajes Protobuf compartidos,
uno para nuestra aplicación Ruby on Rails con Active Publisher que usaremos
para publicar mensajes y un consumidor. Podrías crear múltiples consumidores
para demostrar que varios clientes pueden escuchar los mismos eventos
publicados en la misma cola.

En el capítulo 9, creamos un directorio `rails-microservices-sample-code` en
nuestro directorio de inicio. La ruta específica no es importante, pero si has
estado siguiendo, podemos reutilizar parte del código que generamos en el
capítulo 9. Siguiendo el tutorial en este capítulo, deberías terminar con los
siguientes directorios (y muchos archivos y directorios en cada directorio).

* rails-microservices-sample-code
  * chapter-13
    * active-record
    * active-remote-publisher
    * action-subscriber
  * protobuf

### Configurar un Entorno de Desarrollo

Algunos de los pasos a continuación son los mismos que los pasos cubiertos en
los capítulos 9 y 12. Reutilizaremos algunos de los mismos Dockerfiles que
mantendrán nuestras versiones de Ruby consistentes. Los incluiré aquí, solo
para que no tengamos que saltar de un capítulo a otro. Si seguiste los
capítulos 9 y 12 y creaste estos archivos, puedes saltarte algunos de estos
pasos.

Let's create a builder Dockerfile and Docker Compose file. We'll use the
Dockerfile file to build an image with the command-line apps we need, and we'll
use a Docker Compose configuration file to reduce the number of parameters
we'll need to use to run each command.

Crea el siguiente archivo Dockerfile en el directorio
`rails-microservices-sample-code`. Usaremos el nombre `Dockerfile.builder` para
diferenciar el Dockerfile que usaremos para generar nuevos servicios de Rails
del Dockerfile que usaremos para construir y ejecutar nuestras aplicaciones
Rails.

_**Listado 13-2**_ Dockerfile usado para crear una imagen que utilizaremos para
generar nuestra aplicación Rails

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

Crea el siguiente archivo `docker-compose.builder.yml` en el directorio
`rails-microservices-sample-code`. Usaremos este archivo de configuración para
iniciar nuestro entorno de desarrollo con todas las herramientas de línea de
comandos que necesitaremos.

_**Listado 13-3**_ Archivo Docker Compose para iniciar el contenedor que
utilizaremos para generar nuestra aplicación Rails

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

Vamos a iniciar y acceder al contenedor builder. Luego ejecutaremos los
comandos de generación de Rails desde el contenedor, lo que creará dos
aplicaciones Rails. Debido a que hemos asignado un volumen en el archivo `.yml`
anterior, los archivos que se generen se guardarán en el directorio
`rails-microservices-sample-code`. Si no asignamos un volumen, los archivos que
generamos solo existirían dentro del contenedor, y cada vez que detengamos y
reiniciemos el contenedor tendrían que ser regenerados. Asignar un volumen a un
directorio en el host permitirá que los archivos se sirvan a través del entorno
del contenedor, que incluye una versión específica de Ruby, Rails y las gems
que necesitaremos para ejecutar nuestras aplicaciones.

_**Listado 13-4**_ Iniciando nuestro contenedor builder

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
```

El comando `run` de Docker Compose construirá la imagen (si no se ha construido
ya), iniciará el contenedor, se conectará por ssh al contenedor en ejecución y
nos dará un prompt de comandos usando el shell `bash`.

Ahora deberías ver que has iniciado sesión como el usuario root en el
contenedor (verás un prompt que comienza con un hash `#`). Iniciar sesión como
el usuario root suele ser aceptable dentro de un contenedor, porque el
aislamiento del entorno del contenedor limita lo que el usuario root puede
hacer.

### Protobuf

Ahora vamos a crear un mensaje Protobuf y compilar el archivo `.proto` para
generar el archivo Ruby relacionado, que contendrá las clases que se copiarán
en cada una de nuestras aplicaciones Ruby on Rails. Este archivo definirá el
mensaje Protobuf, las solicitudes y las definiciones de llamadas de
procedimientos remotos.

Crea un par de directorios para nuestros archivos de entrada y salida. El
comando `mkdir -p` a continuación creará directorios con la siguiente
estructura:

* protobuf
  * definitions
  * lib

_**Listado 13-5**_ Creando los directorios necesarios

```console
$ mkdir -p protobuf/{definitions,lib}
```

Nuestro archivo de definición Protobuf:

_**Listado 13-6**_ Archivo Protobuf del mensaje Employee

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

service EmployeeMessageService {
  rpc Search (EmployeeMessageRequest) returns (EmployeeMessageList);
  rpc Create (EmployeeMessage) returns (EmployeeMessage);
  rpc Update (EmployeeMessage) returns (EmployeeMessage);
  rpc Destroy (EmployeeMessage) returns (EmployeeMessage);
}
```

Para compilar los archivos `.proto`, usaremos una tarea Rake proporcionada por
la gema `protobuf`. Para acceder a las tareas Rake de la gema `protobuf`,
necesitaremos crear un `Rakefile`. Hagámoslo ahora.

_**Listing 13-7**_ Rakefile

```ruby
# rails-microservices-sample-code/protobuf/Rakefile

require 'protobuf/tasks'
```

Ahora podemos ejecutar la tarea Rake `compile` para generar el archivo.

_**Listado 13-8**_ Iniciando el contenedor builder y compilando la definición
protobuf

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd protobuf
# rake protobuf:compile
```

Esto generará un archivo llamado `employee_message.pb.rb` en el directorio
`protobuf/lib`. Copiaremos este archivo en el directorio `app/lib` de las
aplicaciones Rails que crearemos a continuación.

### Crear una Aplicación Rails sin una Base de Datos

Llamaremos a esta primera aplicación `active-remote`. Tendrá un modelo, pero
las clases del modelo heredarán de `ActiveRemote::Base` en lugar del
`ApplicationRecord` predeterminado (que hereda de `ActiveRecord::Base`). En
otras palabras, estos modelos interactuarán con los modelos de `active-remote`
enviando mensajes a través del servidor NATS.

Generemos la aplicación `active-remote`. No necesitaremos la capa de
persistencia de Active Record, por lo que utilizaremos la bandera
`--skip-active-record`. Necesitaremos las gemas `active_remote` y
`protobuf-nats`, pero no la gema `protobuf-activerecord` que incluimos en la
aplicación `active-record`. Usaremos el scaffolding de Rails para generar un
modelo, un controlador y vistas para ver y gestionar nuestro protobuf de
Employee que se compartirá entre nuestras aplicaciones.

_**Listado 13-9**_ Generando las aplicaciones Rails y los archivos necesarios

```console
$ mkdir chapter-13 # create a directory for this chapter
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-13
# rails new active-remote --skip-active-record
# cd active-remote
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# exit
```

We'll need to make a couple of changes to the `active-remote` app. First, let's copy the Protobuf file.

_**Listing 13-10**_ Setting up the app/lib directory and copying the proto class

```console
$ mkdir chapter-13/active-remote/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-13/active-remote/app/lib/
```

Ahora editemos el archivo `config/environments/development.rb` para habilitar la carga ansiosa.

_**Listado 13-11**_ Configuración de desarrollo

```ruby
# rails-microservices-sample-code/chapter-13/active-remote/config/environments/development.rb

...
config.eager_load = true
...
```

Agreguemos el archivo `protobuf_nats.yml`.

_**Listado 13-12**_ Configuración de Protbuf Nats

```yml
# rails-microservices-sample-code/chapter-13/active-remote/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

Ahora agreguemos un modelo que herede de Active Remote.

_**Listado 13-13**_ Modelo Employee de Active Remote

```ruby
# rails-microservices-sample-code/chapter-13/active-remote/app/models/employee.rb

class Employee < ActiveRemote::Base
  service_class ::EmployeeMessageService

  attribute :guid
  attribute :first_name
  attribute :last_name
end
```

Lo último que necesitamos hacer es cambiar un par de llamadas a métodos en el
archivo `employees_controller.rb` para modificar la forma en que nuestros
mensajes Protobuf son recuperados e instanciados. Debemos usar el método
`search` en lugar de los métodos predeterminados `all` y `find` de Active
Record. Además, como estamos usando uuids (guides) como clave única entre
servicios, generaremos un nuevo uuid cada vez que se llame a la acción `new`.

_**Listado 13-14**_ Controlador de Employee

```ruby
# rails-microservices-sample-code/chapter-13/active-remote/controllers/employees_controller.rb

def index
  @employees = Employee.search({})
end

...

def new
  @employee = Employee.new(guid: SecureRandom.uuid)
end

...

def set_employee
  @employee = Employee.search(guid: params[:id]).first
end
```

### Crear una Aplicación Rails con una Base de Datos

La segunda aplicación Rails que crearemos tendrá su propia base de datos y
escuchará mensajes a través de NATS mediante Active Remote. También utilizará
la gema Active Publisher para publicar mensajes en RabbitMQ. Agregaremos las
gemas requeridas al archivo `Gemfile`. Luego, ejecutaremos el comando `bundle`
para recuperar las gemas desde https://rubygems.org. Después de recuperar las
gemas, crearemos el scaffolding para una entidad Employee. Esta aplicación
almacenará los datos en una base de datos SQLite para que podamos configurar
los eventos de creación y actualización.

_**Listado 13-15**_ Generando la aplicación Rails y los archivos necesarios

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-13
# rails new active-record-publisher
# cd active-record-publisher
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'active_publisher'" >> Gemfile
# echo "gem 'protobuf-activerecord'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# rails db:migrate
# exit
```

Asegúrate de inspeccionar la salida de cada uno de los comandos anteriores,
buscando errores. Si encuentras errores, por favor verifica cada comando para
detectar errores tipográficos o caracteres adicionales.

Vamos a personalizar la aplicación para servir nuestra entidad Employee a
través de Protobuf. Necesitaremos un directorio `app/lib`, y luego copiaremos
el archivo `employee_message.pb.rb` generado a este directorio.

_**Listado 13-16**_ Generando los directorios de la aplicación Rails y copiando
la clase de mensaje

```console
$ mkdir chapter-13/active-record-publisher/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-13/active-record-publisher/app/lib/
```

A continuación, agregaremos un archivo de configuración `active_publisher` al
directorio `config`. Este archivo definirá cómo debe conectarse nuestra
aplicación al servidor RabbitMQ. El host `rabbit` se definirá en el archivo
`docker-compose` que definiremos en unos minutos.

_**Listado 13-17**_ Configuración de Active Publisher

```yml
# rails-microservices-sample-code/chapter-13/active-record-publisher/config/active_publisher.yml

default: &default
  host: rabbit
  username: guest
  password: guest

development:
  <<: *default
```

Agreguemos el archivo `protobuf_nats.yml`.

_**Listado 13-18**_ Configuración de Protobuf Nats

```yml
# rails-microservices-sample-code/chapter-13/active-record-publisher/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

Ahora vamos a crear un inicializador para Active Publisher. Esto cargará la
gema, establecerá el adaptador y cargará el archivo de configuración. Vamos a
crear este archivo en el directorio `config/initializers`.

_**Listado 13-19**_ Inicializador de Active Publisher

```ruby
# rails-microservices-sample-code/chapter-13/active-record-publisher/config/initializers/active_publisher.rb

require 'active_publisher'

::ActivePublisher::Configuration.configure_from_yaml_and_cli
```

A continuación, modifiquemos el modelo de empleado para que podamos enviar el
objeto Protobuf del empleado a RabbitMQ. Utilizaremos callbacks de Active
Record para publicar mensajes en colas separadas de `created` y `updated`
después de que se haya creado o modificado un registro de empleado. Abre el
archivo `app/models/employee.rb` y agrega el siguiente código.

_**Listado 13-20**_ Modelo de Employee

```ruby
# rails-microservices-sample-code/chapter-13/active-record-publisher/app/models/employee.rb

require 'protobuf'

class Employee < ApplicationRecord
  protobuf_message :employee_message

  after_create :publish_created
  after_update :publish_updated

  scope :by_guid, ->(*values) { where(guid: values) }
  scope :by_first_name, ->(*values) { where(first_name: values) }
  scope :by_last_name, ->(*values) { where(last_name: values) }

  field_scope :guid
  field_scope :first_name
  field_scope :last_name

  def publish_created
    Rails.logger.info(
      "Publishing employee object #{inspect} on the employee.created queue."
    )
    ::ActivePublisher.publish('employee.created', to_proto.encode, 'events', {})
  end

  def publish_updated
    Rails.logger.info(
      "Publishing employee object #{inspect} on the employee.updated queue."
    )
    ::ActivePublisher.publish('employee.updated', to_proto.encode, 'events', {})
  end
end
```

### Crear un Suscriptor de Mensajes

Vamos a crear la aplicación `action-subscriber`. Esta aplicación se suscribirá
a las colas de mensajes de empleado creado y actualizado y simplemente
registrará que ha recibido un mensaje en la cola.

_**Listado 13-21**_ Iniciando nuestro contenedor builder

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-13
# rails new action-subscriber --skip-active-record
# cd action-subscriber
# echo "gem 'action_subscriber'" >> Gemfile
# echo "gem 'protobuf'" >> Gemfile
# bundle
# exit
```

Ahora configuremos Action Subscriber para escuchar eventos. Necesitaremos
agregar una clase `EmployeeSubscriber` y agregar rutas mediante el método
`ActionSubscriber.draw_routes`.

Queremos colocar nuestras clases de suscriptor en su propio directorio
`subscribers`. También necesitaremos el directorio `lib` donde copiaremos
nuestra clase Protobuf de Employee. Vamos a crear estos directorios y copiar el
archivo `employee_message.pb.rb` generado a este directorio.

_**Listado 13-22**_ Configuración del directorio app/lib

```console
$ mkdir chapter-13/action-subscriber/app/{lib,subscribers}
$ cp protobuf/lib/employee_message.pb.rb chapter-13/action-subscriber/app/lib/
```

Necesitaremos agregar un directorio de servicios y una clase para escuchar
mensajes de Active Remote publicados a través de NATS.

_**Listado 13-23**_ Creando el directorio app/services

```console
$ mkdir chapter-13/active-record-publisher/app/services
```

_**Listado 13-24**_ Clase de servicio de mensaje de Employee

```ruby
# rails-microservices-sample-code/chapter-13/active-record-publisher/app/services/employee_message_service.rb

class EmployeeMessageService
  def search
    records = ::Employee.search_scope(request).map(&:to_proto)

    respond_with records:
  end

  def create
    record = ::Employee.create(request)

    respond_with record
  end

  def update
    record = ::Employee.where(guid: request.guid).first
    record.assign_attributes(request)
    record.save!

    respond_with record
  end

  def destroy
    record = ::Employee.where(guid: request.guid).first

    record.delete
    respond_with record.to_proto
  end
end
```

Ahora agreguemos la clase de suscriptor. Para los fines de nuestro entorno de
pruebas, lo mantendremos simple: simplemente registraremos que hemos recibido
el mensaje.

_**Listado 13-25**_ Clase de suscriptor de Employee

```ruby
# rails-microservices-sample-code/chapter-13/action-subscriber/app/subscribers/employee_subscriber.rb

class EmployeeSubscriber < ::ActionSubscriber::Base
  def created
    Rails.logger.info(
      "Received created message: #{EmployeeMessage.decode(payload).inspect}"
    )
  end

  def updated
    Rails.logger.info(
      "Received updated message: #{EmployeeMessage.decode(payload).inspect}"
    )
  end
end
```

Nuestra aplicación necesita saber a qué colas suscribirse, por lo que usamos el
método `default_routes_for`, que leerá nuestra clase `EmployeeSubscriber` y
generará colas para cada uno de nuestros métodos públicos o se suscribirá a
esas colas si ya existen. El nombre de host `host.docker.internal` es un nombre
de host especial de Docker; apunta a la dirección IP de la máquina anfitriona.

_**Listado 13-26**_ Inicializador de Action Subscriber

```ruby
# rails-microservices-sample-code/chapter-13/action-subscriber/config/initializers/action_subscriber.rb

ActionSubscriber.draw_routes do
  default_routes_for EmployeeSubscriber
end

ActionSubscriber.configure do |config|
  config.hosts = ['host.docker.internal']
  config.port = 5672
end
```

Necesitaremos habilitar las configuraciones `cache_classes` y `eager_load`, de
la misma manera que lo hicimos para el publicador. También necesitaremos
configurar un registrador (logger) para que podamos ver la salida de los
registros desde nuestro contenedor Docker.

_**Listado 13-27**_ Configuración de desarrollo

```ruby
# rails-microservices-sample-code/chapter-13/action-subscriber/config/environments/development.rb

config.cache_classes = true
...
config.eager_load = true
...
logger           = ActiveSupport::Logger.new($stdout)
logger.formatter = config.log_formatter
config.logger    = ActiveSupport::TaggedLogging.new(logger)
```

### Crear y Configurar Nuestro Entorno

Por último, pero no menos importante, agreguemos un `Dockerfile` y dos archivos
Compose: `docker-compose.yml` y `docker-compose-subscriber.yml`. Estos archivos
se utilizarán para construir una imagen y poner en marcha nuestros contenedores
Rails, NATS y RabbitMQ. El `Dockerfile` puede que ya exista del sandbox que
construimos en los capítulos 9 y 12, pero si no es así, tendrá el mismo
contenido aquí.

_**Listado 13-28**_ Dockerfile del sandbox

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
nuestras nuevas aplicaciones Rails `active-record-publisher` y `active-remote`.
Expondremos la aplicación web `active-remote` en el puerto 3002.

Normalmente, agregaríamos el suscriptor al mismo archivo Docker Compose, pero,
dado que el servicio Action Subscriber intenta conectarse inmediatamente y
RabbitMQ puede tardar unos segundos en cargar, ejecutaremos el proceso del
suscriptor desde un archivo Docker Compose separado. También necesitaremos
exponer el puerto 5672 a la máquina anfitriona para que podamos conectarnos
desde el otro entorno Compose.

_**Listado 13-29**_ Archivo Docker Compose del sandbox

```yml
# rails-microservices-sample-code/chapter-13/docker-compose.yml
# Usage: docker-compose up

version: "3.4"

services:
  active-record-publisher:
    environment:
    - PB_SERVER_TYPE=protobuf/nats/runner
    build:
      context: ./active-record-publisher
      dockerfile: ../../Dockerfile
    command: bundle exec rpc_server start -p 9399 -o active-record-publisher ./config/environment.rb
    volumes:
    - ./active-record-publisher:/usr/src/service
    depends_on:
    - nats
    - rabbit
  active-remote:
    environment:
    - PB_CLIENT_TYPE=protobuf/nats/client
    build:
      context: ./active-remote
      dockerfile: ../../Dockerfile
    command: bundle exec puma -C config/puma.rb
    ports:
    - 3002:3000
    volumes:
    - ./active-remote:/usr/src/service
    depends_on:
    - nats
  rabbit:
    image: rabbitmq:latest
    ports:
    - 5672:5672
  nats:
    image: nats:latest
```

Ahora agreguemos el archivo de configuración `action-subscriber`. Ten en cuenta
que, debido a que el ejecutable de Action Subscriber genera un proceso hijo
para escuchar eventos de RabbitMQ, perdemos la salida de los registros si
iniciamos el contenedor usando el comando `up`. Para ver toda la información de
los registros en el terminal, utilizaremos el comando `run` de Docker Compose
para iniciar un shell bash y ejecutar nuestro ejecutable `action_subscriber`
allí.

_**Listado 13-30**_ Archivo Docker Compose para el suscriptor del sandbox

```yml
# rails-microservices-sample-code/chapter-13/docker-compose-subscriber.yml
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

Ahora que todo está en su lugar, iniciemos nuestras aplicaciones
`active-remote` y `active-record-publisher`.

_**Listado 13-31**_ Iniciando el sandbox

```console
$ cd chapter-13
$ docker-compose up
```

Una vez que veas líneas como estas, RabbitMQ ha iniciado y la aplicación Rails
Active Publisher se ha conectado con éxito.

_**Listado 13-32**_ Registro del sandbox

```console
rabbit_1            | 2020-02-09 22:54:02.253 [info] <0.8.0> Server startup complete; 0 plugins started.
rabbit_1            |  completed with 0 plugins.
72.30.0.2:5672)
rabbit_1            | 2020-02-09 22:54:37.395 [info] <0.641.0> connection <0.641.0> (172.30.0.1:53140 -> 172.30.0.2:5672): user 'guest' authenticated and granted access to vhost '/'
```

Ahora iniciemos el suscriptor en otra ventana de terminal. Podemos usar la
bandera `-f` para especificar que queremos usar el archivo
`docker-compose-subscriber.yml`. Ejecute este comando ahora.

_**Listado 13-33**_ Iniciando el sandbox del suscriptor

```console
$ docker-compose -f docker-compose-subscriber.yml run action-subscriber bash -c 'bundle exec action_subscriber start'
```

Deberías ver una salida similar a la siguiente.

_**Listado 13-34**_ Registro del sandbox del suscriptor

```console
I, [2020-03-09T02:54:50.619645 #1]  INFO -- : Starting server...
I, [2020-03-09T02:54:50.667362 #1]  INFO -- : Rabbit Hosts: ["host.docker.internal"]
Rabbit Port: 5672
Threadpool Size: 8
Low Priority Subscriber: false
Decoders:
  --application/json
  --text/plain

I, [2020-03-09T02:54:50.667541 #1]  INFO -- : Middlewares [
I, [2020-03-09T02:54:50.667632 #1]  INFO -- : [ActionSubscriber::Middleware::ErrorHandler, [], nil]
I, [2020-03-09T02:54:50.667665 #1]  INFO -- : [ActionSubscriber::Middleware::Decoder, [], nil]
I, [2020-03-09T02:54:50.667681 #1]  INFO -- : ]
I, [2020-03-09T02:54:50.667708 #1]  INFO -- : EmployeeSubscriber
I, [2020-03-09T02:54:50.667766 #1]  INFO -- :   -- method: created
I, [2020-03-09T02:54:50.667818 #1]  INFO -- :     --  threadpool: default (8 threads)
I, [2020-03-09T02:54:50.667872 #1]  INFO -- :     --    exchange: events
I, [2020-03-09T02:54:50.668058 #1]  INFO -- :     --       queue: actionsubscriber.employee.created
I, [2020-03-09T02:54:50.668253 #1]  INFO -- :     -- routing_key: employee.created
I, [2020-03-09T02:54:50.668350 #1]  INFO -- :     --    prefetch: 2
I, [2020-03-09T02:54:50.668401 #1]  INFO -- :   -- method: updated
I, [2020-03-09T02:54:50.668603 #1]  INFO -- :     --  threadpool: default (8 threads)
I, [2020-03-09T02:54:50.668649 #1]  INFO -- :     --    exchange: events
I, [2020-03-09T02:54:50.668682 #1]  INFO -- :     --       queue: actionsubscriber.employee.updated
I, [2020-03-09T02:54:50.668711 #1]  INFO -- :     -- routing_key: employee.updated
I, [2020-03-09T02:54:50.668737 #1]  INFO -- :     --    prefetch: 2
I, [2020-03-09T02:54:50.674268 #1]  INFO -- : Action Subscriber connected
```

Estas líneas de registro indican que el suscriptor se ha conectado al servidor
con éxito, ha conectado a dos colas y ahora está escuchando eventos.

Vamos a crear un evento. Abre tu navegador y accede a
[http://localhost:3002/employees](http://localhost:3002/employees). El puerto
3002 es el puerto que expusimos desde la aplicación Rails `active-remote` en el
archivo `docker-compose.yml`. Deberías ver una página web simple con el título
**Employees** y un enlace 'New Employee'. Haz clic en el enlace. Ahora deberías
poder crear un nuevo registro de empleado en el formulario web. Una vez que lo
completes y hagas clic en el botón 'Create Employee', sucederán varias cosas.
Primero, los datos del formulario se enviarán de vuelta a la aplicación Rails
`active-remote`. El controlador pasará esos datos al modelo Employee de Active
Remote, que enviará los datos a través de NATS a nuestra aplicación Rails
`active-record-publisher`. La aplicación `active-record-publisher` creará un
nuevo registro en la base de datos SQLite. En el modelo
`active-record-publisher`, el callback `after_create` se ejecutará, codificando
nuestro mensaje Protobuf y colocándolo en la cola
`actionsubscriber.employee.created`. RabbitMQ notificará a todos los
suscriptores que escuchan en una cola específica sobre los nuevos mensajes.
Nuestra aplicación Rails `action-subscriber` es uno de esos suscriptores. En el
método `EmployeeSubscriber#created` de nuestro manejador de eventos, escribimos
código para registrar que recibimos un mensaje. Si inspeccionas la salida de la
ventana de terminal donde iniciamos la aplicación Rails `action-subscriber`,
deberías ver información de registro similar a la salida a continuación.

_**Listado 13-35**_ Más registros del sandbox del suscriptor

```console
I, [2020-03-09T03:03:05.876609 #1]  INFO -- : RECEIVED 35f733 from actionsubscriber.employee.created
I, [2020-03-09T03:03:05.877003 #1]  INFO -- : START 35f733 EmployeeSubscriber#created
Received created message: #<EmployeeMessage guid="df3ec377-21be-4b29-84de-a4fba0306274" first_name="Adrian" last_name="Pennino">
I, [2020-03-09T03:03:05.877295 #1]  INFO -- : FINISHED 35f733
```

¡Felicidades! Has construido con éxito una plataforma de mensajería que puede
publicar mensajes a través de Active Remote y aplicaciones que pueden responder
a eventos. Intenta editar el registro que acabas de crear. Deberías ver una
salida similar en la aplicación Rails de Action Subscriber mientras recibe y
procesa el evento y los datos. Para mayor diversión, intenta poner en marcha un
segundo o tercer servicio de suscriptor que escuche las mismas colas y observa
cómo todos responden simultáneamente al mismo mensaje publicado.

## Recursos

* https://github.com/kevinwatson/rails-microservices-sample-code

## Conclusión

En este capítulo, hemos construido tres aplicaciones Rails que comparten datos
utilizando patrones que proporcionan tanto comunicaciones en tiempo real como
impulsadas por eventos. Cada patrón tiene su lugar. A veces, la comunicación
necesita ser en tiempo real, como cuando un microservicio necesita acceso a uno
o más registros. Otras veces, las solicitudes entre servicios no necesitan ser
en tiempo real, sino impulsadas por eventos, como cuando un servicio necesita
ser notificado y un proceso prolongado necesita ser iniciado, pero el llamador
no necesita saber cuándo ha terminado el proceso. Examinar los requisitos de tu
negocio puede ayudarte a determinar cuándo es necesario cada patrón.

Este capítulo concluye nuestro viaje de construcción de microservicios
utilizando Ruby on Rails. Hemos cubierto una gran cantidad de terreno. En
nuestro próximo y último capítulo, resumiremos lo que hemos aprendido hasta
ahora. También discutiremos algunas formas de continuar nuestro viaje.

[Siguiente  >>](150-chapter-14.es.md)

  [alt_text]: images/synchronous-and-event-driven-platform.png "Publicando un mensaje de empleado creado mediante Active Remote y Active Publisher"
