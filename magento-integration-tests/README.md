# Magento 2 Integration Tests
To use this action, create a YAML file `.github/workflows/example.yml` in your extension folder, based upon the following contents:
```yaml
name: ExtDN Actions
on: [push, pull_request]

jobs:
  integration-tests:
    name: Magento 2 Integration Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: M2 Integration Tests with Magento 2
        uses: extdn/github-actions-m2/magento-integration-tests@master
        env:
            MAGENTO_MARKETPLACE_USERNAME: ${{ secrets.MAGENTO_MARKETPLACE_USERNAME }}
            MAGENTO_MARKETPLACE_PASSWORD: ${{ secrets.MAGENTO_MARKETPLACE_PASSWORD }}
        with:
            extension_vendor: Foo
            extension_module: Bar
            ce_version: 2.3.5
            php: 7.3 
```

Make sure to modify the following values:
- `extension_vendor` - for instance, `Foo` if your Magento 2 module is called `Foo_Bar`
- `extension_module` - for instance, `Bar` if your Magento 2 module is called `Foo_Bar`

Next, make sure to add the secrets `MAGENTO_MARKETPLACE_USERNAME` and `MAGENTO_MARKETPLACE_USERNAME` to your GitHub repository under **Settings > Secrets**.
