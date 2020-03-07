#!/usr/bin/env sh
if [[ ! -z $DEBUG ]]; then
  set -x
fi

# Login Gitlab
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY 2> /tmp/docker-login.log
ret=$?
if [[ $ret -ne 0 ]]; then
  echo "Login Gitlab Registry failed."
  cat /tmp/docker-login.log
  exit $ret
fi

# Write deploy key
if [[ ! -z "$DEPLOY_KEY" ]] && [[ ! -e ~/.ssh/id_rsa ]]; then
  if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
  fi
  echo "$DEPLOY_KEY" > ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
fi

# Encode deploy key without newline
ENCODED_KEY=`awk -e 'BEGIN {print ENVIRON["DEPLOY_KEY"] }' | base64 | tr -d '\n'`

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

# User defined before script
if [[ ! -z "$BEFORE_SCRIPT" ]]; then
  eval "$BEFORE_SCRIPT"
fi
