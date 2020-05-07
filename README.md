# GitHub Actions for Magento 2 Extensions

This repository's aim is to provide a set of open sourced GitHub actions to write better tested Magento 2 extensions.

# Available Actions
## Magento Coding Standard
Provides an action that can be used in your GitHub workflow to execute the latest [Magento Coding Standard](https://github.com/magento/magento-coding-standard). 

#### Screenshot
![Screenshot Coding Style Action](magento-coding-standard/screenshot.png?raw=true")

#### How to use it
In your GitHub repository add the below as 
`.github/workflows/ci.yml`

```
name: Continous Integration
on: [push, pull_request]

jobs:
  static:
    name: Static Code Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-coding-standard@master
```

---

## Magento Mess Detector
Provides an action that can be used in your GitHub workflow to execute the PHP Mess Detector rules included in Magento 2 ([link](https://github.com/magento/magento2/blob/2.3.4/dev/tests/static/framework/Magento/TestFramework/CodingStandard/Tool/CodeMessDetector.php)).

#### Screenshot
![Screenshot Mess Detector Action](magento-mess-detector/screenshot.png?raw=true")
#### How to use it
In your GitHub repository add the below as 
`.github/workflows/ci.yml`

```
name: Continous Integration
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
`.github/workflows/ci.yml`

```
name: Continous Integration
on: [push, pull_request]

jobs:
  phpstan:
    name: M2 PhpStan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: extdn/github-actions-m2/magento-phpstan@master
```
