# Crossplane

Crossplane is an open source Kubernetes extension that transforms a Kubernetes
cluster into a universal control plane.

It allows platform teams to provision, manage, and compose infrastructure and
services using Kubernetes-style APIs, enabling consistent governance, security,
and automation across multiple environments and cloud providers.

---

## Prerequisites

To use this package, you must have:

- A Kubernetes cluster, minimum version **v1.27.0**
- Cluster-admin permissions
- Helm **v3.0.0+** (required for installing Crossplane via Helm)
- Internet access to pull container images and packages from OCI registries

---

## Parameters

Crossplane can be configured using Helm values during installation or upgrade.
The most relevant parameters are listed below.

### General Configuration

| Parameter | Description | Default |
|---------|-------------|---------|
| `replicas` | Number of Crossplane controller replicas | `1` |
| `leaderElection` | Enable leader election for Crossplane | `true` |
| `deploymentStrategy` | Deployment strategy for the pods | `RollingUpdate` |
| `hostNetwork` | Enable host networking for the pod | `false` |

### Image Configuration

| Parameter | Description | Default |
|---------|-------------|---------|
| `image.repository` | Crossplane image repository | `xpkg.crossplane.io/crossplane/crossplane` |
| `image.tag` | Crossplane image tag | Chart `appVersion` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Package Management

| Parameter | Description | Default |
|---------|-------------|---------|
| `provider.packages` | List of Provider packages to install | `[]` |
| `configuration.packages` | List of Configuration packages to install | `[]` |
| `function.packages` | List of Function packages to install | `[]` |

### Resources

| Parameter | Description | Default |
|---------|-------------|---------|
| `resourcesCrossplane.requests.cpu` | CPU request | `100m` |
| `resourcesCrossplane.requests.memory` | Memory request | `256Mi` |
| `resourcesCrossplane.limits.cpu` | CPU limit | `500m` |
| `resourcesCrossplane.limits.memory` | Memory limit | `1024Mi` |

> For the complete list of supported parameters, refer to the `values.yaml` file
> provided with this package.

---

## Upgrade

To upgrade Crossplane using Helm:

```bash
helm repo update

helm upgrade crossplane \
  --namespace crossplane-system \
  crossplane-stable/crossplane
```

---

## Usage

Crossplane is installed into a Kubernetes cluster and acts as a control plane
for managing infrastructure and services using Kubernetes APIs.

After installation, functionality is extended by installing Provider,
Configuration, or Function packages, which enable Crossplane to reconcile
external resources and compose higher-level abstractions.

Example of installing a Provider:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-palette
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-palette:v0.23.5
```

---

## References
https://docs.crossplane.io/
https://docs.crossplane.io/latest/concepts/
https://docs.crossplane.io/latest/concepts/providers/
https://marketplace.upbound.io/