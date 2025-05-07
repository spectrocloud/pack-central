# Hitachi Storage Plug-in for Containers

Hitachi Storage Plug-in for Containers lets you create containers and run stateful applications
inside those containers by using the Hitachi storage volumes as dynamically provisioned
persistent volumes.


## Prerequisites

- A Hitachi Virtual Storage Platform (VSP) array.


## Parameters

To deploy the Hitachi HSPC pack, you need to set, at minimum, the following parameters in the pack's YAML.

| Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `hspc.vsp.url` | The URL of your Hitachi VSP management endpoint. | String  | - | Yes |
| `hspc.vsp.user` | The username of a Hitachi VSP account with appropriate permissions. | String  | - | Yes |
| `hspc.vsp.password` | The password of a Hitachi VSP account with appropriate permissions. | String  | - | Yes |
| `hspc.storageClass.parameters.serialNumber` | The serial number of the VSP storage chassis. | String  | - | Yes |
| `hspc.storageClass.parameters.poolID` | The HDP Pool ID (omit for VSP One SDS Block). | String  | - | Yes |
| `hspc.storageClass.parameters.portID` | The port ID (omit for VSP One SDS Block). Use a comma separator for multipath. If an NVMe over FC is used, don't set this option. | String  | - | Yes |
| `hspc.storageClass.parameters.connectionType` | Storage connection type. fc, iscsi, and nvme-fc are supported. Defaults to fc if not set. | String  | fc | No |
| `hspc.storageClass.parameters.storageEfficiency` | Adaptive data reduction. "Compression", "CompressionDeduplication", and "Disabled" are supported. | String  | - | Yes |
| `hspc.storageClass.parameters.storageEfficiencyMode` | Compression execution mode. "Inline" and "PostProcess" are supported. | String  | - | No |
| `hspc.storageClass.parameters.storageType` | For VSP One SDS Block, set the "storagetype" parameter to "vsp-one-sds-block". | String  | - | No |
| `hspc.storageClass.parameters.csi.storage.k8s.io/fstype` | Filesystem type, ext4 and xfs are supported. Defaults to ext4 if not set. | String  | ext4 | No |


Review the [Hitachi Storage Plug-in for Containers Quick Reference Guide](https://docs.hitachivantara.com/v/u/en-us/adapters-and-drivers/3.15.x/mk-92adptr142) for more details on parameters. 

## Upgrade

This pack deploys an operator, which takes care of phased upgrades


## Usage

To use the Hitachi Storage Plug-in for Containers pack, first create a new [infrastructure cluster profile](https://docs.spectrocloud.com/profiles/cluster-profiles/create-cluster-profiles/create-infrastructure-profile/), select MAAS for the Infrastructure Provider and when you get to the Storage pack, search for the **Hitachi Storage Plug-in for Containers** pack in the Palete Community Registry. Then configure the `hspc.vsp` and `hspc.storageClass` sections in the pack YAML:

```yaml
charts:  
  hspc:
    ...
    vsp:
      url: http://172.16.1.1
      user: "User01"
      password: "*******"
    storageClass:
      name: spectro-storage-class
      isDefaultStorageClass: true
      allowVolumeExpansion: true
      reclaimPolicy: Delete
      volumeBindingMode: Immediate
      parameters:
        serialNumber: "54321"
        poolID: "1"
        portID : CL1-A,CL2-A
        connectionType: fc
        storageEfficiency: "CompressionDeduplication"
        storageEfficiencyMode: "Inline"
```

Once you have confiogured the pack, you can deploy a cluster with it.

In order to use this CSI for snapshots, the following `VolumeSnapshotClass` can be created (manually, not part of this pack):
```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: hspc-snapshotclass
driver: hspc.csi.hitachi.com
deletionPolicy: Delete
parameters:
  poolID: "1"
  csi.storage.k8s.io/snapshotter-secret-name: "hspc-secret"
  csi.storage.k8s.io/snapshotter-secret-namespace: "hspc-system"
```

## References

- [Hitachi Vantara website](https://www.hitachivantara.com/)
- [Hitachi HSPC Quick Reference Guide](https://docs.hitachivantara.com/v/u/en-us/adapters-and-drivers/3.15.x/mk-92adptr142)