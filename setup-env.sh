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
    "loki-pipeline-stage-file": "/etc/docker/loki/pipeline.yml",
    "max-size": "50m",
    "keep-file": "true",
    "max-file": "1"
  }
}
EOF

#LOKI PIPELINE STAGES FILE
mkdir -p /etc/docker/loki
cat << EOF > /etc/docker/loki/pipeline.yml
pipeline_stages:
- regex:
     expression: '.*'
- labels:
    filename: '/var/log/docker/*.json'
EOF

# GRAFANA AGENT CONFIG
mkdir -p /etc/docker/grafana-agent
cat << EOF > /etc/docker/grafana-agent/grafana-agent.yml
server:
  log_level: debug
  http_listen_port: 12345

prometheus:
  global:
    scrape_interval: 30s
    remote_write:
        - url: "${CORTEX_URL}"
  configs:
    - name: prometheus
      host_filter: false
      scrape_configs:
        - job_name: 'Traefik'
          static_configs:
            - targets: ['traefik:8082']
              labels:
                cluster: 'docker_compose'
                container: 'traefik'
          relabel_configs:
            - source_labels: [__address__]
              regex: '.*'
              target_label: instance
              replacement: '${HOST}'

        - job_name: 'cAdvisor'
          static_configs:
            - targets: ['cadvisor:8080']
              labels:
                cluster: 'docker_compose'
                container: 'cAdvisor'
          relabel_configs:
            - source_labels: [__address__]
              regex: '.*'
              target_label: instance
              replacement: '${HOST}'

integrations:
  node_exporter:
    enabled: true
    scrape_integration: true
    rootfs_path: /host/root
    sysfs_path: /host/sys
    procfs_path: /host/proc
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: ${HOST}
    disable_collectors:
      - arp
      - bcache
      - bonding
      - conntrack
      - edac
      - entropy
      - filefd
      - infiniband
      - mdadm
      - nfs
      - nfsd
      - pressure
      - rapl
      - schedstat
      - sockstat
      - softnet
      - stat
      - thermal_zone
      - timex
      - vmstat
      - xfs
      - zfs

loki:
  configs:
  - name: default
    positions:
      filename: /tmp/positions.yaml
    clients:
      - url: "${LOKI_URL}"
    scrape_configs:
    - job_name: system
      static_configs:
        - targets:
          - localhost
          labels:
            job: varlogs
            __path__: /var/log/*log

EOF

