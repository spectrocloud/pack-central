# Knative Operator

The [Knative Operator](https://knative.dev/docs/install/operator/) manages the
lifecycle of Knative's serving and eventing components. It watches two custom
resources — `KnativeServing` and `KnativeEventing` — and installs, upgrades and
reconfigures the Knative stack behind them, so the Knative version is pinned by a
CR rather than by a Helm release.

This pack deploys the operator itself: the controller and webhook Deployments,
their RBAC (including the `knative-serving` and `knative-eventing` operator
roles), the `operator-webhook-certs` Secret, and the `KnativeServing` and
`KnativeEventing` CRDs.

> This README was written for the pack — the upstream chart ships no README of
> its own. The parameter table below is derived from the chart's `values.yaml`.

## Prerequisites

- Kubernetes **1.25 or newer** — the floor the chart declares via
  `knative_operator.kubernetes_min_version` (passed to the operator as
  `KUBERNETES_MIN_VERSION`).

## Deployment

The pack installs into the `knative-operator` namespace as Helm release
`knative-operator`. Both are set in this pack's `values.yaml`
(`pack.namespace`, `pack.releaseNameOverride`) and can be changed there before
deploying.

The images this pack mirrors:

```
gcr.io/knative-releases/knative.dev/operator/cmd/operator:v1.23.1
gcr.io/knative-releases/knative.dev/operator/cmd/webhook:v1.23.1
registry.k8s.io/cluster-inventory-api/kubeconfig-secretreader:v0.1.3
registry.k8s.io/cluster-inventory-api/secretreader:v0.1.3
```

The first two are what the chart pulls with its default values. The last two are
the plugin images the chart documents for multi-cluster support
(`knative_operator.multicluster.plugins`); they are only mounted as volumes when
`multicluster.enabled` is set, so they are mirrored here to keep that feature
usable air-gapped, not because a default install needs them.

### Air-gap caveat: Serving and Eventing images

This pack mirrors the **operator only**. When you create a `KnativeServing` or
`KnativeEventing` CR, the operator deploys the Knative Serving/Eventing workloads,
which pull their own images from `gcr.io/knative-releases/…` — those are not in
this pack's list, because they belong to the Knative release the CR asks for, not
to the operator.

For a fully air-gapped install, mirror the serving/eventing images for whichever
Knative version you intend to run, and point the CR at that mirror:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    default: your-mirror.example.com/knative-releases
```

## Configuration

Every parameter below lives under `charts.knative-operator` in this pack's
`values.yaml`, using the chart's own key names.

| Parameter | Description | Default |
|---|---|---|
| `knative_operator.multicluster.enabled` | Enable multi-cluster support via the Cluster Inventory API | `false` |
| `knative_operator.multicluster.accessProvidersConfig` | Access-provider configuration (`providers[]`). **Required** when multicluster is enabled — the chart fails to render without it | `{}` |
| `knative_operator.multicluster.plugins` | Plugin images mounted into the operator as `image` volumes; each `mountPath` must be absolute and each provider's `execConfig.command` must sit under one | `[]` |
| `knative_operator.multicluster.remoteDeploymentsPollInterval` | Polling cadence for spoke deployment readiness | `10s` |
| `knative_operator.knative_operator.image` | Controller image repository | `gcr.io/knative-releases/knative.dev/operator/cmd/operator` |
| `knative_operator.knative_operator.tag` | Controller image tag | `v1.23.1` |
| `knative_operator.operator_webhook.image` | Webhook image repository | `gcr.io/knative-releases/knative.dev/operator/cmd/webhook` |
| `knative_operator.operator_webhook.tag` | Webhook image tag | `v1.23.1` |
| `knative_operator.kubernetes_min_version` | Minimum Kubernetes version the operator enforces | `v1.25.0` |
| `…operator_webhook.affinity` | Webhook pod anti-affinity (spreads replicas across nodes by default) | `{}` (see `values.yaml`) |
| `…knative_operator.resources` / `…operator_webhook.resources` | Requests and limits for each Deployment | `100m/100Mi` → `1000m/1000Mi` and `100m/100Mi` → `500m/500Mi` |
| `…containerSecurityContext` | Container security context for both Deployments | non-root, read-only root filesystem, no privilege escalation |

## Provenance

Packaged from the upstream chart
`https://knative.github.io/operator/knative-operator`, version `v1.23.1`
(sha256 `fbdab558474a547cb244904fb947f4fe028dcbc8049b8f5dda029d7ac07ac889`,
matching the repository index). The chart in `charts/` was repackaged from the
extracted tree and verified byte-identical to upstream — no local modifications.

Note that the chart's `version` is `1.23.1` while the repository, the tarball
name and the image tags all use `v1.23.1`; the pack version follows the chart,
so it is `1.23.1`. The chart declares no `appVersion`, and no template reads
`.Chart.AppVersion`, so nothing is affected by its absence.

Pack icon: the Knative mark from the [CNCF artwork
repository](https://github.com/cncf/artwork/tree/main/projects/knative)
(`projects/knative/icon/color/knative-icon-color.png`).
