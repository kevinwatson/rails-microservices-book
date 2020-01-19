### Chapter 10 - Event Driven Messaging

## Introduction

Up to this point we have built a platform that communicates between services in a synchronous manner. A messaging system sits between the apps, but the apps are issuing requests and expecting immediate responses. This pattern works great for retrieving and modifying data. What if you want your services to be notified when something happens in another service? Enter the event driven architecture.

An event driven messaging architecture can be demonstrated by the following example: Imagine you have two services, one is an human resources system and another is a payroll system. In a synchronous system, a new employee record could be created in the human resources record, and then in a synchronous workflow (a Active Model callback, a call from a service object, etc) a call could then be made to pass some info to the payroll system to create a new employee payroll record. One advantage of building software this way is that the process is synchronous, and errors can be reported immediately to the user. A disadvantage is that these two services are tightly coupled. If the payroll service was offline for some reason, the human resource service would appear to be having issues, and the user may perceive that the entire system is having issues and may report incorrect info when reporting the issue.

There are a number of advantages to building an event driven architecture. One is that the services can be loosely coupled. If the services were built on an event driven architecture and the human resource system was online, the user could add new employees and the payroll (and other services watching for the same employee created events) would perform their processing in the background. The perceived user experience would be better because the user is interacting with a small service that performs few tasks - because it has less responsibility, we might expect it to be a more responsive application. What is happening in the background is not the user's concern nor are they required to wait for all of the other services to complete processing before control is returned to the user.

Another advantage to asynchronous processing on an event driven platform is that additional services can be added to watch for the same events, such as the employee created event mentioned above. For example, if it is later decided that all new employees should receive a weekly dining gift card, a new service could be added to the platform that watches for the employee created event. Adding this new service to watch for an existing event would require zero downtime for the rest of the services.

## Implementation

The software that provides event driven messaging is sometimes called a message broker. Some of the most popular brokers include, but are not limited to: Apache Kafka, RabbitMQ and Amazon Simple Queue Service (Amazon SQS).

The gems we'll use to implement our event driven architecture in the next couple of chapters are designed around RabbitMQ, so from here we'll focus on the features provided by the RabbitMQ message broker.

## Wrap-up

Event driven messaging architectures provide numerous advantages. Some of these advantages are loose-coupling of services, zero downtime when adding new services and in some cases a better user experience.

Earlier, we implemented the NATS service to route messages between our services. In the next chapter, we'll spin up a RabbitMQ service, subscribe to and publish events to see how an .
