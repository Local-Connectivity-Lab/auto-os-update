#!/bin/bash

set -e
set -u
set -o pipefail

exec >> /var/log/os_packages_update.log 2>&1

if [ -z "${BUCKET:-}" ]; then
  echo "Error: Environment variable BUCKET is not set"
  exit 1
fi

if [ -z "${API_TOKEN:-}" ]; then
  echo "Error: Environment variable API_TOKEN is not set"
  exit 1
fi

if [ -f ./.planned_update_flag ]; then
  rm ./.planned_update_flag
else
  exit 0
fi

curl --request POST "https://influxdb.infra.seattlecommunitynetwork.org/api/v2/write?org=scn&bucket=$BUCKET&precision=s" \
  --header "Authorization: Token $API_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --data-binary "measurement success=1"
