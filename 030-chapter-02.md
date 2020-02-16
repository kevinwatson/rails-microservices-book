### Chapter 2 - Service Communications

## Introduction

As your service infrastructure grows, you'll need to find a communication protocol that is a good balance of development, maintenance, speed and resilency.

## Protocols

While there are a wide number of protocols available, our discussion will only include those in the table below:

| Protocol | Advantages | Disadvantages | Example uses |
|---|---|---|---|
| tcp | one of the main protocols on the Internet, used for establishing the connection between server and client | guarantees that the data was delivered to the client, provides error checking and resends lost packets | ssh, world wide web, email |
| http | runs on top of TCP | | world wide web, email |
| nats | text-based, so clients are available for a wide variety of programming languages | only used to connect to a NATS server | publishing to or listening on queues on a NATS server |
| udp | its connection-less design is for speed and efficiency | Does not provide error checking or any guarantees that the client received the data | video streaming, dns |

### HTTP(S)
### TCP
### UDP

## Data Serialization

The data that is sent over the wire needs to be pakcaged for delivery. A few ways to package this data are in the table below:

| Format | Text/Binary | Advantages | Disadvantages |
|---|---|---|---|
| json | text | structured, human readable | |
| protocol buffers (protobuf) | binary | small footprint | both client and server need to know the structure of the encoded message |
| xml | text | structured, human readable | opening and closing tags which increase the message size |

### Examples

Here are examples in each format.

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

Serialized data

```console
# Person 1
\b\x01\x12\x06George\x1A\bCostanza

# Person 2
\b\x02\x12\x06Elaine\x1A\x05Benes

# Both
\n\x14\b\x01\x12\x06George\x1A\bCostanza\n\x11\b\x02\x12\x06Elaine\x1A\x05Benes
```

#### XML

XML (Extensible Markup Language) is a human-readable, text-based format. Like JSON, XML defines both the structure and the data in the same message body. It is widely used to exchange data over the Internet.

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

## Shared Database

## References

* https://developers.google.com/protocol-buffers

## Wrap-up

In this chapter, we discussed various protocols and message formats that can be used to share data between services. In the next chapter, we'll cover the Ruby language and the Ruby on Rails framework.

[Next >>](040-chapter-03.md)
