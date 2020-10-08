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
on: [push, pull_request]

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
on: [push, pull_request]

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
on: [push, pull_request]

jobs:
  phpmd:
    name: M2 Mess Detector
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-mess-detector@master
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
on: [push, pull_request]

jobs:
  phpstan:
    name: M2 PHPStan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-phpstan@master
```
