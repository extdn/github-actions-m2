FROM extdn/magento-integration-tests-action:7.3-latest AS builder
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
RUN composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ --no-plugins --no-install --no-interaction magento/project-community-edition /var/www/magento2ce "2.4.1"
WORKDIR "/var/www/magento2ce"
RUN composer config --unset repo.0
RUN composer config repo.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
RUN composer install --prefer-dist


FROM extdn/magento-integration-tests-action:7.4-latest
COPY --from=builder /var/www/magento2ce/ /m2/
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
ADD phpunit.phpcpd.xml /m2/dev/tests/static/phpunit.phpcpd.xml
ADD PhpcpdRunner.php /m2/dev/tests/static/testsuite/Magento/Test/Php/PhpcpdRunner.php
ADD LiveCodePhpcpdRunner.php /m2/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/LiveCodePhpcpdRunner.php

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]