# VAST CSI Driver (NFS)

The VAST CSI Driver provisions ReadWriteMany (and ReadWriteOnce) persistent volumes on a [VAST Data](https://vastdata.com) cluster over NFS. Each PersistentVolumeClaim becomes a VAST *view* under a configurable base path, served from a tenant VIP pool. This pack is Helm-based and uses a *build-on-deploy* model: the only image shipped as pack content is the 0-CVE Chainguard `wolfi-base`; the VAST driver and the CSI sidecars are crane-exported onto it by an init container at deploy time, so the scanned image surface stays minimal.

## Prerequisites

- A reachable VAST cluster with the VMS management endpoint routable from the workload cluster (e.g. via VPC peering).
- A VAST VIP pool for the data path and a base view path (e.g. `/csi`).
- VMS credentials for the driver, supplied as a Kubernetes `Secret` named `vast-mgmt` in the pack namespace, with keys `username`, `password`, and `endpoint` (the VMS VIP as a **bare host/IP, no scheme**).
- The CSI node plugin runs **privileged** pods to perform mounts. If Pod Security Admission (or Kyverno/OPA) is enforced, the `vast-csi` namespace must be allowed at the `privileged` level.
- `snapshot.storage.k8s.io` CRDs are bundled with the chart (a `VolumeSnapshotClass` is created when a credentials secret is configured).

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.vastcsi.secretName` | Name of the Secret holding VMS `username`/`password`/`endpoint`. | String | `vast-mgmt` | Yes |
| `charts.vastcsi.endpoint` | VMS management VIP as a bare host/IP (no scheme). May instead be set via the secret's `endpoint` key. | String | `""` | Yes (here or in secret) |
| `charts.vastcsi.storageClasses.vastdata-filesystem.storagePath` | Base view path on VAST where CSI volumes are created. | String | `/csi` | Yes |
| `charts.vastcsi.storageClasses.vastdata-filesystem.vipPool` | VAST VIP pool name for the data path. | String | `protocolsPool` | Yes |
| `charts.vastcsi.storageClasses.vastdata-filesystem.viewPolicy` | VAST view policy controlling client access. | String | `default` | No |
| `charts.vastcsi.storageClasses.vastdata-filesystem.setDefaultStorageClass` | Mark this StorageClass as the cluster default. | Bool | `true` | No |

## Upgrade

- The redistributed driver version tracks the bundled chart `vastcsi-2.6.5`; the VAST cluster (VMS) must be on a compatible major version.
- The `endpoint` value must be a **bare host** — a value containing `https://` will be parsed as the hostname and fail. If upgrading from a configuration that set a scheme, remove it.

## Usage

1. Create the credentials secret in the pack namespace:
   ```bash
   kubectl create namespace vast-csi
   kubectl -n vast-csi create secret generic vast-mgmt \
     --from-literal=username='<vms-user>' \
     --from-literal=password='<vms-password>' \
     --from-literal=endpoint='<vms-vip>'        # bare host/IP, no scheme
   ```
2. Add this pack as an add-on layer to your cluster profile and set the VIP pool / storage path / view policy to match your VAST tenant.
3. Provision a volume:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata: { name: vast-nfs }
   spec:
     accessModes: [ReadWriteMany]
     storageClassName: vastdata-filesystem
     resources: { requests: { storage: 10Gi } }
   ```
4. For multi-tenancy, add additional StorageClasses under `charts.vastcsi.storageClasses`, each pointing at a per-tenant VIP pool / view path, and set `setDefaultStorageClass: false` to avoid clobbering the default.

## References

- [VAST Data documentation](https://support.vastdata.com)
- [VAST CSI Driver (GitHub)](https://github.com/vast-data/vast-csi)
- [Palette — registries and packs](https://docs.spectrocloud.com/registries-and-packs)
