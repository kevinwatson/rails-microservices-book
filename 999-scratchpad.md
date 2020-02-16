# Scratch Pad

## Generating protobuf classes

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
# require 'protobuf'
# cd protobuf
# rake protobuf:compile
```

## Encoding protobuf messages

```console
# irb
> require_relative 'lib/person_message.pb'
> PersonMessage.encode(id: 1, first_name: "George", last_name: "Costanza")
> PeopleMessageList.encode(records: [PersonMessage.new(id: 1, first_name: "George", last_name: "Costanza"), PersonMessage.new(id: 2, first_name: "Elaine", last_name: "Benes")])
```
