# scn-automation
Currently I have put scripts in here that will be run automatically on a schedule on a host itself. For example, backups and software updates. 

There is a trade off between automation and availability for example if a service goes down because it was not ready for a software update that happened. A mitigation to this is to have an operator be alerted on their phone when an upgrade does happen so at least they are aware when it does happen so if people complain to them, they can remember they got notified that an update happened. I have implemented this as a discord

Each folder contains a 3 tuple: The OS name, the package manager name, and the shell implementation

In each folder contains two scripts. The os packages update script will be run on a cron probably once per week to do a packages update and reboot. It will report its success status to discord. The other is a script that can be run when the service comes back up from being rebooted

## Installation
This is how I did the alpine one at least

- copy `os_packages_update.sh` to `/root/`
- chmod +x it
- create a file somewhere, lets say `/root/` and call it `webhook_url`
- Put the workflow URL in the file as one line. This is a discord workflow URL, it gives permissions to post in a certain discord channel that the workflow is in. 
- run the command once to make sure everything is working `WEBHOOK_URL_FILE=/root/webhook_url ash /root/os_packages_update.sh`
- Then put this in a crontab to run once per week. `crontab -e` should work, put a line at the bottom with a cron expression of "0 3 * * 6" but you can pick the hour (chose three in this case) and choose the day (chose the 6 day of the week in this case). The command should be the same command you ran above
- put the `reboot_verify.sh` script in `/etc/local.d/` and change the suffix from `.sh` to `.start`
- change `/root/webhook_url` in that file to the workflow file path that you have chosen. If that is it, then cool, I guess you do not have to modify anything.
- chmod +x it
- run `rc-update add local`
- Test a reboot to see if the discord message works
