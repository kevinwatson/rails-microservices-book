## What's in This Book?

This book has several sections. We'll discuss several architectural patterns for building distributed or not-so-distributed systems. We'll discuss various methods of moving data between applications. 

We'll discuss the Ruby on Rails framework, and the building blocks that provide access to the data your application will process. We'll discuss messaging platforms. We'll discuss modeling data entities and their relationships in a distributed environment.

We'll walk through all of the steps required to spin up a new environment that consists of a NATS server and two Ruby on Rails applications, one having a model backed by a database and the other having a model that remotely accesses the data from the first application.

We'll discuss event-driven messaging and when it is appropriate. We'll build two applications that communicate via RabbitMQ.

Finally, we'll build a platform that uses both synchronous and event-driven architectural patterns to share data between services.

[Next >>](004-what-you-need.md)
