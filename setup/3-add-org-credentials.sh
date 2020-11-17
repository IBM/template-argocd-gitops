#!/usr/bin/env bash

GIT_REPO="$1"
if [[ -z "${GIT_REPO}" ]]; then
  GIT_REPO=$(git remote get-url origin | sed -E "s~(.*)/.*~\1~g")
fi

if [[ "${GIT_REPO}" =~ ^git ]]; then
  echo -n "Provide the path to the private SSH key for repo (${GIT_REPO}): "
  read KEY_PATH

  argocd repocreds add "${GIT_REPO}" \
    --ssh-private-key-path "${KEY_PATH}"
else
  echo -n "Username for git repo (${GIT_REPO}): "
  read GIT_USER

  echo -n "Personal access token for git repo (${GIT_REPO}): "
  read -s GIT_PASSWORD
  echo ""

  argocd repocreds add "${GIT_REPO}" \
    --username "${GIT_USER}" \
    --password "${GIT_PASSWORD}"
fi
