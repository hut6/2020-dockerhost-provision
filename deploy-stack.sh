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
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: $LOKI_URL
    tenant_id: solvemyclaim

scrape_configs:
  - job_name: system
    static_configs:
      labels:
        job: applogs
        __path__: /var/log/app/*log
EOF

docker stack deploy --prune -c docker-compose.yml server-"${HOST//./-}"

#docker container prune -f;
#docker image prune -f --filter "until=24h"
