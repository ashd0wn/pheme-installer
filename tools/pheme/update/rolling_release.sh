#!/usr/bin/env bash

##############################################################################
# This script will update Pheme to its latest Rolling Release.
# Please note that this is a simple update script and not an upgrade script.
# If the Pheme developers add new dependencies, you will have to install them manually.
# This script will only update Pheme's files itself.
##############################################################################

# Prompt the user to confirm the update
echo -e "\n\n---\n\n"

echo "Before we proceed:"
echo "1. Have you taken a backup of your installation?"
read -rp "Enter 'yes' or 'no': " yn_one
echo

echo "2. Are you sure you want to upgrade to the latest Pheme Rolling Release?"
read -rp "Enter 'yes' or 'no': " yn_two
echo

echo
echo "3. Have you updated the installer using the following command?"
echo "./install.sh --upgrade_installer"
read -rp "Enter 'y' for yes or 'n' for no: " yn_three

# Ensure user has given correct confirmation
if [[ "$yn_one" != "yes" ]] || [[ "$yn_two" != "yes" ]] || [[ "$yn_three" != "yes" ]]; then
    echo "Error: Your answers were not correct."
    exit 1
fi

# Include external script
source tools/apt_get_with_lock.sh || { echo "Error sourcing apt_get_with_lock.sh"; exit 1; }

# Backup the current Pheme version
FALLBACK_VERSION=$(cat /var/pheme/pheme_version.txt)
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
su pheme <<EOF
cd /var/pheme/www
git stash
git pull
git checkout main
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
echo "rolling" >| /var/pheme/pheme_version.txt

# Ensure correct permissions post update
chown -R pheme.pheme /var/pheme
