FROM extdn/magento-integration-tests-action:7.4-latest AS builder

RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini
RUN composer2 create-project --repository=https://repo-magento-mirror.fooman.co.nz/ --no-plugins --no-install --no-interaction magento/project-community-edition /var/www/magento2ce "2.4.3"

WORKDIR "/var/www/magento2ce"
RUN composer2 config --unset repo.0
RUN composer2 config repo.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
RUN composer2 require hoa/regex --no-update
RUN composer2 install --prefer-dist


FROM extdn/magento-integration-tests-action:7.4-latest
COPY --from=builder /var/www/magento2ce/ /m2/
RUN echo memory_limit = -1 >> /usr/local/etc/php/conf.d/custom-memory.ini

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
