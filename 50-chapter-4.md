### Chapter 4 - ActiveRecord and ActiveModel

## Introduction

   1. ActiveRecord
   1. ActiveModel
   1. ActiveSupport
   1. What's the difference
   1. Wrap-up

#### Active Model

Active Model is a library of modules that provides various methods to Active Record. Active Model's modules can also be included in your classes to provide the same functionality. Some of the included modules are below.

* AttributeMethods - adds custom prefixes and suffixes on methods of a class
* Callbacks - adds before, after and around methods
* Conversion - adds `to_model`, `to_key` and `to_param` methods to an object
* Dirty - adds methods to determine whrther the object has been changed or not
* Validations - adds validation methods to an object
* Naming - adds class methods that provide singular and plural versions of the class name
* Model - adds class methods for validations, translations, conversions, etc, and the ability to initialize an object with a hash of attributes
* Serialization - adds functionality to make it easy to serialize and deserialize an object to and from a hash or JSON object
* Translation - adds methods for internationalization using the i18n framework
* Lint Tests - adds functionality to test whether your object is compliant with the Active Model API
* SecurePassword - adds methods to store passwords or other data securely using the `bcrypt` gem

https://guides.rubyonrails.org/active_model_basics.html

#### Active Record

The core of a Rails application is it's data. Rails applications (as are many framework patterns) are built in multiple layers. Rails itself follows the model-view-controller (MVC) architecture pattern to separate programming logic into separate elements. Active Record is the model part of the MVC pattern in Rails. Active Record is where you add the behavior and persist the data that is required by your application.

Using Active Record, whether stand-alone or in a Rails app, provides the following benefits:

* A way to represent models and data
* Associations between models
* Hierarchies through related models
* Data validation
* Database access using objects

Active Record maps a class to a database table.

https://guides.rubyonrails.org/active_record_basics.html

#### Active Resource

Active Resource provides a way to map a model class to a RESTful resource. It can manage data at an HTTP endpoint in either XML or JSON format.

For example, if you need to access data at http://localhost:8080/bicycles, you can 

#### What's the Difference?

The most common way to present and persist data in a Rails application is with Active Record. Active Record is a wrapper for database tables and their relationships. Active Resource is a wrapper for RESTful. 

Active Model is used by Active Record for data validation, serialization and a number of other features. 

Not all models need to be Active Record models that map to a database. We can add models to our app where some models are backed by a database, while another model could map to an API endpoint. This leads us to Active Remote - models that map to a remote service over a message bus. We'll discuss this in detail in the next chapter.

ActiveRecord 