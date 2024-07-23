### Chapter 9 - Active Remote Microservice Sandbox

> I try to formulate a plan but my thoughts are a toxic fizz of regret, panic, and self-loathing, as if someone shook up a bottle of carbonated soda and uncapped it inside my brain. - Elan Mastai, All Our Wrong Todays

## Introduction

Before we can dive into building our distributed environment, we'll first need to set up our development environment. We'll use Docker to quickly get up and running. Docker also provides its own isolated network that won't interfere with processes already running on your development machine.

We'll use the terms images and containers. While these terms are sometimes used interchangeably, there are distinct differences. Docker images are the file structure of an application on your hard drive (think of an image as the files in your project folder). A Docker container is a running instance of the image (think of a container as the instance of your application). One or more containers can be spun up from a single image, as long as separate service names have been provided. Another example is you can run multiple instances of a Rails app from the same directory by specifying a different port number (e.g. `rails server -p 3000` and `rails server -p 3001`).

The sandbox environment we'll build in this chapter will use the Active Remote gem to spin up a client (we'll call this app `active-remote`) that can access data in the service that owns the data (we'll call this app `active-record` because it will use Active Record to persist the data to a database that only it has access to).

In this environment, we'll use NATS to pass messages between our microservices. A request to create a new employee will be sent from the Active Remote app to NATS, and NATS will forward the request to any services that have subscribed to that route. The Active Record app that we build will subsribe and respond with the newly created employee entity wrapped in a Protobuf message.

_**Figure 9-1**_ Active Remote Message Passing

![alt text](images/active-remote-sequence-diagram.png "Active Remote message passing between applications")

## Install Docker

If you already have Docker and Docker Compose installed, great! If not, you'll need to follow the steps below.

If you're using Windows or macOS, download and install Docker Desktop. Download links and instructions can be found here: https://www.docker.com/products/docker-desktop.

We'll also use Docker Compose to configure and run several applications from a single configuration file. Docker Compose is included in Docker Desktop for macOS and Windows. If you're running Linux, you'll need to install Docker separately and then follow the Docker Compose installation instructions found here: https://docs.docker.com/compose/install.

## Implementation

### What we'll need

* NATS
* Ruby
* Ruby gems
  * Active Remote
  * Protobuf
  * Rails
* SQLite

Because we installed Docker Desktop, there is no need to install Ruby, the Ruby on Rails framework, NATS or SQLite on your computer. They will be installed inside of the Docker images and containers that we will spin up next.

#### Testing our Docker and Docker Compose installation

We can test our installation by running the `docker version` and the `docker-compose --version` commands. The versions you see in your output may differ from the versions you see below.

**Listing 9-2** Docker environment check

```console
$ docker version
Client:
 Cloud integration: v1.0.29
 Version:           20.10.17
 API version:       1.41
...
Server: Docker Desktop 4.12.0 (85629)
 Engine:
  Version:          20.10.17
  API version:      1.41 (minimum version 1.12)

$ docker compose version
Docker Compose version v2.10.2
```

If you see any errors, check your Docker Desktop installation.

### Project Directory Structure

Now we'll need to create a directory for our project. As you follow along, you'll create three project sub-directories, one for our shared Protobuf messages, one for our ActiveRecord Ruby on Rails server application that stores the data in a SQLite database and one for our ActiveRemote client application that will provide a front-end for our ActiveRecord service.

Following along in this tutorial, you should end up with the following directories (and many files and directories in each directory). The directory `rails-microservices-sample-code` is named after the GitHub repo found at https://github.com/kevinwatson/rails-microservices-sample-code.

* rails-microservices-sample-code
  * chapter-09
    * active-record
    * active-remote
  * protobuf

### Set up a development environment

Let's get started by creating a builder Dockerfile and Docker Compose file. We'll use the Dockerfile file to build an image with the command-line apps we need, and we'll use a Docker Compose configuration file to reduce the number of parameters we'll need to use to run each command. The alternative is to simply use a Dockerfile and related `docker` commands.

Create the following Dockerfile file in the `rails-microservices-sample-code` directory. We'll use the name `Dockerfile.builder` to differentiate the Dockerfile we'll use to generate new rails services vs the Dockerfile we'll use to build and run our Rails applications.

Note: The first line of these files is a comment and is used to indicate the file path and file name. This line can be omitted from the file.

_**Listing 9-3**_ Dockerfile used to create an image that we'll use to generate our Rails application

```dockerfile
# rails-microservices-sample-code/Dockerfile.builder

FROM ruby:3.0.6

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
    build-essential \
    protobuf-compiler \
    nodejs \
    vim

WORKDIR /home/root

RUN gem install rails -v 6.1
RUN gem install protobuf
```

Create the following `docker-compose.builder.yml` file in the `rails-microservices-sample-code` directory. We'll use this configuration file to start our development environment with all of the command-line tools that we'll need.

_**Listing 9-4**_ Docker Compose file to start the container we'll use to generate our Rails application

```yaml
# rails-microservices-sample-code/docker-compose.builder.yml

version: "3.4"

services:
  builder:
    build:
      context: .
      dockerfile: Dockerfile.builder
    volumes:
      - .:/home/root
    stdin_open: true
    tty: true
```

Let's start and log into the builder container. We'll then run the Rails generate commands from the container, which will create two Rails apps. Because we've mapped a volume in the `.yml` file above, the files that are generated will be saved to the `rails-microservices-sample-code` directory. If we didn't map a volume, the files we generate would only exist inside the container, and each time we stop and restart the container they would need to be regenerated. Mapping a volume to a directory on the host computer's will serve files through the container's environment, which includes a specific version of Ruby, Rails and the gems we'll need to run our apps.

```console
$ docker compose -f docker-compose.builder.yml run builder bash
```

The `run` Docker Compose command will build the image (if it wasn't built already), start the container, ssh into the running container and give us a command prompt using the `bash` shell.

You should now see that you're logged in as the root user in the container (you'll see a prompt starting with a hash `#`). Logging in as the root user is usually ok inside a container, because the isolation of the container environment limits what the root user can do.

### Protobuf

Now let's create a Protobuf message and compile the `.proto` file to generate the related Ruby file, containing the classes that will be copied to each of our Ruby on Rails apps. This file will define the Protobuf message, requests and remote procedure call definitions.

Create a couple of directories for our input and output files. The `mkdir -p` command below will create directories with the following structure:

* protobuf
  * definitions
  * lib

```console
$ mkdir -p protobuf/{definitions,lib}
```

Our Protobuf definition file:

_**Listing 9-5**_ Employee message protobuf file

```protobuf
# rails-microservices-sample-code/protobuf/definitions/employee_message.proto

syntax = "proto3";

message EmployeeMessage {
  string guid = 1;
  string first_name = 2;
  string last_name = 3;
}

message EmployeeMessageRequest {
  string guid = 1;
  string first_name = 2;
  string last_name = 3;
}

message EmployeeMessageList {
  repeated EmployeeMessage records = 1;
}

service EmployeeMessageService {
  rpc Search (EmployeeMessageRequest) returns (EmployeeMessageList);
  rpc Create (EmployeeMessage) returns (EmployeeMessage);
  rpc Update (EmployeeMessage) returns (EmployeeMessage);
  rpc Destroy (EmployeeMessage) returns (EmployeeMessage);
}
```

To compile the `.proto` files, we'll use a Rake task provided by the `protobuf` gem. To access the `protobuf` gem's Rake tasks, we'll need to create a `Rakefile`. Let's do that now.

_**Listing 9-6**_ Rakefile

```ruby
# rails-microservices-sample-code/protobuf/Rakefile

require 'protobuf/tasks'
```

Now we can run the `compile` Rake task to generate the file.

```console
$ mkdir chapter-09 # create a directory for this chapter
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd protobuf
# rake protobuf:compile
```

This will generate a file named `employee_message.pb.rb` file in the `protobuf/lib` directory. We'll copy this file into the `app/lib` directory in the Rails apps we'll create next.

### Create a Rails App with a Database

The first Rails app we'll generate will have an Active Record model and will be able to persist the records to a SQLite database. We'll add the `active_remote`, `protobuf-nats` and `protobuf-activerecord` gems to the `Gemfile` file. We'll then run the `bundle` command to retrieve the gems from https://rubygems.org. After retrieving the gems, we'll create scaffolding for an Employee entity and generate an `employees` table in the SQLite database. We could connect our app to a PostgreSQL or MySQL database, but for the purposes of this demo app, the file-based SQLite database is sufficient for our purposes. Of course, the Active Remote app we generate will not know nor will it care how the data is persisted (or if the data is persisted at all).

Let's generate the Rails app that will act as the server and owner of the data. As the owner of the data, it can persist the data to a database. We'll call this app `active-record`.

```console
# cd chapter-09
# rails new active-record
# cd active-record
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# echo "gem 'protobuf-activerecord'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# rails db:migrate
# exit
```

Be sure to inspect the output of each of the commands above, looking for errors. If errors are encountered, please double-check each command for typos or extra characters.

Let's customize the app to serve our Employee entity via Protobuf. We'll need an `app/lib` directory, and then we'll copy the generated `employee_message.pb.rb` file to this directory.

```console
$ mkdir chapter-09/active-record/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-09/active-record/app/lib/
```

Next, we'll need to create a service class to define how to handle the remote procedure call service endpoints we defined in the `.proto` file. We'll need to create an `app/services` directory. We'll then add a `app/services/employee_message_service.rb` file to re-open the `EmployeeMessageService` class defined in our `app/lib/employee_message.pb.rb` file to provide implementation details. Lastly, we'll define some scopes and field_scopes in our `app/models/employee.rb` to wire up existing model attributes with protobuf attributes.

_**Listing 9-6**_ Employee Active Record model

```ruby
# rails-microservices-sample-code/chapter-09/active-record/app/models/employee.rb

require 'protobuf'

class Employee < ApplicationRecord
  protobuf_message :employee_message

  scope :by_guid, ->(*values) { where(guid: values) }
  scope :by_first_name, ->(*values) { where(first_name: values) }
  scope :by_last_name, ->(*values) { where(last_name: values) }

  field_scope :guid
  field_scope :first_name
  field_scope :last_name
end
```

```console
$ mkdir chapter-09/active-record/app/services
```

_**Listing 9-7**_ Employee message service class

```ruby
# rails-microservices-sample-code/chapter-09/active-record/app/services/employee_message_service.rb

class EmployeeMessageService
  def search
    records = ::Employee.search_scope(request).map(&:to_proto)

    respond_with records:
  end

  def create
    record = ::Employee.create(request)

    respond_with record
  end

  def update
    record = ::Employee.where(guid: request.guid).first
    record.assign_attributes(request)
    record.save!

    respond_with record
  end

  def destroy
    record = ::Employee.where(guid: request.guid).first

    record.delete
    respond_with record.to_proto
  end
end
```

We'll also need to add a few more details. Because the `app/lib/employee_message.pb.rb` file contains multiple classes, only the class that matches the file name is loaded. In development mode, Rails can lazy load files as long as the file name can be inferred from the class name, e.g. code requiring the class `EmployeeMessageService` will try to lazy load a file named `employee_message_service.rb`, and throw an error if the file is not found. We can either separate the classes in the `app/lib/employee_message.pb.rb` file into separate files, or enable eager loading in the config. For the purposes of this demo, let's enable eager loading.

Rails 6 now uses zeitwerk to autoload files. Zeitwerk expects that filenames ending with `.rb` match the convention of one class per file, but the employee_message.pb.rb file we generated above doesn't follow this convention. For this reason, we'll need to change the default autoloader configuration back to classic mode by setting `autoloader = :classic`.

_**Listing 9-8**_ Development configuration file

```ruby
# rails-microservices-sample-code/chapter-09/active-record/config/environments/development.rb

...
config.eager_load = true
...
config.autoloader = :classic
...
```

The last change we need to make to the `active-record` app is to add a `protobuf_nats.yml` config file to configure the code provided by the `protobuf-nats` gem.

_**Listing 9-9**_ Protobuf Nats config file

```yml
# rails-microservices-sample-code/chapter-09/active-record/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

### Create a Rails App without a Database

Now it's time to create our second Rails app. We'll call this one `active-remote`. It will have a model, but the model classes will inherit from `ActiveRemote::Base` instead of the default `ApplicationRecord` (which inherits from `ActiveRecord::Base`). In other words, these models will interact with the `active-remote`'s models by sending messages via the NATS server.

Let's generate the `active-remote` app. We won't need the Active Record persistence layer, so we'll use the `--skip-active-record` flag. We'll need the `active_remote` and `protobuf-nats` gems, but not the `protobuf-activerecord` gem that we included in the `active-record` app. We'll use Rails scaffolding to generate a model, controller and views to view and manage our Employee entity that will be shared between the two apps.

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd chapter-09
# rails new active-remote --skip-active-record --skip-webpack-install
# cd active-remote
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# exit
```

We'll need to make a couple of changes to the `active-remote` app. First, let's copy the Protobuf file.

```console
$ mkdir chapter-09/active-remote/app/lib
$ cp protobuf/lib/employee_message.pb.rb chapter-09/active-remote/app/lib/
```

Let's now add a model that inherits from Active Remote.

_**Listing 9-10**_ Employee Active Remote class

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/app/models/employee.rb

class Employee < ActiveRemote::Base
  service_class ::EmployeeMessageService

  attribute :guid
  attribute :first_name
  attribute :last_name
end
```

Now let's edit the `config/environments/development.rb` file to enable eager loading and use the classic autoloader for the same reasons listed above.

_**Listing 9-11**_ Development configuration file

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/config/environments/development.rb

...
config.eager_load = true
...
config.autoloader = :classic
...
```

Let's add the `protobuf_nats.yml` file.

_**Listing 9-12**_ Protobuf Nats config file

```yml
# rails-microservices-sample-code/chapter-09/active-remote/config/protobuf_nats.yml

default: &default
  servers:
    - "nats://nats:4222"

development:
  <<: *default
```

Because we don't need webpacker or JavaScript for our test app, we'll need to disable pre-defined calls to the runtime. We can do this by removing the `javascript_pack_tag` line from the `application.html.erb` file.

_**Listing 9-13**_ Remove javascript_pack_tag

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/app/views/layouts/application.html.erb
# remove or comment out this line

<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

The last thing we need to do is change a couple of method calls in the `employees_controller.rb` file to change the way that our Protobuf messages are retrieved and instantiated. We need to use the `search` method instead of the default `all` and `find` Active Record methods. Also, because we're using uuids (guids) as the unique key between services, we'll generate a new uuid each time the `new` action is called.

_**Listing 9-14**_ Employee controller class

```ruby
# rails-microservices-sample-code/chapter-09/active-remote/controllers/employees_controller.rb

  def index
    @employees = Employee.search({})
  end

...

def new
  @employee = Employee.new(guid: SecureRandom.uuid)
end

...

def set_employee
  @employee = Employee.search(guid: params[:id]).first
end
```

### Create and Configure Our Environment

Last but not least, let's add a `Dockerfile` and `docker-compose.yml` file to create an image and spin up containers and link our services together.

_**Listing 9-15**_ Sandbox Dockerfile

```dockerfile
# rails-microservices-sample-code/Dockerfile

FROM ruby:3.0.6

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential nodejs

ENV INSTALL_PATH /usr/src/service
ENV HOME=$INSTALL_PATH PATH=$INSTALL_PATH/bin:$PATH
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install rails -v 6.1

ADD Gemfile* ./
RUN set -ex && bundle install --no-deployment
```

_**Listing 9-16**_ Sandbox Docker Compose file

```yml
# rails-microservices-sample-code/chapter-09/docker-compose.yml

version: "3.4"

services:
  active-record:
    environment:
    - PB_SERVER_TYPE=protobuf/nats/runner
    build:
      context: ./active-record
      dockerfile: ../../Dockerfile
    command: bundle exec rpc_server start -p 9399 -o active-record ./config/environment.rb
    volumes:
    - ./active-record:/usr/src/service
    depends_on:
    - nats
  active-remote:
    environment:
    - PB_CLIENT_TYPE=protobuf/nats/client
    build:
      context: ./active-remote
      dockerfile: ../../Dockerfile
    command: bundle exec puma -C config/puma.rb
    ports:
    - 3000:3000
    volumes:
    - ./active-remote:/usr/src/service
    depends_on:
    - nats
  nats:
    image: nats:latest
    ports:
    - 8222:8222
```

### Run the Apps

Congratulations! Your apps are now configured and ready to run in a Docker container. Run the following command to download the required images, build a new image that will be used by both Rails containers, and start three services: `active-record`, `active-remote` and `nats`.

```console
$ cd chapter-09
$ docker-compose up
```

It may take a few minutes, but once all of the containers are up and running, we can browse to http://localhost:3000/employees. The Rails app running on port 3000 is the Active Remote app.

### Monitoring

If we review the log output in the console where you ran the `docker-compose up` command, we should see output like the following:

```console
active-remote_1  | I, [2019-12-28T00:35:06.460838 #1]  INFO -- : [CLT] - 6635f4080982 - 2aca3d71d6d0 - EmployeeMessageService#search - 48B/75B - 0.0647s - OK - 2019-12-28T00:35:06+00:00
```

This indicates that the `EmployeeMessageService#search` method was called. Not all output from the services is displayed in the output.

Go ahead and click the `New Employee` link. Fill out the First name and Last name fields and click the `Create Employee` button to create a new Employee record. Review the logs again. You should see a message like the one below.

```console
active-remote_1  | I, [2019-12-28T00:40:43.597089 #1]  INFO -- : [CLT] - 0d6886451aa0 - 3f910c005424 - EmployeeMessageService#create
```

We can also check the NATS connection info to verify that data is being passed over the NATS server. Browse to http://localhost:8222 and click the 'connz' link. Clicking links to pull data on the http://localhost:3000/employees page will pass additional messages to the `active-record` app through the NATS server. Refreshing the http://localhost:8222/connz page will display incrementing counters on the `num_connections` and the `num_connections/in_msgs` and `num_connections/out_msgs` fields.

## Resources

* https://docs.docker.com/compose
* https://nats.io
* https://www.sqlite.org

## Wrap-up

Now that you have configured and spun up two new services that can communicate and share data via Protobuf, feel free to experiement by adding new Protobuf messages, additional remote procedure calls, etc.

After completing the exercises in this chapter, we've built a synchronous platform. In other words, when the service asks for a specific Active Remote object, it expects a quick response from one of the services that own the Active Record model. In the next chapter, we'll discuss the event-driven architectural pattern. This pattern allows us to add one or more of services that can each perform an action when an event is detected.

[Next >>](110-chapter-10.md)
