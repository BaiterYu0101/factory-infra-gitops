#!/bin/bash
echo "Starting Enterprise K8s Bootstrap..."

# Checking Homebrew, 2>&!, means no matter how, keep the screen clears
if ! command -v brew > /dev/null 2>&1; then  
    echo "Homebrew is not installed. Please install..."
    exit 1
fi

# Checking Orbstack
if ! docker info > /dev/null 2>&1; then
    echo "Docker engine is not running. Please start Orbstack or Docker Desktop."
    exit 1 
else
    echo "Docker engine is healthy."
fi

# Check Kind 
if ! command -v kind > /dev/null 2>&1; then
    echo "Kind is not installed. Automatically installing via Homebrew..."
    brew install kind
else
    kind_version=$(kind --version)
    echo "Kind had been installed ($kind_version)"
fi

# Check K8s CLI
if ! command -v kubectl > /dev/null 2>&1; then
    echo "kubectl not found. Automatically installing via Homebrew..."
    brew install kubernetes-cli
else
    K8s_version=$(kubernetes-cli --version)
    echo "Kubectl had been installed ($K8s_version)"
fi

# Check for the Multi-Node Cluster...^ means right here to start at the very beginning of the line and $ means must match end right here at the end of the line...
CLUSTER_NAME="factory-sandbox"
CONFIG_FILE="../config/kind-config.yaml"

echo "Bootstrapping $CLUSTER_NAME..."


if kind get cluster 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Kind cluster '$CLUSTER_NAME' is already running. System stable."
else 
    echo "Provisioning isolated 2-Node Cluster Topology via Kind..."
    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
fi

echo "All Dependencies Checks Done!"
kubectl get nodes