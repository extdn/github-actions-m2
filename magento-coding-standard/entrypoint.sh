#!/bin/sh -l

sh -c "/root/.composer/vendor/bin/phpcs --standard=Magento2 $GITHUB_WORKSPACE $*"
