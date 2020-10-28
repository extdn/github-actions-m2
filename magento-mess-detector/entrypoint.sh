#!/bin/sh -l
echo "Testing Code in "$GITHUB_WORKSPACE
sh -c "cd /m2/dev/tests/static && PATH_TO_SOURCE=$GITHUB_WORKSPACE /m2/vendor/bin/phpunit -c /m2/dev/tests/static/phpunit.phpmd.xml $*"