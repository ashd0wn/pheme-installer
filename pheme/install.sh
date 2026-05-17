#!/usr/bin/env bash

##############################################################################
# setup_pheme_install
##############################################################################

# Clone and checkout Pheme stable branch
su pheme <<SUEOF
    git clone https://github.com/ashd0wn/pheme.git /var/pheme/www
    git -C /var/pheme/www checkout -f ${set_pheme_version}-org
    composer --working-dir=/var/pheme/www install --no-dev --no-ansi --no-interaction
SUEOF

# Permissions
find /var/pheme/www -type d -exec chmod 755 {} \;
find /var/pheme/www -type f -exec chmod 644 {} \;

# Écrire env.ini
cat > /var/pheme/www/env.ini << ENVEOF

;
; Pheme Environment Settings
;

[configuration]
application_env = production
MYSQL_HOST = localhost
MYSQL_PORT = 3306
MYSQL_USER = phemeMySQLUsername
MYSQL_DB = phemeMySQLDatabase
MYSQL_PASSWORD = phemeMySQLPassword
ENVEOF

sed -i "s/phemeMySQLDatabase/$set_pheme_database/g" /var/pheme/www/env.ini
sed -i "s/phemeMySQLUsername/$set_pheme_username/g" /var/pheme/www/env.ini
sed -i "s/phemeMySQLPassword/$set_pheme_password/g" /var/pheme/www/env.ini

chmod 0640 /var/pheme/www/env.ini
chown pheme:pheme /var/pheme/www/env.ini

# Démarrer Redis
supervisorctl restart redis

# Démarrer MariaDB via systemd
systemctl start mariadb

# Attendre que MariaDB soit prêt
echo -en "\n- Attente MariaDB...\n"
for i in $(seq 1 30); do
    if mariadb-admin ping --silent 2>/dev/null; then
        echo "MariaDB pret apres ${i}s"
        break
    fi
    sleep 1
done

# Lancer la migration
# install.sh est sourcé donc on exporte les vars dans le shell courant
# puis on les passe explicitement à PHP via env(1)
export PHEME_DB_HOST="localhost"
export PHEME_DB_PORT="3306"
export PHEME_DB_USER="$set_pheme_username"
export PHEME_DB_NAME="$set_pheme_database"
export PHEME_DB_PASS="$set_pheme_password"

env \
    MYSQL_HOST="$PHEME_DB_HOST" \
    MYSQL_PORT="$PHEME_DB_PORT" \
    MYSQL_USER="$PHEME_DB_USER" \
    MYSQL_DB="$PHEME_DB_NAME" \
    MYSQL_PASSWORD="$PHEME_DB_PASS" \
    APPLICATION_ENV=production \
    php /var/pheme/www/bin/console pheme:setup:migrate

# Passer le relais à Supervisor
systemctl stop mariadb
sleep 2
supervisorctl start mariadb

# Build frontend
echo -en "\n- Build Pheme\n"
source pheme/build.sh || { echo "Error sourcing build.sh"; exit 1; }

# Set ulimit
echo -en "\n- Set ulimit\n"
source pheme/ulimit.sh || { echo "Error sourcing ulimit.sh"; exit 1; }

# Configure logs
echo -en "\n- Set Pheme Logs\n"
source pheme/logs.sh || { echo "Error sourcing logs.sh"; exit 1; }
