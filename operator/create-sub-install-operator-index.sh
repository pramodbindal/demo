#!/usr/bin/env bash
export INDEX_IMAGE=quay.io/openshift-pipeline/pipelines-index-4.18:next
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd && echo x)"
oc delete subscription openshift-pipelines-operator -n openshift-operators --ignore-not-found
oc delete CatalogSource custom-osp-nightly -n openshift-marketplace --ignore-not-found
oc delete csv --all
cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: "custom-osp-nightly"
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${INDEX_IMAGE}
  displayName: "Custom OSP Nightly"
  publisher: Red Hat Local
  updateStrategy:
    registryPoll:
      interval: 30m
EOF

sleep 10
cat <<EOF | oc apply -f-

apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
#  channel: latest
  name: openshift-pipelines-operator-rh
  source: "custom-osp-nightly"
  sourceNamespace: openshift-marketplace
EOF
