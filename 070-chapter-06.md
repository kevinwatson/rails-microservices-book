### Chapter 6 - Messaging Systems

> There are around seven octillion atoms in a human body. That's a lot of goddamn atoms to disassemble, shoot back through time and space, and reassemble in perfect order. - Elan Mastai, All Our Wrong Todays

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

```yml
$ cat ~/projects/nats/docker-compose.yml
# usage: docker-compose up

version: "3.4"

services:
  nats:
    image: nats:latest
    ports:
      - 4222:4222
      - 8222:8222
    stdin_open: true
  busybox:
    image: busybox:latest
    stdin_open: true
```

Save the file with the filename `docker-compose.yml`. Let's now switch to that directory and run the containers. The versions of the software and output may differ from what you see in your terminal.

Listing 6-2 Start NATS and Busybox

```console
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

Listing 6-3 Subscribing to a Subject

```console
$ docker-compose exec busybox sh
/ # telnet nats 4222
...
sub messages 1
+OK
```

Let's open a new terminal and create a publisher. The publishing client will need to provide the name of the subject it wishes to publish the message on. Along with the subject, the client will also provide the number of bytes that will be published. If the number of bytes is missing or incorrect, the publisher is not following the NATS protocol and the message will be rejected.

Let's run a telnet command to publish messages to NATS. 

Listing 6-4 Publishing to a Subject

```console
$ docker-compose exec busybox sh
/ # telnet nats 4222
...
pub messages 12
Hello WORLD!
+OK
```

You should see the `Hello WORLD!` message in the terminal window where we subscribed to the subject (Figure 6-3). This demonstrates that we have NATS server running, we published a message to a subject, and our subscriber received the message.

NATS also provides a monitoring API which we can query to keep tabs on how many messages are sent through the server, etc. Because we're exposing NATS port 8222 outside the Docker environment (see the docker-compose.yml file in Figure 6-2), we can view the instrumentation by opening the browser on our host machine at the following address: [http://localhost:8222](http://localhost:8222). A page should render in your browser, with a handful of links. If we were to set up a cluster of NATS servers, additional links would appear.

As of the time of this writing, there are 5 links on the page. Let's briefly look at each of them:

* [varz](http://localhost:8222/varz) - General information about the server state and configuration.
* [connz](http://localhost:8222/connz) - More detailed information on current and recently closed connections.
* [routez](http://localhost:8222/routez) - Information on active routes for a cluster.
* [subsz](http://localhost:8222/subsz) - Detailed information about the current subscriptions and the routing data structure.
* [help](https://nats-io.github.io/docs/nats_server/monitoring.html) - A link to the NATS documentation at https://nats-io.github.io/docs/nats_server/monitoring.html.

Some of the endpoints above also have querystring parameters that can be passed, e.g. http://localhost:8222/connz?sort=start, which will sort the connections by the start time. Check out the documentation at https://nats-io.github.io/docs/nats_server/monitoring.html for more information about these endpoints and their options.

We have successfully spun up a NATS server, subscribed to a subject, and published messages over that subject. We also learned about the instrumentation that NATS provides on port 8222. Next, we'll set up a full environment with several Rails applications that will use NATS to communicate.
