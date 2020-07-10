#!/bin/bash
docker build -t yireo/github-actions-magento-unit-tests .
docker push yireo/github-actions-magento-unit-tests
