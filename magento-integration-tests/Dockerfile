FROM php:7.3

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer

RUN apt-get update && apt-get -y install git zlib1g-dev zip libzip-dev libpng-dev
RUN docker-php-ext-install gd
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install sodium
RUN docker-php-ext-install zip

COPY entrypoint.sh /entrypoint.sh
COPY files/install-config-mysql.php /install-config-mysql.php
COPY files/phpunit.xml /phpunit.xml
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]

