# NetApp Trident CSI Driver

Trident is a fully supported open source project maintained by NetApp. It has been designed from the ground up to help you meet your containerized applications' persistence demands using industry-standard interfaces, such as the Container Storage Interface (CSI).

## Prerequisites

- Kubernetes version v1.29 or above.
- Target platform must be supported Kubernetes clusters (including ONTAP, Element, Azure NetApp Files, Google Cloud NetApp Volumes, or Amazon FSx for ONTAP).

## Upgrade

If in the previous version `true` is set for charts.csi-trident.useOldCSIDriver, then change value of charts.csi-trident.useOldCSIDriver from false to true in values.yaml of pack for upgrade to work.

Upgrade from `v1.28.0` has been blocked, because volumes created on v26.02.1 or any future version will be incompatible with versions before v1.28.0.

## Usage

While creating the cluster profile and deploying the cluster, select the NetApp Trident CSI pack as the CSI layer. Deploy an application that uses Persistent Volume Claims. Once the application is deployed, the Persistent Volume will be dynamically provisioned using the default storage class.

To create a `StorageClasses` of your choice, use the pack's values.yaml `charts.csi-trident.storageClasses` parameter section. To make a storageclass as a default storageClass, set the parameter `storageclass.kubernetes.io/is-default-class parameter` to `true` in `charts.csi-trident.storageClasses section` of pack's values.yaml. By default, the storageClass `spectro-storage-class` is created and used as the default storageClass.

:::tip

Check out the [Palette Backup and Restore Documentation](https://docs.spectrocloud.com/clusters/cluster-management/backup-restore/) to learn how to backup and restore your cluster.

::::

### Snapshot Creation

The NetApp Trident CSI pack supports snapshot creation. In the **values.yaml**, modify the parameter `charts.csi-trident.sidecars.snapshotter` to enable the snapshotter sidecar. Snapshot creation requies the cluster profile to have the [Volume-Snapshot-controller](https://docs.spectrocloud.com/integrations/packs/?pack=volume-snapshot-controller) pack. You can add the Volume-Snapshot-controller pack to the cluster profile as an addon pack. Refer to the [Volume-Snapshot-controller](https://docs.spectrocloud.com/integrations/packs/?pack=volume-snapshot-controller) README for more information.

## References

- [NetApp Trident Official Documentation](https://docs.netapp.com/us-en/trident/index.html)

- [NetApp Trident Release and Support Lifecycle](https://mysupport.netapp.com/site/info/trident-support)

- [NetApp Trident Pack Documentation](https://docs.spectrocloud.com/integrations/packs/?pack=csi-trident)

- [Palette Backup and Restore Documentation](https://docs.spectrocloud.com/clusters/cluster-management/backup-restore/)

