# RabbitMQ

This pack installs the [RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/operator-overview)
(and, by default, the companion RabbitMQ Messaging Topology Operator) via Helm, and
prepares the cluster to run RabbitMQ `4.3.4`.

Team RabbitMQ maintains the Cluster Operator as the officially recommended way to run
RabbitMQ on Kubernetes. It extends the Kubernetes API with a `RabbitmqCluster` custom
resource and embeds RabbitMQ-specific operational knowledge (clustering, quorum
queues, safe rolling upgrades, TLS, plugin management, feature flags) directly into
the control plane, instead of relying on a generic StatefulSet template. Generic
community/vendor charts that deploy RabbitMQ as a plain StatefulSet — most notably the
Bitnami `rabbitmq` chart — are explicitly discouraged by Team RabbitMQ for production
use, and since Bitnami moved most of its free catalog behind "Bitnami Secure Images"
in August 2025, previously-packaged Bitnami charts (including
`bitnami/rabbitmq-cluster-operator`) are frozen and may not deploy correctly without a
paid subscription.

The official `rabbitmq/cluster-operator` repository does not publish a Helm chart
itself — Team RabbitMQ's documented installation method is
`kubectl apply -f cluster-operator.yml`. Since this pack packages the Operator as a
Helm chart, it uses the
[CloudPirates-io/helm-charts](https://github.com/CloudPirates-io/helm-charts/tree/main/charts/rabbitmq-cluster-operator)
chart, which faithfully re-packages the same upstream operator images
(`ghcr.io/rabbitmq/cluster-operator`, `ghcr.io/rabbitmq/messaging-topology-operator`)
as a signed, actively-maintained Helm chart.

This pack installs only the operators. It does **not** deploy a RabbitMQ cluster
instance — see [Usage](#usage) for how to create one pinned to `4.3.4`.

## Prerequisites

- Kubernetes 1.29+
- Helm 3.8+

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `clusterOperator.watchAllNamespaces` | Watch `RabbitmqCluster` resources in all namespaces | Bool | `true` | No |
| `clusterOperator.replicaCount` | Cluster Operator replica count | Int | `1` | No |
| `clusterOperator.webhook.enabled` | Enable the `RabbitmqCluster` admission webhook (requires TLS serving certificates) | Bool | `false` | No |
| `msgTopologyOperator.enabled` | Deploy the RabbitMQ Messaging Topology Operator alongside the Cluster Operator | Bool | `true` | No |
| `msgTopologyOperator.replicaCount` | Messaging Topology Operator replica count | Int | `1` | No |
| `useCertManager` | Use cert-manager to issue webhook TLS certs instead of chart-generated ones | Bool | `false` | No |

Refer to the vendored chart's own README at
[`charts/rabbitmq-cluster-operator/README.md`](charts/rabbitmq-cluster-operator/README.md)
for the complete parameter reference.

## Upgrade

This is the initial version of this pack, so there is no prior version to upgrade
from.

> [!CAUTION]
> When upgrading this pack to a future version with a newer Cluster Operator release,
> be aware that the Operator never upgrades the RabbitMQ server version of existing
> `RabbitmqCluster` instances on your behalf. The RabbitMQ version running in a
> cluster is controlled exclusively by that cluster's `spec.image` field, independent
> of the Operator's own version. A newer Operator release only changes the *default*
> image used for newly-created `RabbitmqCluster` resources that don't set `spec.image`
> explicitly.

## Usage

Add the **RabbitMQ** pack to a cluster profile as an add-on layer. The default
configuration deploys the Cluster Operator and Messaging Topology Operator with no
required overrides.

Once the pack's operator pods are `Running`, create a RabbitMQ cluster by adding a new
manifest layer with a `RabbitmqCluster` custom resource, pinning `spec.image` to
`4.3.4`:

```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: my-rabbitmq
  namespace: rabbitmq-system
spec:
  replicas: 3
  image: rabbitmq:4.3.4-management-alpine
  resources:
    requests:
      cpu: 1
      memory: 2Gi
    limits:
      cpu: 1
      memory: 2Gi
  persistence:
    storage: 20Gi
```

> [!CAUTION]
> Do not set `persistence.storageClassName: ""` (empty string). In Kubernetes an
> explicit empty string means "do not dynamically provision — bind only to a
> pre-existing static PersistentVolume", not "use the cluster's default
> StorageClass". Omit the field entirely to use the cluster's default StorageClass,
> or set it to an explicit StorageClass name (check available classes with
> `kubectl get storageclass`). Setting it to `""` leaves the `RabbitmqCluster`
> stuck with `ALLREPLICASREADY: False` and its PVCs permanently `Pending` with
> `no persistent volumes available for this claim and no storage class is set`.

The image tag above (`4.3.4-management-alpine`) is also declared in
[`values.yaml`](values.yaml) under `pack.content.images`, so it is available to
airgapped/private-registry environments even though the chart itself never applies
the `RabbitmqCluster` resource.

See [Using the RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/using-operator)
for the full list of `RabbitmqCluster` spec fields (TLS, persistence, resource
limits, affinity, plugins, and more).

## References

- [RabbitMQ Cluster Kubernetes Operator overview](https://www.rabbitmq.com/kubernetes/operator/operator-overview)
- [Installing the RabbitMQ Cluster Operator](https://www.rabbitmq.com/kubernetes/operator/install-operator)
- [Using the RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/using-operator)
- [rabbitmq/cluster-operator on GitHub](https://github.com/rabbitmq/cluster-operator)
- [rabbitmq/messaging-topology-operator on GitHub](https://github.com/rabbitmq/messaging-topology-operator)
- [Helm chart source — CloudPirates-io/helm-charts](https://github.com/CloudPirates-io/helm-charts/tree/main/charts/rabbitmq-cluster-operator)
