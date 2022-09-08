### Capítulo 2 - Comunicaciones del servicio

## Introducción

En la medida que la infraestructura del servicio crece necesitamos buscar un
protocolo de comunicaicón que tenga un buen equilibrio entre desarrollo,
mantenimiento, velocidad y que sea capaz de adaptarse con facilidad a nuevos
cambios.

## Protocolos

Varios protocolos pueden ser utilizados para transportar los datos entre los
servicios. Cada uno tiene sus pros y sus contras, HTTP por ejmplo, es uno de los
más ampliamente utilizados para páginas webs y APIs tipo REST. HTTP provee
discímiles características tales como autenticación pero también envía datos de
encabezado con cada petición. Enviar dichos encabezados con cada petición puede
causar congestión del tráfico de red cuando estamos diseñando una plataforma que
para escalar requiere que cada mensaje sea lo más pequeño posible.

_**Table 2-1**_ Protocolos de red

| Protocolo | Ventajas | Desventajas | Ejemplos de uso |
|---|---|---|---|
| AMQP | Formato binario que provee mecanismos de cola, enrutamiento y confiabilidada | Sólo soporta formato bienario | Envía y recive mensajes de RabbitMQ |
| HTTP(S) | Corre encima de TCP, provee métodos de solicitud, autenticación y conexiones persistentes | Algunas características requiren procesamiento adicional y los encabezados también se envían con cada petición | El www, el correo-e, las API tipo REST |
| NATS | Basado en texto, por lo que los clientes disponen de una gran varieda de lenguajes de programación | Sólo se utiliza para conectarse a un servidor NATS | Publicar hacia o consumir desde un servidor NATS|
| TCP | Uno de los protocolos de Internet más populares que es usado para estblecer conexiones cliente-servidor; garantizando que los datos sean entregados al cliente y provee mecanismos de detección y reenvío de errores | Más lento que otros protocolos como UDP | SSH, el www, el correo-e |
| UDP | Su diseño no orientado a conexión permite una mayor velocidad y eficiencia |  No provee mecanismos de chequeo de errores ni garantía alguna de que el cliente reciba los datos | Transmisión de video, DNS |

## Serialización de datos

Los datos enviados necesitan ser empaquetados para su entrega. Algunos de los
mecanismos de empaquetar datos se muestran en la siguiente tabla:

_**Table 2-2**_ Formatos de serialización de datos

| Formato | Texto/Binario | Ventajasn | Desventajas |
|---|---|---|---|
| JSON | Texto | Estructurado, inteligible por un humano | Las llaves están presentes en cada objeto lo que los hace mayores en tamaño |
| Protocol Buffers (Protobuf) | Binario | Compacto | Tanto cliente como servidor deben saber la estructura del mensaje codificado |
| XML | Texto | Estructurado, inteligible por un humano | Requiere abrir y cerrar etiqutas alrededor de cada campo lo que los hace mayores en tamaño |

### Ejemplos

He aquí algunos ejemplos de datos serializados para cada formato.

#### JSON

JSON (del inglés JavaScript Object Notation) es un formato basado en texto e
inteligible por un humano, cuya estructura consiste en pares nombre-valor.
Debido a su estructura simple se ha convertido en una opción popular para
compartir datos entre servicios.

```json
[
  {
    "id": 1,
    "first_name": "George",
    "last_name": "Costanza"
  },
  {
    "id": 2,
    "first_name": "Elaine",
    "last_name": "Benes"
  }
]
```

#### Protocol Buffers

Protocol Buffers (Profobuf) es un formato independiente del lenguaje de
programación que se usa para generar código específico del lenguaje que produce
mensajes muy pequeños para ser enviados por la red. La principal ventaja es
la eficiencia de red pero a su vez la principal desventaja es que ambos
extremos de la comunicación (ciente y servidor) deben estar previamente de
acuerdo en la estructura del mensaje.

Mientras otros formatos como JSON usan pares nombre-valor para describir cada
pieza de dato, Protobuf en cambio usa una posición del campo para definir a
medida que el campo en cuestión es codificado o decodificado en el formato
binario.

El mensaje Persona (Person en Inglés)

```protobuf
message Person {
  int32 id = 1;
  string first_name = 2;
  string last_name = 3;
}
```

Una lista de gente en un mensaje simple (People es el plural de Person en
Inglés, N. del T.)

```protobuf
message PeopleMessageList {
  repeated PersonMessage records = 1;
}
```

##### Implementación en Ruby

La clase Persona

```ruby
class PersonMessage < ::Protobuf::Message
  optional :int32, :id, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end
```

Una clase para representar una lista de gente

```ruby
class PeopleMessageList < ::Protobuf::Message
  repeated ::PersonMessage, :records, 1
end
```

*Datos serializados*

Los datos a continuación representan una cadena de caracteres en codificación
binaria.

```console
# Person 1
\b\x01\x12\x06George\x1A\bCostanza

# Person 2
\b\x02\x12\x06Elaine\x1A\x05Benes

# Both
\n\x14\b\x01\x12\x06George\x1A\bCostanza\n\x11\b\x02\x12\x06Elaine\x1A\x05Benes
```

#### XML

XML (del Inglés Extensible Markup Language) es un formato basado en texto e
inteligible por un humano que al igual que JSON define tanto la estructura como
los datos en el mismo cuerpo del mensaje. XML también es una opción popular para
el intercambio de datos en Internet y entre sistemas.

```xml
<People>
  <Person>
    <Id>1</Id>
    <FirstName>George</FirstName>
    <LastName>Costanza</LastName>
  </Person>
  <Person>
    <Id>2</Id>
    <FirstName>Elaine</FirstName>
    <LastName>Benes</LastName>
  </Person>
</People>
```

## Messaging Systems

Hasta ahora hemos descrito protocolos para transferir y empaquetar nuestros
datos. Ahora analizaremos las arquitecturas establecidas que podemos usar para
comunicarnos entre sistemas. Los microservicios son aplicaciones pequeñas e
independientes que pueden comunicarse con otras aplicaciones para realizar algún
trabajo.

Los servicios pueden llamar directa o indirectamente a otros servicios. Cuando
un servicio (emisor) llama directamente a otro servicio (receptor), el emisor
espera que el receptor esté disponible en el recurso que el emisor ya conoce.
Por ejemplo, si una API aloja un recurso `HTTP` en
`http://humanresources.internal/employees`, puediéramos escribir un servicio que
actúe como un cliente que puede llamar a ese recurso. Como respuesta esperaríamos
recibir una lista de empleados, codificada en algún formato, como `JSON`.

Llamar indirectamente a un servicio significa que hay algún sistema entre los
dos servicios. Ejemplos de sistemas que actúan como intermediarios incluyen a
un servidor proxy que puede devolver una copia en caché de los datos o a un
servidor de cola de mensajes que puede poner en cola las solicitudes y suavizar
la carga de trabajo del servidor que proporciona los datos.

Los servicios también pueden realizar llamadas de solicitud-respuesta o de
lanza-y-olvida. El patrón de arquitectura de solicitud-respuesta se utiliza
cuando el servicio envía una solicitud a otro servicio y espera una respuesta.
El patrón dispara-y-olvida se utiliza para enviar un mensaje a un servicio
intermediario que luego notifica a todos los servicios interesados. El remitente
del mensaje en dispara-y-olvida no espera ninguna respuesta, solo que el
mensaje sea enviado.

Nuestras necesidades comerciales regirán los patrones de la arquitectura de
microservicios que finalmente implementaremos. Estos patrones no son mutuamente
excluyentes por servicio, o dicho de otra manera, se pueden combinar en un solo
servicio como mostraremos en el capítulo 13.

## Referencias

[Advance Message Queuing Protocol][]
[Protocol Buffers][]
[NATS][]
[JSON][]
[XML][]

## Empaquetando

En este capítulo discutimos varios protocolos y formatos de mensajes que se
pueden usar para compartir datos entre servicios. En el próximo capítulo,
cubriremos el lenguaje Ruby y la plataforma Ruby on Rails.

[Siguiente >>](040-chapter-03.es.md)

[Advance Message Queuing Protocol]: https://www.amqp.org
[Protocol Buffers]: https://developers.google.com/protocol-buffers
[NATS]: https://docs.nats.io/nats-protocol/nats-protocol
[JSON]: https://www.json.org
[XML]: https://www.w3.org/XML
