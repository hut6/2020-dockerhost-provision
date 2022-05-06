#!/bin/bash

export $(cat .env | xargs)

docker stack deploy --prune -c docker-compose.yml server
