#!/usr/bin/env bash

##############################################################################
# setup_mariadb
##############################################################################

apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

# Install MariaDB
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"
apt_get_with_lock install -y mariadb-server mariadb-client

# Démarrer via systemd pour l'initialisation
systemctl start mariadb
systemctl enable mariadb

# Attendre que MariaDB soit vraiment prêt
for i in $(seq 1 30); do
    if mariadb-admin ping --silent 2>/dev/null; then
        echo "MariaDB pret apres ${i}s"
        break
    fi
    sleep 1
done

# Créer la base et l'utilisateur
# Sur MariaDB 11.x le root se connecte via unix_socket par défaut
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$set_pheme_database\` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mariadb -u root -e "CREATE USER IF NOT EXISTS '$set_pheme_username'@'localhost' IDENTIFIED BY '$set_pheme_password';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON \`$set_pheme_database\`.* TO '$set_pheme_username'@'localhost';"
mariadb -u root -e "FLUSH PRIVILEGES;"

# Vérifier que le user peut se connecter
if mariadb -u "$set_pheme_username" -p"$set_pheme_password" -e "SELECT 1;" "$set_pheme_database" &>/dev/null; then
    echo "Connexion user pheme OK"
else
    echo "ERREUR: impossible de se connecter avec le user pheme"
    exit 1
fi

# Sécuriser root EN DERNIER — après avoir tout créé
sed -i "s/changeToMySQLRootPW/$mysql_root_pass/g" mariadb/config/mysql_secure_installation.sql
mariadb -u root < "mariadb/config/mysql_secure_installation.sql"

# Désactiver systemd — Supervisor prendra le relais
systemctl disable mariadb
systemctl stop mariadb

# S'assurer qu'aucun processus MariaDB ne tourne encore
sleep 2
pkill -f mysqld 2>/dev/null || true
sleep 1
