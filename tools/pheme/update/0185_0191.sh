#!/usr/bin/env bash

##############################################################################
# This script will update Pheme from version 0.18.5 Stable to 0.19.1 Stable.
# Please note that this update process is designed for users who have previously used this installer for version 0.18.5 Stable.
# If you are upgrading from older versions, you should upgrade them one by one. For example, upgrade from 0.17.6 to 0.18.5 and then to 0.19.1.
##############################################################################

# Define the old and new versions
oldVersion="0.18.5"
newVersion="0.19.1"

# Prompt the user to confirm the update
echo -e "\n---\n"
read -rp "Do you have a backup of your installation? (yes or no): " yn_one
echo
read -rp "Do you really want to upgrade to Pheme Stable $newVersion? (yes or no): " yn_two

# Ensure user has given correct confirmation
if [[ "$yn_one" != "yes" && "$yn_one" != "scy" ]] || [[ "$yn_two" != "yes" && "$yn_two" != "scy" ]]; then
    echo "Error: Your answers were not correct."
    exit 1
fi

# Include external script
source tools/apt_get_with_lock.sh || { echo "Error sourcing apt_get_with_lock.sh"; exit 1; }

# Check for Pheme version compatibility
azv=/var/pheme/www/src/Version.php
if [ -f "$azv" ]; then
    FALLBACK_VERSION="$(grep -oE "FALLBACK_VERSION = '.*';" "$azv" | sed "s/FALLBACK_VERSION = '//g;s/';//g")"
    echo -e "Pheme Version $FALLBACK_VERSION will be upgraded to $newVersion\n"
    
    if [ "$FALLBACK_VERSION" != "$oldVersion" ]; then
        echo "Invalid Pheme version. Exiting the script."
        exit 1
    fi
fi

# Copy some files from old version to new version
echo -e "Copy new Centrifugo config\n"
cp web/centrifugo/config.json /var/pheme/centrifugo/config.json

echo -e "Copy new Pheme config\n"
cp web/nginx/pheme.conf /etc/nginx/sites-available/pheme.conf

echo -e "Copy new Nginx config\n"
cp web/nginx/nginx.conf /etc/nginx/nginx.conf

# Backup the current Pheme version
CURRENT_DATE=$(date +%Y%m%d)  # Fetching current date
BACKUP_FILENAME="${FALLBACK_VERSION}_${CURRENT_DATE}.zip"
chmod +x /var/pheme/www/bin/console
/var/pheme/www/bin/console pheme:backup "$installerHome/tools/pheme/update/backup/$BACKUP_FILENAME"
echo -e "Backup of $FALLBACK_VERSION is located in $installerHome/tools/pheme/update/backup/$BACKUP_FILENAME\n"

# Update system packages
export DEBIAN_FRONTEND=noninteractive
apt_get_with_lock update
apt_get_with_lock upgrade -y

# Stop services before updating
systemctl stop zabbix-agent || :
supervisorctl stop all || :

# Clean and prepare Pheme for the update
rm -rf /var/pheme/www_tmp/*
chown -R pheme.pheme /var/pheme

# Update Pheme
CHECKOUT_VERSION="$newVersion-$( [[ $yn_one == "yes" ]] && echo "org" || echo "scy" )"
su pheme <<EOF
cd /var/pheme/www
git stash
git pull
git checkout $CHECKOUT_VERSION
cd /var/pheme/www/frontend
export NODE_ENV=production
npm ci --include=dev
npm run build
EOF

# Refresh supervisor configs and restart necessary services
cd $installerHome
supervisorctl reread
supervisorctl update
supervisorctl restart all || :

# Migrate database
chmod +x /var/pheme/www/bin/console
/var/pheme/www/bin/console pheme:setup:migrate

# Update Pheme version file
echo "$newVersion" >| /var/pheme/pheme_version.txt

# Ensure correct permissions post update
chown -R pheme.pheme /var/pheme

# Upgrade to latest version 0.19.1 is complete
echo -e "\nUpgrade is Done\n"

# Upgrade Liquidsoap
echo -e "\nNow we will upgrade Liquidsoap\n"

# Update Liquidsoap to latest Version
source tools/liquidsoap/update_latest.sh || { echo "Error sourcing tools/liquidsoap/update_latest.sh"; exit 1; }

# Notify the user that the update is complete
echo -e "\nLiquidsoap Upgrade is also Done\n"