#!/bin/sh
###################################################################################
# Register IBM Multi Cloud Mamanger Helm Repository as a Channel in MCM
#
# Author : Matthew Perrins
# email  : mjperrin@us.ibm.com
#
###################################################################################
echo "IBM MCM Channel Registration"

# the NAMESPACE and HELM_REPOSITORY
NAMESPACE=$1
HELM_REPOSITORY=$2

if [[ $# -eq 0 ]] ; then
  echo "channel.sh {NAMESPACE} {HELM_REPOSITORY}"
  exit
fi

# input validation
if [ -z "${NAMESPACE}" ]; then
    echo "Please provide NAMESPACE as first parameter"
    exit
fi

# input validation
if [ -z "${HELM_REPOSITORY}" ]; then
    echo "Please provide your HELM_REPOSITORY as second paramter"
    exit
fi

# Apply the yaml to MCM
cat channel-template.yaml | sed "s/#NAMESPACE/${NAMESAPCE}/g" | sed "s@#HELM_REPOSITORY@${HELM_REPOSITORY}@g"| kubectl apply -f -

echo "Channel Registration Complete ...!"