#!/bin/bash
set -e
set -u
set -o pipefail
set -x

webhook_url="<insert here>"

send_message() {
	local timestamp=$(date +'%Y-%m-%dT%H:%M:%S.%3N%:z')

	local response=$(curl -s -w "\n%{http_code}" -H "Content-Type: application/json" -X POST -d "{\"content\": \"[$timestamp] $1\"}" $webhook_url)
	local body=$(echo "$response" | sed '$d')
	local status=$(echo "$response" | tail -n1)

	if [ "$status" -ne 204 ]; then
		curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"Error trying to send message\"}" $webhook_url
  		exit 1
	fi
}

run_command() {
	local message="$1"

	send_message "running \`$message\`..."

	eval "$message"

        send_message "\`$message\` succeeded"
}

send_message "Initiating update sequence for penguin <@405064409396805632>"
run_command "sudo apt update"
run_command "sudo apt upgrade -y"
run_command "sudo apt autoremove -y"
send_message "Now make sure this server is shut down"
