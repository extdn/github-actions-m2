#!/bin/sh -l
export PATH_TO_SOURCE=$GITHUB_WORKSPACE
sh -c "cd /m2/dev/tests/static && /m2/vendor/bin/phpunit -c /m2/dev/tests/static/phpunit.phpmd.xml $*"