# Magento 2 Integration Tests
To use this action, create a YAML file `.github/workflows/example.yml` in your extension folder, based upon the following contents:
```yaml
name: ExtDN Actions
on: [push]

jobs:
  quick-integration-tests:
    name: Magento 2 Quick Integration Tests
    runs-on: ubuntu-latest
    services:
      es:
        image: docker.elastic.co/elasticsearch/elasticsearch:7.8.0
        ports:
          - 9200:9200
      mysql:
        image: mysql:5.7
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_SQL_TO_RUN: 'GRANT ALL ON *.* TO "root"@"%";'
        ports:
          - 3306:3306
        options: --tmpfs /tmp:rw --tmpfs /var/lib/mysql:rw --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    steps:
      - uses: actions/checkout@v4
      - name: M2 Integration Tests with Magento 2
        uses: extdn/github-actions-m2/magento-integration-tests@master
        env:
            MODULE_NAME: Foo_Bar
            COMPOSER_NAME: foo/magento2-foobar
            MAGENTO_VERSION: 2.3.5
```

Make sure to modify the following values:
- `module_name` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `composer_name` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

Additionally, you can add an environment variable `MAGENTO_PRE_INSTALL_SCRIPT` to run a script, after composer is
configured, but before the composer installation is run. Likewise, you can customize your PHPUnit procedure by supplying
a custom XML file using `PHPUNIT_FILE`. See `entrypoint.sh` for clearification.

### Todo
- Make the PHP version dynamic too

### Maintenance of the Docker image
To use the `Dockerfile` of this package, a new image needs to be built and pushed to the Docker Hub:

    docker build -t VENDOR/IMAGE .
    docker push VENDOR/IMAGE

For instance with the vendor and image-name used in this package:

    docker build -t yireo/github-actions-magento-quick-integration-tests .
    docker push yireo/github-actions-magento-quick-integration-tests
