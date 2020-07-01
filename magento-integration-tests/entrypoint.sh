#!/bin/bash

set -e

test -z "${INPUT_EXTENSION_VENDOR}" && (echo "'extension_vendor' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${INPUT_EXTENSION_MODULE}" && (echo "'extension_module' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${INPUT_CE_VERSION}" && (echo "'ce_version' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${MAGENTO_MARKETPLACE_USERNAME}" && (echo "'MAGENTO_MARKETPLACE_USERNAME' is not available as a secret" && exit 1)
test -z "${MAGENTO_MARKETPLACE_PASSWORD}" && (echo "'MAGENTO_MARKETPLACE_PASSWORD' is not available as a secret" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
CE_VERSION=$INPUT_CE_VERSION

# MySQL check
nc -z -w1 127.0.0.1 3306 || (echo "MySQL is not running" && exit)
php /db-create-and-test.php magento2 || exit
php /db-create-and-test.php magento2test || exit

# Magento credentials
composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

# Magento installation
composer global require hirak/prestissimo
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction
cd $MAGENTO_ROOT
composer install --prefer-dist

# Run Magento setup
bin/magento setup:install --base-url=http://magento2.test/ \
--db-host=127.0.0.1 --db-name=magento2 \
--db-user=root --db-password=root \
--admin-firstname=John --admin-lastname=Doe \
--admin-email=johndoe@example.com \
--admin-user=johndoe --admin-password=johndoe!1234 \
--backend-frontname=admin --language=en_US \
--currency=USD --timezone=Europe/Amsterdam --cleanup-database \
--sales-order-increment-prefix="ORD$" --session-save=db \
--use-rewrites=1

# Setup extension
mkdir -p app/code/$INPUT_EXTENSION_VENDOR
cd app/code/$INPUT_EXTENSION_VENDOR
cp -R ${GITHUB_WORKSPACE}/${INPUT_EXTENSION_SOURCE} $INPUT_EXTENSION_MODULE

# Enable the module
cd $MAGENTO_ROOT
bin/magento module:enable ${INPUT_EXTENSION_VENDOR}_${INPUT_EXTENSION_MODULE}
bin/magento setup:upgrade

# Prepare for integration tests
cd $MAGENTO_ROOT
cp /install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
cp /phpunit.xml dev/tests/integration/phpunit.xml

# Run the integration tests
cd $MAGENTO_ROOT/dev/tests/integration && ../../../vendor/bin/phpunit -c phpunit.xml

