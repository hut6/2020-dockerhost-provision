#!/bin/bash

export $(cat .env | xargs)

cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "${LOKI_URL}"
  }
}
EOF

cp promtail /etc/docker/promtail

echo "${CLIENT_URL}" > /etc/docker/promtail/CLIENT_URL
echo "${HOST}" > /etc/docker/promtail/HOST

docker stack deploy --prune -c docker-compose.yml server-"${HOST//./-}"

#docker container prune -f;
#docker image prune -f --filter "until=24h"
