# Scratch Pad

## Generating protobuf classes

```console
$ docker-compose -f docker-compose.builder.yml run builder bash
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

## Diagrams

Figure 9-1

```
sequenceDiagram
    participant Remote as Active Remote App
    participant N as NATS
    participant Record as Active Record App
    Remote->>N: Employee proto
    N->>Record: Employee proto
    Record->>N: Employee proto
    N->>Remote: Employee proto
```

Figure 12-1

```
sequenceDiagram
    participant Record as Active Record/Publisher App
    participant R as RabbitMQ
    participant S1 as Action Subscriber App 1
    participant S2 as Action Subscriber App 2
    participant S3 as Action Subscriber App 3
    Record->>R: Employee proto
    R->>S1: Employee proto
    R->>S2: Employee proto
    R->>S3: Employee proto
```

Figure 13-1

```
sequenceDiagram
    participant Remote as Active Remote App
    participant N as NATS
    participant Record as Active Record/Publisher App
    participant R as RabbitMQ
    participant S1 as Action Subscriber App 1
    participant S2 as Action Subscriber App 2
    Remote->>N: Employee proto
    N->>Record: Employee proto
    Record->>N: Employee proto
    N->>Remote: Employee proto
    Record->>R: Employee proto
    R->>S1: Employee proto
    R->>S2: Employee proto
```
