#!/bin/bash

set -e

test -z "${MODULE_NAME}" && (echo "'module_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${CE_VERSION}" && (echo "'ce_version' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${MAGENTO_MARKETPLACE_USERNAME}" && (echo "'MAGENTO_MARKETPLACE_USERNAME' is not available as a secret" && exit 1)
test -z "${MAGENTO_MARKETPLACE_PASSWORD}" && (echo "'MAGENTO_MARKETPLACE_PASSWORD' is not available as a secret" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE

echo "MySQL checks"
nc -z -w1 mysql 3306 || (echo "MySQL is not running" && exit)
php /docker-files/db-create-and-test.php magento2 || exit
php /docker-files/db-create-and-test.php magento2test || exit

echo "Setup Magento credentials"
composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

echo "Prepare composer installation"
composer global require hirak/prestissimo
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction --no-progress

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} $MODULE_NAME

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config repositories.local-source path local-source/\*
composer require $COMPOSER_NAME:@dev --no-update --no-interaction

if [[ ! -z "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" && -f "${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ]] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . ${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT
fi

echo "Run installation"
COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-interaction --no-progress --no-suggest

echo "Run Magento setup"
php -d memory_limit=2G bin/magento setup:install --base-url=http://magento2.test/ \
--db-host=mysql --db-name=magento2 \
--db-user=root --db-password=root \
--admin-firstname=John --admin-lastname=Doe \
--admin-email=johndoe@example.com \
--admin-user=johndoe --admin-password=johndoe!1234 \
--backend-frontname=admin --language=en_US \
--currency=USD --timezone=Europe/Amsterdam --cleanup-database \
--sales-order-increment-prefix="ORD$" --session-save=db \
--use-rewrites=1

echo "Enable the module"
cd $MAGENTO_ROOT
bin/magento module:enable ${MODULE_NAME}
bin/magento setup:db:status -q || bin/magento setup:upgrade

echo "Determine which phpunit.xml file to use"
if [[ -z "$INPUT_PHPUNIT_FILE" || ! -f "$INPUT_PHPUNIT_FILE" ]] ; then
    INPUT_PHPUNIT_FILE=/docker-files/phpunit.xml
fi

echo "Using PHPUnit file: $INPUT_PHPUNIT_FILE"
echo "Prepare for integration tests"
cd $MAGENTO_ROOT
cp /docker-files/install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
sed "s#%COMPOSER_NAME%#$COMPOSER_NAME#g" $INPUT_PHPUNIT_FILE > dev/tests/integration/phpunit.xml
cp /docker-files/patches/Memory.php dev/tests/integration/framework/Magento/TestFramework/Helper/Memory.php

echo "Run the integration tests"
cd $MAGENTO_ROOT/dev/tests/integration && php -d memory_limit=1G ../../../vendor/bin/phpunit -c phpunit.xml

