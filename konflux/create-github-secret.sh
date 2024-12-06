#!/bin/bash

set -x
oc create secret generic github-auth-secret --from-literal github-auth-key=$GITHUB_TOKEN -n openshift-pipelines
PATCH_DATA="{\"spec\":{\"pipeline\":{\"git-resolver-config\":{\"api-token-secret-key\":\"github-auth-key\", \"api-token-secret-name\":\"github-auth-secret\", \"api-token-secret-namespace\":\"openshift-pipelines\", \"default-revision\":\"main\", \"fetch-timeout\":\"1m\", \"scm-type\":\"github\"}}}}"
oc patch  tektonconfig config -p "$PATCH_DATA" --type=merge




#eaas-spacerequest-jvpkr-4hqfn

