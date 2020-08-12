### Chapter 5 - Active Remote

> ...Senator Amidala, the former Queen of Naboo, is returning to the Galactic Senate to vote on the critical issue of creating an ARMY OF THE REPUBLIC to assist the overwhelmed Jedi.... - Star Wars: Episode II: Attack of the Clones opening crawl

## Introduction

Active Remote is a Ruby gem that can replace Active Record models in your application to provide access to other models that exist in other applications on your network. Similar in philosophy to Active Resource, Active Remote provides data access for remote resources.

The difference is that while Active Resource provides access to RESTful resources, Active Remote provides access using more durable and efficient methods (e.g. using a message bus for durability, and Protobuf for efficient data serialization and deserialization).

## Philosophy

Active Remote attempts to provide a solution to accessing and managing distributed resources by providing a model which can be implemented with a minimal amount of code. Whether the model's data is persisted locally or somewhere else is of no concern to the rest of the application.

Further, because Active Remote implements a pub-sub messaging system, clients do not need to be configured with details about which servers own and respond to specific resources. Clients only need to know which message system subjects to publish to and that some other server will respond to their requests.

## Design

During application initialization, Active Record models read the database schema and generate all of the getters, setters and methods which reduces the amount of boilerplate code that needs to be added to your models which inherit from ActiveRecord::Base. Because Active Remote doesn't have direct access to the database, on the client side, you'll need to declare the Active Remote model's attributes using the `attribute` method. On the server side, where you want to share the Active Record data, you'll need to create a Service class for each model that will define endpoints to allow for searching, creating, updating, deleting, etc.

## Implementation

Active Remote is packaged as a Ruby gem. The Active Remote gem provides a DSL (domain-specific language), handles primary key guid fields, handles serialization, among a number of other features. The Active Remote gem depends on the Protobuf gem, so that gem will get installed automatically when you install or include the Active Remote gem.

To share data between services, you'll need to include the Protobuf NATS gem. For the client Rails app, the Active Remote and Protobuf NATS are the two gems you'll need to include with your application. In the server Rails app, you'll want to include the Active Remote, Protobuf NATS and the Protobuf Active Record gems. The Protobuf Active Record gem glues together Protobuf and Active Record, providing features such as linking your Protobuf messages to your Active Remote classes.

## Resources

* https://github.com/abrandoned/protobuf-nats
* https://github.com/liveh2o/active_remote
* https://github.com/liveh2o/protobuf-activerecord
* https://github.com/rails/activeresource
* https://github.com/ruby-protobuf/protobuf

## Wrap-up

Active Remote allows you to build a durable and efficient communication platform between microservices. It also allows you to follow established architectural patterns such as MVC.

Because Active Remote implements a message bus to communicate between services, it gives your services durability. As long as the message bus service remains online, your Rails apps can send a message to another service, and eventually get a reply when the other service comes back online.

Active Remote also implements Protobuf, an efficient serialization and deserialization. As your platform grows, minimizing the amount of data traveling over the wire will pay dividends as you continue to scale your platform.

In the next chapter, we'll discuss messaging queues. We'll spin up a NATS server and send and receive simple messages via the telnet protocol.

[Next >>](070-chapter-06.md)
