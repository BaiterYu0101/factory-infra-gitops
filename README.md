# Sentinel-X Telemetry Pipeline

A GitOps-driven local DevOps sandbox for a cloud-native observability workflow.

This repository contains the bootstrap tooling and local Kubernetes configuration needed to launch a lightweight development cluster using `kind`, plus the initial cluster settings for ingress-ready deployment.

## Architecture Overview

- GitOps-managed infrastructure and deployment flow
- Local development cluster with a control-plane node labeled for ingress
- Standard entry points mapped to host ports `80` and `443` for browser-accessible testing

![DevOps_flow](./assets/pic/DevOps.png)

## What this repo contains

- `bash/bootstrap.sh` — dependency checks and local kind cluster provisioning
- `config/kind-config.yaml` — kind cluster definition, ingress node label, and host port mappings
- `assets/` — documentation and diagram assets for the project

## Prerequisites

- macOS
- Homebrew installed
- Docker engine or Orbstack running
- `kind` and `kubectl` (bootstrap script installs them if missing)
- Host ports `80` and `443` must be free before provisioning the cluster

## Quick start

From the repository root:

```bash
./bash/bootstrap.sh
```

The script will:

1. verify Homebrew is installed
2. verify Docker/Orbstack is running
3. install `kind` if needed
4. install `kubectl` if needed
5. verify host ports `80` and `443` are available
6. create a local cluster named `factory-sandbox`

## Cluster details

The local cluster is defined in `config/kind-config.yaml` and includes:

- a control-plane node with `ingress-ready=true`
- a worker node
- `extraPortMappings` for host `80` and `443` to the control-plane container

### Why `extraPortMappings` is included

This mapping makes local browser access easier for Ingress-based services by forwarding traffic from your Mac host into the kind control-plane container.

> Note: this is a local development convenience, not an enterprise production pattern.

## Recommended workflow

1. Bootstrap the local cluster
2. Deploy GitOps manifests or applications into the cluster
3. Use ingress to validate HTTP/HTTPS access via `http://localhost` and `https://localhost`
4. When moving to staging/production, replace host port mapping with a proper LoadBalancer or external ingress solution

## Manual commands

If you want to run the cluster manually:

```bash
kind create cluster --name factory-sandbox --config config/kind-config.yaml
kubectl get nodes
```

Delete the cluster when you are done:

```bash
kind delete cluster --name factory-sandbox
```

## Troubleshooting

- If the bootstrap script fails because ports are busy, stop any local service listening on `80` or `443`.
- If `kind` already has a cluster named `factory-sandbox`, delete it first or choose a different name.
- Verify Docker is running before starting the script.

## Notes for enterprise-style GitOps

This repo is intentionally small so you can start with a local DevOps workflow and scale later. In a production GitOps pipeline, you would typically:

- manage manifests declaratively in Git
- use an external load balancer or MetalLB for bare-metal
- avoid relying on host port mappings for production traffic

---

Happy building!
