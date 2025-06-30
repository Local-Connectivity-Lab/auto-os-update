#!/bin/sh

set -e
set -u
set -o pipefail
set -x

if [ -z "$WEBHOOK_URL_FILE" ]; then
  echo "WEBHOOK_URL_FILE needs to be set as an env var"
  exit 1
fi

if [ ! -s "$WEBHOOK_URL_FILE" ]; then
  echo "$WEBHOOK_URL_FILE does not exist or is empty"
  exit 1
fi

WEBHOOK_URL="$(cat "$WEBHOOK_URL_FILE")"


if [ -f /root/planned_update_flag ]; then
  rm /root/planned_update_flag
else
  exit 0
fi

timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] Reboot successful\"}" $WEBHOOK_URL
