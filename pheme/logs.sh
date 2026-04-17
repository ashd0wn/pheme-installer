#!/usr/bin/env bash

##############################################################################
# Pheme is storing the Logfiles in www_tmp with much other files.
# I personally like it, when everything is somewhat in order.
##############################################################################

# supervisord
rm -f /var/pheme/www_tmp/supervisord.log
ln -s /var/pheme/logs/supervisord.log /var/pheme/www_tmp/supervisord.log

# nginx
rm -f /var/pheme/www_tmp/access.log
ln -s /var/pheme/logs/service_nginx_access.log /var/pheme/www_tmp/access.log

rm -f /var/pheme/www_tmp/error.log
ln -s /var/pheme/logs/service_nginx_error.log /var/pheme/www_tmp/error.log

# php
rm -f /var/pheme/www_tmp/php_errors.log
ln -s /var/pheme/logs/service_php_fpm.log /var/pheme/www_tmp/php_errors.log
