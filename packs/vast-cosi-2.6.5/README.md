# VAST COSI Driver (S3)

The VAST COSI Driver provisions S3 object-storage buckets on a [VAST Data](https://vastdata.com) cluster through the Kubernetes [Container Object Storage Interface (COSI)](https://kubernetes.io/blog/2022/09/07/storage-object-lifecycle-management/). A `BucketClaim` is satisfied by a VAST view with the S3 protocol, exposed on a tenant VIP pool. This pack is Helm-based and uses a *build-on-deploy* model (0-CVE Chainguard `wolfi-base` as the only pack-content image; the VAST driver + the COSI sidecar are crane-exported onto it at deploy time). It also bundles the v1alpha1 COSI CRDs and the matching central `objectstorage-controller` so `BucketClaim` → `Bucket` provisioning works without a separate COSI install.

## Prerequisites

- A reachable VAST cluster with the VMS management endpoint routable from the workload cluster.
- A VAST VIP pool for the S3 data path.
- VMS credentials as a Kubernetes `Secret` named `vast-mgmt` (keys `username`, `password`, `endpoint` — the VMS VIP as a **bare host/IP, no scheme**).
- The bundled `objectstorage-controller` is pinned to the v0.1.0 (v1alpha1) COSI image to match the VAST driver/sidecar API; do not mix with a v0.2.x (v1alpha2) controller.

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.vastcosi.secretName` | Name of the Secret holding VMS credentials. | String | `vast-mgmt` | Yes |
| `charts.vastcosi.endpoint` | VMS management VIP as a bare host/IP (no scheme). May be set via the secret instead. | String | `""` | Yes (here or in secret) |
| `charts.vastcosi.bucketClassDefaults.vipPool` | VAST VIP pool name for the S3 data path. | String | `""` | Yes |
| `charts.vastcosi.bucketClassDefaults.scheme` | Scheme advertised for the bucket endpoint (`http` or `https`). | String | `http` | No |
| `charts.vastcosi.cosiController.enabled` | Deploy the bundled central COSI controller. | Bool | `true` | No |
| `charts.vastcosi.bucketClasses` | Map of BucketClasses to create (each with a `vipPool`/`storagePath`). | Map | `{}` | No |

## Upgrade

- The bundled COSI API is **v1alpha1**. If your cluster already has a different COSI controller or v1alpha2 CRDs installed, disable `cosiController.enabled` and reconcile the API versions before upgrading.
- The `endpoint` must be a **bare host** (no `https://`).

## Usage

1. Create the `vast-mgmt` secret in the pack namespace (see the vast-csi pack for the exact `kubectl create secret` command).
2. Add the pack as an add-on layer and define a BucketClass under `charts.vastcosi.bucketClasses` pointing at your tenant VIP pool.
3. Provision a bucket:
   ```yaml
   apiVersion: objectstorage.k8s.io/v1alpha1
   kind: BucketClaim
   metadata: { name: my-bucket }
   spec:
     bucketClassName: vastdata-bucket
     protocols: [S3]
   ```
   The central controller creates a `Bucket`; the VAST sidecar provisions it on the cluster.

## References

- [VAST Data documentation](https://support.vastdata.com)
- [VAST CSI/COSI Driver (GitHub)](https://github.com/vast-data/vast-csi)
- [Kubernetes COSI](https://github.com/kubernetes-sigs/container-object-storage-interface-api)
- [Palette — registries and packs](https://docs.spectrocloud.com/registries-and-packs)
