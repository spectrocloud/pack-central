# Garage

[Garage](https://garagehq.deuxfleurs.fr/) is a lightweight, S3-compatible distributed object store built by [Deuxfleurs](https://deuxfleurs.fr/). It is designed for self-hosted, geo-distributed deployments running on commodity hardware — it tolerates high-latency links between nodes and does not require a dedicated storage network, which makes it a good fit for edge clusters and small on-prem footprints where Ceph or MinIO would be too heavy.

This pack deploys Garage as a 3-replica StatefulSet using the upstream Helm chart (chart `0.9.3`, app `v2.3.0`). Nodes discover each other automatically through the built-in Kubernetes discovery mechanism, so no bootstrap peer list is needed.

> [!IMPORTANT]
> Garage does not self-assemble into a usable cluster. After the pods are running you **must** manually assign a layout to each node before the S3 API will accept any data. See [Post-Installation](#post-installation).


## Prerequisites

- A Kubernetes cluster with a default StorageClass, or an explicit `storageClass` set under `persistence` (see [Storage](#storage)).
- Permission to create cluster-scoped resources. The chart installs the `garagenodes.deuxfleurs.fr` CRD and a ClusterRole used for peer discovery. If you cannot grant cluster-scoped access, set `garage.kubernetesSkipCrd: true` and install the CRD out of band.
- At least 3 schedulable nodes if you keep the default `replicationFactor: "3"`. With fewer nodes, replicas will co-locate and you lose the durability the replication factor implies.


## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `deployment.kind` | `StatefulSet` (PVC-backed) or `DaemonSet` (hostPath-backed) | String | `StatefulSet` | No |
| `deployment.replicaCount` | Number of Garage nodes | Integer | `3` | No |
| `garage.replicationFactor` | Copies of each object across the cluster | String | `"3"` | No |
| `garage.consistencyMode` | `consistent` (read-after-write), `degraded`, or `dangerous` | String | `"consistent"` | No |
| `garage.dbEngine` | Metadata engine: `lmdb` or `sqlite` | String | `"lmdb"` | No |
| `garage.blockSize` | Data block size in bytes | String | `"1048576"` | No |
| `garage.compressionLevel` | zstd level for stored blocks | String | `"1"` | No |
| `garage.metadataAutoSnapshotInterval` | Interval for automatic metadata DB snapshots, e.g. `6h`. Empty disables | String | `""` | No |
| `garage.rpcSecret` | Shared secret for inter-node RPC. Generated and stored in a Secret if left empty | String | `""` | No |
| `garage.existingRpcSecret` | Name of an existing Secret holding the RPC secret under key `rpcSecret` | String | `""` | No |
| `garage.kubernetesSkipCrd` | Skip installing the `garagenodes` CRD | Boolean | `false` | No |
| `garage.s3.api.region` | S3 region name advertised to clients | String | `"garage"` | No |
| `garage.s3.api.rootDomain` | Suffix enabling virtual-hosted bucket addressing | String | `".s3.garage.tld"` | No |
| `garage.s3.web.rootDomain` | Suffix for static website hosting from buckets | String | `".web.garage.tld"` | No |
| `garage.additionalTopLevelConfig` | Raw TOML appended to `garage.toml` | String | `""` | No |
| `garage.garageTomlString` | Full `garage.toml` template. **Overrides all other `garage.*` values** | String | `""` | No |
| `persistence.enabled` | Persist metadata and data | Boolean | `true` | No |
| `persistence.meta.size` | Metadata volume size | String | `100Mi` | **Yes — raise it** |
| `persistence.data.size` | Data volume size | String | `100Mi` | **Yes — raise it** |
| `service.type` | `ClusterIP`, `NodePort`, or `LoadBalancer` | String | `ClusterIP` | No |
| `ingress.s3.api.enabled` | Expose the S3 API through an Ingress | Boolean | `false` | No |
| `ingress.s3.web.enabled` | Expose bucket static-website serving through an Ingress | Boolean | `false` | No |
| `monitoring.metrics.enabled` | Annotate a Service for Prometheus scraping | Boolean | `false` | No |
| `monitoring.metrics.serviceMonitor.enabled` | Create a `ServiceMonitor` (requires Prometheus Operator) | Boolean | `false` | No |
| `resources` | Pod resource requests and limits | Object | `{}` | No |

The full set of chart values is documented in [`charts/garage/README.md`](charts/garage/README.md).


## Storage

The chart ships with `100Mi` volumes for both metadata and data. **These defaults are placeholders and are not usable for real workloads** — size them before the first deploy:

```yaml
charts:
  garage:
    persistence:
      meta:
        storageClass: "fast-storage-class"   # SSD-backed; LMDB is latency-sensitive
        size: 5Gi
      data:
        storageClass: "bulk-storage-class"   # Capacity matters more than latency here
        size: 500Gi
```

Resizing after deployment is awkward: StatefulSet `volumeClaimTemplates` are immutable, so growing volumes requires orphaning the StatefulSet (`kubectl delete sts --cascade=orphan`), editing the PVCs, and letting the pack recreate the controller. Your StorageClass must have `allowVolumeExpansion: true`. Size generously up front.

Setting `deployment.kind: DaemonSet` switches Garage to hostPath storage at `persistence.meta.hostPath` and `persistence.data.hostPath`, placing one node per host. This suits edge clusters with direct-attached disks, but the paths must exist and be writable by UID/GID `1000`.


## Usage

To use this pack, create or edit an [add-on cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-addon-profile/), search for the **garage** pack, and adjust the values. A minimal production-shaped override:

```yaml
charts:
  garage:
    deployment:
      replicaCount: 3
    garage:
      replicationFactor: "3"
      consistencyMode: "consistent"
      metadataAutoSnapshotInterval: "6h"
      s3:
        api:
          region: "us-east-1"
          rootDomain: ".s3.example.com"
    persistence:
      meta:
        storageClass: "fast-storage-class"
        size: 5Gi
      data:
        storageClass: "bulk-storage-class"
        size: 500Gi
    resources:
      requests:
        cpu: 250m
        memory: 1Gi
      limits:
        memory: 2Gi
```

The pack deploys into the `garage` namespace.

### Exposing the S3 API

By default the API is only reachable in-cluster at `garage.garage.svc.cluster.local:3900`. To reach it from outside, either set `service.type: LoadBalancer` or enable the Ingress. Virtual-hosted bucket addressing (`bucket.s3.example.com`) requires a wildcard host, and `garage.s3.api.rootDomain` must match:

```yaml
charts:
  garage:
    ingress:
      s3:
        api:
          enabled: true
          className: "nginx"
          hosts:
            - host: "s3.example.com"
              paths:
                - path: /
                  pathType: Prefix
            - host: "*.s3.example.com"
              paths:
                - path: /
                  pathType: Prefix
          tls:
            - secretName: garage-s3-tls
              hosts:
                - "s3.example.com"
                - "*.s3.example.com"
```

S3 clients that only support path-style addressing (`s3.example.com/bucket`) work without the wildcard host.


## Post-Installation

A freshly deployed Garage cluster has no layout, which means it has zero usable capacity and rejects all S3 operations. The `garage` CLI is bundled in the container image; run it via `kubectl exec` against any pod.

**1. Confirm all nodes see each other.** Each pod should be listed with a node ID:

```bash
kubectl exec -it -n garage garage-0 -- ./garage status
```

**2. Assign a layout role to each node.** Use the first several characters of each node ID (enough to be unique). `--zone` should reflect physical failure domains — with `replicationFactor: 3`, Garage spreads copies across distinct zones when it can. `--capacity` is the share of data the node accepts, and should track the size of its data volume:

```bash
kubectl exec -it -n garage garage-0 -- ./garage layout assign <node-id-1> -z dc1 -c 500G -t garage-0
kubectl exec -it -n garage garage-0 -- ./garage layout assign <node-id-2> -z dc2 -c 500G -t garage-1
kubectl exec -it -n garage garage-0 -- ./garage layout assign <node-id-3> -z dc3 -c 500G -t garage-2
```

**3. Review and apply.** The version number must be exactly one greater than the current layout version — `1` for the first apply:

```bash
kubectl exec -it -n garage garage-0 -- ./garage layout show
kubectl exec -it -n garage garage-0 -- ./garage layout apply --version 1
```

**4. Create a bucket and a key, then grant access:**

```bash
kubectl exec -it -n garage garage-0 -- ./garage bucket create my-bucket
kubectl exec -it -n garage garage-0 -- ./garage key create my-app-key
kubectl exec -it -n garage garage-0 -- ./garage bucket allow --read --write my-bucket --key my-app-key
```

`key create` prints the access key ID and secret access key **once** — capture them at that moment. Point any S3 client at the API endpoint using the region from `garage.s3.api.region`.

Adding or removing nodes later repeats steps 2–3 with an incremented `--version`. Garage rebalances data automatically after the new layout is applied.


## Monitoring

Garage exposes Prometheus metrics on the admin API port (`3903`). With the Prometheus Operator installed:

```yaml
charts:
  garage:
    monitoring:
      metrics:
        enabled: true
        serviceMonitor:
          enabled: true
          interval: 30s
```

The admin API is deliberately excluded from the main Service because its responses are not consistent across nodes — query a specific pod when using it directly.


## Uninstalling

Removing the pack from the cluster profile deletes the workloads but leaves two things behind on purpose:

- **PersistentVolumeClaims** are retained by the StatefulSet controller. Delete them explicitly to reclaim storage — and only once you are certain the data is not needed.
- **The `garagenodes.deuxfleurs.fr` CRD** is not removed by Helm and must be deleted manually if you are permanently retiring Garage.


## Kubernetes Compatibility

Requires Kubernetes v1.19 or later (`networking.k8s.io/v1` Ingress).


## References

- [Garage documentation](https://garagehq.deuxfleurs.fr/documentation/)
- [Deploying on Kubernetes](https://garagehq.deuxfleurs.fr/documentation/cookbook/kubernetes/)
- [Creating a cluster layout](https://garagehq.deuxfleurs.fr/documentation/operations/layout/)
- [Configuration reference](https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/)
- [S3 compatibility matrix](https://garagehq.deuxfleurs.fr/documentation/reference-manual/s3-compatibility/)
- [Source code](https://git.deuxfleurs.fr/Deuxfleurs/garage)
