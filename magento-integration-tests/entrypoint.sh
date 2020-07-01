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
mysqladmin -u root --password=root ping

# Magento credentials
composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

# Magento installation
composer global require hirak/prestissimo
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction
cd $MAGENTO_ROOT
composer install --prefer-dist

# Setup extension
mkdir -p app/code/$INPUT_EXTENSION_VENDOR
cd app/code/$INPUT_EXTENSION_VENDOR
ln -s ${GITHUB_WORKSPACE}/${INPUT_EXTENSION_SOURCE} $INPUT_EXTENSION_MODULE

# Prepare for integration tests
cd $MAGENTO_ROOT
cp /install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
cp /phpunit.xml dev/tests/integration/phpunit.xml

# Run the integration tests
cd $MAGENTO_ROOT/dev/tests/integration && ../../../vendor/bin/phpunit -c phpunit.xml

