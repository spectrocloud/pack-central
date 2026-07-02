# VAST CSI Block Driver (NVMe/TCP)

The VAST CSI Block Driver provisions raw block / filesystem PersistentVolumes on a [VAST Data](https://vastdata.com) cluster over **NVMe/TCP**. Each PVC becomes a VAST block volume (namespace) under an NVMe subsystem and is attached to the node over NVMe-oF (TCP). Helm-based, with a *build-on-deploy* model (0-CVE Chainguard `wolfi-base` as the only pack-content image; the VAST driver + sidecars craned at deploy time).

## Prerequisites

- A reachable VAST cluster with the VMS endpoint routable from the workload cluster, and a VAST VIP pool for the data path.
- VMS credentials as a `Secret` named `vast-mgmt` (keys `username`, `password`, `endpoint` — bare host/IP, no scheme).
- A VAST **block subsystem**: a VAST *view* with `protocols: ["BLOCK"]` whose **name** equals the StorageClass `subsystem` parameter (the driver looks the subsystem up by name; it is not auto-created).
- **Firewall:** the NVMe-oF **discovery port 8009** must be open from the nodes to the VAST VIPs, in addition to 4420 (NVMe I/O). The driver's `nvme connect-all` contacts the discovery controller on 8009; if it is blocked the mount times out (`Failed to write to /dev/nvme-fabrics: Connection timed out`).
- **Node prerequisites:** the `nvme-tcp` kernel module and the `nvme-cli` tool must be present on each node (absent from some base images, e.g. shipped in `linux-modules-extra` on Ubuntu). Load/install them via the OS layer (e.g. a `preKubeadm` step).

## Parameters

| **Parameter** | **Description** | **Type** | **Default Value** | **Required** |
|---|---|---|---|---|
| `charts.vastblock.secretName` | Name of the Secret holding VMS credentials. | String | `vast-mgmt` | Yes |
| `charts.vastblock.storageClasses.<name>.subsystem` | Name of the VAST BLOCK view used as the NVMe subsystem. | String | — | Yes |
| `charts.vastblock.storageClasses.<name>.vipPool` | VAST VIP pool for the NVMe/TCP data path. | String | — | Yes |
| `charts.vastblock.storageClassDefaults.transportType` | NVMe transport (AWS supports TCP only). | String | `TCP` | No |
| `charts.vastblock.storageClassDefaults.fsType` | Filesystem laid on the block device (empty = raw block). | String | `ext4` | No |

> The pack ships `storageClasses: {}` empty because the `subsystem` is environment-specific. Add a StorageClass once the BLOCK view exists.

## Upgrade

- NVMe/TCP block volumes are typically ReadWriteOnce; define StorageClasses per environment.
- The driver version tracks the bundled chart `vastblock-2.6.5`; the VAST cluster must be on a compatible major version.

## Usage

1. On the VAST cluster, create a BLOCK view (the subsystem), e.g. via the VMS API: `POST /api/views/ {name: k8s-block, path: /k8s-block, protocols: ["BLOCK"], policy_id, tenant_id, create_dir: true}`.
2. Create the `vast-mgmt` secret in the pack namespace.
3. Add the pack as an add-on layer and define a StorageClass:
   ```yaml
   charts:
     vastblock:
       storageClasses:
         vastdata-block:
           subsystem: k8s-block
           vipPool: protocolsPool
           transportType: TCP
           fsType: ext4
   ```
4. Provision a volume:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata: { name: vast-block }
   spec:
     accessModes: [ReadWriteOnce]
     storageClassName: vastdata-block
     resources: { requests: { storage: 10Gi } }
   ```

## References

- [VAST Data — Configuring an NVMe/TCP client](https://kb.vastdata.com/documentation/docs/configuring-an-nvmetcp-client-on-linux-for-vast-cluster-block-storage-1)
- [VAST CSI Driver (GitHub)](https://github.com/vast-data/vast-csi)
- [Palette — registries and packs](https://docs.spectrocloud.com/registries-and-packs)
