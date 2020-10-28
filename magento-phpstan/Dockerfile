FROM duhon/php:7.3-alpine AS builder
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
RUN composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ magento/project-community-edition /var/www/magento2ce --no-install --no-interaction
RUN composer config --unset repo.0
RUN composer config repo.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
RUN composer install --prefer-dist


FROM php:7.3-cli-alpine3.9
COPY --from=builder /var/www/magento2ce/ /m2/
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
ADD phpunit.phpmd.xml /m2/dev/tests/static/phpunit.xml
ADD PhpStanRunner.php /m2/dev/tests/static/testsuite/Magento/Test/Php/PhpStanRunner.php
ADD LiveCodePhpStanRunner.php /m2/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/LiveCodePhpStanRunner.php

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]