#!/usr/bin/env bash

set -e

test -z "${INPUT_CE_VERSION}" && (echo "'ce_version' is not set" && exit)
test -z "${INPUT_MARKETPLACE_URL}" && (echo "'marketplace_url' is not set" && exit)

TMP_PATH=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
MARKETPLACE_URL=$INPUT_MARKETPLACE_URL
CE_VERSION=$INPUT_CE_VERSION

# Magento installation
composer create-project --repository=$MARKETPLACE_URL magento/project-community-edition:${CE_VERSION} $TMP_PATH --no-install --no-interaction
cd $TMP_PATH
composer config --unset repo.0
composer config repo.custom-mirror composer $MARKETPLACE_URL
composer install --prefer-dist

# Setup extension

# Prepare for integration tests
cp /install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
cp /phpunit.xml dev/tests/integration/phpunit.xml

# Run the integration tests
cd dev/tests/integration && ../../../vendor/bin/phpunit -c phpunit.xml

