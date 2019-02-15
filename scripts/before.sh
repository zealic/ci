#!/usr/bin/env sh
# Login Gitlab
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY

# Encode deploy key without newline
ENCODED_KEY=`printf -e "$DEPLOY_KEY" | base64 | tr -d '\n'`

# Docker options
export BUILD_OPTS=" \
  --build-arg CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
  --build-arg REGISTRY_BASE=${CI_REGISTRY}/${CI_PROJECT_NAMESPACE} \
  --build-arg REGISTRY_IMAGE=${CI_REGISTRY_IMAGE} \
  --build-arg PROJECT_PATH=${CI_PROJECT_PATH} \
  --build-arg PROJECT_NAMESPACE=${CI_PROJECT_NAMESPACE} \
  --build-arg PROJECT_NAME=${CI_PROJECT_NAME} \
  --build-arg DEPLOY_KEY=$ENCODED_KEY \
"

# Install make
apk add make
