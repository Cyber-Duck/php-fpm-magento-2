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
        curl \
        libssl-dev \
        openssh-server \
        git \
        cron \
        nano

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install xsl
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install soap
RUN docker-php-ext-install exif
RUN docker-php-ext-install gettext
RUN docker-php-ext-install sockets
RUN docker-php-ext-install calendar
RUN docker-php-ext-install wddx

# Install the PHP intl extention
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

#####################################
# GD:
#####################################

# Install the PHP gd library
RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

#####################################
# xDebug:
#####################################

# Install the xdebug extension
RUN pecl install xdebug && docker-php-ext-enable xdebug
# Copy xdebug configration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#####################################
# PHP OP Cache:
#####################################

# Install the php opcache extension
RUN docker-php-ext-enable opcache
# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
# Source the bash
RUN . ~/.bashrc

#####################################
# Magento2 Cron Jobs Setup:
#####################################

RUN echo "#~ MAGENTO START" >> /etc/cron.d/magento2-jobs
RUN echo "* * * * * /usr/bin/php /var/www/bin/magento cron:run 2>&1 | grep -v Ran jobs by schedule >> /var/www/var/log/magento.cron.log" >> /etc/cron.d/magento2-jobs
RUN echo "* * * * * /usr/bin/php /var/www/update/cron.php >> /var/www/var/log/update.cron.log" >> /etc/cron.d/magento2-jobs
RUN echo "* * * * * /usr/bin/php /var/www/bin/magento setup:cron:run >> /var/www/var/log/setup.cron.log" >> /etc/cron.d/magento2-jobs
RUN echo "#~ MAGENTO END" >> /etc/cron.d/magento2-jobs
RUN chmod 0644 /etc/cron.d/magento2-jobs

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

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000
CMD ["php-fpm"]
