#!/usr/bin/env bash

##############################################################################
# setup_pheme_user
##############################################################################

# Install required packages
apt_get_with_lock install -y --no-install-recommends sudo

# Add user
adduser --home /var/pheme --disabled-password --gecos "" pheme
usermod -aG www-data pheme

# Define base directory
BASE_DIR="/var/pheme"

# Create directories
mkdir -p $BASE_DIR/{www,stations,servers/{shoutcast2,stereo_tool},backups,www_tmp,uploads,geoip,dbip,centrifugo,sftpgo/{persist,backups},acme,logs}

# Adjust permissions
chmod -R 777 $BASE_DIR/www_tmp

# Set ownership
chown -R pheme:pheme $BASE_DIR
