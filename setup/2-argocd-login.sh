#!/usr/bin/env bash

ARGOCD_HOST=$(oc get route argocd-server -o jsonpath='{.spec.host}')

ARGOCD_USER="admin"
ARGOCD_PASSWORD=$(oc get secret argocd-cluster -o jsonpath='{.data.admin\.password}' | base64 -D)

argocd login "${ARGOCD_HOST}" --insecure --grpc-web --username "${ARGOCD_USER}" --password "${ARGOCD_PASSWORD}"
