# CloudNativePG

[CloudNativePG](https://cloudnative-pg.io/) is a Kubernetes operator that manages the full lifecycle of highly available PostgreSQL database clusters. You declare a `Cluster` Custom Resource and the operator handles provisioning, streaming replication, automated failover, rolling updates, backups, and recovery — running PostgreSQL natively on Kubernetes without an external failover tool.

This pack installs the operator (app version `1.30.0`) and its Custom Resource Definitions. It does not create any PostgreSQL clusters on its own — you define `Cluster`, `Pooler`, `Backup`, and related CRs after the operator is running.


## Prerequisites

- A running Kubernetes cluster on version `1.29.0` or later.
- Helm-based add-on support in Palette (this is a Helm chart-based pack).
- A `StorageClass` capable of provisioning persistent volumes for PostgreSQL data.
- For air-gapped or offline environments, mirror the operator image and the default operand and pooler images the operator pulls. See the [References](#references) for the image list.


## Parameters

The pack is configured under the `charts.cloudnative-pg` key. The most commonly adjusted parameters are listed below.

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `replicaCount` | Number of operator replicas. | Int | `1` | No |
| `image.repository` | Operator image repository. | String | `ghcr.io/cloudnative-pg/cloudnative-pg` | No |
| `image.tag` | Operator image tag. Overrides the chart `appVersion` when set. | String | `""` (uses `1.30.0`) | No |
| `config.clusterWide` | Whether the operator watches the entire cluster or only its own namespace. | Bool | `true` | No |
| `config.data` | Extra operator configuration keys (for example `INHERITED_LABELS`, `WATCH_NAMESPACE`). See [operator configuration](https://cloudnative-pg.io/documentation/current/operator_conf/). | Map | `{}` | No |
| `crds.create` | Whether the chart installs the CloudNativePG CRDs. | Bool | `true` | No |
| `monitoring.podMonitorEnabled` | Creates a `PodMonitor` for the operator (requires Prometheus Operator CRDs). | Bool | `false` | No |
| `monitoring.grafanaDashboard.create` | Creates a `ConfigMap` holding the CloudNativePG Grafana dashboard. | Bool | `false` | No |

The full parameter reference is available in the [CloudNativePG Helm chart documentation](https://github.com/cloudnative-pg/charts/tree/main/charts/cloudnative-pg).


## Upgrade

- CRDs are managed by the chart (`crds.create: true`). Review the [chart release notes](https://github.com/cloudnative-pg/charts/releases) and the [operator release notes](https://cloudnative-pg.io/documentation/current/release_notes/) before upgrading across minor versions, as CRD schema changes may apply.
- The default operand PostgreSQL image and the default pgbouncer image are compiled into the operator and change with each operator release. Existing `Cluster` and `Pooler` resources keep the image they were created with unless you set `imageName` explicitly or trigger an upgrade; newly created resources without an explicit image adopt the new operator defaults.
- Pin the operator image tag with `image.tag` if you need reproducible, offline-cacheable deployments rather than tracking the chart `appVersion`.

> [!CAUTION]
> Upgrades from a manifest-based pack to a Helm chart-based pack might not be compatible.


## Usage

Create a new [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/) and add the **CloudNativePG** pack. The operator and its CRDs deploy into the `cloudnative-pg` namespace.

The operator only manages CRs — it does not stand up a database by itself. Add a manifest layer with the PostgreSQL objects you want. The example below deploys a three-instance highly available PostgreSQL cluster with 10Gi of storage per instance.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: example
  namespace: cloudnative-pg
spec:
  instances: 3
  storage:
    size: 10Gi
```

The operator generates a `-rw` service (primary, read-write), a `-ro` service (replicas, read-only), and a `-r` service (any instance) for the cluster, along with a secret holding the generated application credentials.

To add connection pooling, define a `Pooler` that references the cluster. It uses the operator's default pgbouncer image unless you override `spec.pgbouncer.image`:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Pooler
metadata:
  name: example-pooler
  namespace: cloudnative-pg
spec:
  cluster:
    name: example
  instances: 2
  type: rw
  pgbouncer:
    poolMode: session
```

To pin PostgreSQL to a specific operand image (for example in an air-gapped install or to control the major version), set `imageName` on the cluster:

```yaml
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18.4-system-trixie
```

> [!CAUTION]
> Deleting a `Cluster` removes its managed pods. Persistent volume claims are retained according to the cluster's `storage` and reclaim policy — verify your `StorageClass` reclaim behavior before deleting a production cluster.


## References

- [CloudNativePG documentation](https://cloudnative-pg.io/documentation/current/)
- [Operator configuration options](https://cloudnative-pg.io/documentation/current/operator_conf/)
- [CloudNativePG Helm chart](https://github.com/cloudnative-pg/charts/tree/main/charts/cloudnative-pg)
- [Cluster CRD / API reference](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/)
- [CloudNativePG on GitHub](https://github.com/cloudnative-pg/cloudnative-pg)
