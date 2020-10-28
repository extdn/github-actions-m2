#!/bin/bash
set -e

test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
EXTENSION_BRANCH=${GITHUB_REF#refs/heads/}

MAGENTO_ROOT=/m2
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R "${GITHUB_WORKSPACE}"/"${MODULE_SOURCE}" "$GITHUB_ACTION"

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config --unset repo.0
composer config repositories.local-source path local-source/\*
composer config repositories.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/

echo "Pre Install Script: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [ -n "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] && [ -f "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT";
fi;

echo "Run installation"
composer require $COMPOSER_NAME:dev-$EXTENSION_BRANCH#$GITHUB_SHA

echo "Running PHPStan"
php $MAGENTO_ROOT/vendor/bin/phpstan analyse --level $INPUT_PHPSTAN_LEVEL --no-progress --memory-limit=4G --configuration "$MAGENTO_ROOT/dev/tests/static/testsuite/Magento/Test/Php/_files/phpstan/phpstan.neon" $GITHUB_WORKSPACE/${MODULE_SOURCE}