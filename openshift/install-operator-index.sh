#!/usr/bin/env bash


#Create Secret
oc delete secret rosa
oc create secret  generic rosa --from-file=kubeconfig=$KUBE_HOME/rosa

export major=4
export minor=17

cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: custom-osp-nightly
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/openshift-pipeline/openshift-pipelines-pipelines-operator-bundle-container-index:v${major}.${minor}-candidate
  displayName: "Custom OSP Nightly"
  updateStrategy:
    registryPoll:
      interval: 30m
EOF
    sleep 10
    # Create the "correct" subscription
    oc delete subscription pipelines -n openshift-operators || true
    cat <<EOF | oc apply -f-
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: custom-osp-nightly
  sourceNamespace: openshift-marketplace
EOF