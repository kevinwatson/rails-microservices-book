### Chapter 6 - Messaging Systems

## Overview

Messaging communication systems are used as a critical component when designing distributed systems. NATS is one such messaging platform which provides security, resiliency, is scalable and can meet the performance requirements of most systems. As of the time of this writing, it has clients written in over 30 programming languages.

1. Nats Server
1. Rabbit MQ ??
1. Setup
1. Testing
1. Monitoring
1. Wrap-up

Let's use Docker to run a local NATS server and write messages to it. We'll include a BusyBox image so we can run telnet commands to test NATS.

Listing 6-1 Docker compose with NATS and BusyBox

```bash
$ cat ~/projects/nats/docker-compose.yml
# usage: docker-compose up

version: "3.4"

services:
  nats:
    image: nats:latest
    ports:
      - 4222:4222
      - 6222:6222
      - 8222:8222
    stdin_open: true
  busybox:
    image: busybox:latest
    stdin_open: true
```

Save the file with the filename `docker-compose.yml`. Let's now switch to that directory and run the containers. The versions of the software and output may differ from what you see in your terminal.

```bash
$ cd ~/projects/nats
$ docker-compose up
Starting nats_nats_1    ... done
Starting nats_busybox_1 ... done
Attaching to nats_busybox_1, nats_nats_1
nats_1     | [1] 2019/10/07 13:53:36.029873 [INF] Starting nats-server version 2.0.2
...
nats_1     | [1] 2019/10/07 13:53:36.032328 [INF] Listening for client connections on 0.0.0.0:4222
...
nats_1     | [1] 2019/10/07 13:53:36.033766 [INF] Server is ready
```


Creating a subscriber is simple. We'll open a NATS session with telnet. Telnet is a client application that will allow us to issue text-based commands to NATS. We'll provide a subject (in example 6-2 we create a subject named 'messages') and also provide a _subscription identifier_. The subscription identifier can be a number or a string. We'll use the keyword 'SUB' to create and subscribe to a subject. Docker Compose provides a convenient `exec` command to connect and ssh into to a running container. We'll use the `exec` command to log into the running BusyBox container and subscribe via telnet.

Listing 6-2 Subscribing to a subject

```bash
$ docker-compose exec busybox sh
/ # telnet nats 4222
...
sub messages 1
+OK
```

Let's open a new terminal and create a publisher. The publishing client will need to provide the name of the subject it wishes to publish the message on. Along with the subject, the client will also provide the number of bytes that will be published. If the number of bytes is missing or incorrect, the publisher is not following the NATS protocol and the message will be rejected.

Let's run a telnet command to publish messages to NATS. 

Listing 6-3 Publishing to a subject

```bash
$ docker-compose exec busybox sh
/ # telnet nats 4222
...
pub messages 12
Hello WORLD!
+OK
```

You should see the `Hello WORLD!` message in the terminal window where you subscribed to the subject (Figure 6-2).
