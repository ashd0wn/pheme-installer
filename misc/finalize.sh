#!/usr/bin/env bash

# Update package lists and install any missing dependencies
apt_get_with_lock update
apt_get_with_lock install -yf

# Upgrade all packages and dependencies
apt_get_with_lock upgrade -y

# Remove not needed packages
apt_get_with_lock autoremove -y

# Write installed version
echo "$set_pheme_version" > "/var/pheme/pheme_version.txt"
chown pheme:pheme "/var/pheme/pheme_version.txt"

# Pheme ENV Variables — écrit dans /var/pheme/pheme.env (getParentDirectory())
ENV_FILE=/var/pheme/pheme.env
touch "$ENV_FILE"
chown pheme:pheme "$ENV_FILE"
echo "ENABLE_WEB_UPDATER=false" >> "$ENV_FILE"
