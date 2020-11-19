# Magento 2 Integration Tests
To use this action, create a YAML file `.github/workflows/example.yml` in your extension folder, based upon the following contents:
```yaml
name: ExtDN Actions
on: [push]

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

Make sure to modify the following values:
- `module_name` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `composer_name` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

You could also choose to switch PHP version, by changing the tag of the Docker image:

    - uses: extdn/github-actions-m2/magento-integration-tests/7.3@master

Additionally, you can add an environment variable `MAGENTO_PRE_INSTALL_SCRIPT` to run a script, after composer is
configured, but before the composer installation is run. Likewise, you can customize your PHPUnit procedure by supplying
a custom XML file using `PHPUNIT_FILE`. And there is an environment variable `MAGENTO_POST_INSTALL_SCRIPT` to run a script, after the Magento setup has been completed, but before the tests
are run.

See `entrypoint.sh` for clearification.

