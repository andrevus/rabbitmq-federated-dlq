# RabbitMQ Federation DLQ Problem

Create rabbitmq instances

```
docker-compose up
```

This will create 4 rabbitmq instances.

Next setup 2 clusteres and federation:

```
./setup_setup_cluster.sh
```

Next run simple node.js application wchich connect into rabbit2 and rabbit4, 
declare queue and exchanges and send one messge

```
docker-compose run --rm admin npm install
docker-compose run --rm admin npm run start
```

Next run consumer, which connect to one cluster. Consumer will nack msg with reque set to false.
Two messages will be consumed, both should return to dlq, and retry is set to 10 sec, but only one will come back.


```
docker-compose run --rm admin npm run federated-dlq
```