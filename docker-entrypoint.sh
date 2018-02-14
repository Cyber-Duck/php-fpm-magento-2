#!/bin/bash

if [ "false" == "$XDEBUG" ]; then
    # Disable xdebug
    sed -i "s/^/;/" /usr/local/etc/php/conf.d/xdebug.ini
    sed -i "s/^/;/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

exec "$@"
