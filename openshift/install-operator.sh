#!/usr/bin/env bash


NAMESPACE=openshift-operators
docker run \
  -v $HOME/.kube/:/root/.kube --platform linux/amd64 \
  -e KUBECONFIG=/root/.kube/config \
  quay.io/operator-framework/operator-sdk:latest \
  run bundle \
  --namespace $NAMESPACE \
    quay.io/redhat-user-workloads/tekton-ecosystem-tenant/operator-main/bundle@sha256:e06e655caad40269ab34e2ffbd48ca3ac88a021a8b82077e41b13ef5e66adcc6
#   quay.io/redhat-user-workloads/tekton-ecosystem-tenant/operator-main/bundle@sha256:df708564029c13d55efce11c5cfcdc4f4b3034c9ce8744dd9c06e19377e8b183


 tkn version