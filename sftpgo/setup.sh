#!/usr/bin/env bash

# Add SFTPGo PPA repository
add-apt-repository -y ppa:sftpgo/sftpgo

# Update package lists
apt_get_with_lock update

# Install SFTPGo
apt_get_with_lock install -y --no-install-recommends sftpgo

# Copy the SFTPGo configuration file to the appropriate directory
cp sftpgo/config/sftpgo.json /var/pheme/sftpgo/sftpgo.json

# Create an empty SFTPGo database file and set the ownership to pheme user
touch /var/pheme/sftpgo/sftpgo.db
chown -R pheme:pheme /var/pheme/sftpgo

# Generate SSH keys if they don't exist and set the ownership to pheme user
if [[ ! -f /var/pheme/sftpgo/persist/id_rsa ]]; then
    ssh-keygen -t rsa -b 4096 -f /var/pheme/sftpgo/persist/id_rsa -q -N ""
fi

if [[ ! -f /var/pheme/sftpgo/persist/id_ecdsa ]]; then
    ssh-keygen -t ecdsa -b 521 -f /var/pheme/sftpgo/persist/id_ecdsa -q -N ""
fi

if [[ ! -f /var/pheme/sftpgo/persist/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -f /var/pheme/sftpgo/persist/id_ed25519 -q -N ""
fi

chown -R pheme:pheme /var/pheme/sftpgo/persist

# Disable and stop the SFTPGo service due to Pheme's Supervisor integration
systemctl disable sftpgo
systemctl stop sftpgo
