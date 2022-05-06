#!/bin/bash

export $(cat .env | xargs)

docker network create --scope=swarm --driver=bridge node_bridge | true
docker stack deploy --prune -c docker-compose.yml server-"${HOST//./-}"
