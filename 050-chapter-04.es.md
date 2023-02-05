### Capítulo 4 - Active Record y Active Model

> Un objeto que encapsula una tabla en una base de datos o en una vista
encapsula el acceso a dicha base de datos y añade lógica de dominio en esos
datos - Martin Fowler, Patterns of Enterprise Architecture

## Introducción

El patrón arquitectura de modelo provee la serialización y deserialización de
datos para nuestra aplicación.

#### Active Model

Active Model es una biblioteca de módulos que preovee varios métodos para Active
Record. Los módulos de Active Model pueden  ser incluídos en nuestras clases
para proveer la misma funcionalidad. Algunos de los módulos incluídos se
muestran a continuación.

- AttributeMethods - añade prefijos y sufijos personalizados a los métods de una
clase.
- Callbacks - añade los métodos "before", "after" y "around".
- Conversion - añade los métodos "to_model, "to_key" y "to_param" a un objeto.
- Dirty - añade métodos para determinar cuando el objeto fue modificado o no.
- Validations - añade el método "validation" a un objeto.
- Naming - añade métodos de clase que proveen las versiones plural y singular
del nombre de la clase.
- Model - añade métodos de clase para validaciones, traducciones y conversiones,
así como la habilidad para inicializar un objeto con un hash de atributos.
- Serialization - añade funcionalidades para facilitar la serialización a y
deserialización desde un objeto hacia o desde un hash o un objeto JSON.
- Translation - añade métodos para internationalización usando i18n.
- Lint Tests - añade funcionalidades para probar cuando nuestro objeto es
conforma con el API de Active Model.
- SecurePassword - añade métodos para almacenar passwords o cualquier otro tipo
de datos de manera segura utilizando la gema "bcrypt".

#### Active Record

El núcleo de una aplicación Rails son sus datos. Las aplicaciones Rails, así
como muchos otros frameworks similares, son construidos con múltiples capas.
Rails, en sí, sigue el patrón de arquitectura MVC (modelo-vista-controlador)
para separar la lógica de programación de la presentación de los datos y del
procesamiento de los mismos. Active Record es la parte del modelo del patrón
MVC en Rails. Active Record es donde añadimos funcionamiento y persisten los
datos requeridos por nuestra aplicación.

Usar Active Record, ya sea en una aplicación Rails u otra independiente,
nos trae los siguientes beneficios:

* Una forma de representar los modelos y los datos
* Asociasiones entre modelos
* Jerarquías a través de modelos relacionados
* Validación de los datos
* Acceso a la base de datos utilizando objetos

#### ¿Cuál es la diferencia?

La forma más común de almacenar y obtener datos en una aplicación Rails es
usando Active Record, el cual encapsula la base de datos y sus relaciones.
Active Record es, por tanto, una envoltura para recursos tipo REST

Active Model es utilizado por Active Record para la validación de los datos y
la serialización entre otras funciones.

No todos los modelos necesitan ser modelos de Active Record que mapean alguna
tabla en la base de datos. Podemos añadir a nuestra aplicación algunos modelos
cuyos datos persisten en la base de datos, mientras que otros modelos pueden
mapear puntos de entradas en un API.

Todo lo anterior nos lleva a Active Remote que provee modelos que mapean
servicios remotos sobre un canal de mensajes. Discutiremos esto en detalles en
el próximo capítulo.

## Recursos

* [Active Model][]
* [Active Record][]

## Recapitulando

Hay una variedad de gemas de Ruby disponibles que pueden ayudar a construir
nuestra capa de modelos de la aplicación. Si seguimos algún tipo de patrón de
arquitectura orientado al modelo podremos crear modelos respaldados por recursos
tipo REST, una base de datos o similares. En el próximo capítulo vamos a
discutir un nuevo tipo de modelo: Active Remote, el cual provee un modelo para
nuestra aplicación cuyos datos son obtenidos de otro servicio, nos permite
continuar utlizando el patrón MVC de Rails y  nos permite compartir datos entre
aplicaciones de manera eficiente.

[Next >>](060-chapter-05.es.md)

  [Active Model]:  https://guides.rubyonrails.org/active_model_basics.html
  [Active Record]:  https://guides.rubyonrails.org/active_record_basics.html
