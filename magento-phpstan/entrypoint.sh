#!/bin/bash
set -e

test -z "${MODULE_SOURCE}" && MODULE_SOURCE=$INPUT_MODULE_SOURCE
test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
test -z "${COMPOSER_VERSION}" && COMPOSER_VERSION=$INPUT_COMPOSER_VERSION

if [ -z "$COMPOSER_VERSION" ] ; then
   COMPOSER_VERSION=2
fi

EXTENSION_BRANCH=${GITHUB_REF#refs/heads/}

MAGENTO_ROOT=/m2
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)

echo "Using composer ${COMPOSER_VERSION}"
ln -s /usr/local/bin/composer$COMPOSER_VERSION /usr/local/bin/composer

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

if [[ "$COMPOSER_VERSION" -eq "2" ]] ; then
    echo "Allow composer plugins"
    composer config --no-plugins allow-plugins true
fi

echo "Pre Install Script [magento_pre_install_script]: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [ -n "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] && [ -f "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . "${GITHUB_WORKSPACE}"/"$INPUT_MAGENTO_PRE_INSTALL_SCRIPT";
fi;

echo "Run installation"
COMPOSER_MIRROR_PATH_REPOS=1 composer install

echo "Installing module"
COMPOSER_MIRROR_PATH_REPOS=1 composer require $COMPOSER_NAME:@dev --no-interaction --dev

CONFIGURATION_FILE=$MAGENTO_ROOT/dev/tests/static/testsuite/Magento/Test/Php/_files/phpstan/phpstan.neon
test -f $GITHUB_WORKSPACE/${MODULE_SOURCE}/phpstan.neon && CONFIGURATION_FILE=$GITHUB_WORKSPACE/${MODULE_SOURCE}/phpstan.neon

echo "Configuration file: $CONFIGURATION_FILE"
echo "Level: $INPUT_PHPSTAN_LEVEL"

echo "Running PHPStan"
cd ${GITHUB_WORKSPACE}/${MODULE_SOURCE}
php $MAGENTO_ROOT/vendor/bin/phpstan analyse \
    --level $INPUT_PHPSTAN_LEVEL \
    --no-progress \
    --memory-limit=4G \
    --configuration ${CONFIGURATION_FILE} \
    ${GITHUB_WORKSPACE}/${MODULE_SOURCE}
