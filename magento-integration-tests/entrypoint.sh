#!/bin/bash

set -e

test -z "${INPUT_EXTENSION_VENDOR}" && (echo "'extension_vendor' is not set" && exit)
test -z "${INPUT_EXTENSION_MODULE}" && (echo "'extension_module' is not set" && exit)
test -z "${INPUT_CE_VERSION}" && (echo "'ce_version' is not set" && exit)
test -z "${INPUT_MARKETPLACE_URL}" && (echo "'marketplace_url' is not set" && exit)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
MARKETPLACE_URL=$INPUT_MARKETPLACE_URL
CE_VERSION=$INPUT_CE_VERSION

# Magento installation
echo "Using Marketpace URL $MARKETPLACE_URL"
composer global require hirak/prestissimo
composer create-project --repository-url=$MARKETPLACE_URL magento/project-community-edition:${CE_VERSION} $MAGENTO_ROOT --no-install --no-interaction
cd $MAGENTO_ROOT
composer config --unset repo.0
composer config repo.custom-mirror composer $MARKETPLACE_URL
cat composer.json
composer install --prefer-dist

# Setup extension
mkdir app/code/$INPUT_EXTENSION_VENDOR
cd app/code/$INPUT_EXTENSION_VENDOR
ln -s ${GITHUB_WORKSPACE}${INPUT_EXTENSION_SOURCE} $INPUT_EXTENSION_MODULE

# Prepare for integration tests
cd $MAGENTO_ROOT
cp /install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
cp /phpunit.xml dev/tests/integration/phpunit.xml

# Run the integration tests
cd $MAGENTO_ROOT/dev/tests/integration && ../../../vendor/bin/phpunit -c phpunit.xml

