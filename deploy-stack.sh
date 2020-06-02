#!/bin/bash

export $(cat .env | xargs)

docker stack deploy --prune -c docker-compose.yml "$HOST"-server

#docker container prune -f;
#docker image prune -f --filter "until=24h"
