Currently I have put scripts in here that will be run automatically on a schedule on a host itself. For example, backups and software updates. 

There is a trade off between automation and availability for example if a service goes down because it was not ready for a software update that happened. A mitigation to this is to have an operator be alerted on their phone when an upgrade does happen so at least they are aware when it does happen so if people complain to them, they can remember they got notified that an update happened. I have implemented this as a discord


There are two scripts. The os packages update script will be run on a cron probably once per week to do a packages update and reboot. It will report its success status to discord. The other is a script that can be run when the service comes back up from being rebooted

## Installation
This is how I did the alpine one at least

- First establish the home directory on the server. If you are the root user, it will be `/root`. If you are logged in as another user, it will be `/home/<your_username>`
- copy `os_packages_update.sh` file to the home dir on the server. If you are using alpine, also download bash from apk
- chmod +x it
- Then put this in a crontab to run once per week. `crontab -e` should work, put a line at the bottom with a cron expression of `0 3 * * 6` but you can pick the hour (this example uses 3 as the hour of the day) and choose the day (This example uses 6 as the day of the week). The command should be the same command you ran above
- Go to [influx db](influxdb.infra.seattlecommunitynetwork.org) and create a bucket named `$hostname\_os\_updates`. Then go to api tokens, generate a new custom API token named `$hostname_os_updates` and give it permissions to write to the bucket you just created
- For this step we want to run a command on start up to tell discord that the server is up. This will vary depending on the OS
  - On alpine: put the `reboot_verify.sh` script in `/etc/local.d/` and change the suffix from `.sh` to `.start`. Then run `rc-update add local`
    - Also you will have to hardcode the bucket name and the api token since I dont think these script accept env vars
  - On Ubuntu, you can put the `reboot_verify.sh` script in the home dir, Also add a line to the crontab (so run `crontab -e` again) `@reboot BUCKET=<your_bucket_name> API_TOKEN<your_api_token> ./reboot_verify.sh`
- chmod +x the reboot verify script
- Test out running the `os_packages_update` script. It should update your OS packages and then reboot. When it comes back up it should create a metric in influxdb inside your bucket
