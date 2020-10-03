#!/bin/bash

export $(cat .env | xargs)

hostnamectl set-hostname ${HOST}

# LOKI DOCKER DRIVER CONFIG

cat << EOF > /etc/docker/daemon.json
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

# PROMETHEUS CONFIG

mkdir -p /etc/docker/prometheus
cat << EOF > /etc/docker/prometheus/prometheus.yml
global:
    scrape_interval:     40s
    evaluation_interval: 40s

remote_write:
  - url: "${CORTEX_URL}"
    remote_timeout: 10s
    queue_config:
      capacity: 100
      max_shards: 300
      max_samples_per_send: 35
      batch_send_deadline: 20s
      min_backoff: 100ms
      max_backoff: 5s

scrape_configs:
  - job_name: 'Host Metrics'
    static_configs:
      - targets: ['node_exporter:9100']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

  - job_name: 'Traefik'
    static_configs:
      - targets: ['traefik:8082']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

  - job_name: 'cAdvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

EOF

cat << EOF > /etc/docker/prometheus/prometheus-lite.yml
global:
    scrape_interval:     60s
    evaluation_interval: 60s

remote_write:
  - url: "${CORTEX_URL}"
    remote_timeout: 10s
    queue_config:
      capacity: 100
      max_shards: 300
      max_samples_per_send: 35
      batch_send_deadline: 20s
      min_backoff: 100ms
      max_backoff: 5s

scrape_configs:
  - job_name: 'cAdvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '${HOST}'

EOF
