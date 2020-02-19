### Chapter 3 - Ruby and Rails

> What if every creative idea that someone has is unconsciously borrowed from that person's experiences in another reality? Maybe all ideas are plagiarized without us knowing it, because they come to us through some cryptic and unprovable reality slippage? - Elan Mastai, All Our Wrong Todays

## Ruby

The Ruby programming language was designed and developed by Yukihiro "Matz" Matsumoto in the mid 1990s. The language was relatively obscure until David Heinemeier Hansson published the Ruby on Rails framework in July of 2004. Ruby on Rail's popularity drove the development of the Ruby language.

Ruby is a high-level language. It is high-level because it has a strong abstraction from the details of the computer hardware. The benefit is that the developer has more freedom to write code that the Ruby interpreter will interpret and in some cases optimize for the hardware. The downside is that the developer has more freedom to write code that may not be optimized for the hardware.

Ruby is also an interpreted language. Interpreted languages (depending on the implementation) run on top of a virtual machine. The virtual machine layer runs on top of the native processor. In contrast, compiled languages are compiled to bytecode and run directly on the native processor. Because of the extra virtual machine layer, interpreted languages are generally slower.

## Ruby on Rails

By the simple fact that you're reading this book, you're most likely familiar with the benefits of the Ruby language and the Ruby on Rails framework. If not, my take is that the Ruby language and the Ruby on Rails framework provide the tools a developer needs to be highly productive while building web applications. New applications can be spun up in a matter of seconds. There are a large number of libraries available (known in the Ruby world as gems), that can be used to extend your application's functionality. For example, if you need to run background processes, there's a gem for that: Sidekiq. If your app needs to manage money and currencies, there's a gem for that: Money. I could go on, but you get the point.

For more information about why you should use the Rails framework, please review the official Ruby on Rails documentation at https://rubyonrails.org.

### Interpreters

There are a few of Ruby interpreters available. We'll discuss a few of them below.

#### MRI & YARV

The Matz's Ruby Interpreter (MRI) was the default Ruby interpreter until Ruby 1.8. When Ruby 1.9 was released, Yet another Ruby VM (YARV) replaced MRI. YARV is the interpreter through Ruby 2+. YARV only supports green threads (which aren't recognized by the operating system and aren't scheduled as tasks among its cores).

The good news is, there are other interpreters available that can help optimize your hardware for the custom apps you write.

#### JRuby

JRuby is an implementation of Ruby that compiles Ruby code to Java bytecode. Some of the benefits are true multithreading, the stability of the Java platform, the ability to call native Java classes, and in some cases, better performance. One of the downsides is increased memory consumption (this is Java, after all).

## Resources

* https://rubygems.org/gems/money
* https://rubygems.org/gems/sidekiq
* https://rubyonrails.org
* https://www.jruby.org
* https://www.ruby-lang.org

## Wrap-up

Ruby is a language that was designed with developer productivity in mind. Ruby on Rails is a framework that provides the toolset a developer needs to quickly spin up an application. There are a wide variety of gems (libraries) available to extend your application's features.

In the next chapter, we'll discuss two popular gems, Active Record and Active Model. These gems are used to manage and persist the data in your application.

[Next >>](050-chapter-04.md)
