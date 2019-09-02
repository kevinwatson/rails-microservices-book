## Preface

Welcome to *Building Distributed Rails Applications.*

Ruby on Rails is a framework built upon the Ruby programming language. The Rails framework provides you with the tools you need to easily build a database-backed application. Rails has achieved widespread popularity - many popular websites run on Rails, including Shopify, Basecamp, and Github.

Distributed application architecture defines separate, specialized modules or components of a system which, as a whole, provides the functionality that your users require. Distributed applications can be configured to scale up and down as needed, specifically for modules that require extra computing power. For example, the module that renders the login form may not require much compute power, but the module that optimizes your customer's uploaded  photos may need to scale out each time a user uploads a fresh batch of files.

This book will walk you through building distributed applications in Ruby on Rails. We will discuss monolithic applications, breaking those applications into smaller units (microservices), and ways to share data between those services.

Even if your primary framework isn't Rails, hopefully this book will at least give you an overview of what is possible with this language.

Chap 1?: As your application becomes popular, you and your team add features, and eventually end up with a large monolithic application. Large applications become difficult to maintain, test, and deploy. Microservice architecture is one solution which provides patterns for breaking your monilithic application down into smaller maintainable, testable, and deployable units of functionality.

I write for developers who use Ruby on Rails to build applications for themselves, for their employer, or as a proof of concept way to quickly standing up an application. 