#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl apply -f $SCRIPT_DIR/image-copier-task.yaml

tkn task start image-copier \
  --serviceaccount=release-registry-openshift-pipelines-operator-1-20 \
  --param TAG="v1.22-stage" \
  --param JSON_CONTENT="$(cat $SCRIPT_DIR/index.json)" \
  --showlog


#kubectl delete -f $SCRIPT_DIR/image-copier-task.yaml
