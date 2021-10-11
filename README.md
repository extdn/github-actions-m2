# GitHub Actions for Magento 2 Extensions

This repository's aim is to provide a set of open sourced GitHub actions to write better tested Magento 2 extensions.

# Available Actions
## Magento Coding Standard
Provides an action that can be used in your GitHub workflow to execute the latest [Magento Coding Standard](https://github.com/magento/magento-coding-standard). 

#### Screenshot
![Screenshot Coding Style Action](magento-coding-standard/screenshot.png?raw=true")

#### How to use it
In your GitHub repository add the below as 
`.github/workflows/coding-standard.yml`

```
name: ExtDN M2 Coding Standard
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  static:
    name: M2 Coding Standard
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-coding-standard@master
```

---
## Magento Integration tests
Run your Magento 2 integration tests via this Github Action. All you need is to add your tests. This action will set up the needed Magento services and set up. Please note this action will perform a Composer installation so will provide additional confirmation that this works as well.

#### Screenshot
![Screenshot Mess Detector Action](magento-integration-tests/screenshot.png?raw=true")
#### How to use it
In your GitHub repository add the below as 
`.github/workflows/integration.yml`

```
name: ExtDN M2 Integration Tests
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  integration-tests:
    name: Magento 2 Integration Tests
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:5.7
        env:
          MYSQL_ROOT_PASSWORD: root
        ports:
          - 3306:3306
        options: --tmpfs /tmp:rw --tmpfs /var/lib/mysql:rw --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
      es:
        image: docker.io/wardenenv/elasticsearch:7.8
        ports:
          - 9200:9200
        env:
          'discovery.type': single-node
          'xpack.security.enabled': false
          ES_JAVA_OPTS: "-Xms64m -Xmx512m"
        options: --health-cmd="curl localhost:9200/_cluster/health?wait_for_status=yellow&timeout=60s" --health-interval=10s --health-timeout=5s --health-retries=3
    steps:
      - uses: actions/checkout@v2
      - name: M2 Integration Tests with Magento 2 (Php7.4)
        uses: extdn/github-actions-m2/magento-integration-tests/7.4@master
        with:
          module_name: Foo_Bar
          composer_name: foo/magento2-foobar
          ce_version: '2.4.0'
```

The following images are provided for use

|Php   | Image  |
|---|---|
|7.4 | extdn/github-actions-m2/magento-integration-tests/7.4@master |
|7.3 | extdn/github-actions-m2/magento-integration-tests/7.3@master |
|7.2 | extdn/github-actions-m2/magento-integration-tests/7.2@master |

The following inputs are required:
| with  | description  |
|---|---|
| module_name   | Your Magento module name. Example: Foo_Bar   |
| composer_name   | Your composer name. Example: foo/magento2-bar   |
| ce_version  | Magento 2 Open Source version number. Example: 2.4.0  |




The default [phpunit.xml](https://github.com/extdn/github-actions-m2/blob/master/magento-integration-tests/docker-files/phpunit.xml) configuration will check the following folders for *Test files:

- Test/Integration
- tests/Integration
- tests/integration

If this phpunit file does not work for you can provide a relative path to your own PHPUnit file via phpunit_file

``` 
      - name: M2 Integration Tests with Magento 2 (Php7.4)
        uses: extdn/github-actions-m2/magento-integration-tests/7.4@master
        with:
          module_name: Foo_Bar
          composer_name: foo/magento2-foobar
          ce_version: '2.4.0'
          phpunit_file: './path/to/phpunit.xml'
```

Sometimes it may be needed to run additional commands before tests can run. For example to add or remove additional dependencies. Use the input magento_pre_install_script to provide a relative path to this script. Example

``` 
      - name: M2 Integration Tests with Magento 2 (Php7.4)
        uses: extdn/github-actions-m2/magento-integration-tests/7.4@master
        with:
          module_name: Foo_Bar
          composer_name: foo/magento2-foobar
          ce_version: '2.4.0'
          magento_pre_install_script: './.github/integration-test-setup.sh'
```

---

## Magento Mess Detector
Provides an action that can be used in your GitHub workflow to execute the PHP Mess Detector rules included in Magento 2 ([link](https://github.com/magento/magento2/blob/2.3.4/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/CodeMessDetector.php)).

#### Screenshot
![Screenshot Mess Detector Action](magento-mess-detector/screenshot.png?raw=true")
#### How to use it
In your GitHub repository add the below as 
`.github/workflows/mess-detector.yml`

```
name: ExtDN M2 Mess Detector
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  phpmd:
    name: M2 Mess Detector
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-mess-detector@master
```

---

## Magento Copy Paste Detector
Provides an action that can be used in your GitHub workflow to execute the PHP Copy Paste Detector rules included in Magento 2 ([link](https://github.com/magento/magento2/blob/2.3.4/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/CopyPasteDetector.php)).

#### How to use it
In your GitHub repository add the below as 
`.github/workflows/copy-paste-detector.yml`

```
name: ExtDN M2 Copy Paste Detector
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  phpmd:
    name: M2 Copy Paste Detector
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-copy-paste-detector@master
```

---

## Magento PHPStan
Provides an action that can be used in your GitHub workflow to execute the PHPStan rules included in Magento 2 ([link](https://github.com/magento/magento2/blob/2.3.5-p1/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/PhpStan.php)).

#### Screenshot
![Screenshot PHPStan Action](magento-phpstan/screenshot.png?raw=true")

#### How to use it
In your GitHub repository add the below as 
`.github/workflows/phpstan.yml`

```
name: ExtDN M2 PHPStan
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  phpstan:
    name: M2 PHPStan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-phpstan@master
        with:
          composer_name: foo/magento2-foobar
```

## Magento Performance Smoke Test
Provides an action that can be used in your GitHub workflow to execute blackfire.io profiling before and after installing extension code.

#### How to use it
In your GitHub repository add the below as 
`.github/workflows/performance.yml`

```
name: ExtDN M2 Performance Testing
on:
  push:
    branches:
      - master
  pull_request:

jobs:
  performance:
    name: M2 Performance Testing
    runs-on: ubuntu-latest
    env:
      DOCKER_COMPOSE_FILE: "./docker-compose.yml"
      EXTENSION_NAME: "Foo_Bar"
      EXTENSION_PACKAGE_NAME: "foo/magento2-foobar"

    steps:
      - uses: actions/checkout@v2
        name: Checkout files
        with:
          path: extension

      - name: Get composer cache directory
        id: composer-cache
        run: "echo \"::set-output name=dir::$(composer config cache-dir)\""
        working-directory: ./extension

      - name: Cache dependencies
        uses: actions/cache@v1
        with:
          path: ${{ steps.composer-cache.outputs.dir }}
          key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
          restore-keys: ${{ runner.os }}-composer-

      - name: Prepare ExtDN performance testing
        uses: extdn/github-actions-m2/magento-performance-setup@master
        env:
          BLACKFIRE_CLIENT_ID: ${{ secrets.BLACKFIRE_CLIENT_ID }}
          BLACKFIRE_CLIENT_TOKEN: ${{ secrets.BLACKFIRE_CLIENT_TOKEN }}
          BLACKFIRE_SERVER_ID: ${{ secrets.BLACKFIRE_SERVER_ID }}
          BLACKFIRE_SERVER_TOKEN: ${{ secrets.BLACKFIRE_SERVER_TOKEN }}

      - name: Install Magento
        run: >-
          docker-compose -f ${{ env.DOCKER_COMPOSE_FILE }} exec -T php-fpm
          bash -c 'cd /var/www/html/m2 && sudo chown www-data: -R /var/www/html/m2 && ls -al && id
          && php -f bin/magento setup:install --base-url=http://magento2.test/ --backend-frontname=admin --db-host=mysql --db-name=magento_performance_tests --db-user=root --db-password=123123q --admin-user=admin@example.com --admin-password=password1 --admin-email=admin@example.com --admin-firstname=firstname --admin-lastname=lastname'
      - name: Generate Performance Fixtures
        run: >-
          docker-compose -f ${{ env.DOCKER_COMPOSE_FILE }} exec -T php-fpm
          bash -c 'cd /var/www/html/m2
          && php -f bin/magento setup:performance:generate-fixtures setup/performance-toolkit/profiles/ce/small.xml
          && php -f bin/magento cache:enable
          && php -f bin/magento cache:disable block_html full_page'
      - name: Run Blackfire
        id: blackfire-baseline
        run: docker-compose -f ${{ env.DOCKER_COMPOSE_FILE }} run blackfire-agent blackfire --json curl http://magento2.test/category-1/category-1-1.html > ${{ github.workspace }}/baseline.json
        env:
          BLACKFIRE_CLIENT_ID: ${{ secrets.BLACKFIRE_CLIENT_ID }}
          BLACKFIRE_CLIENT_TOKEN: ${{ secrets.BLACKFIRE_CLIENT_TOKEN }}
          BLACKFIRE_SERVER_ID: ${{ secrets.BLACKFIRE_SERVER_ID }}
          BLACKFIRE_SERVER_TOKEN: ${{ secrets.BLACKFIRE_SERVER_TOKEN }}

      - name: Install Extension
        run: >-
          docker-compose -f ${{ env.DOCKER_COMPOSE_FILE }} exec -e EXTENSION_BRANCH=${GITHUB_REF#refs/heads/} -T php-fpm
          bash -c 'cd /var/www/html/m2
          && php -f vendor/composer/composer/bin/composer config repo.extension path /var/www/html/extension
          && php -f vendor/composer/composer/bin/composer require ${{ env.EXTENSION_PACKAGE_NAME }}:dev-$EXTENSION_BRANCH#${{ github.sha }}
          && php -f bin/magento module:enable ${{ env.EXTENSION_NAME }}
          && php -f bin/magento setup:upgrade
          && php -f bin/magento cache:enable
          && php -f bin/magento cache:disable block_html full_page'
      - name: Run Blackfire Again
        id: blackfire-after
        run: docker-compose -f ${{ env.DOCKER_COMPOSE_FILE }} run blackfire-agent blackfire --json curl http://magento2.test/category-1/category-1-1.html > ${{ github.workspace }}/after.json
        env:
          BLACKFIRE_CLIENT_ID: ${{ secrets.BLACKFIRE_CLIENT_ID }}
          BLACKFIRE_CLIENT_TOKEN: ${{ secrets.BLACKFIRE_CLIENT_TOKEN }}
          BLACKFIRE_SERVER_ID: ${{ secrets.BLACKFIRE_SERVER_ID }}
          BLACKFIRE_SERVER_TOKEN: ${{ secrets.BLACKFIRE_SERVER_TOKEN }}

      - name: Compare Performance Results
        uses: extdn/github-actions-m2/magento-performance-compare@master
```
Change these environment variables:
```
EXTENSION_NAME: "Foo_Bar"
EXTENSION_PACKAGE_NAME: "foo/magento2-foobar"
```

Additionally please create the following Github Secrets for this repository with the values available in your blackfire.io account:
```
BLACKFIRE_CLIENT_ID
BLACKFIRE_CLIENT_TOKEN
BLACKFIRE_SERVER_ID
BLACKFIRE_SERVER_TOKEN
```

### Magento Marketplace repository
With various of the GitHub Actions, you will need to setup Magento, with all of its packages. Normally, you would
use the official Magento Marketplace for this, which also requires you to setup authentication.

Amongst the environment variables, there is a variable `REPOSITORY_URL` which defaults - when kept empty -
to `https://repo-magento-mirror.fooman.co.nz/` - a mirror of the Magento Marketplace, that removes the
need of authentication.

If you want to use the original Magento Marketplace anyway, reset the `REPOSITORY_URL` variable and add
the marketplace credentials like this:

```yaml
jobs:
  unit-tests:
    env:
      REPOSITORY_URL: https://repo.magento.com/
      MAGENTO_MARKETPLACE_USERNAME: ${{ secrets.MAGENTO_MARKETPLACE_USERNAME }}
      MAGENTO_MARKETPLACE_PASSWORD: ${{ secrets.MAGENTO_MARKETPLACE_PASSWORD }}
```

Next, make sure to add the secrets `MAGENTO_MARKETPLACE_USERNAME` and `MAGENTO_MARKETPLACE_PASSWORD` to your GitHub repository under **Settings > Secrets**. Tip: You could also use the secrets to define the module and composer name: This way your workflow file remains generic.

Alternatively, the credentials could also be hard-coded :(

```yaml
jobs:
  unit-tests:
    env:
      MAGENTO_MARKETPLACE_USERNAME: foo
      MAGENTO_MARKETPLACE_PASSWORD: bar
```

