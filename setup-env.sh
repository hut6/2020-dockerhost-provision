#!/bin/bash

export $(cat .env | xargs)

hostnamectl set-hostname ${HOST}

cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "${LOKI_URL}"
  }
}
EOF

rm -rf /etc/docker/promtail
cp -r promtail /etc/docker/promtail
chmod 655 /etc/docker/promtail/entry.sh

mkdir /etc/docker/prometheus
cat << EOF > /etc/docker/prometheus/prometheus.yml
global:
    scrape_interval:     5s
    evaluation_interval: 20s

remote_write:
  - url: "${CORTEX_URL}"

scrape_configs:
  - job_name: '${HOST} - Host Metrics'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'Traefik'
    static_configs:
      - targets: ['traefik:8082']

EOF

echo "${LOKI_URL}" > /etc/docker/promtail/LOKI_URL
echo "${HOST}" > /etc/docker/promtail/HOST
