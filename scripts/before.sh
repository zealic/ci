#!/usr/bin/env sh
# Auto detect docker service host
if nc -z docker 2375 2>/dev/null; then
  export DOCKER_HOST=tcp://docker:2375
elif nc -z localhost 2375 2>/dev/null ; then
  # see also:
  # - https://docs.gitlab.com/runner/executors/kubernetes.html#using-dockerdind
  # - https://gitlab.com/gitlab-org/gitlab-runner/issues/2623
  export DOCKER_HOST=tcp://127.0.0.1:2375
fi

# Login Gitlab
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY 2> /dev/null

# Write deploy key
if [[ ! -z "$DEPLOY_KEY" ]] && [[ ! -e ~/.ssh/id_rsa ]]; then
  if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
  fi
  echo "$DEPLOY_KEY" > ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
fi

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

# Install packages
if [[ -e `which bash` ]]; then
  PACKAGES="${PACKAGES} bash"
fi

if [[ -e `which make` ]]; then
  PACKAGES="${PACKAGES} make"
fi

if [[ -e `which curl` ]]; then
  PACKAGES="${PACKAGES} curl"
fi

if [[ ! -z "${PACKAGES}" ]]; then
  apk add ${PACKAGES}
fi

# User defined before script
if [[ ! -z "$BEFORE_SCRIPT" ]]; then
  eval "$BEFORE_SCRIPT"
fi
