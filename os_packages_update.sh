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

if [ -z "$UPDATE_FLAG_PATH" ]; then
  echo "UPDATE_FLAG_PATH needs to be set as an env var"
  exit 1
fi

WEBHOOK_URL="$(cat "$WEBHOOK_URL_FILE")"

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
if grep -qi 'ubuntu' /etc/os-release || grep -qi 'id=debian' /etc/os-release; then
    run_command "sudo apt update"
    run_command "sudo apt upgrade -y"
    run_command "sudo apt autoremove -y"
elif grep -qi 'alpine' /etc/os-release; then
    run_command "apk update"
    run_command "apk upgrade"
else
    echo "Unknown OS"
    exit 1
fi
touch $UPDATE_FLAG_PATH
send_message "Running reboot command. If a 'reboot successful' message does not appear after this, something whent wrong on reboot"
reboot
