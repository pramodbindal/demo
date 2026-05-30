STAGE=${1:-core}
ENVIRONMENT=${2:-staging}
RELEASE=${2:-1.22.2}


case "$ENVIRONMENT" in
  "staging")
    ENV=${2:-stage}
    ;;
  "production")
    ENV=${2:-prod}
    ;;
  *)
    echo "Invalid selection! $ENVIRONMENT"
    exit 1
    ;;
esac

BRANCH="release-v${RELEASE%.*}.x"


function get_snapshots() {
    MINOR_RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"-"$2}')
    export RELEASE MINOR_RELEASE ENV ENVIRONMENT
    oc get snapshot \
    -l "pac.test.appstudio.openshift.io/event-type=push" \
    --sort-by=.metadata.creationTimestamp \
    -o json | \
    jq -r '
      [ .items[]
      | select(.metadata.labels["appstudio.openshift.io/application"] != null and (.metadata.labels["appstudio.openshift.io/application"]
      | contains(env.MINOR_RELEASE))) ]
      | group_by(.metadata.labels["appstudio.openshift.io/application"])
      | map(.[-1])
      | map({ application: .spec.application, snapshot: .metadata.name })
    '> snapshots.json
}


function generate_yamls() {
  GENERATED_FILES=()

  # Read the JSON array element by element
  while read -r item; do

    # Extract the application and snapshot values and export them as environment variables
    export APPLICATION=$(echo "$item" | jq -r '.application')
    export SNAPSHOT=$(echo "$item" | jq -r '.snapshot')
    export RELEASE_PLAN=$(
       oc get releaseplan -o json | jq -r --arg APP $APPLICATION '
       [
         .items[]
         | select(.spec.application == $APP and (.metadata.name | contains("stage")))
         |.metadata.name
       ]
       |.[-1]'
    )
    # Define an output filename
    OUTPUT_FILE="release-${APPLICATION}.yaml"

    # Use envsubst to inject the exported variables into the template
    echo "---" > "$OUTPUT_FILE"
    envsubst < release-template.yaml >> "$OUTPUT_FILE"

  #  echo "Created: $OUTPUT_FILE"
    # 2. Add the filename to the array
    GENERATED_FILES+=("$OUTPUT_FILE")
  done < <(jq -c '.[]' snapshots.json  )
}


function release_application() {
    app=$1
    # Loop through the generated files in the array
    for file in "${GENERATED_FILES[@]}"; do
      # Check if the filename contains the word "core"
      if [[ "$file" == *"${app}"* ]]; then
        echo "Found core release file. Applying: $file"
        oc create -f $file
      fi
    done
}

COUNTER=1

echo "STEP:  Get Snapshots"
get_snapshots


echo "STEP:  Generating Release YAMLs..."
generate_yamls

case "$STAGE" in
  "core")
    release_application core
    ;;
  "bundle")
    echo  "STEP:  Update Bundle to use ${ENV} images"
    #gh workflow run operator-update-images.yaml -f environment=$ENVIRONMENT --ref $BRANCH -R openshift-pipelines/operator
    echo "STEP:  Wait for Bundle build to complete"
    #tkn pr logs operator-1-22-bundle-on-push-tq2td -f
    release_application bundle
    ;;
  "index")
    echo "STEP:  Merge Bundle Nudge PR"
    echo "STEP:  Wait for Index Builds OLM to use ${ENVIRONMENT} images"
    echo "STEP:  Release Index Images"
    release_application index
    echo "STEP:  Send Slack Notification"
    oc get release -l pac.test.appstudio.openshift.io/sha=0e697c27269fde0396be689fbb81b042ef25da2f -o jsonpath="{.items[*].status.artifacts.index_image}"  | jq -s 'add | to_entries | sort_by(.key) |
     from_entries'
    ;;
  *)
    echo "Invalid selection! $STAGE"
    exit 1
    ;;
esac



















