#!/usr/bin/env bash

##############################################################################
# setup_mariadb
##############################################################################

apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

# Install MariaDB from official repo
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"

apt_get_with_lock install -y mariadb-server mariadb-client

# Create Pheme database and user
mysql -e "create database $set_pheme_database character set utf8mb4 collate utf8mb4_bin;"
mysql -e "create user $set_pheme_username@localhost identified by '$set_pheme_password';"
mysql -e "grant all privileges on $set_pheme_database.* to $set_pheme_username@localhost;"

# Secure MySQL root password
sed -i "s/changeToMySQLRootPW/$mysql_root_pass/g" mariadb/config/mysql_secure_installation.sql
mysql -sfu root < "mariadb/config/mysql_secure_installation.sql"

# Disable systemd service — Pheme uses Supervisor
systemctl disable mariadb
systemctl stop mariadb
