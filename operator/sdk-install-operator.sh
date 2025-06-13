#!/usr/bin/env bash

set -x

NAMESPACE=openshift-operators
export KUBECONFIG=${KUBECONFIG:=$HOME/.kube/config}
echo $KUBECONFIG
podman run --rm \
  -v $KUBECONFIG:$KUBECONFIG --platform linux/amd64 \
  -e KUBECONFIG=$KUBECONFIG \
  quay.io/operator-framework/operator-sdk:latest \
  run bundle \
  --namespace $NAMESPACE \
quay.io/openshift-pipeline/pipelines-operator-bundle:main