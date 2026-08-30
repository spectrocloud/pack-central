# K8GB - Kubernetes Global Balancer

## Description

k8gb is a Kubernetes Global Load Balancer (GSLB) that provides DNS-based traffic management across multiple Kubernetes clusters. It enables automatic failover and load balancing by managing DNS records based on the health and availability of application endpoints.

## Prerequisites

Before deploying this pack, ensure that:

- Kubernetes 1.29 or later.
- A supported DNS provider is configured.
- A namespace is specified for the deployment.
- Network connectivity exists between participating clusters when using a multi-cluster deployment.

## CloudTypes Supported

Supported for all cloudTypes.

## Pack Contents

This pack deploys the following components:

- k8gb Operator
- Custom Resource Definitions (CRDs)
- CoreDNS
- ExternalDNS (optional)
- RBAC resources

## Configuration

The following Pack parameter is required:

| Parameter | Description |
|-----------|-------------|
| `pack.namespace` | Namespace where k8gb will be installed. |

Additional application settings can be customized through the `values.yaml` file.

## Presets

This pack provides two presets for configuring how k8gb discovers the external address used for DNS records.

### CoreDNS - ClusterIP 

Uses an Ingress resource for address discovery.

Requirements:

- An Ingress Controller (for example, NGINX Ingress Controller) must be installed.
- An Ingress resource must be created for the application.
- The Ingress must be labeled with:

```yaml
k8gb.io/ip-source=true
```

This is the recommended deployment model described in the official k8gb documentation for Ingress-based address discovery.

### CoreDNS - LoadBalancer (Default)

Uses the CoreDNS Service of type `LoadBalancer` to discover the external address.

Recommended for:

- Managed Kubernetes services that provide external LoadBalancers.
- Bare-metal environments using MetalLB.
- Environments where an Ingress Controller is not required.

No Ingress Controller or labeled Ingress resource is required when using this preset.

## Verification

After the deployment completes, verify that:

- All k8gb pods are in the `Running` state.
- The required CRDs have been installed.
- The k8gb controller is running successfully.

Example commands:

```bash
kubectl get pods -n k8gb
kubectl get svc -n k8gb
kubectl get crds | grep k8gb
kubectl logs -n k8gb deployment/k8gb
```

## References

- https://www.k8gb.io/latest/
- https://www.k8gb.io/latest/address_discovery/
- https://github.com/k8gb-io/k8gb