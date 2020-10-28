FROM extdn/magento-integration-tests-action:7.4-latest AS builder
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
RUN composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ --no-plugins --no-install --no-interaction magento/project-community-edition /var/www/magento2ce "2.4.1"
WORKDIR "/var/www/magento2ce"
RUN composer config --unset repo.0
RUN composer config repo.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
RUN composer require hoa/regex --no-update
RUN composer install --prefer-dist


FROM extdn/magento-integration-tests-action:7.4-latest
COPY --from=builder /var/www/magento2ce/ /m2/
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
ADD phpunit.xml /m2/dev/tests/static/phpunit.xml
ADD PhpStanRunner.php /m2/dev/tests/static/testsuite/Magento/Test/Php/PhpStanRunner.php
ADD LiveCodePhpStanRunner.php /m2/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/LiveCodePhpStanRunner.php

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]