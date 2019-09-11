FROM php:7.3-apache
MAINTAINER Martin Krizan <mnohosten@gmail.com>

RUN apt-get -y update
RUN apt-get install -y \
    git \
    mc \
    htop \
    curl \
    wget \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libedit-dev \
    libicu-dev \
    libssl-dev \
    freetds-dev \
    libc-client-dev \
    libkrb5-dev \
    libzip-dev \
    uuid-dev \
    rsyslog

RUN docker-php-ext-install gd soap pdo_mysql mysqli intl pcntl zip xmlrpc bcmath

# Install PHP extensions
RUN docker-php-ext-install mbstring opcache

# Imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Redis
RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

# Sockets
RUN docker-php-ext-install sockets && docker-php-ext-enable sockets

# Blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

# XDebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini
RUN echo "session.gc_maxlifetime=1209600" >> /usr/local/etc/php/php.ini

# MongoDB
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && composer global require hirak/prestissimo \
    && ln -s /root/.composer/vendor/bin/* /usr/local/bin/
