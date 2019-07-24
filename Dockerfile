FROM ubuntu:18.04

LABEL maintainer="ducong"

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai
ENV PHP_VERSION=7.3

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y gnupg tzdata software-properties-common gettext-base \
    && dpkg-reconfigure -f noninteractive tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update --fix-missing\
    && add-apt-repository ppa:ondrej/php \
    && apt-get install -y curl zip unzip git supervisor vim sqlite3 cron \
       nginx php$PHP_VERSION-fpm php$PHP_VERSION-cli \
       php$PHP_VERSION-pgsql php$PHP_VERSION-sqlite3 php$PHP_VERSION-gd \
       php$PHP_VERSION-curl php$PHP_VERSION-memcached \
       php$PHP_VERSION-imap php$PHP_VERSION-mysql php$PHP_VERSION-mbstring \
       php$PHP_VERSION-xml php$PHP_VERSION-zip php$PHP_VERSION-bcmath php$PHP_VERSION-soap php-mongodb \
       php$PHP_VERSION-intl php$PHP_VERSION-readline php$PHP_VERSION-xdebug \
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

USER root

COPY ./crontab /etc/cron.d
COPY xdebug.ini /etc/php/$PHP_VERSION/mods-available/xdebug.ini
COPY default /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-container.sh /usr/bin/start-container

RUN chmod -R 644 /etc/cron.d \
    && chmod +x /usr/bin/start-container

ENTRYPOINT ["start-container"]
