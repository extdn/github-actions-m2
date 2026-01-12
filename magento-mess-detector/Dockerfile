FROM extdn/magento-integration-tests-action:7.4-latest AS builder
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
RUN composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ --no-plugins --no-install --no-interaction magento/project-community-edition /var/www/magento2ce "2.4.1"
WORKDIR "/var/www/magento2ce"
# https://github.com/composer/composer/issues/12623#issuecomment-3551953185
RUN composer config --unset repositories || true
RUN composer config --unset repo.0
RUN composer config repo.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
RUN composer install --prefer-dist


FROM extdn/magento-integration-tests-action:7.4-latest
COPY --from=builder /var/www/magento2ce/ /m2/
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
ADD phpunit.phpmd.xml /m2/dev/tests/static/phpunit.phpmd.xml
ADD PhpmdRunner.php /m2/dev/tests/static/testsuite/Magento/Test/Php/PhpmdRunner.php
ADD LiveCodePhpmdRunner.php /m2/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/LiveCodePhpmdRunner.php

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
