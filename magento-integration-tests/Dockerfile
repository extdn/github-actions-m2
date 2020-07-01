FROM php:7.3

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer

RUN apt-get update && apt-get -y install \
    mysql-client \
    apt-transport-https \
    git \
    zlib1g-dev \
    zip \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libsodium-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    netcat
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install xsl
RUN docker-php-ext-install soap
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install sodium
RUN docker-php-ext-install zip
RUN docker-php-ext-install intl

COPY entrypoint.sh /entrypoint.sh
COPY files/install-config-mysql.php /install-config-mysql.php
COPY files/db-test.php /db-test.php
COPY files/phpunit.xml /phpunit.xml
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]

