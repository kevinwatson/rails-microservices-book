### Chapter 9 - El sandbox del microservicio Active Remote

> Intento formular un plan pero mis pensamientos son una mezcla tóxica de
arrepentimiento, pánico y autodesprecio; como si alguien agitara una botella
de refresco carbonatado y la destapara dentro de mi cerebro.
- Elan Mastai, Todos nuestros presentes equivocados

## Introducción

Antes de que podamos sumergirnos en la construcción de nuestro entorno
distribuido, primero necesitaremos configurar nuestro entorno de desarrollo.
Usaremos Docker para comenzar a funcionar rápidamente. Docker también
proporciona su propia red aislada de manera que no interferirá con los procesos
que ya se ejecutan en su computadora de desarrollo.

Usaremos los términos imágenes y contenedores. Si bien estos términos a veces se
usan indistintamente, existen claras diferencias. Las imágenes de Docker son la
estructura de archivos de una aplicación en su disco duro (piense en una imagen
como los archivos en la carpeta de su proyecto). Un contenedor Docker es una
instancia en ejecución de la imagen (piense en un contenedor como la instancia
de su aplicación). Se pueden crear uno o más contenedores a partir de una sola
imagen, siempre que se hayan proporcionado nombres de servicios separados. Otro
ejemplo es que puede ejecutar varias instancias de una aplicación Rails desde
el mismo directorio especificando un número de puerto diferente (por ejemplo,
`rails server -p 3000` y `rails server -p 3001`).

El entorno sandbox que crearemos en este capítulo utilizará la gema Active
Remote para levantar un cliente (llamaremos a esta aplicación `active-remote`)
que puede acceder a datos en el servicio que los posee (llamaremos esta
aplicación `active-record` porque usará Active Record para conservar los datos
en una base de datos a la que solo él tiene acceso).

En este entorno, usaremos NATS para pasar mensajes entre nuestros microservicios
. Se enviará una solicitud para crear un nuevo empleado desde la aplicación
Active Remote a NATS, y NATS reenviará la solicitud a cualquier servicio que se
haya suscrito a esa ruta. La aplicación Active Record que creamos se suscribirá
y responderá con la instancia de empleado recién creada envuelta en un mensaje
de Protobuf.

_**Imagen 9-1**_ Pasando mensajes de Active Remote

![alt text](images/active-remote-sequence-diagram.png "Pasando mensajes de
Active Remote entre applicaciones")

## Instalando Docker

Si ya tienes Docker y Docker Compose instalados, ¡genial! De lo contrario,
deberá seguir los pasos a continuación.

Si está utilizando Windows o macOS, descargue e instale Docker Desktop. Los
enlaces de descarga y las instrucciones se pueden encontrar aquí:
https://www.docker.com/products/docker-desktop.

También usaremos Docker Compose para configurar y ejecutar varias aplicaciones
desde un único archivo de configuración. Docker Compose está incluido en Docker
Desktop para macOS y Windows. Si está ejecutando Linux, deberá instalar Docker
por separado y luego seguir las instrucciones de instalación de Docker Compose
que se encuentran aquí: https://docs.docker.com/compose/install.

## Implementación

### Requisitos

* NATS
* Ruby
* Ruby gems
  * Active Remote
  * Protobuf
  * Rails
* SQLite

Debido a que instalamos Docker Desktop, no es necesario instalar Ruby, Ruby on
Rails, NATS o SQLite en su computadora. Se instalarán dentro de las imágenes y
contenedores de Docker que desarrollaremos a continuación.

#### Probando nuestra instalación de Docker y Docker Compose

Podemos probar nuestra instalación ejecutando los comandos `docker version` y
`docker-compose --version`. Las versiones que ve en su resultado pueden diferir
de las versiones que ve a continuación.

**Ejemplo 9-2** Verificando el entorno de Docker

```console
$ docker version
Client: Docker Engine - Community
 Version:           19.03.5
...
Server: Docker Engine - Community
 Engine:
  Version:          19.03.5

$ docker-compose --version
docker-compose version 1.24.1
```

Si ve algún error, verifique la instalación de Docker Desktop.

### Estructurfe de directory del projecto

Ahora necesitaremos crear un directorio para nuestro proyecto. A medida que
avance, creará tres subdirectorios, uno para nuestros mensajes Protobuf
compartidos, uno para nuestra aplicación de servidor ActiveRecord Ruby on Rails
que almacena los datos en una base de datos SQLite y otro para nuestra
aplicación cliente ActiveRemote que proporcionará una front-end para nuestro
servicio ActiveRecord.

Siguiendo este tutorial, debería terminar con los siguientes directorios (y
muchos archivos y directorios en cada directorio). El directorio
`rails-microservices-sample-code` lleva el nombre del repositorio de GitHub
que se encuentra en
https://github.com/kevinwatson/rails-microservices-sample-code.

* rails-microservices-sample-code
  * chapter-09
    * active-record
    * active-remote
  * protobuf

### Configurando un entorno de desarrollo

Comencemos creando un archivo Dockerfile y un archivo Docker Compose. Usaremos
el archivo Dockerfile para crear una imagen con las aplicaciones de línea de
comandos que necesitamos y usaremos un archivo de configuración de Docker
Compose para reducir la cantidad de parámetros que necesitaremos usar para
ejecutar cada comando. La alternativa es simplemente usar un Dockerfile y
comandos `docker` relacionados.

Cree el siguiente archivo Dockerfile en el directorio
`rails-microservices-sample-code`. Usaremos el nombre `Dockerfile.builder` para
diferenciar el Dockerfile que usaremos para generar nuevos servicios Rails del
Dockerfile que usaremos para construir y ejecutar nuestras aplicaciones Rails.

Nota: La primera línea de estos archivos es un comentario y se utiliza para
indicar la ruta y el nombre del archivo. Esta línea se puede omitir del archivo.

_**Ejemplo 9-3**_ Fichero Dockerfile utilizado para crear una imagen que será
utiliazada para generar nuestra aplicación Rails.

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

Cree el siguiente archivo `docker-compose.builder.yml` en el directorio
`rails-microservices-sample-code`. Usaremos este archivo de configuración para
inicilizar nuestro entorno de desarrollo con todas las herramientas de línea de
comandos que necesitaremos.

_**Ejemplo 9-4**_ Fichero Docker Compose para iniciar el contenedor que vamos
a utilizar para generar nuestra aplicación Rails.

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

Comencemos e iniciemos sesión en el contenedor builder. Luego ejecutaremos los
comandos de generación de Rails desde el contenedor, lo que creará dos
aplicaciones Rails. Debido a que hemos asignado un volumen en el archivo `.yml`
anterior, los archivos que se generan se guardarán en el directorio
`rails-microservices-sample-code`. Si no asignamos un volumen, los archivos que
generamos solo existirían dentro del contenedor, y cada vez que detengamos y
reiniciemos el contenedor, será necesario regenerarlos. Mapear un volumen a un
directorio en la computadora host servirá archivos a través del entorno del
contenedor, que incluye una versión específica de Ruby, Rails y las gemas que
necesitaremos para ejecutar nuestras aplicaciones.

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
```

El comando `run` de Docker Compose construirá la imagen (si aún no se creó),
iniciará el contenedor, ingresará al contenedor en ejecución y nos brindará un
símbolo de sistema usando el shell `bash`.

Ahora debería ver que ha iniciado sesión como usuario root en el contenedor
(verá un mensaje que comienza con un hash `#`). Iniciar sesión como usuario root
suele estar bien dentro de un contenedor, porque el aislamiento del entorno del
contenedor limita lo que el usuario root puede hacer.

### Protobuf

Ahora creemos un mensaje Protobuf y compilaremos el archivo `.proto` para
generar el archivo Ruby relacionado, que contiene las clases que se copiarán en
cada una de nuestras aplicaciones Ruby on Rails. Este archivo definirá el
mensaje de Protobuf, las solicitudes y las definiciones de llamadas a
procedimientos remotos.

Cree un par de directorios para nuestros archivos de entrada y salida. El
siguiente comando `mkdir -p` creará directorios con la siguiente estructura:

* protobuf
  * definitions
  * lib

```console
$ mkdir -p protobuf/{definitions,lib}
```

Nuestro fichero de definición Protobuf:

_**Ejemplo 9-5**_ Fichero protobuf del mensaje Employee

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
necesitaremos crear un `Rakefile`. ¡Hagámoslo!

_**Ejemplo 9-6**_ Rakefile

```ruby
# rails-microservices-sample-code/protobuf/Rakefile

require "protobuf/tasks"
```

Ahora podemos ejecutar la tarea Rake `compile` para generar el fichero.

```console
$ mkdir chapter-09 # create a directory for this chapter
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd protobuf
# rake protobuf:compile
```

Esto generará un archivo llamado `employee_message.pb.rb` en el directorio
`protobuf/lib`. Copiaremos este archivo en el directorio `app/lib` en las
aplicaciones Rails que crearemos a continuación.

### Crear una aplicación Rails con una base de datos

La primera aplicación Rails que generaremos tendrá un modelo de Active Record y
podrá conservar los registros en una base de datos SQLite. Agregaremos las gemas
`active_remote`, `protobuf-nats` y `protobuf-activerecord` al archivo `Gemfile`.
Luego ejecutaremos el comando `bundle` para obtener las gemas del repositorio
[Rubygems][]. Después de obtener las gemas, crearemos un andamiaje para una
entidad Employee y generaremos una tabla "employees" en la base de datos SQLite.
Podríamos conectar nuestra aplicación a una base de datos PostgreSQL o MySQL,
pero para los propósitos de esta aplicación de demostración, la base de datos
SQLite basada en archivos es suficiente. Por supuesto, la aplicación Active
Remote que generamos no sabrá ni le importará cómo se conservan los datos (o si
los datos persisten).

Generemos la aplicación Rails que actuará como servidor y poseedor de los datos.
Como poseedor de los datos, puede conservarlos en una base de datos. Llamaremos
a esta aplicación "active-record".

```console
# cd chapter-09
# rails new active-record
# cd active-record
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# echo "gem 'protobuf-activerecord'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# rails db:migrate
# exit
```

Asegúrese de inspeccionar el resultado de cada uno de los comandos anteriores en
busca de errores. Si se encuentran errores, vuelva a verificar cada comando en
busca de errores tipográficos o caracteres adicionales.

Personalicemos la aplicación para servir a nuestra entidad Employee a través de
Protobuf. Necesitaremos un directorio `app/lib` y luego copiaremos el archivo
`employee_message.pb.rb` generado a este directorio.

```console
$ mkdir chapter-09/active-record/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-09/active-record/app/lib/
```

A continuación, necesitaremos crear una clase de servicio para definir cómo
manejar los puntos de acceso del servicio de llamada a procedimiento remoto que
definimos en el archivo `.proto`. Necesitaremos crear un directorio
`app/services`. Luego agregaremos un archivo
`app/services/employee_message_service.rb` para volver a abrir la clase
`EmployeeMessageService` definida en nuestro archivo
`app/lib/employee_message.pb.rb` para proporcionar detalles de implementación.
Por último, definiremos algunos scpes y field_scopes en nuestro
`app/models/employee.rb` para conectar los atributos del modelo existente con
los atributos de protobuf.

_**Ejemplo 9-6**_ Employee, un modelo de Active Record.

```ruby
# rails-microservices-sample-code/chapter-09/active-record/app/models/employee.rb

require 'protobuf'

class Employee < ApplicationRecord
  protobuf_message :employee_message

  scope :by_guid, lambda { |*values| where(guid: values) }
  scope :by_first_name, lambda { |*values| where(first_name: values) }
  scope :by_last_name, lambda { |*values| where(last_name: values) }

  field_scope :guid
  field_scope :first_name
  field_scope :last_name
end
```

```console
$ mkdir chapter-09/active-record/app/services
```

_**Ejemplo 9-7**_ La clase EmployeeMessageService.

```ruby
# rails-microservices-sample-code/chapter-09/active-record/app/services/employee_message_service.rb

class EmployeeMessageService
  def search
    records = ::Employee.search_scope(request).map(&:to_proto)

    respond_with records: records
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

También necesitaremos agregar algunos detalles más. Debido a que el archivo
`app/lib/employee_message.pb.rb` contiene varias clases, solo se carga la clase
que coincide con el nombre del archivo. En el modo de desarrollo, Rails puede
cargar archivos de forma diferida (lazy loading) siempre que el nombre del
archivo pueda inferirse del nombre de la clase, Ej: El código que requiere la
clase `EmployeeMessageService` intentará cargar de forma diferida un archivo
llamado `employee_message_service.rb` y lanzará un error si no se encuentra
el archivo. Podemos separar las clases en el archivo
`app/lib/employee_message.pb.rb` en archivos separados o habilitar la carga
inmediata (eager load) en la configuración. Para los propósitos de esta
demostración, habilitemos la carga inmediata.

_**Ejemplo 9-8**_ Fichero de configurarión de desarrollo

```ruby
# rails-microservices-sample-code/chapter-09/active-record/config/environments/development.rb

...
config.eager_load = true
...
```

El último cambio que debemos hacer en la aplicación `active-record` es agregar
un archivo de configuración `protobuf_nats.yml` para configurar el código
proporcionado por la gema `protobuf-nats`.

_**Ejemplo 9-9**_ Fichero de configuración Protobuf Nats

```yml
# rails-microservices-sample-code/chapter-09/active-record/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

### Crear una aplicación Rails sin base de datos

Ahora es momento de crear nuestra segunda aplicación Rails. A esta la llamaremos
"active-remote". Tendrá un modelo, pero las clases del modelo heredarán de
`ActiveRemote::Base` en lugar del `ApplicationRecord` predeterminado (que hereda
de `ActiveRecord::Base`). En otras palabras, estos modelos interactuarán con los
modelos "active-remote" enviando mensajes a través del servidor NATS.

Generemos la aplicación "active-remote". No necesitaremos la capa de
persistencia de Active Record, por lo que usaremos el indicador
`--skip-active-record`. Necesitaremos las gemas `active_remote` y
`protobuf-nats`, pero no la gema `protobuf-activerecord` que incluimos en la
aplicación `active-record`. Usaremos el andamiaje Rails para generar un modelo,
un controlador y vistas para ver y administrar nuestra entidad Empleado que se
compartirá entre las dos aplicaciones.

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-09
# rails new active-remote --skip-active-record
# cd active-remote
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
```

Necesitaremos realizar un par de cambios en la aplicación "active-remote".
Primero, copiemos el archivo Protobuf.

```console
$ mkdir chapter-09/active-remote/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-09/active-remote/app/lib/
```

Ahora agreguemos un modelo que hereda de Active Remote.

_**Ejemplo 9-10**_ Clase Employee Active Remote

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/app/models/employee.rb

class Employee < ActiveRemote::Base
  service_class ::EmployeeMessageService

  attribute :guid
  attribute :first_name
  attribute :last_name
end
```

Ahora editemos el fichero `config/environments/development.rb` para habilitar la
carga inmediata por las mismas razones antes mencionadas.

_**Ejemplo 9-11**_ Fichero de configuración de desarrollo

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/config/environments/development.rb

...
config.eager_load = true
...
```

Añadamos el fichero `protobuf_nats.yml`.

_**Ejemplo 9-12**_ Fichero de configuración Protobuf Nats

```yml
# rails-microservices-sample-code/chapter-09/active-record/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

Lo último que debemos hacer es cambiar un par de llamadas a métodos en el
archivo `employees_controller.rb` para cambiar la forma en que se obtienen y
crean instancias de nuestros mensajes Protobuf. Necesitamos usar el método
`search` en lugar de los métodos predeterminados `all` y `find` de Active Record
. Además, debido a que utilizamos uuids (guids) como clave única entre servicios
, generaremos un nuevo uuid cada vez que se llame a la acción "new".

_**Ejemplo 9-13**_ Clase Employee controller

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/controllers/employees_controller.rb

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

### Crear y configurar nuestro entorno

Por último, pero no menos importante, agreguemos un archivo `Dockerfile` y
`docker-compose.yml` para crear una imagen, activar contenedores y vincular
nuestros servicios.

_**Ejemplo 9-14**_ Fichero Dockerfile del sandbox

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

_**Ejemplo 9-15**_ Fichero Docker Compose del sandbox

```yml
# rails-microservices-sample-code/chapter-09/docker-compose.yml

version: "3.4"

services:
  active-record:
    environment:
    - PB_SERVER_TYPE=protobuf/nats/runner
    build:
      context: ./active-record
      dockerfile: ../../Dockerfile
    command: bundle exec rpc_server start -p 9399 -o active-record ./config/environment.rb
    volumes:
    - ./active-record:/usr/src/service
    depends_on:
    - nats
  active-remote:
    environment:
    - PB_CLIENT_TYPE=protobuf/nats/client
    build:
      context: ./active-remote
      dockerfile: ../../Dockerfile
    command: bundle exec puma -C config/puma.rb
    ports:
    - 3000:3000
    volumes:
    - ./active-remote:/usr/src/service
    depends_on:
    - nats
  nats:
    image: nats:latest
    ports:
    - 8222:8222
```

### Ejecutando las aplicaciones

¡Felicidades! Sus aplicaciones ahora están configuradas y listas para ejecutarse
en un contenedor de Docker. Ejecute el siguiente comando para descargar las
imágenes requeridas, cree una nueva imagen que será utilizada por ambos
contenedores de Rails e inicie tres servicios: `active-record`, `active-remote`
y `nats`.

```console
$ cd chapter-09
$ docker-compose up
```

Puede que tarde unos minutos, pero una vez que todos los contenedores estén en
funcionamiento, podemos navegar hasta http://localhost:3000/employees. La
aplicación Rails que se ejecuta en el puerto 3000 es la aplicación Active Remote
.

### Monitorizando

Si revisamos el log en la consola donde ejecutó el comando `docker-compose up`,
deberíamos ver una salida como la siguiente:

```console
active-remote_1  | I, [2019-12-28T00:35:06.460838 #1]  INFO -- : [CLT] - 6635f4080982 - 2aca3d71d6d0 - EmployeeMessageService#search - 48B/75B - 0.0647s - OK - 2019-12-28T00:35:06+00:00
```

Esto indica que se llamó al método `EmployeeMessageService#search`. No todos los
resultados de los servicios se muestran en la salida por consola.

Continúe y haga clic en el enlace "New Employee". Complete los campos Nombre y
Apellido y haga clic en el botón "Create Employee" para crear un nuevo registro
de empleado. Revise los registros nuevamente. Debería ver un mensaje como el
siguiente.

```console
active-remote_1  | I, [2019-12-28T00:40:43.597089 #1]  INFO -- : [CLT] - 0d6886451aa0 - 3f910c005424 - EmployeeMessageService#create
```

También podemos verificar la información de conexión NATS para verificar que los
datos se pasan a través del servidor NATS. Vaya a http://localhost:8222 y haga
clic en el enlace 'connz'. Al hacer clic en los enlaces para extraer datos en la
página http://localhost:3000/employees se pasarán mensajes adicionales a la
aplicación `active-record` a través del servidor NATS. Al actualizar la página
http://localhost:8222/connz se mostrarán contadores incrementales en los campos
`num_connections`, `num_connections/in_msgs` y `num_connections/out_msgs`.

## Recursos

* https://docs.docker.com/compose
* https://nats.io
* https://www.sqlite.org

## Recapitulando

Ahora que ha configurado y puesto en marcha dos nuevos servicios que pueden
comunicarse y compartir datos a través de Protobuf, siéntase libre de
experimentar agregando nuevos mensajes de Protobuf, llamadas a procedimientos
remotos adicionales, etc.

Después de completar los ejercicios de este capítulo, hemos creado una
plataforma sincrónica. En otras palabras, cuando el servicio solicita un objeto
Active Remote específico, espera una respuesta rápida de uno de los servicios
poseedores del modelo Active Record. En el próximo capítulo, discutiremos el
patrón de arquitectura basado en eventos. Este patrón nos permite agregar uno o
más servicios, cada uno de los cuales puede realizar una acción cuando se
detecta un evento.

[Siguiente >>](110-chapter-10.es.md)

  [Rubygems]: https://rubygems.org.
