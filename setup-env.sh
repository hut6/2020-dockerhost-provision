#!/bin/bash

export $(cat .env | xargs)

hostnamectl set-hostname ${HOST}

# LOKI DOCKER DRIVER CONFIG
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "log-driver": "awslogs",
  "log-opts": {
    "awslogs-region": "ap-southeast-2",
    "awslogs-group": "${HOST}",
    "awslogs-create-group": "true",
    "tag": "{{.ID}} - {{.Name}}"
  }
}
EOF


