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
| html | text | semi-structured, human readable | data is represented in a loosley-structured format, intended for human, not machine consumption with comments |
| json | text | structured, human readable | |
| protocol buffers (protobuf) | binary | small footprint | both client and server need to know the structure of the encoded message |
| xml | text | structured, human readable | opening and closing tags which increase the message size |

### Examples

Here are a few examples of each format.

#### HTML and XHTML

In most situations, your first choice is probably wouldn't be to use HTML to encode and deliver data. HTML's primary use is to render data in a web browser. Because HTML is loosely structured - the producer can make up tags and forget to close tags - and over the years web browsers have been designed to work around these issues while still displaying some or all of the data to the user, XHTML was introduced. XHTML is a variant of HTML, but it must conform to the stricter XML standards. Web browsers can render both HTML and XHTML.

Even though HTML and XHTML are not usually thought of as a data exchange format, they are one of the primary ways that data is delivered over the world wide web. Humans are one consumer of HTML data (if you're reading this book in a web browser, you're consuming HTML or maybe even XHTML right now). Screen scraping is a technique of automating the retrieval of data from HTML and XHTML data. If other choices such as JSON or XML are available, a developer should choose those methods over scraping and parsing HTML.

Valid HTML

```html
<html>
  <body>
    <table>
      <th>
        <th>Id</th>
        <th>First Name</th>
        <th>Last Name</th>
      </th>
      <tr>
        <td>1</td>
        <td>George</td>
        <td>Costanza</td>
      </tr>
      <tr>
        <td>2</td>
        <td>Elaine</td>
        <td>Benes</td>
      </tr>
    </table>
  </body>
</html>
```

Valid XHTML

```xhtml
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE html 
PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <body>
    <table>
      <th>
        <th>Id</th>
        <th>First Name</th>
        <th>Last Name</th>
      </th>
      <tr>
        <td>1</td>
        <td>George</td>
        <td>Costanza</td>
      </tr>
      <tr>
        <td>2</td>
        <td>Elaine</td>
        <td>Benes</td>
      </tr>
    </table>
  </body>
</html>
```

#### JSON
#### Protocol Buffers
#### XML

## Messaging Systems

## Shared Database

## Wrap-up

In this chapter, we discussed various protocols and message formats that can be used to share data between services. In the next chapter, we'll cover the Ruby language and the Ruby on Rails framework.

[Next >>](040-chapter-03.md)
