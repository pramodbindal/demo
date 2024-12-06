#!/usr/bin/env bash


kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/v0.9.1/manifests.yaml
kubectl wait deploy/kueue-controller-manager -nkueue-system --for=condition=available --timeout=5m

