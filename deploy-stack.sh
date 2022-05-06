#!/bin/bash

export $(cat .env | xargs)

docker network create --scope=local --driver=bridge node_bridge | true
docker stack deploy --prune -c docker-compose.yml server-"${HOST//./-}"
