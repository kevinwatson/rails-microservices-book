### Chapter 13 - Active Remote with Events Sandbox

## Introduction

So far we've built two Rails services that can communicate with each other via Active Remote and NATS. We've also built two different Rails services that communicate with each via Active Publisher and Action Subscriber and RabbitMQ. As your business requirements grow, you may find the need to use both in your environment - Active Remote for real-time communications between services and Active Subscriber for event-driven messaging.

Lucky for us, we've already laid the groundwork for this type of platform. We've built Docker Compose files for each environment. In this chapter, we're going to spin up a new sandbox environment that uses both NATS and RabbitMQ to communicate and publish fire-and-forget messages.

![alt text](images/synchronous-and-event-driven-platform.png "Publishing an employee created message via Active Remote and Active Publisher")

_**Figure 13-1**_ Creating an employee and notifying all interested parties

## What We'll Need

* NATS
* RabbitMQ
* Ruby
* Ruby gems
  * Active Publisher
  * Active Remote
  * Action Subscriber
  * Protobuf
  * Rails
* SQLite

## Implementation

## Resources

* https://github.com/kevinwatson/rails-microservices-sample-code

## Wrap-up
