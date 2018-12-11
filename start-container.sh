#!/usr/bin/env bash

WORKING_DIR=/var/www/html

if [ ! -z $BASH_NAMES ]; then
    BASH_ARR=(${BASH_NAMES//,/ })
    for i in ${BASH_ARR[@]}
    do
        if [ -f "${WORKING_DIR}/${i}" ]; then
            bash "${WORKING_DIR}/${i}"
        fi
    done
fi

composer config -g repo.packagist composer https://packagist.laravel-china.org
chown -R root:crontab /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root
touch /var/log/cron.log
/etc/init.d/cron start

sed -i "s/xdebug\.remote_host\=.*/xdebug\.remote_host\=$XDEBUG_HOST/g" /etc/php/$PHP_VERSION/mods-available/xdebug.ini
sed -i 's/;daemonize = yes/daemonize = no/g'  /etc/php/$PHP_VERSION/fpm/php-fpm.conf

if [ ! "production" == "$APP_ENV" ] && [ ! "prod" == "$APP_ENV" ] && [ ! "" == "$APP_ENV" ]; then
    # Enable xdebug

    ## FPM
    ln -sf /etc/php/$PHP_VERSION/mods-available/xdebug.ini /etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini

    ## CLI
    ln -sf /etc/php/$PHP_VERSION/mods-available/xdebug.ini /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini
else
    # Disable xdebug

    ## FPM
    if [ -e /etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini ]; then
        rm -f /etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini
    fi

    ## CLI
    if [ -e /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini ]; then
        rm -f /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini
    fi
fi

##
# Ensure /.composer exists and is writable
#
if [ ! -d /.composer ]; then
    mkdir /.composer
fi

chmod -R ugo+rw /.composer

##
# Run a command or start supervisord
#
if [ $# -gt 0 ];then
    # If we passed a command, run it
    exec "$@"
else
    # Otherwise start supervisord
    /usr/bin/supervisord
fi
