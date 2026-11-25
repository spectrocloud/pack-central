# NVIDIA DPF Operator

This pack installs the Nvidia DPF Operator v26.8.0.

## Prerequisites

This pack should be used in conjunction with the Nvidia DPF Prereqs v26.8.0 pack, as the dependencies for the DPF Operator are no longer part of the DPF Operator itself. If you're deploying DPF clusters in Host-Trusted mode, you also need to combine this with the Nvidia OVN Kubernetes v26.8.0 CNI.

## Charts

| Chart | Version | Source |
| ----- | ------- | ------ |
| `dpf-operator` | `v26.8.0` | NVIDIA NGC: `helm.ngc.nvidia.com/nvidia/doca` (chart `dpf-operator`), byte-identical to NGC (sha256 `0252d473...`) |
| `dpf-operator-config` | `1.3.0` | Spectro Cloud wrapper that renders the `DPFOperatorConfig` CR |

The `dpf-operator` chart is pulled verbatim from NGC. `dpf-operator-config` is a
thin Spectro wrapper (not an upstream chart) whose every value maps 1:1 onto a
field of the `DPFOperatorConfig` CR (`operator.dpu.nvidia.com/v1alpha1`).

## What changed vs 26.4.0

- `dpf-operator` chart `v26.4.0` -> `v26.8.0`; `dpf-system` image `v26.4.0` -> `v26.8.0`.
  New chart values: `deprecationWarnings.enabled` (non-blocking
  ValidatingAdmissionPolicies, 9 VAP + 9 bindings), `controllerManager.featureGates`.
- `dpf-operator-config` wrapper `1.2.0` -> `1.3.0`:
  - **added** `deploymentMode` (required, rendered first), `coreDNS`, `security`
  - **removed** `ovsCNI` (deprecated in 26.8) and the `bfbRegistryAddress: auto`
    lookup (the field has been ignored since 26.4 and is deprecated in 26.8)
- New `presets.yaml` with the three Deployment Mode presets above.
- **BMC factory reset** (new 26.8 default `OnInitialization`): every newly
  onboarded DPU BMC gets a one-time Redfish factory reset, which wipes its
  network configuration. A BMC on a static IP then drops off the network. The
  Zero Trust presets set `discoveredDPUDeviceBMCFactoryResetPolicy: Never`
  (applies to DPUDevices created by DPUDiscovery). Hand-made DPUDevices carry their
  own `spec.bmcFactoryResetPolicy` (the dpf-deployment wrapper renders `Never`).
- 26.8 raised the default replicas of dpuServiceController, serviceSetController,
  staticClusterManager, nvipam and nodeSRIOVDevicePluginController to 2 (preferred
  anti-affinity, so one node still schedules them); commented `replicas: 1`
  overrides are in values.yaml.

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

DPF 26.8 makes `DPFOperatorConfig.spec.deploymentMode` **required** and
**immutable**: once the CR exists, changing the mode means deleting the CR and
reprovisioning every DPU. Choose it with the **Deployment Mode** preset:

| Preset | deploymentMode | installInterface | skipDPUNodeDiscovery | controlPlaneMTU | enableNodeFeatureRules |
|---|---|---|---|---|---|
| Host Trusted (default values) | `host-trusted` | host rshim (none set) | n/a | 1500 | true |
| Zero Trust (DPUDiscovery) | `zero-trust` | `installViaRedfish` | `false` (crawler creates DPUNodes) | 1500 | false |
| Zero Trust - Hostless | `zero-trust` | `installViaRedfish` | `true` (hand-declared hostless DPUDevices) | 1500 | false |

The presets follow NVIDIA's v26.8.0 reference DPFOperatorConfigs
(`docs/public/user-guides/.../manifests/*operatorconfig.yaml`): Host Trusted adds
`nodeSRIOVDevicePluginController.disable: false` (DPF's SR-IOV device plugin for
host VFs); MTUs stay at the CRD default 1500; `bfbPVCName` is not set (host
storage, as NVIDIA does; set it only to a PVC you create). Zero Trust presets set
`dpuDetector.disable: true`. Deliberate deviations, commented in presets.yaml:
`discoveredDPUDeviceBMCFactoryResetPolicy: Never` (see below) and
`enableNodeFeatureRules: false` in Zero Trust.

**`kubernetesAPIServerVIP`:** the default `auto` reads `kube-public/cluster-info`,
which RKE2 edge clusters do not have. On Palette Edge (agent/appliance) set
`{{ .spectro.system.cluster.kubevip }}`; zero-trust requires the field.

## Upgrade

NVIDIA supports n-1 upgrades only (26.4.x -> 26.8.0). The existing
DPFOperatorConfig must gain `deploymentMode` (and, for ZT, `controlPlaneMTU <= 1500`)
in the SAME apply, which this wrapper does. Pre-upgrade validation blocks the
operator rollout until every DPU is `Ready` or `Error`. Upgrading TO 26.8 does
not hold new provisioning, so do not start provisioning during the rollout.


## Usage

The deploy this pack for Host-Trusted mode clusters, first configure the parameters mentioned above. Then deploy just the Control Plane of your cluster and make sure the `ovn-kubernetes-resource-injector.enabled` setting in the Nvidia OVN Kubernetes CNI pack is set to `false`. Then deploy the DPF Framework to the cluster (Spectro Cloud provides a reference profile for this that aligns to the [HBN-OVN guidance from Nvidia](https://github.com/NVIDIA/doca-platform/blob/v26.4.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)).

Once the DPF Framework is deployed, change the `ovn-kubernetes-resource-injector.enabled` setting to `true` and add worker nodes containing Bluefield-3 DPUs in Host-Trusted mode. It will take between 20 and 40 minutes for the DPF Framework to flash the DPUs, reboot the nodes and configure them appropriately. After that, the nodes should become Healthy in Spectro Cloud Palette and ready for workloads.

The deploy this pack in Zero-Trusted mode, deploy this operator and use the Zero Trust - Passthrough preset in the DPF Deployment 26.8.0 pack.

## DPU Cluster Monitoring preset group

`DPFOperatorConfig.spec.monitoring` (NVIDIA doc
`operational-readiness/observability/deployment/operator-managed-components.md`):

| Preset | Effect |
|---|---|
| Default (KSM + node-problem-detector) | DPF default: kube-state-metrics and node-problem-detector on every DPU cluster, no OTEL |
| Stream DPU logs + metrics to management monitoring | adds the DPU-cluster OpenTelemetry Collector, exporting to `http://<kubevip>:30050` (the collector the nvidia-dpf-prereqs "Monitoring enabled" preset deploys, with Prometheus remote-write on) |
| Disabled | `monitoring.disable: true` |

## Airgap

`pack.content.images` lists the chart images AND the images the operator deploys on
the management cluster at runtime (bfb-registry, dpf-keepalived, nvidia-k8s-ipam,
CoreDNS, kube-state-metrics, the kamaji DPU control plane v1.35.6, and the Host
Trusted host agents), all multi-arch. DPU-cluster images (arm64) are a commented
block; DPF also pulls the `dpu-networking` v26.8.0 chart from
`helm.ngc.nvidia.com/nvidia/doca` at runtime, which an airgapped site must mirror.

The wrapper fails the render (instead of letting admission reject the CR) when:
`deploymentMode` is unset or not one of the two values; zero-trust has no
`installViaRedfish`; host-trusted has one; zero-trust `controlPlaneMTU > 1500`.

## References

- [Nvidia DOCA Platform Guidance 26.8.0](https://github.com/NVIDIA/doca-platform/blob/v26.8.0/docs/public/user-guides/host-trusted/use-cases/hbn-ovnk/README.md)
- [Release Notes](https://github.com/NVIDIA/doca-platform/blob/v26.8.0/docs/public/release-notes/v26.8.0.md)