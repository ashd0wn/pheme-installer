#!/usr/bin/env bash

##############################################################################
# setup_mariadb
##############################################################################

# Charger les credentials depuis le fichier généré
source "$installerHome/.pheme_credentials"

apt_get_with_lock install -y wget software-properties-common dirmngr ca-certificates apt-transport-https

# Install MariaDB
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$set_mariadb_version"
apt_get_with_lock install -y mariadb-server mariadb-client

# Démarrer via systemd
systemctl start mariadb
systemctl enable mariadb

# Attendre que MariaDB soit prêt
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
    echo "ERREUR: impossible de se connecter avec $PHEME_DB_USER"
    exit 1
fi

# Sécuriser root EN DERNIER
sed -i "s/changeToMySQLRootPW/$PHEME_MYSQL_ROOT_PASS/g" mariadb/config/mysql_secure_installation.sql
mariadb -u root < "mariadb/config/mysql_secure_installation.sql"

# Désactiver systemd — Supervisor prendra le relais
systemctl disable mariadb
systemctl stop mariadb
sleep 2
pkill -f mysqld 2>/dev/null || true
sleep 1
