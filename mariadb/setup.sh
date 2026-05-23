#!/usr/bin/env bash

##############################################################################
# setup_mariadb
# Etape 3 — Supervisor pas encore installé, on utilise systemctl
##############################################################################

source "$installerHome/.pheme_credentials"

apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

# Install MariaDB
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"
apt_get_with_lock install -y mariadb-server mariadb-client

# Démarrer via systemctl pour cette étape
systemctl start mariadb

# Attendre que MariaDB soit prêt
echo "Attente MariaDB..."
for i in $(seq 1 30); do
    if mariadb-admin ping --silent 2>/dev/null; then
        echo "MariaDB pret apres ${i}s"
        break
    fi
    sleep 1
done

# Créer la base et l'utilisateur
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$PHEME_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mariadb -u root -e "CREATE USER IF NOT EXISTS '$PHEME_DB_USER'@'localhost' IDENTIFIED BY '$PHEME_DB_PASS';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON \`$PHEME_DB_NAME\`.* TO '$PHEME_DB_USER'@'localhost';"
mariadb -u root -e "FLUSH PRIVILEGES;"

# Vérifier la connexion
if mariadb -u "$PHEME_DB_USER" -p"$PHEME_DB_PASS" -e "SELECT 1;" "$PHEME_DB_NAME" &>/dev/null; then
    echo "Connexion user OK : $PHEME_DB_USER"
else
    echo "ERREUR: connexion impossible avec $PHEME_DB_USER"
    exit 1
fi

# Sécuriser root EN DERNIER
sed -i "s/changeToMySQLRootPW/$PHEME_MYSQL_ROOT_PASS/g" "$installerHome/mariadb/config/mysql_secure_installation.sql"
mariadb -u root < "$installerHome/mariadb/config/mysql_secure_installation.sql"

# Désactiver systemd et stopper MariaDB PROPREMENT
# Supervisor prendra le relais à l'étape 8
systemctl disable mariadb
systemctl stop mariadb
pkill -f mysqld 2>/dev/null || true
sleep 2
