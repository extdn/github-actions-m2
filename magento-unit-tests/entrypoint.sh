#!/bin/bash

set -e

test -z "${MODULE_NAME}" && MODULE_NAME=$INPUT_MODULE_NAME
test -z "${MODULE_SOURCE}" && MODULE_SOURCE=$INPUT_MODULE_SOURCE
test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
test -z "${MAGENTO_VERSION}" && MAGENTO_VERSION=$INPUT_MAGENTO_VERSION
test -z "${PROJECT_NAME}" && PROJECT_NAME=$INPUT_PROJECT_NAME
test -z "${PHPUNIT_FILE}" && PHPUNIT_FILE=$INPUT_PHPUNIT_FILE

test -z "$MAGENTO_VERSION" && MAGENTO_VERSION="2.4.4"
test -z "$COMPOSER_VERSION" && [[ "$MAGENTO_VERSION" =~ ^2.4.* ]] && COMPOSER_VERSION=2
test -z "$COMPOSER_VERSION" && COMPOSER_VERSION=1
test -z "$PROJECT_NAME" && PROJECT_NAME="magento/project-community-edition"

test -z "${MODULE_NAME}" && (echo "'module_name' is not set" && exit 1)
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set" && exit 1)
test -z "${MAGENTO_VERSION}" && (echo "'magento_version' is not set" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE
test -z "${REPOSITORY_URL}" && REPOSITORY_URL="https://repo-magento-mirror.fooman.co.nz/"

echo "Setup Magento credentials"
test -z "${MAGENTO_MARKETPLACE_USERNAME}" || composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

echo "Prepare composer installation"
composer create-project --repository=$REPOSITORY_URL ${PROJECT_NAME}:${MAGENTO_VERSION} $MAGENTO_ROOT --no-install --no-interaction --no-progress

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} $MODULE_NAME

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config --unset repo.0
composer config repositories.local-source path local-source/\*
composer config repositories.magento composer $REPOSITORY_URL
composer require $COMPOSER_NAME:@dev --no-update --no-interaction

echo "Pre Install Script [magento_pre_install_script]: $INPUT_MAGENTO_PRE_INSTALL_SCRIPT"
if [[ ! -z "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" && -f "${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ]] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . ${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT
fi

if [[ "$COMPOSER_VERSION" -eq "2" ]] ; then
    echo "Allow composer plugins"
    composer config --no-plugins allow-plugins true
fi

echo "Run installation"
COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-interaction --no-progress

echo "Determine which phpunit.xml file to use"

echo "Trying phpunit.xml file $PHPUNIT_FILE"
if [[ ! -z "$PHPUNIT_FILE" && ! -f "$PHPUNIT_FILE" ]] ; then
    PHPUNIT_FILE=${GITHUB_WORKSPACE}/${PHPUNIT_FILE}
fi

if [[ ! -f "$PHPUNIT_FILE" ]] ; then
    PHPUNIT_FILE=/docker-files/phpunit.xml
fi

echo "Using PHPUnit file: $PHPUNIT_FILE"
echo "Prepare for unit tests"
cd $MAGENTO_ROOT

sed "s#%COMPOSER_NAME%#$COMPOSER_NAME#g" $PHPUNIT_FILE > dev/tests/unit/phpunit.xml

for TESTSFOLDER in $(xmlstarlet select -t -v '/phpunit/testsuites/testsuite/directory/text()' dev/tests/unit/phpunit.xml)
do
   if [[ ! -d "$MAGENTO_ROOT/dev/tests/unit/$TESTSFOLDER" ]]
   then
       echo "Optional $TESTSFOLDER location does not exist on your filesystem - removing it from phpunit.xml"
       xmlstarlet ed --inplace -d "//phpunit/testsuites/testsuite/directory[contains(text(),'$TESTSFOLDER')]" dev/tests/unit/phpunit.xml
   fi
done

echo "Current unit test file"
cat $MAGENTO_ROOT/dev/tests/unit/phpunit.xml

echo "Run the unit tests"
cd $MAGENTO_ROOT/dev/tests/unit && ../../../vendor/bin/phpunit -c phpunit.xml
