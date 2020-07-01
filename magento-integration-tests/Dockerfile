FROM php:7.3-cli-alpine3.9

#CMD ["/bin/bash"]

COPY entrypoint.sh /entrypoint.sh
COPY files/install-config-mysql.php /install-config-mysql.php
COPY files/phpunit.xml /phpunit.xml
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]

