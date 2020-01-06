### Chapter 3 - Ruby on Rails

> What if every creative idea that someone has is unconsciously borrowed from that person's experiences in another reality? Maybe all ideas are plagiarized without us knowing it, because they come to us through some cryptic and unprovable reality slippage? - Elan Mastai, All Our Wrong Todays

## Why Ruby on Rails?

### The Ruby language

### Package management with Bundler

### Popularity

### Rails generators

### Included features

### Interpreters

#### MRI & YARV

The Matz's Ruby Interpreter (MRI) was the default Ruby interpreter until Ruby 1.8. When Ruby 1.9 was released, Yet another Ruby VM (YARV) replaced MRI. YARV is the interpreter through Ruby 2+. YARV only supports green threads (which aren't recognized by the operating system and aren't scheduled as tasks among its cores).

The good news is, there are other interpreters available that can help optimize your hardware for the custom apps you write.

#### JRuby

JRuby is an implementation of Ruby that compiles Ruby code to Java bytecode. Some of the benefits are true multithreading, the stability of the Java platform, the ability to call native Java classes, and in some cases, better performance. One of the downsides is increased memory consumption (this is Java, after all).

## Rails in the enterprise

## Wrap-up

[Next >>](050-chapter-04.md)
