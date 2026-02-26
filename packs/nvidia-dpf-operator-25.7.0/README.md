# NVIDIA DPF Operator

This pack installs the Nvidia DPF Operator v25.7.0.

## Prerequisites

This pack should be used in conjunction with the Nvidia DPF Prereqs v25.7.0 pack, as the dependencies for the DPF Operator are no longer part of the DPF Operator itself. If you're deploying DPF clusters in Host-Trusted mode, you also need to combine this with the Nvidia OVN Kubernetes v25.7.0 CNI.

## Parameters

### dpf-operator-config
| **Parameter** | **Type** | **Default Value** | **Description** |
|---|---|---|---|
| imagePullSecrets | list | `[]` |  |
| overrides.kubernetesAPIServerVIP | string | `"auto"` | Set to "auto" for CAPI clusters, "{{ .spectro.system.cluster.kubevip }}" for agent/appliance mode |
| overrides.kubernetesAPIServerPort | int | `6443` | K8S API Server port |
| provisioningController.bfbPVCName | string | `"bfb-pvc"` | PersistentVolumeClaim name for the BFB |
| provisioningController.dmsTimeout | int | `900` | Maximum time DMS will wait for a BFB flash to complete |
| kamajiClusterManager.disable | bool | `false` | Toggles creation of the Kamaji cluster |
| networking.controlPlaneMTU | int | `9000` | Controls MTU size for OOB control plane network |
| networking.highSpeedMTU | int | `9000` | Controls MTU size for DPU Highspeed network |

### dpf-operator
| **Parameter** | **Type** | **Default Value** | **Description** |
|---|---|---|---|
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"node-role.kubernetes.io/master"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"Exists"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].operator | string | `"Exists"` |  |
| controllerManager.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| controllerManager.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| controllerManager.image.repository | string | `""` |  |
| controllerManager.image.tag | string | `""` |  |
| controllerManager.replicas | int | `1` |  |
| controllerManager.serviceAccount.annotations | object | `{}` |  |
| enableNodeFeatureRules | bool | `true` |  |
| grafanaDashboards.enabled | bool | `true` |  |
| imagePullSecrets | list | `[]` |  |
| isOpenshift | bool | `false` |  |
| kamajiEtcdDefrag.backoffLimit | int | `6` |  |
| kamajiEtcdDefrag.clientPort | int | `2379` |  |
| kamajiEtcdDefrag.defragRule | string | `"dbQuotaUsage > 0.8 || dbSize - dbSizeInUse > 200*1024*1024"` |  |
| kamajiEtcdDefrag.enabled | bool | `true` |  |
| kamajiEtcdDefrag.image | string | `"ghcr.io/ahrtr/etcd-defrag:v0.22.0"` |  |
| kamajiEtcdDefrag.releaseName | string | `"kamaji-etcd"` |  |
| kamajiEtcdDefrag.replicas | int | `3` |  |
| kamajiEtcdDefrag.schedule | string | `"0 0 * * *"` |  |
| kamajiEtcdDefrag.successfulJobsHistoryLimit | int | `3` |  |
| kubeStateMetricsCRDMetrics.enabled | bool | `true` |  |
| prometheusSecureMetrics.enabled | bool | `true` |  |
| tolerations[0].effect | string | `"NoSchedule"` |  |
| tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| tolerations[1].effect | string | `"NoSchedule"` |  |
| tolerations[1].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| tolerations[1].operator | string | `"Exists"` |  |


## Upgrade

This is the first version of the Nvidia DPF Operator pack. There are no previous versions to upgrade from.


## Usage

The deploy this pack for Host-Trusted mode clusters, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting in the Nvidia OVN Kubernetes CNI pack is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.


## References

- [Nvidia DOCA Platform Guidance 25.7.0](https://github.com/NVIDIA/doca-platform/blob/v25.7.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)