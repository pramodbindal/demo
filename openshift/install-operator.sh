#!/usr/bin/env bash

docker run \
  -v $HOME/RedHat/kube:/root/.kube --platform linux/amd64 \
  -e KUBECONFIG=/root/.kube/hive \
  quay.io/operator-framework/operator-sdk:latest \
  run bundle \
  --namespace openshift-operators \
  quay.io/redhat-user-workloads/tekton-ecosystem-tenant/operator-main/bundle@sha256:e847ce42c4e36fb6a9b2ebde307634e990429cf5d590889d6d4c3e71ac86072c
