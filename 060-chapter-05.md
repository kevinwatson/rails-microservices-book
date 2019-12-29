### Chapter 5 - Active Remote

> ...Senator Amidala, the former Queen of Naboo, is returning to the Galactic Senate to vote on the critical issue of creating an ARMY OF THE REPUBLIC to assist the overwhelmed Jedi....
> - Star Wars Episode II: Attack of the Clones Opening crawl

## Introduction

Active Remote is a Ruby library that acts as a model, but communicates over the network via a message bus with another model. If you're using Rails, it appears as a local model but the Active Record model exists in another location on your network.

## Philosophy

The reason for creating a gem that allows models to communicate is that it follows the MVC pattern. Most Rails applications are a wrapper around a database, but as your business needs drive you to scale out your application and its logic, your ability to provide a common interface between Rails applications gives you the advantage for each service that needs to consume or share data with the rest of your larger system.

## Design

During application start, Active Record models read the database schema and generate all of the getters, setters and methods which reduces the amount of biolerplate code that needs to be added to your models which inherit from ActiveRecord::Base. Because Active Remote doesn't have direct access to the database, on the client side, you'll need to declare the model's attributes. On the server side, where you want to share data, you'll need to create a Service class for each model that will define how the data will be shared.

## Wrap-up

Active Remote provides a communication platform that follows established architectural patterns such as MVC, but still build a platform that can scale.

By using a message bus to communicate between services, Active Remote also gives your services resiliency. As long as the message bus service remains online, your Rails apps can send a message to another service, and eventually get a reply when the other service comes back online.
