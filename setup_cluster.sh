#!/bin/bash

set -e

# cluster 2 to 1
docker-compose exec rabbit2 rabbitmqctl stop_app
docker-compose exec rabbit2 rabbitmqctl join_cluster rabbit@rabbit1
docker-compose exec rabbit2 rabbitmqctl start_app

# cluster 4 to 3
docker-compose exec rabbit4 rabbitmqctl stop_app
docker-compose exec rabbit4 rabbitmqctl join_cluster rabbit@rabbit3
docker-compose exec rabbit4 rabbitmqctl start_app

nodes=(rabbit1 rabbit2 rabbit3 rabbit4)
for node in "${nodes[@]}"
do
    docker-compose exec ${node} rabbitmq-plugins enable rabbitmq_federation
    docker-compose exec ${node} rabbitmq-plugins enable rabbitmq_federation_management
done

# federate 4 to 2
config='{"uri": ["amqp://guest:guest@rabbit1", "amqp://guest:guest@rabbit2"]}'
docker-compose exec rabbit4 rabbitmqctl set_parameter federation-upstream cluster1 "${config}"

config='[{"upstream": "cluster1"}]'
docker-compose exec rabbit4 rabbitmqctl set_parameter federation-upstream-set cluster1_federators "${config}"

config='{"ha-mode": "all","ha-sync-mode": "automatic"}'
docker-compose exec rabbit4 rabbitmqctl set_policy --apply-to exchanges ha-exchange ".*" "${config}"

config='{"ha-mode": "all", "ha-sync-mode": "automatic", "federation-upstream-set": "all"}'
docker-compose exec rabbit4 rabbitmqctl set_policy --apply-to queues ha-fed-queues ".*" "${config}"

# federate 2 to 4
config='{"uri": ["amqp://guest:guest@rabbit3", "amqp://guest:guest@rabbit4"]}'
docker-compose exec rabbit2 rabbitmqctl set_parameter federation-upstream cluster2 "${config}"

config='[{"upstream": "cluster1"}]'
docker-compose exec rabbit4 rabbitmqctl set_parameter federation-upstream-set cluster1_federators "${config}"

config='{"ha-mode": "all","ha-sync-mode": "automatic"}'
docker-compose exec rabbit2 rabbitmqctl set_policy --apply-to exchanges ha-exchange ".*" "${config}"

config='{"ha-mode": "all", "ha-sync-mode": "automatic", "federation-upstream-set": "all"}'
docker-compose exec rabbit2 rabbitmqctl set_policy --apply-to queues ha-fed-queues ".*" "${config}"



open http://$(docker-compose port rabbit2 15672)
open http://$(docker-compose port rabbit4 15672)
