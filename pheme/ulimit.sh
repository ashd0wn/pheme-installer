#!/usr/bin/env bash

# Add 'nofile' limits for user 'pheme' to /etc/security/limits.conf
sudo bash -c '
echo -e "\n# Limits for user pheme"
echo "pheme soft nofile 65536"
echo "pheme hard nofile 65536"
' >> /etc/security/limits.conf
