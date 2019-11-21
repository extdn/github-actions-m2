# GitHub Actions for Magento 2 Extensions

This repository's aim is to provide a set of open sourced GitHub actions to write better tested Magento 2 extensions.

# Available Actions
### Magento Coding Standard
Provides an action that can be used in your GitHub workflow to execute the latest [Magento Coding Standard](https://github.com/magento/magento-coding-standard). 

#### How to use it

In your GitHub repository add the below as 
`.github/workflows/ci.yml`

```
name: Continous Integration
on: [push, pull_request]

jobs:
  build:
    name: Static Code Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
        with:
          fetch-depth: 1
      - uses: extdn/github-actions-m2/magento-coding-standard@v1.0.0
```
