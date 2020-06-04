#!/bin/bash

set -eo pipefail
shopt -s nullglob

export CLIENT_URL="$(< "/etc/promtail/CLIENT_URL")"
export HOST="$(< "/etc/promtail/HOST")"

/usr/bin/promtail -client.url="$CLIENT_URL" -client.external-labels=host="${HOST}","${LABELS}" "$@"
