### Chapter 5 - Active Remote

> ... La senadora Amidala, antigua reina de Naboo, regresa al Senado Galáctico
para votar por el tema crítico de crear un Ejercito de la República para asistir
al Jedi preocupado...
- La guerra de las Galaxias - Episodio 2 - El ataque de los Clones

## Introducción

Active Remote es una gema ruby que reemplace los modelos de Active Record en
nuestra aplicación para proveer acceso a otros modelos que existen en otras
aplicaciones en la red. Con una filosofía similar a Active Resource, provee
acceso a los datos de recursos remotos.

La diferencia es que mientras Active Resource provee acceso a recursos tipo REST
Active Remote lo hace utilizando métodos más duraderos y eficientes (Ej
utilizando un bus de mensajes para durabilidad y Protobuff para una eficiente
serialización y deserialización de los datos).

## Filosofía

Active Remote intenta proveer una solución para acceder y administrar recursos
distribuídos brindando un modelo el cual puede ser implementado con una cantidad
de código mínima. Si el modelo de datos persiste de manera local o en cualquier
otro lugar no es problema para el resto de la aplicación.

Incluso, ya que Active Remote implementa un sistema de mensajería
publicador-subscriptor, los clientes no necesitan estar configurados con
detalles acerca de cuáles servidores poseen o responden a determinados recursos.
Los clientes sólo necesitan saber cuáles temas publicar hacie el sistema de
mensaje y que algún otro servidor responderá a sus peticiones.

## Diseño

Durante la inicialización de la aplicación, los modelos de Active Record leen el
esquema de la base de datos y generan todos los métodos get, set y demás métodos
los cuáles reducen la cantidad de andamiaje que necesita ser añadido en el
código de los modelos que heredan de ActiveRecord::Base. Como Active Remote no
tiene acceso directo a la base de datos, en el lado del cliente tendremos que
declarar los atributos del model Active Remote usando el método `attribute`. En
el lado del servidor, donde querramos compartir datos de Active Record,
tendremos que crear una clase Service para cada modelo que defina puntos de
acceso que permitan búsqueda, creación, actualización, eliminación, etc.

## Implementación

Active Remote es empacado como una gema ruby que provee un lenguaje específico
de dominio (DSL por sus siglas en inglés), maneja campos guid de llaves
primarias y maneja serialización entre otras funcionalidades. La gema Active
Remote pendende de la gema Protobuf, la cuál será instalada automaticamente
cuando instalamos o incluímos la gema Active Remote.

Para compartir datos entre servicios, necesitaremos incluir la gema Protobuf
NATS. Para la aplicación cliente en Rails, Active Remote y Protobuf NATS son las
gemas que necesitaremos incluir en nuestra aplicación. En la aplicación servidor
en Rails, incluiremos las gemas Active Remote, Protobuf NATS y Protobuf Active
Record. Esta última gema se adhiere a las otras 2 proporcionando funcionalidades
tales como enlazar los mensajes Protobuff con las clases de ACtive REmote.

## Recursos

* https://github.com/abrandoned/protobuf-nats
* https://github.com/liveh2o/active_remote
* https://github.com/liveh2o/protobuf-activerecord
* https://github.com/rails/activeresource
* https://github.com/ruby-protobuf/protobuf

## Recapitulando

Active Remote nos permite construir una plataforma de comunicación eficiente y
duradera entre microservicios. También permite seguir una arquitectura bien
establecida como lo es MVC.

Debido a que Active Remote implementa un bus de mensajes para comunicar entre
servicios brinda durabilidad a los mismos. Mientras el bus de mensajes
permanezca en línea la aplicación Rails puede enviar mensajes a cualquier
servicio y eventualmente recibir respuesta cuando algún servicio caído vuelva a
estar en línea.

Active Remote también implementa Protobuf como mecanismo eficiente de
serialización y deserialización. En la medida que la plataforma crece minimizar
la cantidad de datos de viaja a través del cable paga dividendos mientras
continuemos escalando la plataforma.

En el próximo capítulo hablaremos de las colas de mensajes, levantaremos un
servidor NATS para enviar y recibir mensajes simples a través del protocolo
telnet.

[Siguiente >>](070-chapter-06.es.md)
