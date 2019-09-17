FROM php:7.1-apache-stretch
MAINTAINER Martin Krizan <mnohosten@gmail.com>

ARG COMPOSER_FLAGS="--prefer-dist --no-interaction"
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_PROCESS_TIMEOUT 3600

RUN apt-get update
RUN apt-get install -y \
    git \
    mc \
    curl \
    wget \
    libmcrypt-dev \
    libpng-dev \
    libxml2-dev \
    libedit-dev \
    freetds-dev \
    libzip-dev \
    libicu-dev \
    libkrb5-dev \
    libc-client-dev \
    autoconf \
    g++ \
    make \
    bash \
    rsyslog

# Install PHP extensions
RUN docker-php-ext-install gd
RUN docker-php-ext-install soap
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install intl
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install zip
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install opcache
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap
RUN pecl install mongodb && docker-php-ext-enable mongodb
RUN docker-php-ext-install sockets
# Blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini
# XDebug
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini
RUN echo "session.gc_maxlifetime=1209600" >> /usr/local/etc/php/php.ini
# Composer & Symfony
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN composer global require hirak/prestissimo

RUN a2enmod rewrite

WORKDIR /var/www
