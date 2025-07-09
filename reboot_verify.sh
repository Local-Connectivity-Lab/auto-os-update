set -e
set -u
set -o pipefail
set -x

WEBHOOK_URL="$(cat ./software_update_discord_webhook_url)"

if [ -f ./planned_update_flag ]; then
  rm ./planned_update_flag
else
  exit 0
fi

timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] Reboot successful\"}" $WEBHOOK_URL
