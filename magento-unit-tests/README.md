# Magento 2 Unit Tests
To use this action, create a YAML file `.github/workflows/example.yml` in your extension folder, based upon the following contents:
```yaml
name: ExtDN Actions
on: [push]
jobs:
  unit-tests:
    name: Magento 2 Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker://yireo/github-actions-magento-unit-tests:7.3
        env:
          MAGENTO_VERSION: '2.3.4'
          MODULE_NAME: Foo_Bar
          COMPOSER_NAME: foo/magento2-foobar
```

You can also run multiple combinations and reuse the same variables:

```yaml
name: ExtDN Actions
on: [push]
jobs:
  unit-tests:
    name: Magento 2 Unit Tests
    runs-on: ubuntu-latest
    env:
      MODULE_NAME: Foo_Bar
      COMPOSER_NAME: foo/magento2-foobar
    steps:
      - uses: actions/checkout@v4
      - uses: docker://yireo/github-actions-magento-unit-tests:7.3
        env:
          MAGENTO_VERSION: '2.3.4'
      - uses: docker://yireo/github-actions-magento-unit-tests:7.3
        env:
          MAGENTO_VERSION: '2.3.5-p2'
      - uses: docker://yireo/github-actions-magento-unit-tests:7.4
        env:
          MAGENTO_VERSION: '2.4.0'
```

Make sure to modify the following values:
- `module_name` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `composer_name` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

You could also choose to switch PHP version, by changing the tag of the Docker image:

    - uses: docker://yireo/github-actions-magento-unit-tests:7.4

### Maintenance of the Docker image
To use the `Dockerfile` of this package, a new image needs to be built and pushed to the Docker Hub:

    docker build -t VENDOR/IMAGE .
    docker push VENDOR/IMAGE

For instance with the vendor and image-name used in this package:

    docker build -t yireo/github-actions-magento-unit-tests .
    docker push yireo/github-actions-magento-unit-tests

The script `build-and-push.sh` is used for this purpose.
