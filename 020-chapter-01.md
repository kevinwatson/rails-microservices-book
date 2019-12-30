### Chapter 1

> I need you to be clever, Bean. I need you to think of solutions to problems we haven't seen yet. I want you to try things that no one has ever tried because they're absolutely stupid. - Orson Scott Card, Ender's Game

## Monoliths vs microservices vs function as a service

First, a few definitions:

* **Monolith:** A single application that provides all or a large portion of the functionality your company requires.
* **API:** Application programming interface - in the context of this book, an application that provides access to its data. An API provides application-to-application communication.
* **Services:** A service, loosely defined, is a stand-alone application that provides some piece of functionality. Examples include a website, an API, a database, etc.
* **Microservices:** An application that provides specific functionality and data.

When you're first designing a service, the requirements usually start out small. As time goes on, you and your team add features and the application grows organically into a larger system. We call this a monolith. There is nothing wrong with monoliths, as long as they can handle the processing load. Monoliths are the simplest architecture because they are easy to maintain by small teams, all of the code is in one place, and communication between modules is instantaneous (no network overhead).

## What is a microservice?

A microservice is a small app that provides a limited set of functionality. In the UNIX philosophy (as documented by Doug McIlroy), one tenet is to make each program do one thing and do it well. In terms of a microservice architecture, your goal is to build small programs or services that provide a specific set of features. As this feature set becomes more wide used in your organization, you can scale up and out that particular feature to keep up with the needs of the business.

## Why should I design microservices?

By nature, building a microservices architecture incurs additional overhead that may not be worth the time in the early stages of a project. Once the app becomes popular and you can identify bottlenecks in the process, then it's time to identify and carve out specific functionality that should be scaled out.

## Wrap-up

[Next >>](030-chapter-02.md)
