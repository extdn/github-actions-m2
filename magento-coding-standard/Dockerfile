FROM php:7.3-cli-alpine3.9

COPY --from=composer:1.9.1 /usr/bin/composer /usr/local/bin/composer

RUN /usr/local/bin/composer global require magento/magento-coding-standard:*
RUN ~/.composer/vendor/bin/phpcs --config-set installed_paths ../../magento/magento-coding-standard/

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
