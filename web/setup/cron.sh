#!/usr/bin/env bash

# Set variables for the crontab file and the specified jobs
CRONTAB_FILE=/etc/cron.d/pheme_user
SYNC_JOB="* * * * * pheme php /var/pheme/www/bin/console pheme:sync:run"
CLEAR_JOB="0 0 * * * pheme php /var/pheme/www/bin/console pheme:station-queues:clear"
TEMPREAPER_JOB="0 */6 * * * pheme tmpreaper 12h /var/pheme/stations/*/temp"

# Populate the crontab with the specified jobs
echo -e "$SYNC_JOB\n$CLEAR_JOB\n$TEMPREAPER_JOB" >$CRONTAB_FILE

# Set the appropriate permissions for the crontab file
chown root.root $CRONTAB_FILE

# Disable and stop service due to Pheme's Supervisor integration
systemctl disable cron
