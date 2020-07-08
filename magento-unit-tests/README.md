# Magento 2 Unit Tests
To use this action, create a YAML file `.github/workflows/example.yml` in your extension folder, based upon the following contents:
```yaml
name: ExtDN Actions
on: [push, pull_request]

jobs:
  unit-tests:
    name: Magento 2 Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: M2 Unit Tests with Magento 2
        uses: extdn/github-actions-m2/magento-unit-tests@master
        env:
            MAGENTO_MARKETPLACE_USERNAME: ${{ secrets.MAGENTO_MARKETPLACE_USERNAME }}
            MAGENTO_MARKETPLACE_PASSWORD: ${{ secrets.MAGENTO_MARKETPLACE_PASSWORD }}
        with:
            module_name: Foo_Bar
            composer_name: foo/magento2-foobar
            ce_version: 2.3.5
```

Make sure to modify the following values:
- `module_name` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `composer_name` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

Next, make sure to add the secrets `MAGENTO_MARKETPLACE_USERNAME` and `MAGENTO_MARKETPLACE_USERNAME` to your GitHub repository under **Settings > Secrets**.

### Todo
- Make the PHP version dynamic too

### Maintenance of the Docker image
To use the `Dockerfile` of this package, a new image needs to be built and pushed to the Docker Hub:

    docker build -t VENDOR/IMAGE .
    docker push VENDOR/IMAGE

For instance with the vendor and image-name used in this package:

    docker build -t yireo/github-actions-magento-unit-tests .
    docker push yireo/github-actions-magento-unit-tests
