#!/bin/bash
docker build -t yireo/github-actions-magento-integration-tests . || exit
docker push yireo/github-actions-magento-integration-tests
