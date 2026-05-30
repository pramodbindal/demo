#!/bin/bash
BUNDLE_IMAGE=$1

contains_element() {
    local target="$1"
    shift
    local element
    for element in "$@"; do
        if [[ "$element" == "$target" ]]; then
            return 0 # 0 means true/success in Bash
        fi
    done
    return 1 # 1 means false/failure
}

if [ -z "$BUNDLE_IMAGE" ]; then
  echo "Usage: ./scan-bundle.sh <bundle-image-url>"
  exit 1
fi

echo "1. Scanning bundle image: $BUNDLE_IMAGE"
#trivy image "$BUNDLE_IMAGE"

echo "2. Extracting CSV manifests..."
mkdir -p /tmp/bundle_manifests
crane export "$BUNDLE_IMAGE" - | tar -xf - -C /tmp/bundle_manifests/

CSV_FILE=$(find /tmp/bundle_manifests -name "*.clusterserviceversion.yaml" | head -n 1)
RELATED_IMAGES=$(yq eval '.spec.relatedImages[].image' "$CSV_FILE")

echo "3. Found related images. Starting scans..."
COUNTER=1
scanned=()
for image in $RELATED_IMAGES; do
  if [[ "$image" == *"/openshift-pipeline"* ]]; then
      #echo "Skipping excluded image: $image"
      continue
  fi
  if contains_element "$image" "${scanned[@]}"; then
      continue
  fi
  echo "Scanning: $image"
  trivy image -q --severity HIGH,CRITICAL --format json --output "trivy_reports/${COUNTER}_related.json" --ignore-unfixed  "$image"
  ((COUNTER++))
  scanned+=($image)
done

echo "4. Merging all JSON files into one..."
# The -s (slurp) flag reads all the files and combines them into a single JSON array
jq -s '.' trivy_reports/*.json > final_combined_report.json

echo "Done! The combined report is saved as final_combined_report.json"



jq -r '["Affected Image", "CVE ID", "Severity", "Reported Date", "Affected Package"], (.[]? | .ArtifactName as $image | .Results[]?.Vulnerabilities[]? | [$image, .VulnerabilityID, .Severity, (.PublishedDate | split("T")[0]), .PkgName]) | @csv' final_combined_report.json > vulnerability_report.csv