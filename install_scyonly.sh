#!/usr/bin/env bash

# Loop that repeats the apt_get_with_lock command until the lock file is released
# It must be double here, because i include this file in other script directly.
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo 'Lock file is in use. Waiting 3 seconds...'
  sleep 3
done

##############################################################################
# Pheme Installer / DO NOT USE THIS OPTION
##############################################################################

cat <<EOF
***************************************************************************
            Pheme $set_pheme_version Installation
***************************************************************************

For more verbose logs, open up a second terminal and use the following command:

tail -f $installerHome/pheme_installer.log
EOF

echo -en "
***********************************************************************
You used the install option --install_scyonly.
This install option will not work on your side.

Please use --install to install Pheme's latest Stable Release $set_pheme_version.
***********************************************************************

"

# prepare_system
echo -en "\n- 1/11 prepare_system\n"
source misc/prepare_system.sh &>>"${LOG_FILE}"

# setup_pheme_user
echo -en "\n- 2/11 setup_pheme_user\n"
source pheme/user.sh &>>"${LOG_FILE}"

# setup_mariadb
echo -en "\n- 3/11 setup_mariadb\n"
source mariadb/setup.sh &>>"${LOG_FILE}"

# setup_stations
echo -en "\n- 4/11 setup_stations\n"
source stations/setup.sh &>>"${LOG_FILE}"

# setup_web
echo -en "\n- 5/11 setup_web\n"
source web/setup.sh &>>"${LOG_FILE}"

# setup_sftpgo
echo -en "\n- 6/11 setup_sftpgo\n"
source sftpgo/setup.sh &>>"${LOG_FILE}"

# setup_redis
echo -en "\n- 7/11 setup_redis\n"
source redis/setup.sh &>>"${LOG_FILE}"

# setup_supervisor
echo -en "\n- 8/11 setup_supervisor\n"
source supervisor/setup.sh &>>"${LOG_FILE}"

# setup_pheme_install
echo -en "\n- 9/11 setup_pheme_install\n"
source pheme/install.sh &>>"${LOG_FILE}"

# Just check permissions again
echo -en "\n- 10/11 Set Pheme Permissions\n"
chown -R pheme.pheme /var/pheme &>>"${LOG_FILE}"

# Update and Upgrade System again
echo -en "\n- 11/11 Set Pheme Permissions\n"
source misc/finalize.sh &>>"${LOG_FILE}"

echo -en "
***************************************************************************
  MySQL Details
  - MySQL "Pheme" DB Name: $set_pheme_database
  - MySQL "Pheme" DB User: $set_pheme_username
  - MySQL "Pheme" DB Password: $set_pheme_password
***************************************************************************\n
" | tee /root/credentials/credentials_pheme.txt

echo -en "\n- End - Forward with main installer\n"
