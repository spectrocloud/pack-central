# HPE CSI Driver for Kubernetes

The HPE CSI Driver for Kubernetes leverages Hewlett Packard Enterprise primary storage platforms to provide scalable, persistent block and file storage for stateful and ephemeral applications. Currently supported storage platforms include HPE Alletra Storage MP B10000, HPE Alletra 5000/6000/9000, HPE Nimble Storage, HPE Primera and HPE 3PAR.

## Prerequisites

The following requirements needs to be fulfilled in order to use the HPE CSI Driver for Kubernetes.

Nodes need to be provisioned with custom `user-data` stanzas to shorten the hostname and create unique IQNs for each node. See the official Spectro Cloud [partner page](https://scod.hpedev.io/csi_driver/partners/spectro_cloud/index.html) for details.

It's recommended to install the `volume-snapshot-controller` pack provided by Spectro Cloud to use `VolumeSnapshotClasses` and `VolumeSnapshots`.

## Limitations

Spectro Cloud edge nodes are locked down and the HPE CSI Driver is unable to fulfill the following prerequisites.

- NVMe user space tools 
- The XFS filesystem utilities

Therefore, only iSCSI and FC devices (if physical HBA drivers are installed) are supported using either ext3 or ext4 filesystems.

## Parameters

The only pack parameter that has a different default value from the Helm chart is the `disableNodeConformance` boolean as the Spectro Cloud edge nodes are immutable. If the pack is installed on a host OS that is part of the [Compatibility & Support](https://scod.hpedev.io/csi_driver/index.html#latest_release) table and is mutable, using `disableNodeConformance=false` is recommended.

| Parameter                 | Description                                                                                        | Default          |
|---------------------------|----------------------------------------------------------------------------------------------------|------------------|
| disable.nimble            | Disable HPE Nimble Storage CSP `Service`.                                                          | false            |
| disable.primera           | Disable HPE Primera (and 3PAR) CSP `Service`.                                                      | false            |
| disable.alletra6000       | Disable HPE Alletra 5000/6000 CSP `Service`.                                                       | false            |
| disable.alletra9000       | Disable HPE Alletra 9000 CSP `Service`.                                                            | false            |
| disable.alletraStorageMP  | Disable HPE Alletra Storage MP B10000 Block Storage CSP `Service`.                                                      | false            |
| disable.b10000FileService  | Disable HPE Alletra Storage MP B10000 File Service CSP `Service`.                                  | false            |
| disableNodeConformance    | Disable automatic installation of iSCSI, multipath and NFS packages.                               | true              |
| disableNodeConfiguration  | Disables node conformance and configuration.`*`                                                    | false            |
| disableNodeGetVolumeStats | Disable NodeGetVolumeStats call to CSI driver.                                                     | false            |
| disableNodeMonitor        | Disables the Node Monitor that manages stale storage resources.                                    | false            |
| disableHostDeletion       | Disables host deletion by the CSP when no volumes are associated with the host.                    | false            |
| disablePreInstallHooks    | Disable pre-install hooks when the chart is rendered outside of Kubernetes, such as CI/CD systems. | true             |
| imagePullPolicy           | Image pull policy (`Always`, `IfNotPresent`, `Never`).                                             | IfNotPresent     |
| iscsi.chapSecretName      | Secret containing chapUser and chapPassword for iSCSI                                              | ""               |
| logLevel                  | Log level. Can be one of `info`, `debug`, `trace`, `warn` and `error`.                             | info             |
| kubeletRootDir            | The kubelet root directory path.                                                                   | /var/lib/kubelet |
| controller.labels         | Additional labels for HPE CSI Driver controller Pods.                                              | {}               |
| controller.nodeSelector   | Node labels for HPE CSI Driver controller Pods assignment.                                         | {}               |
| controller.affinity       | Affinity rules for the HPE CSI Driver controller Pods.                                             | {}               |
| controller.tolerations    | Node taints to tolerate for the HPE CSI Driver controller Pods.                                    | []               |
| controller.resources      | A resource block with requests and limits for controller containers.                               | From [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver) |
| csp.labels                | Additional labels for CSP Pods.                                                                    | {}               |
| csp.nodeSelector          | Node labels for CSP Pods assignment.                                                               | {}               |
| csp.affinity              | Affinity rules for the CSP Pods.                                                                   | {}               |
| csp.tolerations           | Node taints to tolerate for the CSP Pods.                                                          | []               |
| csp.resources             | A resource block with requests and limits for CSP containers.                                      | From [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver) |
| node.labels               | Additional labels for HPE CSI Driver node Pods.                                                    | {}               |
| node.nodeSelector         | Node labels for HPE CSI Driver node Pods assignment.                                               | {}               |
| node.affinity             | Affinity rules for the HPE CSI Driver node Pods.                                                   | {}               |
| node.tolerations          | Node taints to tolerate for the HPE CSI Driver node Pods.                                          | []               |
| node.resources            | A resource block with requests and limits for node containers.                                     | From [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver) |
| images                    | Key/value pairs of HPE CSI Driver runtime images.                                                  | From [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver) |
| maxVolumesPerNode         | Maximum number of volumes the CSI controller will publish to a node.`**`                           | 100 |

## Upgrade

Upgrade considerations are part of the [Helm chart](https://artifacthub.io/packages/helm/hpe-storage/hpe-csi-driver/3.1.0#upgrading-the-chart) on ArtifactHub.io. Other upgrade considerations are [listed with the release](https://scod.hpedev.io/csi_driver/index.html#hpe_csi_driver_for_kubernetes_310) on SCOD.

## Usage

After the pack has been deployed, the next steps involves creating a backend `Secret` and `StorageClass`.

- [Add a HPE storage backend](https://scod.hpedev.io/csi_driver/deployment.html#add_an_hpe_storage_backend)
- Create a `StoragClass` based on your [storage platform](https://scod.hpedev.io/csi_driver/container_storage_provider/index.html).

## References

All documentation elaborating on how to use the HPE CSI Driver for Kubernetes is available on [SCOD](https://scod.hpedev.io).

Additional resources to learn about storage for Kubernetes are available here:

- [Official upstream Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/volumes/) for volume concepts.
- [Official Spectro Cloud partner page on SCOD](https://scod.hpedev.io/csi_driver/partners/spectro_cloud/index.html)
