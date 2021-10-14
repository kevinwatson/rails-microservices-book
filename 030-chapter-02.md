### Chapter 2 - Service Communications

## Introduction

As your service infrastructure grows, you'll need to find a communication protocol that is a good balance of development, maintenance, speed and resilency.

## Protocols

Various protocols can be used to move data between services. Each has its advantages and disadvantages. For example, HTTP is one of the most widely used protocols for web pages and RESTful APIs. HTTP provides many useful features such as authentication, but also sends header data with each request. Sending header data with each request could cause undesired network congestion when we're designing a platform that, in order to scale, requires each message to be a small as possible.

_**Table 2-1**_ Network protocols

| Protocol | Advantages | Disadvantages | Example uses |
|---|---|---|---|
| AMQP | A binary format that provides queuing, routing, reliability | Binary only | Passing messages to and from RabbitMQ |
| HTTP(S) | Runs on top of TCP, provides request methods, authentication and persistent connections | Some processing overhead is required to provide some of its features, headers are also sent over the wire with each request | World Wide Web, Email, RESTful APIs |
| NATS | Text-based, so clients are available for a wide variety of programming languages | Only used to connect to a NATS server | Publishing to or listening on queues on a NATS server |
| TCP | One of the most popular protocols on the Internet, used for establishing the connection between server and client, guarantees that the data was delivered to the client, provides error checking and resends lost packets | Slower than other protocols such as UDP | SSH, World Wide Web, Email |
| UDP | Its connection-less design is for speed and efficiency | Does not provide error checking or any guarantees that the client received the data | Video streaming, DNS |

## Data Serialization

The data that is sent over the wire needs to be pakcaged for delivery. A few ways to package this data are in the table below:

_**Table 2-2**_ Data serialization formats

| Format | Text/Binary | Advantages | Disadvantages |
|---|---|---|---|
| JSON | Text | Structured, human readable | Keys are present in each object which inflates the message size |
| Protocol Buffers (Protobuf) | Binary | Small footprint | Both client and server need to know the structure of the encoded message |
| XML | Text | Structured, human readable | Opening and closing tags around each field which inflates the message size |

### Examples

Here are examples of serialized data in each format.

#### JSON

JSON (JavaScript Object Notation) is a human-readable, text-based format. Its structure consists of name-value pairs. Because of its simple structure, it has become a popular option for sharing data between services.

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

Protocol Buffers (Profobuf) are a language-independent format that is used to generate language-specific code to produce very small messages that are sent over the network. The advantage is network efficiency, the disadvantage is both the sender and receiver need to agree to the message structure in advance.

Other formats such as JSON use name/value pairs to describe each piece of data. Protobuf uses a field position to define the fields as they are encoded and decoded from a binary format.

The Person message

```protobuf
message Person {
  int32 id = 1;
  string first_name = 2;
  string last_name = 3;
}
```

A list of people in a single message

```protobuf
message PeopleMessageList {
  repeated PersonMessage records = 1;
}
```

##### Ruby Implementation

The Person class

```ruby
class PersonMessage < ::Protobuf::Message
  optional :int32, :id, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end
```

A class to hold a list of people

```ruby
class PeopleMessageList < ::Protobuf::Message
  repeated ::PersonMessage, :records, 1
end
```

*Serialized Data*

The data below is a string representation of the binary encoding.

```console
# Person 1
\b\x01\x12\x06George\x1A\bCostanza

# Person 2
\b\x02\x12\x06Elaine\x1A\x05Benes

# Both
\n\x14\b\x01\x12\x06George\x1A\bCostanza\n\x11\b\x02\x12\x06Elaine\x1A\x05Benes
```

#### XML

XML (Extensible Markup Language) is a human-readable, text-based format. Like JSON, XML defines both the structure and the data in the same message body. XML is a popular choice for exchanging data over the Internet and between systems.

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

So far we've described protocols for transfering and packaging our data. Now let's discuss established architectures that we can use to communicate between systems. Microservices are small, independent applications that can reach out to other applications to perform some work.

Services can directly or indirectly call other services. When a service directly calls another service, the caller expects the other service to be available at the endpoint that the caller already knows about. For example, if an API hosts an `HTTP` endpoint at `http://humanresources.internal/employees`, I may write a service that acts as a client that can call that endpoint. I would expect to receive a list of employees, encoded in some format, such as `JSON`.

Indirectly calling a service means that there is some system between the two services. Examples of systems that acts as an intermediary include a proxy server which may return a cached copy of the data or a message queue server which can queue up requests and smooth out the workload of the server that provides the data.

Services can also make request-reply or fire-and-forget requests. The request-reply architecture pattern is used when the service sends a request to another service and expects a response. The fire-and-forget pattern is used to send a message to an intermediary service which then notifies all interested services. The sender of the fire-and-forget message doesn't wait for any responses, only that the message was sent.

Our business needs will drive the microservice architectural patterns that we ultimately implement. These patterns are not mutually exclusive per service. These patterns can be combined in a single service, as we'll show in chapter 13.

## References

* https://www.amqp.org
* https://developers.google.com/protocol-buffers
* https://docs.nats.io/nats-protocol/nats-protocol
* https://www.json.org
* https://www.w3.org/XML

## Wrap-up

In this chapter, we discussed various protocols and message formats that can be used to share data between services. In the next chapter, we'll cover the Ruby language and the Ruby on Rails framework.

[Next >>](040-chapter-03.md)
