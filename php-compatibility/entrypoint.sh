#!/bin/sh -l

# Copy the matcher to a shared volume with the host; otherwise "add-matcher"
# can't find it.
cp /problem-matcher.json ${HOME}/
echo "::add-matcher::${HOME}/problem-matcher.json"

cd $GITHUB_WORKSPACE
test -z "${INPUT_RUNTIME}" && INPUT_RUNTIME=7.3-8.1
sh -c "/root/.composer/vendor/bin/phpcs --report=checkstyle --standard=PHPCompatibility --runtime-set testVersion $INPUT_RUNTIME $GITHUB_WORKSPACE -s $*"
