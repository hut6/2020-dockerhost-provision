#!/bin/bash

set -eo pipefail
shopt -s nullglob

export LOKI_URL="$(< "/etc/promtail/LOKI_URL")"
export HOST="$(< "/etc/promtail/HOST")"

/usr/bin/promtail -client.url="$LOKI_URL" -client.external-labels=host="${HOST}","${LABELS}" "$@"
