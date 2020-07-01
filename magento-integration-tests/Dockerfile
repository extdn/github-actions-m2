FROM php:7.3-cli-alpine3.9

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer

RUN apt-get update \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install zibcmathp

COPY entrypoint.sh /entrypoint.sh
COPY files/install-config-mysql.php /install-config-mysql.php
COPY files/phpunit.xml /phpunit.xml
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]

