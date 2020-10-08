#!/bin/sh -l

echo "::add-matcher::/problem-matcher.json"

sh -c "/root/.composer/vendor/bin/phpcs --standard=Magento2 $GITHUB_WORKSPACE -s $*"
