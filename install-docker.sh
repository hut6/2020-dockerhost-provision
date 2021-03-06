#!/bin/bash

export $(cat .env | xargs)

# including docker sudo
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install curl gnupg-agent apt-transport-https software-properties-common ca-certificates -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo ./setup-env.sh
sudo docker swarm init
sudo docker plugin install  grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
sudo docker plugin enable loki
echo "Waiting to restart docker"
sleep 3
./restart-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

