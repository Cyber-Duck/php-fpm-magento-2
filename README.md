# PHP-FPM Docker image for Laravel

Docker image for a php-fpm container crafted to run Magento 2 based applications.

## Specifications:

Based on the **official Magento 2 requirements** [here](http://devdocs.magento.com/guides/v2.2/install-gde/system-requirements-tech.html) and [there](http://devdocs.magento.com/guides/v2.2/install-gde/prereq/php-ubuntu.html).

* PHP 7.1
* BC-Math PHP Extension
* Ctype PHP Extension
* CURL PHP Extension
* DOM PHP Extension
* GD PHP Extension
* Intl PHP Extension
* Mbstring PHP Extension
* Mcrypt PHP Extension
* Hash PHP Extension
* OpenSSL PHP Extension
* PDO/MySQL PHP Extension
* SimpleXML PHP Extension
* SOAP PHP Extension
* SPL PHP Extension
* LibXML PHP Extension
* XSL PHP Extension
* ZIP PHP Extension
* JSON PHP Extension
* Iconv PHP Extension
* PHP OPcache
* Latest Composer
* Cron (with Magento 2.2 Cron jobs setup, see [the official documentation](http://devdocs.magento.com/guides/v2.2/comp-mgr/prereq/prereq_cron.html))
* PHP ini values for Magento 2 (see [`magento2.ini`](https://github.com/Cyber-Duck/php-fpm-laravel/blob/7.1/magento2.ini))
* xDebug (PHPStorm friendly, see [`xdebug.ini`](https://github.com/Cyber-Duck/php-fpm-laravel/blob/7.1/xdebug.ini))
* `magento` alias created to run unit tests `bin/magento` with `docker-compose exec [service_name] magento ...`
* `t` alias created to run unit tests `vendor/bin/phpunit` with `docker-compose exec [service_name] t ...`

More information: [`Dockerfile`](https://github.com/Cyber-Duck/php-fpm-laravel/blob/7.1/Dockerfile)

## Tags available:

When calling the image you want to use within your `docker-compose.yml` file,
you can specify a tag for the image. Tags are used for various versions of a
given Docker image.

* [`7.1`](https://github.com/Cyber-Duck/php-fpm-magento2/tree/7.1)

**Note:** the `master` branch is not used for generating images, used for documentation instead. Only tags/branches are. 

## docker-compose usage:

```yml
version: '2'
services:
    php-fpm:
        image: cyberduck/php-fpm-magento2(:<version-tag>)
        volumes:
            - ./:/var/www/
            - ~/.ssh:/root/.ssh # can be useful for composer if you use private CVS
        networks:
            - my_net #if you're using networks between containers
```
