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
          MYSQL_SQL_TO_RUN: 'GRANT ALL ON *.* TO "root"@"%";'
        ports:
          - 3306:3306
        options: --tmpfs /tmp:rw --tmpfs /var/lib/mysql:rw --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    steps:
      - uses: actions/checkout@v2
      - uses: docker://yireo/github-actions-magento-integration-tests:7.4
        env:
            MAGENTO_VERSION: '2.3.5-p2'
            MAGENTO_MARKETPLACE_USERNAME: ${{ secrets.MAGENTO_MARKETPLACE_USERNAME }}
            MAGENTO_MARKETPLACE_PASSWORD: ${{ secrets.MAGENTO_MARKETPLACE_PASSWORD }}
            MODULE_NAME: Foo_Bar
            COMPOSER_NAME: foo/magento2-foobar
```

Make sure to modify the following values:
- `module_name` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `composer_name` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

You could also choose to switch PHP version, by changing the tag of the Docker image:

    - uses: docker://yireo/github-actions-magento-integration-tests:7.3

Next, make sure to add the secrets `MAGENTO_MARKETPLACE_USERNAME` and `MAGENTO_MARKETPLACE_USERNAME` to your GitHub repository under **Settings > Secrets**. Tip: You could also use the secrets to define the module and composer name: This way your workflow file remains
generic.

Additionally, you can add an environment variable `MAGENTO_PRE_INSTALL_SCRIPT` to run a script, after composer is
configured, but before the composer installation is run. Likewise, you can customize your PHPUnit procedure by supplying
a custom XML file using `PHPUNIT_FILE`. See `entrypoint.sh` for clearification.

### Maintenance of the Docker image
To use the `Dockerfile` of this package, a new image needs to be built and pushed to the Docker Hub:

    docker build -t VENDOR/IMAGE .
    docker push VENDOR/IMAGE

For instance with the vendor and image-name used in this package:

    docker build -t yireo/github-actions-magento-integration-tests .
    docker push yireo/github-actions-magento-integration-tests
