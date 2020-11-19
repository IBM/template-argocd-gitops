#!/usr/bin/env bash

BOOTSTRAP_PATH="$1"
if [[ -z "${BOOTSTRAP_PATH}" ]]; then
  echo "The path to the configuration in the Git repository must be provided as the first argument"
  exit 1
fi

if ! git remote 1> /dev/null 2> /dev/null; then
  echo "Must be run from within the git directory of the bootstrap repo"
  exit 1
fi

GIT_REPO=$(git remote get-url origin)
if [[ "${GIT_REPO}" =~ ^git ]]; then
  GIT_REPO=$(echo "${GIT_REPO}" | sed "s~git@~https://~g" | sed "s~:~/~g" | sed "s/https\//https:/g")
fi

echo "Git repo: $GIT_REPO"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

argocd app create "${BOOTSTRAP_PATH}" \
  --repo "${GIT_REPO}" \
  --revision "${GIT_BRANCH}" \
  --path "${BOOTSTRAP_PATH}" \
  --dest-namespace $(oc project -q) \
  --dest-server https://kubernetes.default.svc \
  --project default \
  --sync-policy automated \
  --self-heal \
  --sync-option Prune=true
