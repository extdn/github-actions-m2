#!/bin/sh -l

# Copy the matcher to a shared volume with the host; otherwise "add-matcher"
# can't find it.
cp /problem-matcher.json ${HOME}/
echo "::add-matcher::${HOME}/problem-matcher.json"

cd $GITHUB_WORKSPACE

test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD=$INPUT_PHPCS_STANDARD
test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY=$INPUT_PHPCS_SEVERITY
test -z "${PHPCS_REPORT}" && PHPCS_REPORT=$INPUT_PHPCS_REPORT

test -z "${PHPCS_STANDARD}" && PHPCS_STANDARD=Magento2
test -z "${PHPCS_SEVERITY}" && PHPCS_SEVERITY=8
test -z "${PHPCS_REPORT}" && PHPCS_REPORT=checkstyle

sh -c "/root/.composer/vendor/bin/phpcs --report=${PHPCS_REPORT} --severity=${PHPCS_SEVERITY} --standard=$PHPCS_STANDARD $GITHUB_WORKSPACE -s $*"
