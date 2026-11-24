# NVIDIA DPF Operator

This pack installs the Nvidia DPF Operator v26.4.0.

## Prerequisites

This pack should be used in conjunction with the Nvidia DPF Prereqs v26.4.0 pack, as the dependencies for the DPF Operator are no longer part of the DPF Operator itself. If you're deploying DPF clusters in Host-Trusted mode, you also need to combine this with the Nvidia OVN Kubernetes v26.4.0 CNI.

## Charts

| Chart | Version | Source |
| ----- | ------- | ------ |
| `dpf-operator` | `v26.4.0` | NVIDIA NGC: `helm.ngc.nvidia.com/nvidia/doca` (chart `dpf-operator`) |
| `dpf-operator-config` | `1.2.0` | Spectro Cloud wrapper that renders the `DPFOperatorConfig` CR |

The `dpf-operator` chart is pulled verbatim from NGC. `dpf-operator-config` is a
thin Spectro wrapper (not an upstream chart) whose every value maps 1:1 onto a
field of the `DPFOperatorConfig` CR (`operator.dpu.nvidia.com/v1alpha1`).

## What changed vs 25.10.1

- `dpf-operator` chart `v25.10.1` -> `v26.4.0`; `dpf-system` image `v25.10.1` -> `v26.4.0`.
- `dpf-operator-config` wrapper `1.1.0` -> `1.2.0`, updated to the v26.4.0
  `DPFOperatorConfig` spec:
  - **added** `cniInstaller`, `monitoring`, `nodeSRIOVDevicePluginController`
  - **removed** `ovsHelper` (no longer in the v26.4.0 CRD)

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
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"Exists"` |  |
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

## Zero Trust (ZT) vs Host Trusted (HT)

The only operator-level difference is in `dpf-operator-config.provisioningController`:

- **Zero Trust**: the DPU host is not a Kubernetes worker; BFB is flashed over the
  BMC via Redfish. Uncomment `installInterface.installViaRedfish` in `values.yaml`.
- **Host Trusted**: BFB is pushed from the host over rshim/PCIe. Leave the
  `installInterface` block commented out.

## Upgrade

To upgrade from a previous version, change the pack version and transfer your custom settings.


## Usage

The deploy this pack for Host-Trusted mode clusters, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting in the Nvidia OVN Kubernetes CNI pack is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v26.4.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.

The deploy this pack in Zero-Trusted mode, deploy this operator and use the Zero Trust - Passthrough preset in the DPF Deployment 26.4.0 pack.

## References

- [Nvidia DOCA Platform Guidance 26.4.0](https://github.com/NVIDIA/doca-platform/blob/v26.4.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)