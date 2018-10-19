FROM ubuntu:18.04

LABEL maintainer="ducong"

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y gnupg tzdata \
    && dpkg-reconfigure -f noninteractive tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update --fix-missing\
    && apt-get install -y curl zip unzip git supervisor sqlite3 cron \
       nginx php7.2-fpm php7.2-cli \
       php7.2-pgsql php7.2-sqlite3 php7.2-gd \
       php7.2-curl php7.2-memcached \
       php7.2-imap php7.2-mysql php7.2-mbstring \
       php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap php-mongodb \
       php7.2-intl php7.2-readline php7.2-xdebug \
       php-msgpack php-igbinary \
    && php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && mkdir /run/php \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY laravel-schedule.cron /var/spool/cron/crontabs/root
COPY xdebug.ini /etc/php/7.2/mods-available/xdebug.ini
COPY default /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container

ENTRYPOINT ["start-container"]
