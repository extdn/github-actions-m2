#!/bin/sh -l
set -e

MAGENTO_ROOT=/m2
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} $GITHUB_ACTION

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config --unset repo.0
composer config repositories.foomanmirror composer https://repo-magento-mirror.fooman.co.nz/
composer config repositories.local-source path local-source/\*

echo "Pre Install Script: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [[ ! -z "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" && -f "${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ]] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . ${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT
fi

echo "Run installation"
composer require $COMPOSER_NAME:@dev

php $MAGENTO_ROOT/vendor/bin/phpstan analyse --level 1 --no-progress --error-format=raw --memory-limit=4G --configuration '$MAGENTO_ROOT/dev/tests/static/testsuite/Magento/Test/Php/_files/phpstan/phpstan.neon' $GITHUB_WORKSPACE/${MODULE_SOURCE}