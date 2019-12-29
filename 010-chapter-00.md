### Chapter 0

> People are made of stories. Our memories are not the impartial accumulation of every second we've lived; they're the narrative that we assembled out of selected moments. Which is why, even when we've experienced the same events as other individuals, we never constructed identical narratives: the criteria used for selecting moments were different for each of us, and a reflection of our personalities. Each of us noticed the details that caught our attention and remembered what was important to us, and the narratives we built shaped our personalities in turn. But, I wondered, if everyone remembered everything, would our differences get shaved away? What would happen to our sense of self? It seemed to me that a perfect memory couldn't be a narrative any more than unedited security-cam footage could be a feature film. - Ted Chiang, Exhalation

## Setup

Before we can dive into building our distributed environment, we'll first need to set up our development environment. We'll use Docker to quickly get up and running. Docker also provides an networking environment that we'll use that won't interfere with already running processes on your development machine.

## Install Docker

If you're using Windows or macOS, download and install Docker Desktop. Download links and instructions can be found here: https://www.docker.com/products/docker-desktop.

We'll also be using Docker Compose to run several applications from a single configuration file. Docker Compose is included in Docker Desktop for macOS and Windows. If you're running Linux, you'll need to install Docker separately and then follow the Docker Compose installation instructions found here: https://docs.docker.com/compose/install.

## Install Ruby

Because you installed Docker Desktop, there is no need to install Ruby or the Ruby on Rails framework on your computer. That will be handled inside of Docker containers that we will spin up later.

## Wrap-up

We installed Docker Desktop which will allow us to easily spin up a distributed environment on your desktop computer. We'll discuss a distributed microservice architecture in the next chapter.
