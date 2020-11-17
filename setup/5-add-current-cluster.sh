#!/usr/bin/env bash

CURRENT_CLUSTER=$(kubectl config current-context)

argocd cluster add "${CURRENT_CLUSTER}"
