#!/bin/bash

# Toggle xdebug
if [ "false" == "$XDEBUG" ]; then
    sed -i "s/^/;/" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s/^/;/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Magento 2 permissions
find /var/www/var /var/www/vendor /var/www/generated /var/www/pub/static /var/www/pub/media /var/www/app/etc -type f -exec chmod g+w {} \;
find /var/www/var /var/www/vendor /var/www/generated /var/www/pub/static /var/www/pub/media /var/www/app/etc -type d -exec chmod g+ws {} \;
chown -R www-data:www-data /var/www
chmod u+x /var/www/bin/magento

exec "$@"
