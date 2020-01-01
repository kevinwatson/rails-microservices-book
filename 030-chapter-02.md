### Chapter 2 - Service Communications

## Introduction

As your service infrastructure grows, you'll need to find a communication protocol that is a good balance of development, maintenance, speed and resilency. While there are a wide number of protocols available, our discussion will only include those in the table below:

| Protocol | Advantages | Disadvantages | Example uses |
|---|---|---|---|
| tcp | one of the main protocols on the Internet, used for establishing the connection between server and client | guarantees that the data was delivered to the client, provides error checking and resends lost packets | ssh, world wide web, email |
| http | runs on top of TCP | | world wide web, email |
| nats | text-based, so clients are available for a wide variety of programming languages | only used to connect to a NATS server | publishing to or listening on queues on a NATS server |
| udp | its connection-less design is for speed and efficiency | Does not provide error checking or any guarantees that the client received the data | video streaming, dns |

The data that is sent over the wire needs to be encoded. A few ways to encode this data are in the table below:

| Format | Text/Binary | Advantages | Disadvantages |
|---|---|---|---|
| html | text | semi-structured, human readable | data could be received in a loosley-structured format, intended for human, not machine consumption |
| json | text | structured, human readable | |
| protocol buffers (protobuf) | binary | small footprint | both client and server need to know the structure of the encoded message |
| xml | text | structured, human readable | opening and closing tags which increase the message size |


## JSON
## XML
## Message Bus
## Shared Database
## Wrap-up

[Next >>](040-chapter-03.md)
