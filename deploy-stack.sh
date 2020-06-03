#!/bin/bash

export $(cat .env | xargs)

cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "$LOKI_URL"
  }
}
EOF

cat << EOF > /etc/docker/promtail-config.yaml
server:
  disable: true

clients:
  - url: $LOKI_URL

scrape_configs:
  - job_name: system
    static_configs:
    - targets:
      - localhost
      labels:
        host: ${HOST}
        job: applogs
        __path__: /var/log/app/*log
EOF

docker stack deploy --prune -c docker-compose.yml server-"${HOST//./-}"

#docker container prune -f;
#docker image prune -f --filter "until=24h"
