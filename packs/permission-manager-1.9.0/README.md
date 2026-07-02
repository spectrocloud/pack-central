# Permission Manager

Permission Manager is a web-based RBAC management application for Kubernetes that simplifies permission administration through an intuitive and user-friendly interface.

---

## Prerequisites

Before installing Permission Manager, verify the following requirements:

* Kubernetes cluster available and accessible
* Helm 3.x installed
* Cluster administrator permissions
* Ingress Controller installed (optional)
* Namespace creation permissions

---

## Parameters

The following table describes the primary configurable parameters available in the chart.

| Parameter                    | Description                      | Default                             |
| ---------------------------- | -------------------------------- | ----------------------------------- |
| `replicaCount`               | Number of application replicas   | `1`                                 |
| `image.repository`           | Container image repository       | `quay.io/sighup/permission-manager` |
| `image.tag`                  | Container image version          | `1.9.0`                             |
| `image.pullPolicy`           | Image pull policy                | `IfNotPresent`                      |
| `service.type`               | Kubernetes service type          | `ClusterIP`                         |
| `service.port`               | Application service port         | `80`                                |
| `service.nodePort`           | NodePort value (optional)        | `null`                              |
| `ingress.enabled`            | Enable ingress exposure          | `false`                             |
| `autoscaling.enabled`        | Enable Horizontal Pod Autoscaler | `false`                             |
| `autoscaling.minReplicas`    | Minimum replicas                 | `1`                                 |
| `autoscaling.maxReplicas`    | Maximum replicas                 | `100`                               |
| `config.clusterName`         | Cluster display name             | `""`                                |
| `config.controlPlaneAddress` | Kubernetes API endpoint          | `""`                                |
| `config.basicAuthPassword`   | Basic authentication password    | `""`                                |

> Additional parameters can be configured directly in `values.yaml`.

---

## Upgrade

Upgrade an existing installation:

```bash
helm upgrade permission-manager ./charts/permission-manager \
  --namespace permission-manager
```

Apply updated configuration values:

```bash
helm upgrade permission-manager ./charts/permission-manager \
  -f values.yaml
```

Validate the deployment:

```bash
kubectl get pods -n permission-manager
```

---

## Usage

Install the package:

```bash
helm install permission-manager ./charts/permission-manager \
  --namespace permission-manager \
  --create-namespace
```

Verify installation:

```bash
kubectl get all -n permission-manager
```

If ingress is enabled, access the application using the configured hostname.

Example:

```text
https://permission-manager.example.com
```

---

## References

* Permission Manager Official Documentation
* Helm Documentation
* Kubernetes RBAC Documentation
* Chart `values.yaml`
