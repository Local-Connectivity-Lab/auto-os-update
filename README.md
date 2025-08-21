Currently I have put scripts in here that will be run automatically on a schedule on a host itself. For example, backups and software updates. 

There is a trade off between automation and availability for example if a service goes down because it was not ready for a software update that happened. A mitigation to this is to have an operator be alerted on their phone when an upgrade does happen so at least they are aware when it does happen so if people complain to them, they can remember they got notified that an update happened. I have implemented this as a discord


There are two scripts. The os packages update script will be run on a cron probably once per week to do a packages update and reboot. It will report its success status to discord. The other is a script that can be run when the service comes back up from being rebooted

## Installation
This is how I did the alpine one at least

- First establish the home directory on the server. If you are the root user, it will be `/root`. If you are logged in as another user, it will be `/home/<your_username>`
- copy `os_packages_update.sh` file to the home dir on the server. If you are using debian or ubuntu, put a line at the top `#!/bin/bash`. If you are on alpine put this line at the top `#!/bin/sh`
- chmod +x it
- create a file `software_update_discord_webhook_url` in the home dir.
- Put the workflow URL in the file as one line. This is a discord workflow URL, it gives permissions to post in a certain discord channel that the workflow is in. 
- If you are on Alpine, install `coreutils` apk package or else the timestamp will not show the miliseconds correctly.
- Run the command once to make sure everything is working `./os_packages_update.sh`. Note, the last reboot message will not show up on discord yet.
- Then put this in a crontab to run once per week. `crontab -e` should work, put a line at the bottom with a cron expression of `0 3 * * 6` but you can pick the hour (this example uses 3 as the hour of the day) and choose the day (This example uses 6 as the day of the week). The command should be the same command you ran above
- For this step we want to run a command on start up to tell discord that the server is up. This will vary depending on the OS
  - On alpine: put the `reboot_verify.sh` script in `/etc/local.d/` and change the suffix from `.sh` to `.start`. Also put a line at the top `#!/bin/sh` Then run `rc-update add local`
  - On Ubuntu, you can put the `reboot_verify.sh` script in the home dir, and add put a line at the top `#!/bin/bash`. Also add a line to the crontab (so run `crontab -e` again) `@reboot ./reboot_verify.sh`
- chmod +x the reboot verify script
- Run the os update script again like you did previously to verify that the reboot message shows up on discord at the end
