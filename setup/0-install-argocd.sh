#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAMESPACE=$(oc project -q)

echo -n "Installing ArgoCD into ${NAMESPACE} namespace. Proceed? [Y/n] "
read proceed

cat "${SCRIPT_DIR}/templates/argocd-subscription.yaml" | sed "s/NAMESPACE/${NAMESPACE}/g" | oc apply -f -

echo "Wait for ArgoCD CRDs to be installed"
count=1
while [[ $count -lt 10 ]]; do
  if oc get crd argocds.argoproj.io 1> /dev/null 2> /dev/null; then
    echo "ArgoCD CRDs installed"
    break
  fi

  count=$((count + 1))
  sleep 20
done

oc apply -f "${SCRIPT_DIR}/templates/argocd-instance.yaml"

count=0
while [[ $count -lt 10 ]]; do
  if oc get deployment argocd-application-controller 1> /dev/null 2> /dev/null; then
    echo "ArgoCD application controller deployment created"
    break
  fi

  count=$((count + 1))
  sleep 20
done

DEPLOYMENTS=$(oc get deployment -n tools -l app.kubernetes.io/part-of=argocd --output=custom-columns=NAME:.metadata.name | grep -v NAME)

for deployment in ${DEPLOYMENTS}; do
  echo "Waiting for deployment: $deployment"
  oc rollout status deployment "${deployment}"
done
