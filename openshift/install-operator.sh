#!/usr/bin/env bash

docker run \
  -v $HOME/RedHat/kube:/root/.kube --platform linux/amd64 \
  -e KUBECONFIG=/root/.kube/rosa \
  quay.io/operator-framework/operator-sdk:latest \
  run bundle \
  --namespace openshift-operators \
  quay.io/redhat-user-workloads/tekton-ecosystem-tenant/operator-main/bundle@sha256:f743435c4d686ab3482681168fdb854d42feec0a94ab588e224d2efc44512669