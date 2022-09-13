### Capítlo 3 - Ruby y Ruby on Rails

> ¿Qué pasa si cada idea creativa que alguien tiene es adquirida
> inconscientemente de las experiencias de esa persona en otra realidad? ¿Quizás
todas las ideas son plagiadas sin que nos demos cuenta, porque nos llegan a
través de algún desliz de realidad críptico e indemostrable?
- Elan Mastai, All Our Wrong Todays

## Ruby

El lenguaje de programación Ruby fue diseñado y desarrollado por Yukihiro "Matz"
Matsumoto a mediado de los '90. El lenguaje estuvo en la sombra hasta que David
Heinemeier Hansson, en Julio de 2004, publicó la plataforma Ruby on Rails cuya
popularidad impulsó el desarrollo ulterior de Ruby.

Ruby es un lenguage de alto nivel ya que provee una elevada abstracción de los
detalles de implementación del hardware del equipo de cómputo. El beneficio
resultante es que el desarrollador tiene más libertad para escribir código que
el intérprete de Ruby tiene de procesar, traducir y optimizar para hardware. La
desventaja es que el desarrollador tiene más libertad para escribir código que
quizás no sea optimizado para el hardware.

Ruby es, además, un lenguaje interpretdo. Dependiendo de la implementación un
lenguaje interpretdo corre sobre una máquina virtual la que a su vez corre sobre
el procesador del equipo de cómputo. En cambio los lenguajes compilados son
convertidos a código intermedio (por lo general bytecode) y corren directamente
sobre el procesador. Debido a la capa adicional que presupone la máquina virtual
los lenguajes interpretdos suelen ser más lentos.

## Ruby on Rails

Por el simple hecho de estar leyendo este libro, lo más probable es que el
lector esté familiarizado con los beneficios del lenguaje Ruby y la plataforma
Ruby on Rails. Si no, mi opinión es que el lenguaje Ruby y  Ruby on Rails
brindan las herramientas que un desarrollador necesita para ser altamente
productivo al crear aplicaciones web. Las nuevas aplicaciones se pueden activar
en cuestión de segundos. Hay una gran cantidad de bibliotecas disponibles
(conocidas en el mundo de Ruby como gemas), que se pueden usar para ampliar la
funcionalidad de su aplicación. Por ejemplo, si necesita ejecutar procesos en
segundo plano, hay una gema para eso: Sidekiq. Si su aplicación necesita
administrar dinero y monedas, hay una gema para eso: Money. podría seguir, pero
se comprende el punto.

Para más información sobre porqué debemos usar Rails, por favor, revice la
[documentación oficial][].

### Interpretes

Existen algunos intérpretes de Ruby disponibles. Discutiremos un par de ellos a
continuación.

#### MRI y YARV

El intérprete de Ruby de Matz (MRI por sus siglas en inglés) fue el estándar de
facto hasta Ruby 1.8. Cuando Ruby 1.9 fue lanzado otro intérprete ocupó su lugar
YARV (del Inglés Yet another Ruby VM). YARV ha sido el intérprete por defecto
desde Ruby 2.0. YARV en cambio sólo provee soporte para «hilos verdes» los
cuales no son soportados por el systema operativo y no son planificados como
tareas entre sus núcleos)

La buena noticia, en cambio, es que hay otros intérpretes dispoinbles que pueden
ayudar a optimizar el hardware para cualquier aplicación hecha a la medida que
desarrollemos.

#### JRuby

JRuby es una implementación de Ruby que compila el código Ruby y lo convierte en
el bytecode de Java. Algunos de los beneficios inmediatos son contar con un
verdadero soporte para multi-hilos, la estabilidad de la plataforma Java, la
habilidad de llamar, de manera nativa, clases escritas en Java y en algunos
casos mejor rendimiento. Uno de los principales problemas es que incrementa el
consumo de memoria; a fin de cuentas es Java.

## Recuros

* [Money][]
* [Sidekiq][]
* [Ruby on Rails][]
* [JRuby][]
* [Ruby Lang][]


## Recapitulando

Ruby es un lenguaje que fue concebido con la idea de la productividda del
desarrollador en mente. Ruby on Rails es una plataforma que provee las
herramientas necesarias para crear aplicaciones de manera muy rápida. Hay una
gran variedad de gemas (librerías) disponibles para ampliar las características
de nuestra aplicación.

En el siguiente capítulo discutiremos dos gemas muy populares: Active Record y
Active Model. Ambas son utilizadas para administrar y hacer persistir datos en
nustra aplicación.

[Siguiente >>](050-chapter-04.es.md)

[documentación oficial][https://rubyonrails.org]
[Money][https://rubygems.org/gems/money]
[Sidekiq][https://rubygems.org/gems/sidekiq]
[Ruby on Rails][https://rubyonrails.org]
[JRuby][https://www.jruby.org]
[Ruby Lang][https://www.ruby-lang.org]
