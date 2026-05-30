#!/usr/bin/env bash
oc get tektonconfig config
PHASE=$(oc get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
elapsed=0
timeout=1800  # 30 minutes
while [ "$PHASE" != "True" ];
do
oc get tektonconfig config
oc get po -n openshift-pipelines

# Check pod status for errors
error_pods=$(oc get po -n openshift-pipelines --no-headers | awk '$3 !~ /Running|Pending|ContainerCreating|Completed/ {print}' || true)
if [ -n "$error_pods" ]; then
  echo "Error: Pods in failed state detected:"
  echo "$error_pods"
  echo "TektonConfig installation failed due to pod errors"

  oc describe  $pod
  oc logs $pod


  exit 1
fi

sleep 30
elapsed=$((elapsed + 30))
if [ $elapsed -ge $timeout ]; then
  echo "Timeout: TektonConfig not ready after 30 minutes"
  exit 1
fi
PHASE=$(oc get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
done