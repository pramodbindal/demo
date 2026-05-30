#!/usr/bin/env bash
set -euo pipefail

# Example: your org and token
ORG="pruner"
TOKEN="EY0DTOMVPO3CMH0B5TJ123GIG5GALKCWVUO2927KJW5U7JO89MBU55NHDJJQ31X2"


# Extract all quay.io image references from the ko output
# Matches lines like quay.io/org/repo@sha256:...
REPOS=$(curl -Ls -H "Authorization: Bearer $TOKEN" \
  "https://quay.io/api/v1/organization/${ORG}/repositories?public=false&private=true")


echo $REPOS
#
## Make each repo public
#for REPO in $REPOS; do
#  echo "🔓 Making $REPO public..."
#  curl -s -o /dev/null -w "%{http_code}\n" \
#    -X PUT \
#    -H "Authorization: Bearer $QUAY_TOKEN" \
#    -H "Content-Type: application/json" \
#    "https://quay.io/api/v1/repository/${REPO#quay.io/}/changevisibility" \
#    -d '{"visibility": "public"}'
#done
