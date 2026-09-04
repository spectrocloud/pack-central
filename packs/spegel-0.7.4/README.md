# Spegel

Spegel is a stateless, peer-to-peer OCI registry mirror for Kubernetes clusters. It enables nodes to share container images locally, reducing external registry traffic, improving image pull performance, and increasing resiliency during registry outages.

---

# Prerequisites

Before installing Spegel, ensure the following requirements are met:

* Kubernetes cluster version **1.29** or later.
* Helm 3.x.
* Container runtime **containerd**.
* Cluster nodes running Linux.
* Network connectivity between cluster nodes.
* Administrative permissions to install cluster-wide resources.

---

# Parameters

The following table describes the most commonly configured parameters for the Spegel Helm chart.

| Parameter                             | Description                                                        | Default                           |
| ------------------------------------- | ------------------------------------------------------------------ | --------------------------------- |
| `image.repository`                    | Spegel container image repository.                                 | `ghcr.io/spegel-org/spegel`       |
| `image.tag`                           | Overrides the image tag. By default, the chart AppVersion is used. | `""`                              |
| `image.pullPolicy`                    | Image pull policy.                                                 | `IfNotPresent`                    |
| `priorityClassName`                   | Priority class assigned to the DaemonSet pods.                     | `system-node-critical`            |
| `nodeSelector`                        | Node selector for scheduling Spegel pods.                          | `kubernetes.io/os=linux`          |
| `resources`                           | CPU and memory requests/limits for the Spegel container.           | Memory request/limit: `128Mi`     |
| `service.registry.port`               | Registry service port.                                             | `5000`                            |
| `service.registry.nodePort`           | NodePort used by the registry service.                             | `30021`                           |
| `service.registry.hostPort`           | HostPort exposed on each node.                                     | `30020`                           |
| `service.router.port`                 | Router service port.                                               | `5001`                            |
| `service.metrics.port`                | Metrics endpoint port.                                             | `9090`                            |
| `spegel.logLevel`                     | Logging level.                                                     | `INFO`                            |
| `spegel.resolveTags`                  | Resolve image tags to digests.                                     | `true`                            |
| `spegel.mirroredRegistries`           | Registries to mirror. Empty mirrors all registries.                | `[]`                              |
| `spegel.additionalMirrorTargets`      | Additional mirror registries.                                      | `[]`                              |
| `spegel.persistence.enabled`          | Enable persistent local cache.                                     | `true`                            |
| `spegel.persistence.hostPath`         | Host path used to store cached content.                            | `/var/lib/spegel`                 |
| `spegel.containerdSock`               | Path to the containerd socket.                                     | `/run/containerd/containerd.sock` |
| `spegel.containerdRegistryConfigPath` | Path to containerd registry configuration.                         | `/etc/containerd/certs.d`         |
| `serviceMonitor.enabled`              | Enable Prometheus ServiceMonitor.                                  | `false`                           |
| `grafanaDashboard.enabled`            | Deploy Grafana dashboard resources.                                | `false`                           |
| `verticalPodAutoscaler.enabled`       | Enable Vertical Pod Autoscaler.                                    | `false`                           |

Additional parameters are available in the chart's `values.yaml`.

---

# Upgrade

To upgrade an existing Spegel installation:

```bash
helm upgrade spegel <chart-path> \
  --namespace spegel \
  --values values.yaml
```

Verify that the DaemonSet has been successfully updated:

```bash
kubectl rollout status daemonset/spegel -n spegel
```

Check that all pods are running:

```bash
kubectl get pods -n spegel
```

---

# Usage

Install Spegel using Helm:

```bash
helm install spegel <chart-path> \
  --namespace spegel \
  --create-namespace
```

Verify the installation:

```bash
kubectl get pods -n spegel
```

```bash
kubectl get daemonset -n spegel
```

Check the registry service:

```bash
kubectl get svc -n spegel
```

View the container logs:

```bash
kubectl logs -n spegel daemonset/spegel
```

---

# References

* Spegel Documentation: https://spegel.dev/docs/getting-started/
* GitHub Repository: https://github.com/spegel-org/spegel
* Helm Chart: https://github.com/spegel-org/helm-charts
