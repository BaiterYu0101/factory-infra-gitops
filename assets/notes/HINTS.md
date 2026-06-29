### 🌐 Environment & Networking Architecture Note

**Why `extraPortMappings` is used in this Sandbox:**<br>
In this local sandboxed environment (`factory-sandbox`), the Kubernetes cluster runs isolated inside Docker containers via Kind. Because there is no native cloud provider to provision an external load balancer on a local laptop, port-forwarding constraints apply. We utilize `extraPortMappings` within `kind-config.yaml` to explicitly bind the host machine's ports `80` and `443` to the Control Plane container. This allows the local NGINX Ingress Controller to receive traffic directly from `localhost`.

**Production Target Mapping (AWS EKS Transition Stack):**
When promoting this infrastructure architecture to an enterprise cloud ecosystem:
1. `extraPortMappings` will be entirely removed from the infrastructure code.
2. The NGINX Ingress Controller will be deployed via Helm, leveraging the **AWS Load Balancer Controller**.
3. Kubernetes will automatically provision an external AWS **Network Load Balancer (NLB)** in a public subnet, mapping external incoming traffic securely down into the private EKS worker node subnets.