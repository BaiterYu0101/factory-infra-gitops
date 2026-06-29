#!/bin/bash
echo "Starting Enterprise K8s Bootstrap..."

# Checking Homebrew
if ! command -v brew > /dev/null 2>&1; then  
    echo "Homebrew is not installed. Please install..."
    exit 1
fi

# Checking Orbstack / Docker Engine
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
    echo "Kind has been installed ($kind_version)"
fi

# Check K8s CLI
if ! command -v kubectl > /dev/null 2>&1; then
    echo "kubectl not found. Automatically installing via Homebrew..."
    brew install kubernetes-cli
else
    # Fixed: Querying binary instead of package name formula
    K8s_version=$(kubectl version --client --short 2>/dev/null || kubectl version --client | head -n 1)
    echo "Kubectl has been installed ($K8s_version)"
fi

# Verify Host Ports 80 and 443 are clear to prevent container provisioning deadlock
echo "Verifying network port availability on host machine..."
for port in 80 443; do
    if lsof -i -P -n | grep -i "LISTEN" | grep -q "[:\.]${port} "; then
        echo "Port $port is already being bound as a local server on your host machine!"
        echo "Please stop any local web servers or conflicting Docker containers first."
        exit 1
    fi
done
echo "Host network ports 80/443 are clear. Node mapping safe."

# Cluster Configuration Definitions
CLUSTER_NAME="factory-sandbox"
CONFIG_FILE="../config/kind-config.yaml"

echo "Bootstrapping $CLUSTER_NAME..."

# Fixed: Changed 'get cluster' to 'get clusters'
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "Kind cluster '$CLUSTER_NAME' is already running. System stable."
else 
    echo "Provisioning isolated 2-Node Cluster Topology via Kind..."
    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
fi

echo "All Dependencies Checks Done!"
kubectl get nodes