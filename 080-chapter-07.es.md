### Capítulo 7 - Relaciones entre los datos

## Introducción

Lo más probable es que su aplicación se diseñe con una o más tablas en base de
datos, ya sea que estén almacenadas en una base de datos relacional o en una
base de datos NoSQL. A medida que crezca la aplicación, definirá relaciones
entre entidades que deberán definirse tanto en la aplicación como en la base
de datos.

## Llaves priamria y foránea

Las llaves primarias son atributos usados para identifiable la unicidad de una
fila en una relación (también conocida como tabla en la terminología de las
bases de dato). Las llaves foráneas se utilizan para asociar registros hijos o
dependientes a otra relación.

## Llaves naturales Vs llaves subrogadas

En la mayoría de las relaciones las filas deben tener un identificador único.
Un identificador único puede ser un solo atributo, dos o más atributos.

Una llave natural se define como uno o más atributos que identifican de forma
única una fila. Por ejemplo, en una relación donde almacena la información de
su empleado, podría usar sus atributos de nombre y apellido como llave natural.
Pero, ¿qué sucede cuando su empresa contrata a otra persona con el mismo nombre
y apellido? Cuando llegue ese momento, habrá deseado elegir una mejor llave
natural, como su Número de Identidad. Podría utilizar el atributo del Número de
Identidad como llave natural. Los Números de Identidad son únicos y se asignan
a una persona para toda su vida. Debido a esto, es una excelente llave natural
porque identifica de manera única a un empleado, pero no cambia como podría
hacerlo su nombre.

> Nota: No abogamos porque almacene Números de Identidad en su base de datos,
pero esto sirve como un gran ejemplo de un valor único que proviene de una
fuente externa. Otra razón para no depender de los Números de Identidad como
identificadores únicos es que algunos empleados podrían no tener uno asignado
por la Administración correspondiente.

Su sistema de base de datos genera automáticamente llaves subrogadas. La mayoría
de las llaves subrogadas son un tipo de número entero que generalmente comienza
en 1 y aumenta (+1) por cada nueva fila que se inserta.

En teoría se prefieren las llaves naturales a las llaves subrogadas porque están
compuestas por los datos que se almacenan en la base de datos. Sin embargo, en
la práctica, las llaves subrogadas suelen ser más fáciles de usar y, por lo
general, se pueden optimizar para mejorar el rendimiento de la aplicación y la
base de datos.

## Generadas en Base de datos Vs Generadas por la aplicación

La base de datos o la aplicación pueden generar llaves subrogadas. La base de
datos suele generar llaves que son de tipo entero, y la concurrencia de la base
de datos garantiza que cada nuevo registro obtenga un valor único en su columna
de llave principal, ya sea que tenga una o veinte instancias de la aplicación
insertando registros en la misma tabla.

### Enteros generados en la base de datos

Las llaves subrogadas más comunes generadas por un sistema de base de datos son
valores enteros. Al diseñar su base de datos, lo más probable es que necesite
agregar llaves subrogadas de tipo entero para que Active Record pueda
administrar los datos. Al diseñar sus tablas, tenga en cuenta que debe construir
sus estructuras de datos pensando a futuro. De forma predeterminada, el
scaffolding de Rails genera migraciones que utilizan tipos de datos enteros de
32 bits. Para la mayoría de las tablas, especialmente las tablas de búsqueda o
de dominio, este tipo de entero está perfectamente bien. Para algunas de sus
tablas, después de un tiempo (pueden ser meses o años más tarde), su aplicación
podría detenerse cuando la llave primaria entera de 32 bits alcance su valor
máximo.

Cuando esté diseñando su base de datos, si puede identificar qué tablas podrían
continuar creciendo en tamaño con el tiempo, sería mejor comenzar con un número
entero de 64 bits: tipos de datos bigint (MySQL) o bigserial (PostgreSQL). Si
usa un número entero de 64 bits para algunas de sus tablas, recuerde hacer
coincidir el tipo para las laves foráneas.

### Identificadores únicos

Una forma de generar llaves subrogadas, que a su vez las mantenga únicas, es
generar identificadores únicos en la aplicación. Estos identificadores únicos
se pueden compartir con otros servicios. Su diseño podría permitir que la base
de datos también genere una llave primaria incremental, pero esos valores nunca
deben compartirse con sistemas fuera de la aplicación.

Los identificadores únicos a veces se denominan identificadores únicos globales
(GUID, por sus siglas en Inglés) o identificadores únicos universales (UUID por
sus siglas en Inglés). Los UUID son un subconjunto de GUID. La aplicación puede
generar GUID antes de que el registro se conserve en la base de datos. A todos
los efectos prácticos, cada GUID es único. Un GUID de ejemplo es
`83efd88b-ec78-4e84-b8c7-dad8421d42d4`. Los GUID generalmente se representan
mediante dígitos hexadecimales separados por guiones. Estos valores se pueden
compartir como un identificador único para una fila u objeto específico de la
base de datos entre aplicaciones. También se pueden usar como llaves foráneas
para mapear objetos primarios y secundarios.

## Cuándo usar cada uno

Si su aplicación es monolítica (una sola aplicación que se ejecuta sobre una
sola base de datos), por lo general, no hay necesidad de usar incremento
automático nada más que en la llave primaria. Por defecto, las aplicaciones
Rails manejan bastante bien la implementación de la llave subrogada de la base
de datos.

Es en el momento en que decida dividir su base de datos y compartir datos entre
sistemas que necesitará implementar algún tipo de identificador único que se
pueda compartir entre sistemas. Una vez que llega a este punto, sus datos ya no
viven en una sola base de datos o aplicación, sino que se envían y comparten a
través de la red. Además, si implementa una llave primaria entera generada por
la base de datos y una llave UUID a medida que crece su plataforma de
microservicios, el valor entero generado por la base de datos no tiene
significado fuera de su propia base de datos y aplicación. No es necesario
compartir el valor entero, solo el UUID.

## Recursos

* https://en.wikipedia.org/wiki/Database_normalization
* https://en.wikipedia.org/wiki/Universally_unique_identifier

## Recapitulando

La normalización de la base de datos requiere que identifique una llave
principal. Esta llave podría ser una llave natural (una o más columnas que
definen los datos) o una llave subrogada generada por la aplicación o la base de
datos. Rails está diseñado para usar de manera natural llaves primarias
generadas por bases de datos. A medida que crece su infraestructura y comienza
a compartir datos con otros sistemas, el uso de un UUID es una opción que hace
que sus datos sean portátiles e identificables de forma única.

En el próximo capítulo, analizaremos una forma de serializar los datos que se
compartirán entre nuestros microservicios. Una forma de serializar de manera
eficiente los datos a través de Protocol Buffers (también conocido como Protobuf
).

[Siguiente >>](090-chapter-08.es.md)
