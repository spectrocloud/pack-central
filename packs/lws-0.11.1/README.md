# LeaderWorkerSet

[LeaderWorkerSet](https://lws.sigs.k8s.io/) (LWS) is a Kubernetes API for
deploying a group of pods as a unit — a leader and its workers — scheduled
together and addressed as one. It is the workload primitive behind multi-node
inference serving (tensor/pipeline parallelism across pods) and is part of
`kubernetes-sigs`.

This pack deploys the LWS controller: the manager Deployment, its RBAC, the
webhook (with a self-signed certificate unless cert-manager is enabled), and the
`LeaderWorkerSet`, `DisaggregatedSet` and `DisaggregatedSetRoleScaler` CRDs.

## Prerequisites

- Kubernetes **1.34 or newer** — the versions LWS is tested against.
- (Optional) [cert-manager](https://cert-manager.io/docs/installation/) when
  `enableCertManager=true`; otherwise the chart issues its own certificate.

## Deployment

The pack installs into the `lws-system` namespace as Helm release `lws`. Both are
set in this pack's `values.yaml` (`pack.namespace`,
`pack.releaseNameOverride`) and can be changed there before deploying.

The controller image is mirrored from this pack's `pack.content.images`:

```
registry.k8s.io/lws/lws:v0.11.1
```

That list covers the chart's default values *and* every feature gate
(`enablePrometheus`, `enableCertManager`, `enableDisaggregatedSet`) switched on,
so a preset that turns one of them on still pulls from a mirror.

## Configuration

The parameters below are the chart's own (see the [upstream
chart](https://github.com/kubernetes-sigs/lws/tree/main/charts/lws) for the full
list); every one of them lives under `charts.lws` in this pack's `values.yaml`.

| Parameter | Description | Default |
|---|---|---|
| `enablePrometheus` | Create the ServiceMonitor / Prometheus RBAC | `false` |
| `enableCertManager` | Use cert-manager for the webhook certificate | `false` |
| `enableDisaggregatedSet` | Install the DisaggregatedSet roles and validating webhook (the CRD and controller are always installed) | `false` |
| `replicaCount` | Controller replicas | `1` |
| `image.manager.repository` | Controller image repository | `registry.k8s.io/lws/lws` |
| `image.manager.tag` | Controller image tag | `v0.11.1` |
| `imagePullSecrets` | Image pull secrets for the controller pod | `[]` |
| `resources.requests` | Controller resource requests (`cpu: 1`, `memory: 1Gi`) | `{}` |
| `nodeSelector` / `tolerations` / `affinity` | Controller placement | `{}` |
| `gangSchedulingManagement` | Gang-scheduling integration settings | `{}` |

## Provenance

Packaged from the upstream chart
`oci://registry.k8s.io/lws/charts/lws`, version `0.11.1`
(OCI digest `sha256:bf492d6b8310ad8177531a35cd6b559d6ba6e7cb1fb31192d9f6a825c7f7c4ac`).
The chart in `charts/` is unmodified upstream source, repackaged from the
extracted tree so the shipped tarball matches what was inspected.

Pack icon: the LWS mark from the [KubeDiagrams](https://github.com/philippemerle/KubeDiagrams)
icon set (`examples/lws/icons/lws.png`); the LWS project itself publishes no logo.
