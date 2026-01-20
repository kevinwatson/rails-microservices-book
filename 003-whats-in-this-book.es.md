## ¿Qué contiene este Libro?

Este libro está compuesto por muchas secciones a lo largo de las cuales
discutiremos diferentes patrones de arquitectura para desarollar systemas
distribuidos o no tan distribuidos. También discutiremos varios métodos de
comunicación de datos entre las diferentes aplicaciones.

Discutiremos además la plataforma Ruby on Rails y los ladrillos necesarios, en
todo proceso constructivo, para proveer acceso a los datos que nuestra
aplicación procesará. Analizaremos plataformas de comunicación via mensajes,
entidades de modelación de datos y sus relaciones en un entorno distribuido.

Daremos los pasos necesarios para armar un nuevo entorno que consista en un
servidor NATS y dos aplicaciones Rails, una con un modelo soportado por una
base de datos y otra con un modelo que accede de manera remota a los datos
de la primera aplicación.

Debatiremos sobre mensajes orientados a eventos y cuándo es apropiado; mientras
construimos dos aplicaciones que se comunican usando RabbitMQ.

Por último construiremos una plataforma que use ambos patrones de arquitectura:
síncrono y orientado a eventos, para compartir los datos entre los servicios.

[Siguiente >>](004-what-you-need.es.md)
