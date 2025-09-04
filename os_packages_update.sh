#!/bin/bash

set -e
set -u
set -o pipefail

exec >> /var/log/os_packages_update.log 2>&1

echo "Initiating update sequence for $(hostname)"
if grep -qi 'ubuntu' /etc/os-release || grep -qi 'id=debian' /etc/os-release; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
elif grep -qi 'alpine' /etc/os-release; then
    apk update
    apk upgrade
else
    echo "Unknown OS"
    exit 1
fi

touch ./.planned_update_flag
echo Running reboot command. If a 'reboot successful' message does not appear after this, something whent wrong on reboot
if [ $(pwd) = "/root" ]; then
  reboot
else
  sudo reboot
fi
