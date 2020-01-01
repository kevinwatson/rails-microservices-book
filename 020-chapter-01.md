### Chapter 1

> I need you to be clever, Bean. I need you to think of solutions to problems we haven't seen yet. I want you to try things that no one has ever tried because they're absolutely stupid. - Orson Scott Card, Ender's Game

## Monoliths vs microservices vs serverless

First, a few definitions:

* **API:** Application programming interface - in the context of this book, an application that provides access to its data. An API provides application-to-application communication.
* **Function as a service (FaaS):** A small unit of code that can be published and consumed without also building and maintaining the surrounding infrastructure. Considered one way to build a "serverless" architecture.
* **Microservice:** An application that provides specific functionality and data.
* **Monolith:** A single application that provides all or a large portion of the functionality your company requires.
* **Serverless computing:** The cloud provider provisions and can dynamically manage the server resources as needed. Small units of code, such as function as a service are deployed to a serverless environment.
* **Services:** A service, loosely defined, is a stand-alone application that provides some piece of functionality. Examples include a website, an API, a database server, etc.

When you're first designing a service, the requirements usually start out small. As time goes on, you and your team add features and the application grows organically into a larger system. We call this a monolith. There is nothing wrong with monoliths, as long as they can handle the processing load. Monoliths are the simplest architecture because they are easy to maintain by small teams, all of the code is in one place, and communication between modules is instantaneous (no network overhead).

## Tell me more about microservices

A microservice is a small app that provides a limited set of functionality. In the UNIX philosophy (as documented by Doug McIlroy), one tenet is to make each program do one thing and do it well. In terms of a microservice architecture, your goal is to build small programs or services that provide a specific set of features. As this feature set becomes more wide used in your organization, you can scale up and out that particular feature to keep up with the needs of the business.

## Why should I use microservices?

By nature, building a microservices architecture incurs additional overhead that may not be worth the time in the early stages of a project. Once the app becomes popular and you can identify bottlenecks in the process, then it may be time to identify and carve out specific functionality into its own service.

As your development team grows, you may want to split the code base into smaller units that can be maintained and deployed separately. This can have other benefits, such as shorter development and release cycles, faster turn around times for your Quality Assurance (QA) teams because less time will need to be spent regression testing a small codebase vs a large codebase.

If you have different uptime requirements for functionality of your application, your codebase may be a candidate for breaking it up into smaller microservices. This will allow you to meet your service level requirements on a service by service basis. The added benefit is that the services can be designed so that if a less critical piece of the platform goes down, the rest of the platform remains unaffected.

## Wrap-up

There are many ways to provide the logic that meets your business requirements. Most business applications start small, but grow to meet the needs of your business. Most of the time, business applications grow into a large, monolithic app. While there are many reasons to keep the monolith, as your business and team grow, you may want to split your codebase into smaller, easier to maintain units.

[Next >>](030-chapter-02.md)
