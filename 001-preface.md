## Preface

Welcome to *Building Distributed Rails Applications.*

Ruby on Rails is a framework built on the Ruby programming language. The Rails framework provides you with the tools you need to easily build a database-backed application. Rails has achieved widespread popularity - many popular websites run on Rails, including Shopify, Basecamp, and GitHub.

Distributed application architecture defines separate, specialized modules or components of a system which, as a whole, provide the functionality that your users require. Distributed applications can be configured to scale up and down as needed, specifically for modules that require extra computing power. For example, the module that renders the login form may not require much compute power, but the module that optimizes your customer's uploaded photos may need to scale out each time a user uploads a fresh batch of files.

This book will walk you through building distributed applications in Ruby on Rails. We will discuss monolithic applications, breaking those applications into smaller units (microservices), and describe ways to share data between these services. We'll use a handful of Ruby gems, generously open sourced by the people at [MX](https://mx.com). MX is a financial services company based in Utah. The people at MX have built a distributed, heterogeneous platform from the ground up that processes and analyzes billions of financial transactions every month.

MX's generous contributions to Protobuf, RabbitMQ and NATS open standards includes (but is not limited to) the following gems: `active_remote`, `protobuf-nats`, `action_subscriber`, `active_publisher` and `protobuf-activerecord`. We'll discuss each gem in detail in this book.

Ruby continues to evolve and grow in popularity. MX's open source contributions help ensure that Ruby continues to be a viable choice when designing and deploying modern distributed systems.

Because MX's platform is built on top of open standards (e.g. Protobuf, RabbitMQ and NATS), new services can be spun up in any programming language. As long as a service can understand Protobuf messages and connect to NATS and RabbitMQ, it can respond to messages from any application written in any supported language.

Even if your go-to language isn't Ruby, hopefully this book will give you an overview of how to design and build distributed services.

[Next >>](002-who-is-this-book-for.md)
