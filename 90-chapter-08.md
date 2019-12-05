### Chapter 8 - Microservice Playground

## Setup

Before we can dive into building our distributed environment, we'll first need to set up our development environment. We'll use Docker to quickly get up and running. Docker also provides an networking environment that we'll use that won't interfere with already running processes on your development machine.

## Install Docker

If you're using Windows or macOS, download and install Docker Desktop. Download links and instructions can be found here: https://www.docker.com/products/docker-desktop.

We'll also be using Docker Compose to run several applications from a single configuration file. Docker Compose is included in Docker Desktop for macOS and Windows. If you're running Linux, you'll need to install Docker separately and then follow the Docker Compose installation instructions found here: https://docs.docker.com/compose/install.

## What we'll need

* Ruby
* Ruby on Rails and related gems
* Nats
* SQLite

Because you installed Docker Desktop, there is no need to install Ruby or the Ruby on Rails framework on your computer. That will be handled inside of the Docker containers that we will spin up next.

### Testing our Docker and Docker Compose installation

We can test our installation by running the `docker-compose --version` command. This will create two directories, one for each of our microservices.

```bash
$ mkdir -p ~/rails-book/{active-record,active-remote}
$ cd ~/rails-book
$ docker-compose --version
docker-compose version 1.24.1, build 4667896b # your version may vary
```

If you see any errors, check your Docker Desktop installation.

### Set up a development Docker Compose file

Create the following Dockerfile file in the `~/rails-book` directory.

```bash
$ cat ~/rails-book/Dockerfile

FROM ruby:2.6.5

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential

ENV INSTALL_PATH /usr/src/service
ENV HOME=$INSTALL_PATH PATH=$INSTALL_PATH/bin:$PATH
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install rails -v 5.1.7

# We'll uncomment these lines after we've created our rails app
# ADD Gemfile* ./
# RUN set -ex && bundle install --no-deployment
```

Create the following `docker-compose.yml` file in the `~/rails-book` directory. This will create two separate containers from the same Ruby Docker image. We'll create one for the Active Record application, and one for the Active Remote application.

```bash
$ cat docker-compose.yml 
version: "3.4"

services:
  active-record:
    build:
      context: ./active-record
      dockerfile: ../Dockerfile
    command: bundle exec puma -C config/puma.rb
    ports:
      - 3001:3000
    volumes:
      - ./active-record:/usr/src/service
    #stdin_open: true

  active-remote:
    build:
      context: ./active-remote
      dockerfile: ../Dockerfile
    command: bundle exec puma -C config/puma.rb
    ports:
      - 3002:3000
    volumes:
      - ./active-remote:/usr/src/service
    #stdin_open: true

  nats:
    image: nats:latest
    #ports:
    #  - 4222:4222
    #  - 8222:8222
    #stdin_open: true
  busybox:
    image: busybox:latest
    stdin_open: true
```

Let's start and log into the Active Record container. We'll then create a basic Rails app, add an Active Record model and related controller and views, and create a record. The first time you run a `docker-compose` command, Docker will download any specified images and build a new image to run the container.

Let's run commands to generate the Rails applications. The one that supports Active Record and has a database we'll name `active-record`, and the other one that does not have a database we'll name `active-remote`.

```bash
# rails new active-record
# rails new active-remote
##$ docker-compose run active-remote rails new .
```

```bash
$ docker-compose run active-record /bin/bash # start the container and run bash so we can stay logged in and run additional commands
# gem install rails # install the latest stable version of Ruby on Rails
# rails new . # create the app
# echo "gem 'active_remote'" >> Gemfile # add Active Remote to the project
# bundle # find and download all of the dependencies
# rails generate scaffold Employee first_name:string last_name:string # create a model, controller and views
# rails db:migrate # create the database tables
# rails console # start rails console
> Employee.create(first_name: 'Bruce', last_name: 'Wayne') # create an employee record
```



Now let's create an Active Remote Rails app. This app doesn't have direct database access to the Employee model, but in a lot of ways the application will behave as if the model retrieves and persists its data in a database.

```bash
$ docker-compose run active-remote /bin/bash # start the container and run bash so we can stay logged in and run additional commands
# gem install rails # install the latest stable version of Ruby on Rails
# rails new . # create the app
# echo "gem 'active_remote'" >> Gemfile # add Active Remote to the project
# bundle # find and download all of the dependencies
# rails generate scaffold Employee first_name:string last_name:string # create a model, controller and views
# exit # let's go back to the host and edit some files
```

Create two Rails apps without the JavaScript related configuration. JavaScript isn't necessary for our test apps, and it would require that we add and configure additional services such as NodeJS.

```bash
docker-compose run active-record rails new -J --skip-coffee .
docker-compose run active-remote rails new -J --skip-coffee .
```

Now, let's use Rails scaffolding to add views, a controller and a model to the active record application, using SQLite as the database. SQLite is the default database.

```bash
$ docker-compose run active-record rails generate scaffold Employee first_name:string last_name:string
```

Now let's start the app and test our application.

```bash
$ docker-compose up
```

Let's open our browser and navigate to http://localhost:3001/employees. We should see a page that displays employee information. This list is currently empty. Click the New Employee link and add an employee. This employee record will be persisted in the SQLite database that is owned by the active-record app.


Let's add the necessary gems to the `active-record` app's Gemfile and run bundler to retrieve the new dependencies. This will expose the Employee service to other apps.

```bash
$ echo "gem 'active_remote'" >> ./active-record/Gemfile
$ docker-compose run active-record bundle
```

Now, let's set up the active-remote app to view the record we just created in the active-record app.


```bash
$ docker-compose run active-record rails generate scaffold Employee first_name:string last_name:string
$ docker-compose run active-record rails db:migrate
```

Let's add the necessary gems to the `active-remote` app's Gemfile and run bundler to retrieve the new dependencies.

```bash
$ echo "gem 'active_remote'" >> ./active-remote/Gemfile
$ docker-compose run active-remote bundle
```

We'll need to add a service class to provide remote access to our Active Record model. You'll need to create the `app/services` directory and follow the `employee` naming convention by creating a file named `employee_service.rb`.

```bash
$ mkdir ./active-record/app/services
$ touch ./active-record/app/services/employee_service.rb
```

Using your favorite editor, add the following code to the `employee_service.rb` file.

```ruby
class EmployeeService < RPCService
    def search(request)
      records = Employee.where(first_name: request.payload[:first_name]).or(last_name: request.payload[:last_name])
      return records
    end

    def create(request)
    end

    def update(request)
    end

    def delete(request)
    end
  end
```

Let's use Rails scaffolding to add a controller with views to our `active-remote` app. We'll delete the migrations and create our own Active Remote model.

```bash
$ docker-compose run active-remote rails generate scaffold Employee first_name:string last_name: string
```

Now let's create an Active Remote model. We'll also need to add the `attribute` macros to define the remote fields.

We can delete the migration (we won't need it because our `active-record` app will hold the data).

```bash
$ rm ./active-remote/db/migrate/*.rb
```

In your favorite editor, open the `./active-remote/app/models/employee.rb` file and replace the existing code with the following code.

```ruby
class Employee < ActiveRemote::Base
  attribute :first_name
  attribute :last_name
end
```

Make sure you save the file.


Now we're all set up and ready to test it out. We need to start the `active-record` app, the `active-remote` app, and the NATS server. Create the following `docker-compose.yml` file in your code directory.

```yaml

```

Let's restart our docker services. This will reload the Ruby files we've added to the project. Go back to the terminal where you ran the the `docker-compose up` command and press Ctrl-C to stop the services. Run `docker-compose up` to start them back up.

Now let's open two browser windows, one for the `active-record` service and one for the `active-remote` service.

Active Record app

http://localhost:3001/employees

Active Remote app

http://localhost:3002/employees

Congratulations!

You can create or modify an employee in both places, and after refreshing the page in the other app, you can see the changes reflected in both apps.


```bash
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

## Exposed ports

## Testing

## Monitoring

## Wrap-up
