### Chapter 8 - Protocol Buffers (Protobuf)

> Humans had developed a sequential mode of awareness, while heptapods had developed a simultaneous mode of awareness. We experienced events in an order, and perceived their relationship as cause and effect. They experienced all events at once, and perceived a purpose underlying them all. A minimizing, maximizing purpose. - Ted Chiang, Stories of Your Life and Others

## Introduction

Why did you build your app? Most likely the reason was that you needed to track some data. You or someone at your company may have started with a spreadsheet, but over time, realized that tracking the data in a spreadsheet became cumbersome and no longer met your needs. So, an app was born. Your fresh out-of-the-box app then started to grow, with relationships between data entities. As the amount of data and the number of relationships and the processing requirements grew, you decided that you needed to split your app into separate services. When a piece of data needs to be shared between applications, we need to make a couple of decisions. What attributes will be shared? How will clients access the data? Which app will own and persist the data? How can we make it easy to extend or add new attributes to our entities that are still backwards compatible?

When you build a microservice platform, you need to make several decisions, one of them being how do we share data between services. As discussed in chapter 2, protocol buffers (aka protobuf) is one of those options. 

Developed by Google, protobuf is a method of serializing data in a binary format that allows for performance over flexibility. Protobuf has a standard definition structure that is used to define messages. Compilers are available to convert the definitions to classes or structures that are language specific. For example, the same definition file can be used to generate classes or structures for both Java and Ruby, so that apps written in both languages can share the same message.

## Philosophy

Protobuf serializes data to a binary format that is not self-describing. In contrast, a JSON or XML object is usually human readable and human editable, and each object can be inspected and the developer can view the field names and their values. Protobuf is a binary format. It implements an ordered field format and both of the services sharing the message need to know the structure of the message.

There are many ways to encode and share data. XML, JSON and other formats are well-defined and easy to generate and consume. But what if you want better encoding and decoding performance? What if you want to reduce the network load of messages being passed between systems? What if your platform, the number of developers, and the number of messages passed between systems grows overnight?

Protobuf attempts to solve these and other problems by encoding data to a binary format (which of course is much smaller than a XML or JSON encoded object). Protobuf definitions consist of one or more uniquely numbered fields. Each encoded field is assigned a field number and a value. This field number is what differentiates Protobuf from other objects. The field number is used to encode and decode the message attributes, reduces the amount of data that needs to be encoded by leaving out the attribute name, and allows for extendability so developers can add fields to a definition without having to upgrade all of the apps that consume that message at the same time. This is possible because existing apps will ignore new fields on any messages they receive and decode.

## Implementation

An example Protobuf definition is below. Protobuf files have the file extension `.proto`.

**Listing 8-1** Employee protobuf message

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

Let's inspect each line.

Line 1 defines the version of the Protobuf syntax we'd like to use.

Line 3 is the beginning of our message declaration.

Lines 4-6 are the field definitions. Each line has a type (the guid field is a string type). Line 5 has an attribute name of `guid`, and the field number of 1.

This Protobuf definition is by itself not used in your application. What we do next is compile this `employee.proto` field to a class or structure file in the same language your app is written in, whether that's Java, C#, Go or Ruby. If you support a heterogeneous platform with multiple languages, you may want to build scripts which will automatically compile your `.proto` files to the required languages each time you add a new `.proto` file or add a new field to one of your existing definitions.

We briefly covered the [Ruby implementation in chapter 2](https://github.com/kevinwatson/rails-microservices-book/blob/master/030-chapter-02.md#protocol-buffers), but let's review and go into more detail here.

The example below is the output for the Ruby implementation (additional setup and details can be found in [chapter 9](https://github.com/kevinwatson/rails-microservices-book/blob/master/100-chapter-09.md)). After defining the `.proto` definition file and running the `rake protobuf:compile` command, we will now have files similar to the following:

**Listing 8-2** Employee Ruby protobuf class

```ruby
# file employee.pb.rb
class Employee < ::Protobuf::Message
  optional :string, :guid, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end
```

**Serialized Data**

Note that the data below is a string representation of the binary encoding.

**Listing 8-3** Employee protobuf encoding

```console
# Employee
\n$d4b3c75c-2b0c-4f74-87d7-651c5ac284aa\x12\x06George\x1A\bCostanza
```

There are a couple of things to note in this string. The first is that no space is wasted in defining the field names. The numbers at the end of the line in both the `.proto` and `.rb` files indicates the field index. When the data in the protobuf message is serialized, the data is packed in a sequential order without the field names. A delimiter is used to separate the fields, which will always be in the same order. Occasionally, we may need to deprecate or remove a field. Because the fields are indexed, the index of the field that needs to be removed will always take that slot and we should never reuse that index number. If we were to reuse the index number, services which are still using the old definition would misinterpret the data in that position and things can go south especially when the data type is modified but the field index is reused (e.g. if the data type changes from an int32 to a bool).

It's up to the receiver to know the indexes and their related field names when deserializing the message. This has the advantage of requiring less network bandwidth to deliver the message when compared to other message envelopes such as JSON or XML. Another advantage is that when the protobuf message is deserialized, extra fields that are not defined in the protobuf class are ignored. This makes the platform maintainable, because the senders and receivers can be updated and deployed independently.

For example, a sender can have a newer `::Protobuf::Message` class which adds new fields to a protobuf message. When this message is received by another service, the new fields will be ignored by any receivers that are using an older version of the `::Protobuf::Message` class. A receiver can also be modified independently to expect a new field but if it's not defined in the sender's proto message, the field is marked as `nil` (or the language's equivalent zero or `nil` value). In these examples there is a chance that data in the new fields will be lost, so you may want to update the receivers before updating the senders. This design allows you to update the services independently without the risk of breaking the receiving apps because they aren't ready to receive the newly defined fields.

## Resources

* https://developers.google.com/protocol-buffers
* https://github.com/ruby-protobuf/protobuf/wiki/Compiling-Definitions

## Wrap-up

Protobufs are an efficient way to package and share data between services. They are language agnostic and extendable. Because they are language agnostic, you are not constrainted to building services in a single programming language on your platform. For example, you can write your internal line-of-business applications in Rails while writing your data-crunching algorithms in R.

In the next chapter, we'll spin up a development sandbox with NATS and Rails. We'll create two Rails applications, one that owns a database and shares the data via Protobuf and Active Remote and another that acts as a client that can retrieve and modify the data in the first app.

[Next >>](100-chapter-09.md)
