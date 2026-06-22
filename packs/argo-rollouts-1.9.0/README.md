# Argo Rollouts Helm Chart

Helm chart for deploying Argo Rollouts in Kubernetes environments.

Argo Rollouts provides progressive delivery capabilities such as Blue/Green and Canary deployments for Kubernetes workloads.

Source repository:
https://github.com/argoproj/argo-rollouts

---

# Prerequisites

Before installing this chart, ensure the following requirements are met:

## Required

- Kubernetes >= 1.29
- Helm >= 3.0
- Cluster administrator permissions (recommended for cluster-wide installation)
- Access to the container registry hosting images
- CRD installation permissions

## Optional

- Ingress Controller
- Gateway API
- Prometheus Operator (for metrics collection)

---

# Parameters

## General Parameters

| Parameter | Default | Description |
|---|---|---|
| installCRDs | `true` | Install Argo Rollouts CRDs |
| clusterInstall | `true` | Deploy controller cluster-wide |
| keepCRDs | `true` | Preserve CRDs during uninstall |
| imagePullSecrets | `[]` | Registry authentication |

## Controller Parameters

| Parameter | Default |
|---|---|
| controller.replicas | `2` |
| controller.image.registry | `quay.io` |
| controller.image.repository | `argoproj/argo-rollouts` |
| controller.image.tag | `v1.9.0` |
| controller.metrics.enabled | `false` |

Example:

```yaml
controller:
  replicas: 2

  image:
    registry: quay.io
    repository: argoproj/argo-rollouts
    tag: v1.9.0

  metrics:
    enabled: true
```

## Dashboard Parameters

| Parameter | Default |
|---|---|
| dashboard.enabled | `false` |
| dashboard.image.registry | `quay.io` |
| dashboard.image.repository | `argoproj/kubectl-argo-rollouts` |
| dashboard.image.tag | `v1.9.0` |
| dashboard.service.type | `ClusterIP` |

Example:

```yaml
dashboard:
  enabled: true

  image:
    registry: quay.io
    repository: argoproj/kubectl-argo-rollouts
    tag: v1.9.0

  service:
    type: ClusterIP
```

---

# Upgrade

Update repositories:

```bash
helm repo update
```

Upgrade installation:

```bash
helm upgrade argo-rollouts argo/argo-rollouts \
  --namespace argo-rollouts \
  -f values.yaml
```

For upgrades introducing immutable selector changes:

```bash
helm upgrade argo-rollouts argo/argo-rollouts \
  --force
```

Validate rollout:

```bash
kubectl get pods -n argo-rollouts
kubectl get deployments -n argo-rollouts
```

---

# Usage

Install chart:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-rollouts \
  argo/argo-rollouts \
  --namespace argo-rollouts \
  --create-namespace \
  -f values.yaml
```

Enable dashboard:

```bash
helm upgrade argo-rollouts argo/argo-rollouts \
  --set dashboard.enabled=true
```

Access dashboard:

```bash
kubectl port-forward svc/argo-rollouts-dashboard 31000:3100
```

Open:

```text
http://localhost:31000
```

Validate installation:

```bash
kubectl get rollout -A
kubectl argo rollouts version
```

---

# References

- Argo Rollouts
  https://github.com/argoproj/argo-rollouts

- Documentation
  https://argo-rollouts.readthedocs.io/

- Helm Chart
  https://artifacthub.io/packages/helm/argo/argo-rollouts

- Values Reference
  https://github.com/argoproj/argo-helm/tree/main/charts/argo-rollouts

- Release Notes
  https://github.com/argoproj/argo-rollouts/releases
