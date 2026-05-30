#!/usr/bin/env bash

VERSION=${1:-v1.23.0}
INDEX_IMAGE=${2:- quay.io/openshift-pipeline/pipelines-index-4.22:$VERSION}
#export INDEX_IMAGE=quay.io/redhat-user-workloads/tekton-ecosystem-tenant/pipelines-index-4.21:20b059ca8af87de6c2e514e94de5cf0eb23107aa
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd && echo x)"
oc delete subscription -n openshift-operators --ignore-not-found openshift-pipelines-operator-$VERSION
oc delete CatalogSource -n openshift-marketplace --ignore-not-found custom-operators


echo "Create Mirror"
cat <<EOF | oc apply -f-
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: pipelines-mirror
spec:
  imageDigestMirrors:
  - source: registry.stage.redhat.io/openshift-pipelines
    mirrors:
    - quay.io/openshift-pipeline
EOF


cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: "custom-operators"
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

if [[ "$VERSION" == "next" ||  "$VERSION" == "nightly" ]]; then
  CHANNEL="pipelines-5.0"
else
  CHANNEL=$(echo "$VERSION" | gsed -E 's/v?([0-9]+\.[0-9]+).*/pipelines-\1/')
fi

echo "CHANNEL : $CHANNEL"

sleep 10
cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator-$VERSION
  namespace: openshift-operators
spec:
  name: openshift-pipelines-operator-rh
  source: "custom-operators"
  sourceNamespace: openshift-marketplace
  channel: $CHANNEL
EOF
