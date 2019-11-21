#!/bin/sh -l

sh -c "~/.composer/vendor/bin/phpcs --standard=Magento2 $GITHUB_WORKSPACE $*"
