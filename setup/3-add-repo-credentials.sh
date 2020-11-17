#!/usr/bin/env bash

GIT_REPO=$(git remote get-url origin)

if [[ "${GIT_REPO}" =~ ^git ]]; then
  GIT_REPO=$(echo "${GIT_REPO}" | sed "s~git@~https://~g" | sed "s~:~/~g")
fi

echo -n "Username for git repo (${GIT_REPO}): "
read GIT_USER

echo -n "Personal access token for git repo (${GIT_REPO}): "
read -p GIT_PASSWORD

argocd repo add "${GIT_REPO}" \
  --type git \
  --username "${GIT_USER}" \
  --password "${GIT_PASSWORD}" \
  --insecure-skip-server-verification
