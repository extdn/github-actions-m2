#!/bin/bash
set -e

test -z "${MODULE_SOURCE}" && MODULE_SOURCE=$INPUT_MODULE_SOURCE
test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
test -z "${PHPSTAN_LEVEL}" && PHPSTAN_LEVEL=$INPUT_PHPSTAN_LEVEL
test -z "${COMPOSER_VERSION}" && COMPOSER_VERSION=$INPUT_COMPOSER_VERSION
test -z "${COMPOSER_VERSION}" && COMPOSER_VERSION=2

MAGENTO_ROOT=/var/www/magento2ce
test -d "${MAGENTO_ROOT}" || (test -d /var/www/magento2ce && MAGENTO_ROOT=/tmp/m2)
echo "Using Magento root ${MAGENTO_ROOT}"

test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)

echo "Using composer ${COMPOSER_VERSION}"
ln -s /usr/local/bin/composer$COMPOSER_VERSION /usr/local/bin/composer

echo "Setup extension source folder within Magento root"
mkdir -p $MAGENTO_ROOT/local-source/
cd $MAGENTO_ROOT/local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} .

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config repositories.local-source path $MAGENTO_ROOT/local-source/\*

echo "Pre Install Script [magento_pre_install_script]: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [ -n "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] && [ -f "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT";
fi;

echo "Installing module"
COMPOSER_MIRROR_PATH_REPOS=1 composer require $COMPOSER_NAME:@dev --no-interaction --dev || exit

CONFIGURATION_FILE=dev/tests/static/testsuite/Magento/Test/Php/_files/phpstan/phpstan.neon
test -f vendor/${COMPOSER_NAME}/phpstan.neon && CONFIGURATION_FILE=vendor/${COMPOSER_NAME}/phpstan.neon

echo "PHPStan diagnose: `vendor/bin/phpstan diagnose -l 1`"
echo "Configuration file: $CONFIGURATION_FILE"
echo "Level: $PHPSTAN_LEVEL"

echo "Running PHPStan"
php vendor/bin/phpstan analyse \
    --level $PHPSTAN_LEVEL \
    --no-progress \
    --memory-limit=4G \
    --configuration ${CONFIGURATION_FILE} \
    vendor/${COMPOSER_NAME}
