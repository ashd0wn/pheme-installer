#!/usr/bin/env bash

##############################################################################
# setup_mariadb
##############################################################################

apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

# Install MariaDB from official repo
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"

apt_get_with_lock install -y mariadb-server mariadb-client

# Démarrer MariaDB pour les opérations initiales
systemctl start mariadb

# Créer la base et l'utilisateur AVANT de changer le mot de passe root
mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`$set_pheme_database\` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mysql -u root -e "CREATE USER IF NOT EXISTS '$set_pheme_username'@'localhost' IDENTIFIED BY '$set_pheme_password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON \`$set_pheme_database\`.* TO '$set_pheme_username'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Sécuriser MySQL root EN DERNIER
sed -i "s/changeToMySQLRootPW/$mysql_root_pass/g" mariadb/config/mysql_secure_installation.sql
mysql -u root < "mariadb/config/mysql_secure_installation.sql"

# Disable systemd service — Pheme uses Supervisor
systemctl disable mariadb
systemctl stop mariadb
