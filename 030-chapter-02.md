### Chapter 2 - Service Communications

## Introduction

As your service infrastructure grows, you'll need to find a communication protocol that is a good balance of development, maintenance, speed and resilency. Protocols include those in the table below:

| Protocol | Advantages | Disadvantages |
|---|---|---|
| tcp | |
| http | Runs on top of TCP |

The format of the message that is sent is also important. Here are some options:

| Format | Text/Binary | Advantages | Disadvantages | Protocol |
|---|---|---|---|---|
| JSON | text | structured, human readable | | http/tcp |
| XML | text | structured, human readable | opening and closing tags which increase the message size | http/tcp |
| Protobuf | binary? | | |
| ??? | text | | |


## JSON
   1. XML
   1. Message Bus
   1. Shared Database
   1. Wrap-up