#!/bin/bash
# If you are using open shift replace namespace tools to dev the location of where the pipeline runs
helm template chart/gitops-cd-secrets --namespace tools | kubectl apply -n tools -f -
