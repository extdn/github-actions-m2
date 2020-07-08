#!/bin/bash

set -e

test -z "${INPUT_MODULE_NAME}" && (echo "'module_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${INPUT_COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${INPUT_CE_VERSION}" && (echo "'ce_version' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${MAGENTO_MARKETPLACE_USERNAME}" && (echo "'MAGENTO_MARKETPLACE_USERNAME' is not available as a secret" && exit 1)
test -z "${MAGENTO_MARKETPLACE_PASSWORD}" && (echo "'MAGENTO_MARKETPLACE_PASSWORD' is not available as a secret" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
CE_VERSION=$INPUT_CE_VERSION

echo "Setup Magento credentials"
composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

echo "Prepare composer installation"
composer global require hirak/prestissimo
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction --no-progress

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${INPUT_MODULE_SOURCE} $INPUT_MODULE_NAME

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config repositories.local-source path local-source/\*
composer require $INPUT_COMPOSER_NAME:@dev --no-update --no-interaction

echo "Run installation"
composer install --prefer-dist --no-interaction --no-progress --no-suggest

echo "Determine which phpunit.xml file to use"
if [[ -z "$INPUT_PHPUNIT_FILE" || ! -f "$INPUT_PHPUNIT_FILE" ]] ; then
    INPUT_PHPUNIT_FILE=/docker-files/phpunit.xml
fi

echo "Using PHPUnit file: $INPUT_PHPUNIT_FILE"
echo "Prepare for unit tests"
cd $MAGENTO_ROOT
sed "s#%COMPOSER_NAME%#$INPUT_COMPOSER_NAME#g" $INPUT_PHPUNIT_FILE > dev/tests/unit/phpunit.xml

echo "Run the unit tests"
cd $MAGENTO_ROOT/dev/tests/unit && ../../../vendor/bin/phpunit -c phpunit.xml

