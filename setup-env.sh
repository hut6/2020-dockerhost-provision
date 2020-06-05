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

echo "${LOKI_URL}" > /etc/docker/promtail/LOKI_URL
echo "${HOST}" > /etc/docker/promtail/HOST
