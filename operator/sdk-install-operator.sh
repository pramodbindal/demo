#!/usr/bin/env bash

set -x
BUNDLE_IMAGE=${1:-quay.io/redhat-user-workloads/kueue-operator-tenant/kueue-bundle-dev-main:latest}
NAMESPACE=openshift-operators
export KUBECONFIG=${KUBECONFIG:=$HOME/.kube/config}
echo $KUBECONFIG


echo "Installing Operator from $BUNDLE_IMAGE"

docker run --rm \
  -v $KUBECONFIG:$KUBECONFIG --platform linux/amd64 \
  -e KUBECONFIG=$KUBECONFIG \
  quay.io/operator-framework/operator-sdk:latest \
  run bundle \
  --namespace $NAMESPACE $BUNDLE_IMAGE