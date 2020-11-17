#!/usr/bin/env bash

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

curl -sSL "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64" -o /usr/local/bin/argocd && \
  chmod +x /usr/local/bin/argocd
