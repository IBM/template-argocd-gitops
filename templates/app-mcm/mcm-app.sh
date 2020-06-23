#!/bin/sh
###################################################################################
# Register IBM Multi Cloud Mamanger App Configuration in MCM
#
# Author : Matthew Perrins
# email  : mjperrin@us.ibm.com
#
###################################################################################
echo "IBM MCM App Registration"

# the NAMESPACE and HELM_REPOSITORY
APP_NAME=$1
VERSION=$2
NAMESPACE=$3
CLUSTER=$4

if [[ $# -eq 0 ]] ; then
  echo "channel.sh {APP_NAME} {VERSION} {NAMESPACE} {CLUSTER}"
  exit
fi

# input validation
if [ -z "${APP_NAME}" ]; then
    echo "Please provide APP_NAME as first parameter"
    exit
fi

# input validation
if [ -z "${VERSION}" ]; then
    echo "Please provide your VERSION as second parameter"
    exit
fi

# input validation
if [ -z "${NAMESPACE}" ]; then
    echo "Please provide NAMESPACE as first parameter"
    exit
fi

# input validation
if [ -z "${CLUSTER}" ]; then
    echo "Please provide your CLUSER as second parameter"
    exit
fi

# Apply the yaml to MCM
cat mcm-app-template.yaml | sed "s/#APP_NAME/${APP_NAME}/g" \
                          | sed "s/#NAMESPACE/${NAMESPACE}/g" \
                          | sed "s/#VERSION/${VERSION}/g" \
                          | sed "s/#CLUSTER/${CLUSTER}/g" \
                         | kubectl apply -f -

echo "MCM App Registration Complete ...!"