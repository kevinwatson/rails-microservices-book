### Chapter 8 - Protocol Buffers (Protobuf)

## Introduction

Why did you build your app? Most likely the reason was that you needed to track some data. You or someone at your company may have started with a spreadsheet, but over time, realized that tracking the data in a spreadsheet became cumbersome and no longer met your needs. So, an app was born. Your fresh out-of-the-box app then started to grow, with relationships between data entities. As the amount of data and the number of relationships and the processing requirements grew, you decided that you needed to split your app into separate services. When a piece of data needs to be shared between applications, we need to make a couple of decisions. What attributes will be shared? How will clients access the data? Which app will own and persist the data? How can we make it easy to extend or add new attributes to our entities that are still backwards compatible?

When you build a microservice platform, you need to make several decisions, one of them being how do we share data between services. As discussed in chapter 2, protocol buffers (aka protobuf) is one of those options. 

Developed by Google, protobuf is a method of serializing data in a binary format that allows for performance over flexibility. Protobuf has a standard definition structure that is used to define messages. Compilers are available to convert the definitions to classes or structures that are language specific. For example, the same definition file can be used to generate classes or structures for both Java and Ruby, so that apps written in both languages can share the same message.

## Philosophy

Protobuf serializes data to a binary format that is not self-describing. In contrast, a JSON or XML object is usually human readable and human editable, and each object can be inspected and the developer can view the field names and their values. Protobuf is a binary format, implements an ordered field format and both of the services sharing the message need to know the structure of the message.

There are many ways to encode and share data. XML, JSON and other formats are well-defined and easy to generate and consume. But what if you want better encoding and decoding performance? What if you want to reduce the network load of messages being passed between systems? What if your platform, the number of developers, and the number of messages passed between systems grows overnight?

Protobuf attempts to solve these and other problems by encoding data to a binary format (which of course is much smaller than a XML or JSON encoded object). Protobuf definitions consist of one or more uniquely numbered fields. Each encoded field is assigned a field number and a value. This field number is what differentiates Protobuf from other objects. The field number is used to encode and decode the message attributes, reduces the amount of data that needs to be encoded by leaving out the attribute name, and allows for extendability so developers can add fields to a definition without having to upgrade all of the apps that consume that message at the same time. This is possible because existing apps will ignore new fields on any messages the receive and decode.

## Usage

An example Protobuf definition is below. Protobuf files have the file extension `.proto`.

```proto
1 # file employee.proto
2 syntax = "proto3";
3 
4 message Employee {
5   string guid = 1;
6   string first_name = 2;
7   string last_name = 3;
8 }
```

Let's inspect each line.

Line 2 defines the version of the Protobuf syntax we'd like to use.

Line 3 is the beginning of our message declaration.

Lines 4-7 are the field definitions. Each line has a type (the guid field is a string type). Line 5 has an attribute name of `guid`, and the field number of 1.

This Protobuf definition is by itself not used in your application. What we do next is compile this `employee.proto` field to a class or structure file in the same language your app is written in, whether that's Java, C#, Go or Ruby. If you support a heterogeneous platform with multiple languages, you may want to build scripts which will automatically compile your `.proto` files to the required languages each time you add a new `.proto` file or add a new field to one of the definitions.

## Wrap-up

Protocol Buffers are a way to package and share data between our services. They are language agnostic and extendable.

## References

https://developers.google.com/protocol-buffers
https://github.com/ruby-protobuf/protobuf/wiki/Compiling-Definitions
