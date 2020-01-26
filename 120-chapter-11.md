### Chapter 11 - Messaging Systems - Rabbit MQ

## Introduction

RabbitMQ is one of many implementations of message brokers. It provides many features, such as message queuing, support for multiple messaging protocols and delivery acknowledgement. We'll discuss some of these features in this chapter.

We're going to run RabbitMQ the same way we ran NATS in chapter 6. Docker makes it easy. We'll follow most of the same steps but with a slightly different docker-compose.yml file.

## Let's Run It

Let's run a local RabbitMQ server and send messages to it. We'll include a Ruby image so we can build a Ruby client to send messages to and receive messages from queues on the RabbitMQ server. With NATS we used telnet to send and receive simple test-based messages - with RabbitMQ we'll need to construct binary messages that we'll send to RabbitMQ.

Listing 11-1 Docker compose with RabbitMQ and Ruby

```yml
$ cat ~/projects/rabbitmq/docker-compose.yml
# usage: docker-compose up

version: "3.4"

services:
  rabbit:
    image: rabbitmq:latest
    ports:
      - 5672:5672
    stdin_open: true
  ruby:
    image: ruby:2.6.5
    stdin_open: true
```

Save the file with the filename `docker-compose.yml`. Let's now switch to that directory and run the containers. The versions of the software and output may differ from what you see in your terminal.

Listing 11-2 Start RabbitMQ and Ruby

```console
$ cd ~/projects/nats
$ docker-compose up
Starting rabbitmq_ruby_1 ... done
Creating rabbitmq_rabbit_1  ... done
Attaching to rabbitmq_ruby_1, rabbitmq_rabbit_1
ruby_1    | Switch to inspect mode.
rabbit_1   |  Starting RabbitMQ 3.8.2 on Erlang 22.2.3
...
rabbit_1   |   ##  ##      RabbitMQ 3.8.2
rabbit_1   |   ##  ##
rabbit_1   |   ##########  Copyright (c) 2007-2019 Pivotal Software, Inc.
rabbit_1   |   ######  ##
rabbit_1   |   ##########  Licensed under the MPL 1.1. Website: https://rabbitmq.com
...
rabbit_1   |   Starting broker...2020-01-25 14:18:45.535 [info] <0.267.0>
...
rabbit_1   | 2020-01-25 14:18:46.099 [info] <0.8.0> Server startup complete; 0 plugins started.
```

Creating a producer is simple. We'll connect to the Ruby container and run IRB to create a connection, a channel and a queue. Let's create a message in a new terminal window.

Listing 11-3 Creating a message

```console
$ docker-compose exec ruby bash
/# gem install bunny # install the bunny gem
...
/# irb
irb(main):001:0> require 'bunny'
irb(main):002:0> connection = Bunny.new(hostname: 'rabbit') # the 'rabbit' hostname was defined as the service name in the docker-compose.yml file
irb(main):003:0> connection.start
irb(main):004:0> channel = connection.create_channel # create a new channel
irb(main):005:0> queue = channel.queue('hello') # create a queue
irb(main):006:0> channel.default_exchange.publish('Hello World', routing_key: queue.name) # encode a string to a byte array and publish the message to the 'hello' queue
```

Creating a consumer is just about as simple as creating a producer. We'll create a connection, a channel, and a queue. The new queue command will subscribe to queues with the same name, or if it doesn't exist, create a new queue.

Let's open another terminal window and run the commands in listing 11-4.

Listing 11-4 Consuming messages

```console
$ docker-compose exec ruby bash
/# irb
irb(main):001:0> require 'bunny'
irb(main):002:0> connection = Bunny.new(hostname: 'rabbit') # the 'rabbit' hostname was defined as the service name in the docker-compose.yml file
irb(main):003:0> connection.start
irb(main):004:0> channel = connection.create_channel # create a new channel
irb(main):005:0> queue = channel.queue('hello') # create a queue (or connect to an existing queue if it already exists)
irb(main):006:0> queue.subscribe(block: true) do |_delivery_info, _properties, body|
irb(main):007:1*     puts "- Received #{body}"
irb(main):008:0> end
- Received Hello World
```

You should see the `- Received Hello World` message in the terminal window where we consumed the message (Listing 11-4). This demonstrates that we have RabbitMQ server running, we published a message to a queue, and our consumer received the message. Let's switch back to the IRB session we started in listing 11-3 and publish another message.

Listing 11-5 Publish a second message

```console
irb(main):007:0> channel.default_exchange.publish('We thought you were a toad!', routing_key: queue.name) # encode and publish another message
irb(main):008:0> connection.close # the message has been sent, so let's close the connection
```

If you switch back to the terminal in Listing 11-4 where we created a consumer, we should see both the '- Received Hello World' and the '- Received We thought you were a toad!' messages. Congratulations! You've successfully started a RabbitMQ server and a couple of Ruby clients to publish and consume messages.

When you're done, you can press `Ctrl-C` to exit the RabbitMQ consumer terminal, and then `Ctrl-D` or type `exit` to return to the host machine's command prompt.

## Resources

* https://www.rabbitmq.com/tutorials

## Wrap-up

Event-driven messaging systems are a layer in a system architecture that allows you to build a platform that is asynchronous, reliable, decoupled and scalable. Along with NATS, RabbitMQ is one such messaging system that is simple to configure and use.

In this chapter, we successfully spun up a local RabbitMQ server, created a queue, then published and consumed to messages on that queue.

In the next chapter, we'll discuss a couple of Ruby gems that make it easy to configure and set up our RabbitMQ clients.

[Next >>](130-chapter-12.md)
