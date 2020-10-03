#!/bin/bash

export $(cat .env | xargs)

docker stack deploy --prune -c docker-compose-lite.yml server-"${HOST//./-}"
