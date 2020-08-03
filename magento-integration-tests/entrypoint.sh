#!/bin/bash

set -e

test -z "${CE_VERSION}" || MAGENTO_VERSION=$CE_VERSION

test -z "${MODULE_NAME}" && MODULE_NAME=$INPUT_MODULE_NAME
test -z "${COMPOSER_NAME}" && COMPOSER_NAME=$INPUT_COMPOSER_NAME
test -z "${MAGENTO_VERSION}" && MAGENTO_VERSION=$INPUT_MAGENTO_VERSION
test -z "${ELASTICSEARCH}" && ELASTICSEARCH=$INPUT_ELASTICSEARCH

if [[ "$MAGENTO_VERSION" == "2.4."* ]]; then
    ELASTICSEARCH=1
fi

test -z "${MODULE_NAME}" && (echo "'module_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${COMPOSER_NAME}" && (echo "'composer_name' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${MAGENTO_VERSION}" && (echo "'ce_version' is not set in your GitHub Actions YAML file" && exit 1)
test -z "${MAGENTO_MARKETPLACE_USERNAME}" && (echo "'MAGENTO_MARKETPLACE_USERNAME' is not available as a secret" && exit 1)
test -z "${MAGENTO_MARKETPLACE_PASSWORD}" && (echo "'MAGENTO_MARKETPLACE_PASSWORD' is not available as a secret" && exit 1)

MAGENTO_ROOT=/tmp/m2
PROJECT_PATH=$GITHUB_WORKSPACE

echo "MySQL checks"
nc -z -w1 mysql 3306 || (echo "MySQL is not running" && exit)
php /docker-files/db-create-and-test.php magento2 || exit
php /docker-files/db-create-and-test.php magento2test || exit

echo "Setup Magento credentials"
composer global require hirak/prestissimo
composer global config http-basic.repo.magento.com $MAGENTO_MARKETPLACE_USERNAME $MAGENTO_MARKETPLACE_PASSWORD

echo "Prepare composer installation for $MAGENTO_VERSION"
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition:${MAGENTO_VERSION} $MAGENTO_ROOT --no-install --no-interaction --no-progress

echo "Setup extension source folder within Magento root"
cd $MAGENTO_ROOT
mkdir -p local-source/
cd local-source/
cp -R ${GITHUB_WORKSPACE}/${MODULE_SOURCE} $MODULE_NAME

echo "Removing unneeded packages"
composer require yireo/magento2-replace-bundled --no-update --no-interaction
composer require yireo/magento2-replace-sample-data --no-update --no-interaction

echo "Configure extension source in composer"
cd $MAGENTO_ROOT
composer config repositories.local-source path local-source/\*
composer require $COMPOSER_NAME:@dev --no-update --no-interaction

if [[ ! -z "$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" && -f "${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT" ]] ; then
    echo "Running custom pre-installation script: ${INPUT_MAGENTO_PRE_INSTALL_SCRIPT}"
    . ${GITHUB_WORKSPACE}/$INPUT_MAGENTO_PRE_INSTALL_SCRIPT
fi

echo "Run installation"
COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-interaction --no-progress --no-suggest

if [[ "$MAGENTO_VERSION" == "2.3.4" ]]; then
    # Somebody hacked the Magento\Setup\Controller\Landing.php file to add Laminas MVC which is not installed in 2.3.4
    curl -s https://gist.githubusercontent.com/jissereitsma/51742489c6e97138363c93983a034af2/raw/1f14af19a64195b1246263513aba594726e5d72a/remove-laminas-from-setup-landing-controller.patch | patch -p0
fi

echo "Gathering specific Magento setup options"
SETUP_ARGS="--base-url=http://magento2.test/ \
--db-host=mysql --db-name=magento2 \
--db-user=root --db-password=root \
--admin-firstname=John --admin-lastname=Doe \
--admin-email=johndoe@example.com \
--admin-user=johndoe --admin-password=johndoe!1234 \
--backend-frontname=admin --language=en_US \
--currency=USD --timezone=Europe/Amsterdam \
--sales-order-increment-prefix=ORD_ --session-save=db \
--use-rewrites=1"

if [[ "$ELASTICSEARCH" == "1" ]]; then
    SETUP_ARGS="$SETUP_ARGS --elasticsearch-host=es --elasticsearch-port=9200 --elasticsearch-enable-auth=0 --elasticsearch-timeout=60"
fi

echo "Run Magento setup: $SETUP_ARGS"
php -d memory_limit=2G bin/magento setup:install $SETUP_ARGS

echo "Enable the module"
cd $MAGENTO_ROOT
bin/magento module:enable ${MODULE_NAME}
bin/magento setup:db:status -q || bin/magento setup:upgrade

echo "Determine which phpunit.xml file to use"
if [[ -z "$INPUT_PHPUNIT_FILE" || ! -f "$INPUT_PHPUNIT_FILE" ]] ; then
    INPUT_PHPUNIT_FILE=/docker-files/phpunit.xml
fi

echo "Using PHPUnit file: $INPUT_PHPUNIT_FILE"
echo "Prepare for integration tests"
cd $MAGENTO_ROOT
cp /docker-files/install-config-mysql.php dev/tests/integration/etc/install-config-mysql.php
sed "s#%COMPOSER_NAME%#$COMPOSER_NAME#g" $INPUT_PHPUNIT_FILE > dev/tests/integration/phpunit.xml

curl -s https://gist.githubusercontent.com/jissereitsma/004993763b5333e17ac3ba80d931e270/raw/d37da0c283a2f244a41e79bb7ada49b58a2b2a3e/fix-memory-report-after-integration-tests.patch | patch -p0

echo "Run the integration tests"
cd $MAGENTO_ROOT/dev/tests/integration && php -d memory_limit=1G ../../../vendor/bin/phpunit -c phpunit.xml

