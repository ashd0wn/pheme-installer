#!/usr/bin/env bash

##############################################################################
# setup_mariadb
##############################################################################

# It seems that Azuracat is actually need MariaDB 10.9? Actual default Ubuntu version is 10.6
apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

if [ "$pheme_git_version" = "stable" ] || [ "$pheme_git_version" = "rolling" ]; then
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"
else
    apt_get_with_lock install software-properties-common gnupg2 -y
    apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    add-apt-repository -y 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.8/ubuntu jammy main'
    apt_get_with_lock update -y
fi

apt_get_with_lock install -y mariadb-server mariadb-client

# Create Pheme DB
mysql -e "create database $set_pheme_database character set utf8mb4 collate utf8mb4_bin;"
mysql -e "create user $set_pheme_username@localhost identified by '$set_pheme_password';"
mysql -e "grant all privileges on $set_pheme_database.* to $set_pheme_username@localhost;"

# Prepare MySQL-Root-Password
if [ "$pheme_git_version" = "stable" ] || [ "$pheme_git_version" = "rolling" ]; then
    sed -i "s/changeToMySQLRootPW/$mysql_root_pass/g" mariadb/config/mysql_secure_installation.sql

    # Secure MySQL in same way like: mysql_secure_installation
    mysql -sfu root <"mariadb/config/mysql_secure_installation.sql"
else
    echo "do nothing, will do it later in another way"
fi

# Because of Phemes Supervisor Integration
systemctl disable mariadb
systemctl stop mariadb
