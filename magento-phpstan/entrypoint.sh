#!/bin/bash
set -e

test -z "${MODULE_SOURCE}" && MODULE_SOURCE=$INPUT_MODULE_SOURCE
test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
test -z "${COMPOSER_VERSION}" && COMPOSER_VERSION=$INPUT_COMPOSER_VERSION

if [ -z "$COMPOSER_VERSION" ] ; then
   COMPOSER_VERSION=2
fi

MAGENTO_ROOT=/m2
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)

echo "Using composer ${COMPOSER_VERSION}"
ln -s /usr/local/bin/composer$COMPOSER_VERSION /usr/local/bin/composer

echo "Fix issue 115"
cd $MAGENTO_ROOT
#rm -rf vendor/
composer install

echo "Setup extension source folder within Magento root"
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} .

echo "Configure extension source in composer"
composer config repositories.local-source path local-source/\*

echo "Pre Install Script [magento_pre_install_script]: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [ -n "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] && [ -f "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT";
fi;

echo "Installing module"
COMPOSER_MIRROR_PATH_REPOS=1 composer require $COMPOSER_NAME:@dev --no-interaction --dev || exit

CONFIGURATION_FILE=dev/tests/static/testsuite/Magento/Test/Php/_files/phpstan/phpstan.neon
test -f vendor/${COMPOSER_NAME}/phpstan.neon && CONFIGURATION_FILE=vendor/${COMPOSER_NAME}/phpstan.neon

echo "Configuration file: $CONFIGURATION_FILE"
echo "Level: $INPUT_PHPSTAN_LEVEL"

echo "Running PHPStan"
php vendor/bin/phpstan analyse \
    --level $INPUT_PHPSTAN_LEVEL \
    --no-progress \
    --memory-limit=4G \
    --configuration ${CONFIGURATION_FILE} \
    vendor/${COMPOSER_NAME}
