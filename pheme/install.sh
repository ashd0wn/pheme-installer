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

# Écrire env.ini dans /var/pheme/www/ (là où le script le trouve toujours)
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

# Passer les credentials directement en variables d'environnement à PHP
# AppFactory::buildEnvironment() fait getenv() — on injecte directement
MYSQL_HOST=localhost \
MYSQL_PORT=3306 \
MYSQL_USER="$set_pheme_username" \
MYSQL_DB="$set_pheme_database" \
MYSQL_PASSWORD="$set_pheme_password" \
APPLICATION_ENV=production \
php /var/pheme/www/bin/console pheme:setup:migrate

# Passer le relais à Supervisor pour MariaDB
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
