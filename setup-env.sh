#!/bin/bash

export $(cat .env | xargs)

hostnamectl set-hostname ${HOST}

# LOKI DOCKER DRIVER CONFIG

sudo cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "${LOKI_URL}",
    "loki-timeout": "20s",
    "loki-retries": "5",
    "loki-batch-wait": "2s",
    "loki-batch-size": "2000",
    "max-size": "500m",
    "keep-file": "true",
    "max-file": "1"
  }
}
EOF

# PROMTAIL CONFIG

sudo rm -rf /etc/docker/promtail
sudo cp -r promtail /etc/docker/promtail
sudo chmod 655 /etc/docker/promtail/entry.sh

sudo echo "${LOKI_URL}" > /etc/docker/promtail/LOKI_URL
sudo echo "${HOST}" > /etc/docker/promtail/HOST

# PROMETHEUS CONFIG

sudo mkdir -p /etc/docker/prometheus
sudo cat << EOF > /etc/docker/prometheus/prometheus.yml
global:
    scrape_interval:     20s
    evaluation_interval: 20s

remote_write:
  - url: "${CORTEX_URL}"
    remote_timeout: 10s
    queue_config:
      capacity: 500
      max_shards: 1000
      max_samples_per_send: 100
      batch_send_deadline: 20s
      min_backoff: 100ms
      max_backoff: 5s

scrape_configs:
  - job_name: 'Host Metrics'
    scrape_interval:     20s
    static_configs:
      - targets: ['node_exporter:9100']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

  - job_name: 'Traefik'
    scrape_interval:     20s
    static_configs:
      - targets: ['traefik:8082']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

  - job_name: 'cAdvisor'
    scrape_interval:     20s
    static_configs:
      - targets: ['cadvisor:8080']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

EOF
