#!/bin/sh -l

# Copy the matcher to a shared volume with the host; otherwise "add-matcher"
# can't find it.
cp /problem-matcher.json ${HOME}/
echo "::add-matcher::${HOME}/problem-matcher.json"

sh -c "/root/.composer/vendor/bin/phpcs --standard=Magento2 $GITHUB_WORKSPACE -s $*"
