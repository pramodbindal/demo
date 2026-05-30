#!/usr/bin/env bash
VERSION=${1:-v1.21.1}
export INDEX_IMAGE=quay.io/openshift-pipeline/pipelines-index-4.20:$VERSION
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd && echo x)"
cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: "custom-osp-$VERSION"
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${INDEX_IMAGE}
  displayName: "Custom OSP $VERSION"
  publisher: Red Hat Local
  updateStrategy:
    registryPoll:
      interval: 30m
EOF
