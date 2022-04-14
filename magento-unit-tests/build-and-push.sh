#!/bin/bash
for tag in 7.2 7.3 7.4 8.1; do
    docker build -t yireo/github-actions-magento-unit-tests:$tag -f Dockerfile:$tag .
    docker push yireo/github-actions-magento-unit-tests:$tag
done
