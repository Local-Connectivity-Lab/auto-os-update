#!/bin/sh

WEBHOOK_URL="$(cat /root/webhook_url)"

timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] Reboot successful\"}" $WEBHOOK_URL