#!/usr/bin/env bash
export INDEX_IMAGE=quay.io/openshift-pipeline/`pipelines-index-4`.18:next
#export INDEX_IMAGE=quay.io/openshift-pipeline/rh-osbs/iib:935088
#export INDEX_IMAGE=quay.io/redhat-user-workloads/tekton-ecosystem-tenant/next/index-4.18@sha256:7177fe823ba2ab2b16ef4ce018b782635f0c97c94944798466abe8f9cf7fcaa4
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd && echo x)"
oc delete subscription openshift-pipelines-operator -n openshift-operators --ignore-not-found
oc delete CatalogSource custom-osp-nightly -n openshift-marketplace --ignore-not-found
oc delete csv --all
oc -n openshift-operators delete deployment --all
oc -n openshift-operators delete tektonInstallerSet --all
