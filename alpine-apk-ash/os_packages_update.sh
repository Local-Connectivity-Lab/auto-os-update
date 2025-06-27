

set -e
set -u
set -x

if [ -z "${WEBHOOK_URL_FILE:-}" ]; then
  echo "WEBHOOK_URL_FILE needs to be set"
  exit 1
fi

WEBHOOK_URL="$(cat $WEBHOOK_URL_FILE)"

apk add curl

send_message() {
	local timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')

	local response=$(curl -s -w "\n%{http_code}" -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] $1\"}" $WEBHOOK_URL)
	local body=$(echo "$response" | sed '$d')
	local status=$(echo "$response" | tail -n1)

	if [ "$status" -ne 204 ]; then
		curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"Error trying to send message\"}" $WEBHOOK_URL
  		exit 1
	fi
}

run_command() {
	local message="$1"

	send_message "running \`$message\`..."

	eval "$message"

        send_message "\`$message\` succeeded"
}

send_message "Initiating update sequence for $(hostname) <@405064409396805632>"
run_command "apk update"
run_command "apk upgrade"
send_message "running reboot command. Hopefully the reboot will be successful"
reboot
