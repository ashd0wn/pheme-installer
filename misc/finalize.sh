#!/usr/bin/env bash

# Charger les credentials
source "$installerHome/.pheme_credentials"

# Update packages
apt_get_with_lock update
apt_get_with_lock install -yf
apt_get_with_lock upgrade -y
apt_get_with_lock autoremove -y

# Write installed version
echo "$set_pheme_version" > "/var/pheme/pheme_version.txt"
chown pheme:pheme "/var/pheme/pheme_version.txt"

# Pheme ENV Variables
ENV_FILE=/var/pheme/www/pheme.env
touch "$ENV_FILE"
chown pheme:pheme "$ENV_FILE"
echo "ENABLE_WEB_UPDATER=false" >> "$ENV_FILE"

# Sauvegarder les credentials dans pheme_details.txt
cat > "$installerHome/pheme_details.txt" << DETAILSEOF
Pheme $set_pheme_version — Installation Details
================================================
URL Panel      : http://$(hostname -I | awk '{print $1}')
DB Name        : $PHEME_DB_NAME
DB User        : $PHEME_DB_USER
DB Password    : $PHEME_DB_PASS
DB Root Pass   : $PHEME_MYSQL_ROOT_PASS
DETAILSEOF

chmod 600 "$installerHome/pheme_details.txt"
echo "Credentials sauvegardés dans $installerHome/pheme_details.txt"

# Supprimer le fichier credentials temporaire
rm -f "$installerHome/.pheme_credentials"
