SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kind delete cluster --name kind


kind create cluster --name kind --config $SCRIPT_DIR/kind-config.yaml

