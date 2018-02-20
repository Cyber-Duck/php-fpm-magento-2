FROM php:7.1-fpm

MAINTAINER clement@cyber-duck.co.uk

ENV XDEBUG="false"

RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends \
        zlib1g-dev libicu-dev g++ \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libmcrypt-dev \
        libxslt-dev \
        libmemcached-dev \
        libtidy-dev \
        libssl-dev \
        openssh-server \
        curl \
        git \
        cron \
        nano

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install calendar
RUN docker-php-ext-install exif
RUN docker-php-ext-install gettext
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install mysqli
# RUN docker-php-ext-install pcntl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install soap
RUN docker-php-ext-install sockets
RUN docker-php-ext-install tidy
RUN docker-php-ext-install wddx
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install xsl
RUN docker-php-ext-install zip

# Install the PHP intl extention
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

#####################################
# GD:
#####################################

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

#####################################
# xDebug:
#####################################

RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#####################################
# PHP OP Cache:
#####################################

RUN docker-php-ext-enable opcache
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#####################################
# PHP Memcached:
#####################################

RUN pecl install memcached && docker-php-ext-enable memcached

#####################################
# Composer:
#####################################

RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
RUN . ~/.bashrc

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

ADD ./magento2.ini /usr/local/etc/php/conf.d

#####################################
# Aliases:
#####################################

# docker-compose exec php-fpm dep --> locally installed Deployer binaries
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/vendor/bin/dep "$@"' > /usr/bin/dep
RUN chmod +x /usr/bin/dep
# docker-compose exec php-fpm magento --> php bin/magento
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/bin/magento "$@"' > /usr/bin/magento
RUN chmod +x /usr/bin/magento

RUN rm -r /var/lib/apt/lists/*

RUN usermod -u 1000 www-data

WORKDIR /var/www

# Magento 2 permissions
RUN find var vendor generated pub/static pub/media app/etc -type f -exec chmod g+w {} \; && \
    find var vendor generated pub/static pub/media app/etc -type d -exec chmod g+ws {} \; && \
    chown -R :www-data . && chmod u+x bin/magento

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000
CMD ["php-fpm"]
