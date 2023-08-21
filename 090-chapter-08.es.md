### Capítulo 8 - Protocol Buffers (Protobuf)

> Los humanos habían desarrollado un modo secuencial de conciencia, mientras que
los heptápodos habían desarrollado un modo simultáneo de conciencia. Nosotros
experimentamos los eventos en un orden y percibimos su relación como causa y
efecto. Ellos experimentaron todos los eventos a la vez y percibieron un
propósito subyacente a todos. Un propósito minimizador y maximizador.
- Ted Chiang, La historia de tu vida

## Introducción

¿Por qué ha creado su aplicación? Lo más probable es que la razón sea que
necesitaba rastrear algunos datos. Es posible que usted o alguien de su empresa
haya comenzado con una hoja de cálculo, pero con el tiempo se dio cuenta de que
el seguimiento de los datos en una hoja de cálculo se volvió engorroso y ya no
satisfacía sus necesidades. Entonces, nació una aplicación. Su nueva aplicación
lista para usar luego comenzó a crecer, con relaciones entre entidades de datos.
A medida que aumentaba la cantidad de datos, la cantidad de relaciones y los
requisitos de procesamiento, decidió que necesitaba dividir su aplicación en
servicios separados. Cuando es necesario compartir un dato entre aplicaciones
debemos tomar un par de decisiones. ¿Qué atributos se compartirán? ¿Cómo
accederán los clientes a los datos? ¿Qué aplicación poseerá y conservará los
datos? ¿Cómo podemos facilitar la ampliación o la adición de nuevos atributos a
nuestras entidades y que siga siendo compatibles con las versiones anteriores?

Cuando crea una plataforma de microservicios, debe tomar varias decisiones, una
de ellas es cómo compartimos datos entre servicios. Como se discutió en el
capítulo 2, Protocol buffers (también conocidos como protobuf) es una de esas
opciones.

Desarrollado por Google, protobuf es un método de serialización de datos en un
formato binario que permite el rendimiento sobre la flexibilidad. Protobuf tiene
una estructura estándar para definir mensajes. Los compiladores están
disponibles para convertir las definiciones en clases o estructuras que son
específicas del lenguaje. Por ejemplo, el mismo archivo de definición se puede
usar para generar clases o estructuras tanto para Java como para Ruby, de modo
que las aplicaciones escritas en ambos lenguajes puedan compartir el mismo
mensaje.

## Filosofía

Protobuf serializa los datos en un formato binario que no se describe a sí mismo
. Por el contrario, un objeto JSON o XML suele ser legible y editable por
humanos, cada objeto se puede inspeccionar y el desarrollador puede ver los
nombres de los campos y sus valores. Protobuf es un formato binario. Implementa
un formato de campo ordenado y ambos servicios que comparten el mensaje
necesitan conocer la estructura del mensaje.

Hay muchas formas de codificar y compartir datos. XML, JSON y otros formatos
están bien definidos y son fáciles de generar y consumir. Pero, ¿qué sucede si
desea un mejor rendimiento de codificación y decodificación? ¿Qué sucede si
desea reducir la carga de la red de mensajes que se transmiten entre sistemas?
¿Qué pasa si su plataforma, la cantidad de desarrolladores y la cantidad de
mensajes que pasan entre sistemas crecen de la noche a la mañana?

Protobuf intenta resolver estos y otros problemas codificando datos en un
formato binario (que, por supuesto, es mucho más pequeño que un objeto
codificado XML o JSON). Las definiciones de Protobuf constan de uno o más
campos numerados de forma única. A cada campo codificado se le asigna un
número de campo y un valor. Este número de campo es lo que diferencia a
Protobuf de otros objetos. El número de campo se usa para codificar y
decodificar los atributos del mensaje, reduce la cantidad de datos que deben
codificarse al omitir el nombre del atributo y permite la capacidad de
extensión para que los desarrolladores puedan agregar campos a una definición
sin tener que actualizar todas las aplicaciones que consumen ese mensaje al
mismo tiempo. Esto es posible porque las aplicaciones existentes ignorarán los
nuevos campos en cualquier mensaje que reciban y decodifiquen.

## Implementación

A continuación se muestra un ejemplo de definición de Protobuf. Los archivos
Protobuf tienen la extensión de archivo `.proto`.

**Ejemplo 8-1** Mensaje protobuf Employee

```proto
// file employee.proto
1 syntax = "proto3";
2
3 message Employee {
4   string guid = 1;
5   string first_name = 2;
6   string last_name = 3;
7 }
```

Inspeccionemos cada línea.

La línea 1 define la versión de la sintaxis de Protobuf que nos gustaría usar.

La línea 3 es el comienzo de nuestra declaración de mensaje.

Las líneas 4-6 son las definiciones de campo. Cada línea tiene un tipo (el campo
GUID es un tipo de cadena). La línea 4 tiene un nombre de atributo de `guid` y
el número de campo de 1.

Esta definición de Protobuf no se utiliza así en su aplicación. Lo que haremos a
continuación es compilar este archivo `employee.proto` en una clase o archivo de
estructura similar al lenguaje en el que está escrita su aplicación, ya sea Java
, C#, Go o Ruby. Si admite una plataforma heterogénea con varios idiomas, es
posible que desee crear secuencias de comandos que compilarán automáticamente
sus archivos `.proto` en los lenguajes requeridos cada vez que agregue un nuevo
archivo `.proto` o agregue un nuevo campo a uno de sus definiciones existentes.

Cubrimos brevemente la [implementación de Ruby en el capítulo 2][], pero
repasemos y sigamos en más detalle aquí.

El siguiente ejemplo es el resultado de la implementación de Ruby (se pueden
encontrar configuraciones y detalles adicionales en
[chapter 9][]. Después de definir el archivo de definición `.proto` y ejecutar
el comando `rake protobuf:compile`, ahora tendremos archivos similares a los
siguientes:

**Ejemplo 8-2** Clase Employee protobuf en Ruby

```ruby
# file employee.pb.rb
class Employee < ::Protobuf::Message
  optional :string, :guid, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end
```

**Datos serializados**

Note que los datos siguientes corresponden con la representación en cadena de
caracteres de la codificación binaria.

**Ejemplo 8-3** Codificación de Employee protobuf

```console
# Employee
\n$d4b3c75c-2b0c-4f74-87d7-651c5ac284aa\x12\x06George\x1A\bCostanza
```

Hay un par de cosas a tener en cuenta en esta cadena. La primera es que no se
desperdicia espacio al definir los nombres de los campos. Los números al final
de la línea en los archivos `.proto` y `.rb` indican el índice del campo.
Cuando se serializan los datos en el mensaje protobuf, los datos se empaquetan
en un orden secuencial sin los nombres del campo. Se utiliza un delimitador
para separar los campos, que siempre estarán en el mismo orden. Ocasionalmente,
es posible que necesitemos deprecar o eliminar un campo. Debido a que los campos
están indexados, el índice del campo que debe eliminarse siempre ocupará ese
espacio y nunca debemos reutilizar ese número de índice. Si tuviéramos que
reutilizar el número de índice, los servicios que todavía usan la definición
anterior malinterpretarían los datos en esa posición y las cosas pueden salir
mal, especialmente cuando se modifica el tipo de datos pero se reutiliza el
índice del campo (por ejemplo, si el tipo de datos cambia de un int32 a un bool)
.

Depende del receptor conocer los índices y sus nombres de campo relacionados al
deserializar el mensaje. Esto tiene la ventaja de requerir menos ancho de banda
de red para entregar el mensaje en comparación con otras estructuras de mensajes
como JSON o XML. Otra ventaja es que cuando se deserializa el mensaje protobuf,
se ignoran los campos adicionales que no están definidos en la clase protobuf.
Esto hace que la plataforma sea mantenible, porque los remitentes y los
receptores se pueden actualizar e implementar de forma independiente.

Por ejemplo, un remitente puede tener una nueva clase `::Protobuf::Message` que
agrega nuevos campos a un mensaje protobuf. Cuando este mensaje es recibido por
otro servicio, los nuevos campos serán ignorados por cualquier receptor que esté
usando una versión anterior de la clase `::Protobuf::Message`. Un receptor
también se puede modificar de forma independiente para esperar un nuevo campo,
pero si no está definido en el protomensaje del remitente, el campo se marca
como `nil` (o el valor equivalente cero o `nil` del lenguaje). En estos
ejemplos, existe la posibilidad de que se pierdan los datos de los nuevos campos
, por lo que es posible que desee actualizar los receptores antes de actualizar
los remitentes. Este diseño le permite actualizar los servicios de forma
independiente sin el riesgo de romper las aplicaciones receptoras porque no
están listas para recibir los campos recién definidos.

## Recursos

* https://developers.google.com/protocol-buffers
* https://github.com/ruby-protobuf/protobuf/wiki/Compiling-Definitions

## Recapitulando

Protobuf es una forma eficiente de empaquetar y compartir datos entre servicios
. Es agnóstico del lenguaje y extensible. Debido a que son independientes del
lenguaje, no está limitado a crear servicios en un solo lenguaje de programación
en su plataforma. Por ejemplo, puede escribir sus aplicaciones de línea de
negocio internas en Rails mientras escribe sus algoritmos de procesamiento de
datos en R.

En el próximo capítulo, pondremos en marcha un entorno limitado de desarrollo
con NATS y Rails. Crearemos dos aplicaciones Rails, una que posee una base de
datos y comparte los datos a través de Protobuf y Active Remote y otra que
actúa como un cliente que puede recuperar y modificar los datos en la primera
aplicación.

[Siguiente >>](100-chapter-09.es.md)

  [implementación de Ruby en el capítulo 2]: https://github.com/kevinwatson/rails-microservices-book/blob/master/030-chapter-02.es.md#protocol-buffers
  [chapter 9]: https://github.com/kevinwatson/rails-microservices-book/blob/master/100-chapter-09.es
