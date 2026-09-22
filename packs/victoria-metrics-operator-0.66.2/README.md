# Victoria Metrics Operator

The [VictoriaMetrics Operator](https://docs.victoriametrics.com/operator/) is a Kubernetes operator that manages VictoriaMetrics monitoring and observability components through Custom Resources (CRs). Instead of hand-writing Deployments and StatefulSets, you declare objects such as `VMSingle`, `VMCluster`, `VMAgent`, `VMAlert`, `VMAuth`, and `VMAlertmanager`, and the operator reconciles them into running workloads. It also converts existing Prometheus Operator objects (`ServiceMonitor`, `PodMonitor`, `PrometheusRule`, and others) into their VictoriaMetrics equivalents, easing migration from a Prometheus-based stack.

This pack installs the operator (app version `v0.73.1`) and its Custom Resource Definitions. It does not deploy any monitoring workloads on its own — you create the VictoriaMetrics CRs after the operator is running.


## Prerequisites

- A running Kubernetes cluster on version `1.25.0` or later.
- Helm-based add-on support in Palette (this is a Helm chart-based pack).
- Sufficient cluster resources for the operator and any VictoriaMetrics components you later create.
- For air-gapped or offline environments, mirror the operator image and every managed-component image the operator may pull. See the [References](#references) for the image list.


## Parameters

The pack is configured under the `charts.victoria-metrics-operator` key. The most commonly adjusted parameters are listed below.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `image.repository` | Operator image repository. | String | `victoriametrics/operator` | No |
| `image.tag` | Operator image tag. Overrides `Chart.AppVersion` when set. | String | `""` (uses `v0.73.1`) | No |
| `global.image.registry` | Registry prefix shared across the operator and all managed components. Set this to point every image at a private/mirror registry. | String | `""` | No |
| `replicaCount` | Number of operator replicas. | Int | `1` | No |
| `watchNamespaces` | Namespaces the operator watches. Empty means all namespaces. | Array | `[]` | No |
| `operator.disable_prometheus_converter` | Disables conversion of Prometheus Operator objects into VictoriaMetrics objects. | Bool | `false` | No |
| `admissionWebhooks.enabled` | Enables the validating admission webhook for VictoriaMetrics CRs. | Bool | `true` | No |
| `crds.enabled` | Manages CRD creation through the operator chart. | Bool | `true` | No |
| `env` | Extra operator environment variables, including `VM_*DEFAULT_VERSION` / `VM_*DEFAULT_IMAGE` overrides for managed components. | Array | `[]` | No |

The full parameter reference is available in the [VictoriaMetrics Operator Helm chart documentation](https://docs.victoriametrics.com/helm/victoria-metrics-operator/) and the [operator configuration variables](https://docs.victoriametrics.com/operator/configuration/#environment-variables).


## Upgrade

- CRDs are **not** upgraded automatically by a standard Helm upgrade. This chart provides an optional CRD upgrade job (`crds.upgrade.enabled`) and cleanup job (`crds.cleanup.enabled`); review the [changelog](https://docs.victoriametrics.com/helm/victoria-metrics-operator/changelog/) before upgrading across minor versions.
- Default versions for managed components (for example `VMSingle`, `VMAgent`, `VMCluster`) are compiled into the operator and change with each operator release. After upgrading, newly reconciled or newly created CRs adopt the new defaults unless you pin versions explicitly on the CR or via the operator `env` (for example `VM_VMSINGLEDEFAULT_VERSION`).
- Pin the operator image tag with `image.tag` if you need reproducible, offline-cacheable deployments rather than tracking `Chart.AppVersion`.

> [!CAUTION]
> Upgrades from a manifest-based pack to a Helm chart-based pack might not be compatible.


## Usage

Create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/) and add the **Victoria Metrics Operator** pack. The operator and its CRDs deploy into the `victoria-metrics` namespace.

The operator only manages CRs — it does not stand up a monitoring stack by itself. Add a manifest layer with the VictoriaMetrics objects you want. The example below deploys a single-node VictoriaMetrics instance and a `VMAgent` that scrapes targets and remote-writes to it.

```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMSingle
metadata:
  name: example
  namespace: victoria-metrics
spec:
  retentionPeriod: "1"
  removePvcAfterDelete: true
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAgent
metadata:
  name: example
  namespace: victoria-metrics
spec:
  selectAllByDefault: true
  remoteWrite:
    - url: "http://vmsingle-example.victoria-metrics.svc:8429/api/v1/write"
```

To point every image at a private or mirror registry (for example in an air-gapped install), set the shared registry override in the pack YAML:

```yaml
charts:
  victoria-metrics-operator:
    global:
      image:
        registry: my-registry.example.com
```

By default the operator converts existing Prometheus Operator objects into VictoriaMetrics objects. Set `operator.disable_prometheus_converter` to `true` if you run Prometheus Operator alongside this pack and do not want that conversion.

> [!CAUTION]
> Deleting a VictoriaMetrics CR removes its managed workloads. Set `removePvcAfterDelete` deliberately — persistent volumes for storage components are retained unless you opt in to their removal.


## References

- [VictoriaMetrics Operator documentation](https://docs.victoriametrics.com/operator/)
- [Operator configuration and environment variables](https://docs.victoriametrics.com/operator/configuration/)
- [VictoriaMetrics Operator Helm chart](https://docs.victoriametrics.com/helm/victoria-metrics-operator/)
- [VictoriaMetrics Operator on GitHub](https://github.com/VictoriaMetrics/operator)
- [Custom Resource API reference](https://docs.victoriametrics.com/operator/api/)
