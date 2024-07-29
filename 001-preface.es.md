## Prefacio a la edición en Español

Bienvenido a *Creando Aplicaciones Distribuidas con Rails*.

Ruby on Rails es una plataforma construida sobre el lenguaje de programación
Ruby. La plataforma Rails provee las herramientas necesarias para construir
aplicaciones con bases de datos y ha logrado una popularidad generalizada,
actualmente muchos sitios populares corren sobre Rails, entre los que se
incluyen Shopify, Basecamp y Github.

Una arquitectura de aplicaciones distribuidas define modulos especializados o
componentes de un sistema en el cual, como un todo, proveen la funcionalidad que
los usuarios requiren. Las aplicaciones distribuidas pueden ser configuradas
para escalar tanto hacia arriba como hacia abajo según sea necesario,
especificamente por aquellos módulos que requieran un poder de cómputo adicional
. Por ejemplo el módulo que muestra el formulario para el inicio de sesión puede
no requerir mucha potencia de cómputo pero el que optimiza las fotos que suben
los clientes puede necesitar ponerlas a escala cada vez que un usuario añade un
conjunto nuevo de imágenes.

Este libro te adentrará a través del proceso de crear aplicaciones distribuidas
usando Ruby on Rails. Discutiremos aplicaciones monolíticas las cuales serán a
su vez divididas en unidades más pequeñas (microservicios) y describiremos
algunas formas de compartir datos entre estos microservicios. Usaremos un
un pequeño grupo de gemas de Ruby que han sido generosamente liberadas por
[MX][] para su uso por parte de la comunidad de código abierto.

MX es una compañía de servicios financieros basada en Utah. Sus miembros hemos
desarrollado una plataforma, desde sus inicios, distribuida y heterogénea que
procesa y analiza miles de millones de transacciones financieras cada mes.
Las contribuciones de MX a los estándares abiertos Protobuf, RabbitMQ y NATS
incluyen, pero no se limitan a, las siguiente gemas: `active_remote`,
`protobuf-nats`, `action_subscriber`, `active_publisher` and
`protobuf-activerecord`. Discutiremos cada una de ellas con detalles a lo largo
de este libro.

Ruby por su parte continúa evolucionando y ganando en popularidad. Las
contribuciones de MX a la comunidad de código abierto ayudan a asegurar que Ruby
coninúe siendo una opción viable para diseñar y desplegar modernos sistemas
distribuidos.

Debido a que la plataforma de MX está construida sobre estándares abiertos (Ej:
 Protocol Buffers, RabbitMQ y NATS) es agnóstica a los lenguajes de programación
 que sean empleados para crear nuevos servicios sobre ella. Siempre y cuando un
 servicio se comunique usando mensajes Protobuff y se conecte a NATS o a
 RabbitMQ podrá responder a mensajes desde cualquier aplicación escrita en
cualquier lenguaje de programación soportado.

Inlcuso si lenguaje no fuera Ruby, ojalá este libro brinde una visión general de
cómo diseñar y construir servicios distribuidos.

Hemos querido llevar al público hispanoparlante esta obra de valor incalculable
ya que casi toda la información relativa al desarrollo de microservicios en la
nube se genera en países en los que no se habla español. Esto provoca que sea
difícil para nosotros acceder en nuestro idioma nativo a información actualizada
y de calidad sobre estos temas. (N. del T.)

[Siguiente >>](002-who-is-this-book-for.es.md)

[MX]: https://mx.com
