#!/bin/bash

HELM_URL="$1"
if [[ -z "${HELM_URL}" ]]; then
  echo "HELM_URL is required as the first argument"
  exit 1
fi

kubectl patch configmap/argocd-cm -n tools --type='json' -p="[{\"op\": \"add\", \"path\": \"/data/helm.repositories\", \"value\": \"- name: helm-repository-location\n  url: ${HELM_URL}\"}]"
