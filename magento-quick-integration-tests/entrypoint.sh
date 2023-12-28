#!/bin/bash

set -e

test -z "${MODULE_NAME}" && (echo "'module_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${CE_VERSION}" && (echo "'ce_version' is not set in your GitHub Actions YAML file" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
test -z "${REPOSITORY_URL}" && REPOSITORY_URL="https://repo-magento-mirror.fooman.co.nz/"

echo "MySQL checks"
nc -z -w1 mysql 3306 || (echo "MySQL is not running" && exit)
php /docker-files/db-create-and-test.php magento2 || exit
php /docker-files/db-create-and-test.php magento2test || exit

echo "Setup Magento credentials"
test -z "${MAGENTO_MARKETPLACE_USERNAME}" || composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

echo "Prepare composer installation"
composer global require hirak/prestissimo
composer create-project --repository=$REPOSITORY_URL magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction --no-progress

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} $MODULE_NAME

echo "Removing unneeded packages"
composer require yireo/magento2-replace-sample-data --no-update --no-interaction

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config --unset repo.0
composer config repositories.local-source path local-source/\*
composer config repositories.magento composer $REPOSITORY_URL
composer require $COMPOSER_NAME:@dev --no-update --no-interaction

if [[ ! -z "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" && -f "${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ]] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . ${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT
fi

echo "Run installation"
COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-interaction --no-progress

echo "Run Magento setup"
SETUP_ARGS="--base-url=http://magento2.test/ \
--db-host=mysql --db-name=magento2 \
--db-user=root --db-password=root \
--admin-firstname=John --admin-lastname=Doe \
--admin-email=johndoe@example.com \
--admin-user=johndoe --admin-password=johndoe!1234 \
--backend-frontname=admin --language=en_US \
--currency=USD --timezone=Europe/Amsterdam \
--sales-order-increment-prefix=ORD_ --session-save=db \
--use-rewrites=1"

# only add the --search-engine param if it is supported
if bin/magento setup:install --help | grep -q '\-\-search\-engine='; then
    SETUP_ARGS="$SETUP_ARGS --search-engine=elasticsearch7"
fi

if [[ "$ELASTICSEARCH" == "1" ]]; then
    SETUP_ARGS="$SETUP_ARGS --elasticsearch-host=es --elasticsearch-port=9200 --elasticsearch-enable-auth=0 --elasticsearch-timeout=60"
fi

echo "Run Magento setup: $SETUP_ARGS"
php bin/magento setup:install $SETUP_ARGS

echo "Enable the module"
cd $MAGENTO_ROOT
bin/magento module:enable ${MODULE_NAME}
bin/magento setup:db:status -q || bin/magento setup:upgrade

echo "Determine which phpunit.xml file to use"
if [[ -z "$INPUT_PHPUNIT_FILE" || ! -f "$INPUT_PHPUNIT_FILE" ]] ; then
    INPUT_PHPUNIT_FILE=/docker-files/phpunit.xml
fi

echo "Add ReachDigital framework"
COMPOSER_MEMORY_LIMIT=-1 composer require reach-digital/magento2-test-framework

echo "Prepare for integration tests"
cd $MAGENTO_ROOT
cp /docker-files/install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
cp /docker-files/install-config-mysql.php dev/tests/quick-integration/etc/install-config-mysql.php
sed "s#%COMPOSER_NAME%#$COMPOSER_NAME#g" $INPUT_PHPUNIT_FILE > dev/tests/quick-integration/phpunit.xml
sed "s#%COMPOSER_NAME%#$COMPOSER_NAME#g" $INPUT_PHPUNIT_FILE > dev/tests/integration/phpunit.xml
cp /docker-files/patches/Memory.php dev/tests/integration/framework/Magento/TestFramework/Helper/Memory.php

echo "Run the integration tests"
cd $MAGENTO_ROOT/dev/tests/quick-integration && php -d memory_limit=2G ../../../vendor/bin/phpunit -c phpunit.xml
