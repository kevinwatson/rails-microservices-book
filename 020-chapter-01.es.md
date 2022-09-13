### Capítulo 1 - Microservicios

> Bean, necesito que seas inteligente. Necesito que pienses en soluciones que
> no hayamos visto aún. Quisiera que intentaras cosas que nadie haya intentado
> jamás porque sean absolutamente estúpidas.
>
> Orson Scott Card, Ender's Game

## Arquitectura del servicio

Primero algunas definiciones:

* **API:** Interfaz de programación de la aplicación (por sus siglas en Inglés).
En el contexto de este libro, una aplicación que provee acceso a sus datos. Una
API provee comunicación aplicación-aplicación.
* **Función como servicio:** FaaS (por sus siglas en Inglés) es una pequeña
unidad de código que puede ser publicada y consumida sin siquiera contruir o
mantener la infraestructura circundante. Es considerada la forma de contruir
arquitecturas sin servidores (serverless).
* **Microservicio:** Una aplicación que provee funciones y datos específicos.
* **Monolito:** Una aplicación sencilla que provee toda, sino una gran parte de,
las funcionalidades que el producto o la compañía require.
* **Computación sin servidores:** El proveedor en la nube provee y permite
administrar de manera dinámica los resursos del servicio en la medida que sean
necesarios. Pequeñas unidades de código, por ejemplo funciones como servicio,
son desplegadas en un entorno sin servidores.
* **Servicio:** Un servicio, definido burdamente, es una aplicación independiente
que provee algún tipo de funcionalidad. Ejemplos podemos encontrar en un sitio
web, una API, un servidor de bases de datos, etc.

Cuando estamos diseñando un servicio por primera vez los requerimientos suelen
ser pequeños. Sin embargo en la medida que el tiempo pasa comenzamos a añadir
características y la aplicación crece llegando a convertirse en un sistema más
grande. A este tipo de sistema llamamos Monolito y no hay nada malo en construir
monolitos siempre y cuando puedan manejar la carga de procesamiento. Los
monolitos son la arquitectura más simple porque son simples de mantener por
pequeños equipos, todo el código está en el mismo lugar y la comunicaicón entre
módulos es instantánea pues no hay sobrecarga por la red.

## Más acerca de los microservicios

Un microservicio es una pequeña aplicación capaz de proveer un conjunto limitado
de funciones. En la filosofía Unix, según describe Doug McIlroy, un princpio
fundamental es que cada programa haga una sóla cosa y la haga bien. En términos
de arquitectura de microservicio nuestro objetivo es construir pequeños programas
o servicios que provean un conunto específico de funciones. En la medida que
mayor sea el uso de este conjunto de funciones en la organización mayor será la
necesidad de escalar esa función en particular para mantenerse alineado con las
necesidades del negocio.

## ¿Por qué debemos usar microservicios?

Por naturaleza, desarrollar servicios basado en la arquitectura de microservicios
incurre en una sobrecarga adicional que puede no ser adecuada en los momentos
iniciales de un proyecto. Una vez la aplicación comienza a ser popular y
comenzamos a identificar cuellos de botella en el proceso, puede ser tiempo de
identificar y comenzar a agrupar funcionalidades dentro del mismo servicio.

En la medida que el equipo de desarrollo crece puede dividirse el códico base en
unidades más pequeñas que pueden ser mantenidas y desplegadas de manera
independiente. Esto a su vez puede traer otros benificios como cilcos más cortos
de desarrollo, de pruebas y de lanzamiento del producto.

Si las funciones de nuestra aplicación tienen diferentes tiempos de ejecución o
actividad es posible que el código necesite ser dividido en microservicios más
pequeños. Esto nos permitirá conocer los requisitos de nivel de servicio en base
a lo que cada servicio necesita.

## Recursos

* [Filosofía Unix][]
* [Microservicios en Inglés][] 

## Recapitulando

Hay muchas maneras de proveer la lógica que nuestro negocio requiere. Muchos
negocios comienzan con pequeñas aplicaciones que luego van creciendo en la
medida que satisfacen las necesidades propias del modelo de negocios o que sus
usuarios demandan. La mayoría de las veces las aplicaciones de negocios crecen
y se convierten en aplicaciones monolíticas. Si bien hay muchas razones para
mantener el monolito, en la medida que el el negocio y el equipo crecen, podemos
necesitar dividir el código base en unidades más pequeñas y simples de mantener.

En el próximo capítulo discutiremos cómo se comunican los microservicios.
Veremos los pros y contras de algunos protocolos y métodos de serialización
que pueden ser utilizados para hacer persistir o codificar los datos

[Siguiente >>](030-chapter-02.es.md)

[Filosofía Unix]: https://es.wikipedia.org/wiki/Filosof%C3%ADa_de_Unix
[Microservicios en Inglés]: https://martinfowler.com/articles/microservices.html
