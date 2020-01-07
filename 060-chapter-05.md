### Chapter 5 - Active Remote

> ...Senator Amidala, the former Queen of Naboo, is returning to the Galactic Senate to vote on the critical issue of creating an ARMY OF THE REPUBLIC to assist the overwhelmed Jedi.... - Star Wars: Episode II: Attack of the Clones opening crawl

## Introduction

Active Remote is a Ruby gem that can replace Active Record models in your application to provide access to other models that exist in other applications on your network. Similar in philosophy to Active Resource (https://github.com/rails/activeresource), Active Remote provides data access for remote resources.

The difference is that while Active Resource provides access to RESTful resources, Active Remote provides access using more durable and efficient methods (e.g. using a message bus for durability, and Protobuf for efficient data serialization and deserialization).

## Philosophy

Active Remote attempts to provide a solution to accessing and managing distributed resources by providing a model which can be implemented with a minimal amount of code. Whether the model's data is persisted locally or somewhere else is of no concern to the rest of the application.

Further, because Active Remote implements a pub-sub messaging system, clients do not need to be configured with details about which servers own and respond to specific resources. Clients only need to know which message system subjects to publish to and that some other server will respond to their requests.

## Design

During application initialization, Active Record models read the database schema and generate all of the getters, setters and methods which reduces the amount of biolerplate code that needs to be added to your models which inherit from ActiveRecord::Base. Because Active Remote doesn't have direct access to the database, on the client side, you'll need to declare the Active Remote model's attributes using the `attribute` method. On the server side, where you want to share the Active Record data, you'll need to create a Service class for each model that will define endpoints to allow for searching, creating, updating, deleting, etc.

## Wrap-up

Active Remote allows you to build a durable and efficient communication platform between microservices. It also allows you to follow established architectural patterns such as MVC.

Because Active Remote implements a message bus to communicate between services, it gives your services durability. As long as the message bus service remains online, your Rails apps can send a message to another service, and eventually get a reply when the other service comes back online.

Active Remote also implements Protobuf, an efficient serialization and deserialization. As your platform grows, minimizing the amount of data traveling over the wire will pay dividends as you continue to scale your platform.

[Next >>](070-chapter-06.md)
